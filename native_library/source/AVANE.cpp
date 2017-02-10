#include "AVANE.h"
#include "config.h"
#include "json.hpp"
#include <boost/algorithm/string/trim.hpp>
#include <boost/algorithm/string/split.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/format.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>


#ifdef _WIN32
#include "FlashRuntimeExtensions.h"
#include <windows.h>
#include <dshow.h>
#include <conio.h>
bool isSupportedInOS = true;
std::string pathSlash = "\\";

HRESULT EnumerateDevices(REFGUID category, IEnumMoniker **ppEnum) {
	// Create the System Device Enumerator.
	ICreateDevEnum *pDevEnum;
	HRESULT hr = CoCreateInstance(CLSID_SystemDeviceEnum, NULL,
		CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&pDevEnum));

	if (SUCCEEDED(hr)) {
		// Create an enumerator for the category.
		hr = pDevEnum->CreateClassEnumerator(category, ppEnum, 0);
		if (hr == S_FALSE)
			hr = VFW_E_NOT_FOUND;  // The category is empty. Treat as an error.
		pDevEnum->Release();
	}
	return hr;
}
std::string getStringFromBstr(BSTR val) {
	std::wstring ws(val, SysStringLen(val));
	std::string s(ws.begin(), ws.end()); //and convert to string.
	return s;
}
#elif __APPLE__
#include "TargetConditionals.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE

#include "FlashRuntimeExtensions.h"
bool isSupportedInOS = true;
std::string pathSlash = "/";
#include "ObjCInterface.h"

#elif TARGET_OS_MAC
// Other kinds of Mac OS
#include <Adobe AIR/Adobe AIR.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "ObjCInterface.h"

bool isSupportedInOS = true;
std::string pathSlash = "/";

#else
#   error "Unknown Apple platform"
#endif

#endif


#include <boost/thread.hpp>
const std::string ANE_NAME = "AVANE";
#include <ANEhelper.h>
ANEHelper aneHelper = ANEHelper();
#include "Constants.hpp"

unsigned int numAvailableThreads = boost::thread::hardware_concurrency();
boost::thread threads[1];

boost::thread createThread(void(*otherFunction)(int p), int p) {
	boost::thread t(*otherFunction, p);
	return move(t);
}



extern "C" {
#define FRE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
#include "libavformat/avformat.h"
#include "libavcodec/avcodec.h"
#include "libavutil/avassert.h"
#include "libavutil/avstring.h"
#include "libavutil/bprint.h"
#include "libavutil/common.h"
#include "libavutil/display.h"
#include "libavutil/hash.h"
#include "libavutil/opt.h"
#include "libavutil/pixdesc.h"
#include "libavutil/dict.h"
#include "libavutil/intreadwrite.h"
#include "libavutil/parseutils.h"
#include "libavutil/timecode.h"
#include "libavutil/timestamp.h"
#include "libavutil/ffversion.h"
#include "libavdevice/avdevice.h"
#include "libswscale/swscale.h"
#include "libswresample/swresample.h"
#include "libpostproc/postprocess.h"

#include "Utils.h"
#include "cmdutils.h"
#include "ffmpeg.h"

FREContext dllContext;
typedef struct {
	AVFormatContext *fmt_ctx = nullptr;
	std::string fileName;
	std::string playList = "";
}Probe;
Probe probeContext;

typedef struct {
	std::vector<std::string> commandLine;
}Input;
Input inputContext;

static AVInputFormat *iformat = nullptr;
static char *stream_specifier; //pass as arg

int logLevel = 32;
bool isEncoding = false;
//static int nb_streams; ??
static int *selected_streams;

extern void trace(std::string msg) {
	auto value = "[" + ANE_NAME + "] " + msg;
	if (logLevel > 0)
		aneHelper.dispatchEvent(dllContext, "TRACE", msg);
}
extern void logError(std::string msg) {
	auto value = "[" + ANE_NAME + "] " + msg;
	aneHelper.dispatchEvent(dllContext, "Encode.ERROR_MESSAGE", msg);
}
extern void logFatal(std::string msg) {
	auto value = "[" + ANE_NAME + "] " + msg;
	aneHelper.dispatchEvent(dllContext, "Encode.FATAL_MESSAGE", msg);
}
extern void logInfo(std::string msg) {
	auto value = "[" + ANE_NAME + "] " + msg;
	if (logLevel > 0)
		aneHelper.dispatchEvent(dllContext, "INFO", msg);
}
extern void logInfoHtml(std::string msg) {
	auto value = "[" + ANE_NAME + "] " + msg;
	if (logLevel > 0)
		aneHelper.dispatchEvent(dllContext, "INFO_HTML", msg);
}

FRE_FUNCTION(isSupported) {
	return aneHelper.getFREObject(isSupportedInOS);
}

#define REALLOCZ_ARRAY_STREAM(ptr, cur_n, new_n)                        \
	{                                                                       \
		ret = av_reallocp_array(&(ptr), (new_n), sizeof(*(ptr)));           \
		if (ret < 0)                                                        \
			goto end;                                                       \
		memset( (ptr) + (cur_n), 0, ((new_n) - (cur_n)) * sizeof(*(ptr)) ); \
	}


//probe input
static void closeFileToProbe(AVFormatContext **ctx_ptr) {
	int i;
	AVFormatContext *fmt_ctx = *ctx_ptr;
	/* close decoder for each stream */
	for (i = 0; i < fmt_ctx->nb_streams; i++)
		if (fmt_ctx->streams[i]->codecpar->codec_id != AV_CODEC_ID_NONE)
			avcodec_close(fmt_ctx->streams[i]->codec);
	avformat_close_input(ctx_ptr);
}


static int probeFile(const char *filename) {
	probeContext.fmt_ctx = nullptr;
	int ret = 0;
	int err, i, orig_nb_streams;

	AVDictionaryEntry *t;
	AVDictionary **opts;
	av_dict_set(&format_opts, "scan_all_pmts", "1", AV_DICT_DONT_OVERWRITE);

	if ((err = avformat_open_input(&probeContext.fmt_ctx, filename, iformat, &format_opts)) < 0) {
		trace("Error opening file");
		return err;
	}

	av_dict_set(&format_opts, "scan_all_pmts", NULL, AV_DICT_MATCH_CASE);

	// fill the streams in the format context
	opts = setup_find_stream_info_opts(probeContext.fmt_ctx, codec_opts);
	orig_nb_streams = probeContext.fmt_ctx->nb_streams;
	err = avformat_find_stream_info(probeContext.fmt_ctx, opts);

	for (i = 0; i < orig_nb_streams; i++)
		av_dict_free(&opts[i]);

	av_freep(&opts);

	if (err < 0) {
		trace("Error finding stream info");
		return err;
	}

	for (i = 0; i < probeContext.fmt_ctx->nb_streams; i++) {
		AVStream *stream = probeContext.fmt_ctx->streams[i];
		AVCodec *codec;

		if (stream->codecpar->codec_id == AV_CODEC_ID_PROBE) {
			trace("Failed to probe codec for input stream");
			////av_log(NULL, AV_LOG_WARNING,"Failed to probe codec for input stream %d\n",stream->index);
		}
		else if (!(codec = avcodec_find_decoder(stream->codecpar->codec_id))) {
			trace("Unsupported codec with id %d for input stream");
			////av_log(NULL, AV_LOG_WARNING,"Unsupported codec with id %d for input stream %d\n",stream->codec->codec_id, stream->index);
		}
		else {
			AVDictionary *opts = filter_codec_opts(codec_opts, stream->codecpar->codec_id, probeContext.fmt_ctx, stream, codec);
			if (avcodec_open2(stream->codec, codec, &opts) < 0) {
				trace("Could not open codec for input stream");
				////av_log(NULL, AV_LOG_WARNING, "Could not open codec for input stream %d\n",stream->index);
			}
			if ((t = av_dict_get(opts, "", NULL, AV_DICT_IGNORE_SUFFIX))) {
				trace("Option for input stream not found");
				////av_log(NULL, AV_LOG_ERROR, "Option %s for input stream %d not found\n",t->key, stream->index);
				return AVERROR_OPTION_NOT_FOUND;
			}
		}
	}

#define CHECK_END if (ret < 0) goto end
	CHECK_END;

	REALLOCZ_ARRAY_STREAM(selected_streams, 0, probeContext.fmt_ctx->nb_streams);

	for (i = 0; i < probeContext.fmt_ctx->nb_streams; i++) {
		if (stream_specifier) {
			ret = avformat_match_stream_specifier(probeContext.fmt_ctx, probeContext.fmt_ctx->streams[i], stream_specifier);
			CHECK_END;
			else
				selected_streams[i] = ret;
			ret = 0;
		}
		else {
			selected_streams[i] = 1;
		}
	}

	end:
	if (ret < 0) {
		closeFileToProbe(&probeContext.fmt_ctx);
		av_freep(&selected_streams);
	}
	return ret;

}

void threadProbe(int p) {
	boost::mutex mutex;
	using boost::this_thread::get_id;
	mutex.lock();

	av_log_set_flags(AV_LOG_SKIP_REPEATED);
	av_register_all();
	avformat_network_init();
	init_opts();
#if CONFIG_AVDEVICE
	avdevice_register_all();
#endif

	if (!probeContext.playList.empty())
		opt_default(NULL, "playlist", probeContext.playList.c_str());

	int ret;

	ret = probeFile(probeContext.fileName.c_str());
	uninit_opts();
	avformat_network_deinit();
	std::string returnVal = "";
	aneHelper.dispatchEvent(dllContext, ret == 0 ? "ON_PROBE_INFO" : "NO_PROBE_INFO", returnVal);
	mutex.unlock();
}

FRE_FUNCTION(triggerProbeInfo) {
	probeContext.fileName = aneHelper.getString(argv[0]);
	probeContext.playList = aneHelper.getString(argv[1]);
	threads[0] =  move(createThread(&threadProbe, 1));
	return aneHelper.getFREObject(true);
}

FRE_FUNCTION(getProbeInfo) {
	using namespace boost;
	using namespace std;


	auto probe = aneHelper.createFREObject("com.tuarua.ffprobe.Probe");

	if (probeContext.fmt_ctx) {
		auto vecVideoStreams = aneHelper.createFREObject("Vector.<com.tuarua.ffprobe.VideoStream>");
		auto vecAudioStreams = aneHelper.createFREObject("Vector.<com.tuarua.ffprobe.AudioStream>");
		auto vecSubtitleStreams = aneHelper.createFREObject("Vector.<com.tuarua.ffprobe.SubtitleStream>");

		int i;
		int j;
		int numVideoStreams = 0;
		int numAudioStreams = 0;
		int numSubtitleStreams = 0;
		int currVideoStream = -1;
		int currAudioStream = -1;
		int currSubtitleStream = -1;

		//count the number of each stream type
		for (j = 0; j < probeContext.fmt_ctx->nb_streams; j++) {
			if (selected_streams[j]) {
				AVCodecContext *dec_ctx;
				AVStream *stream = probeContext.fmt_ctx->streams[j];
				if ((dec_ctx = stream->codec)) {
					switch (dec_ctx->codec_type) {
						case AVMEDIA_TYPE_VIDEO:
							numVideoStreams++;
							break;
						case AVMEDIA_TYPE_AUDIO:
							numAudioStreams++;
							break;
						case AVMEDIA_TYPE_SUBTITLE:
							numSubtitleStreams++;
							break;
						default:
							break;
					}
				}
			}
		}

		FRESetArrayLength(vecVideoStreams, numVideoStreams);
		FRESetArrayLength(vecAudioStreams, numAudioStreams);
		FRESetArrayLength(vecSubtitleStreams, numSubtitleStreams);


		for (i = 0; i < probeContext.fmt_ctx->nb_streams; i++) {
			if (selected_streams[i]) {
				AVStream *stream = probeContext.fmt_ctx->streams[i];
				AVCodecContext *dec_ctx;
				const AVCodec *dec;
				const AVCodecDescriptor *cd;
				const char *s;
				AVRational sar, dar;

				char val_str[128];

				FREObject objStream = nullptr;

				if ((dec_ctx = stream->codec)) {
					const char *profile = NULL;
					dec = dec_ctx->codec;

					switch (dec_ctx->codec_type) {
						case AVMEDIA_TYPE_VIDEO:
							currVideoStream++;
							objStream = aneHelper.createFREObject("com.tuarua.ffprobe.VideoStream");
							break;
						case AVMEDIA_TYPE_AUDIO:
							currAudioStream++;
							objStream = aneHelper.createFREObject("com.tuarua.ffprobe.AudioStream");
							break;
						case AVMEDIA_TYPE_SUBTITLE:
							currSubtitleStream++;
							objStream = aneHelper.createFREObject("com.tuarua.ffprobe.SubtitleStream");
							break;
						default:
							break;
					}

					aneHelper.setProperty(objStream, "index", stream->index);

					if (dec) {
						aneHelper.setProperty(objStream, "codecName", dec->name);
						aneHelper.setProperty(objStream, "codecLongName", dec->long_name ? dec->long_name : "unknown");
					}
					else if ((cd = avcodec_descriptor_get(stream->codecpar->codec_id))) {
						aneHelper.setProperty(objStream, "codecName", cd->name);
						aneHelper.setProperty(objStream, "codecLongName", cd->long_name);
					}
					else {
						aneHelper.setProperty(objStream, "codecName", "unknown");
						aneHelper.setProperty(objStream, "codecLongName", "unknown");
					}

					if (dec && (profile = av_get_profile_name(dec, dec_ctx->profile))) {
						aneHelper.setProperty(objStream, "profile", profile);
					}
					else {
						if (dec_ctx->profile != FF_PROFILE_UNKNOWN) {
							char profile_num[12];
							snprintf(profile_num, sizeof(profile_num), "%d", dec_ctx->profile);
							aneHelper.setProperty(objStream, "codecLongName", profile_num);
						}
						else {
							aneHelper.setProperty(objStream, "profile", "unknown");
						}
					}

					s = av_get_media_type_string(dec_ctx->codec_type);

					aneHelper.setProperty(objStream, "codecType", s ? s : "unknown");
					aneHelper.setProperty(objStream, "codecTimeBase",
							lexical_cast<string>(dec_ctx->time_base.num) + "/" + lexical_cast<std::string>(dec_ctx->time_base.den));



					/* AVI/FourCC tag */
					av_get_codec_tag_string(val_str, sizeof(val_str), dec_ctx->codec_tag);

					aneHelper.setProperty(objStream, "codecTagString", lexical_cast<string>(val_str));
					aneHelper.setProperty(objStream, "codecTagString", dec_ctx->codec_tag);

					switch (dec_ctx->codec_type) {
						case AVMEDIA_TYPE_VIDEO:

							aneHelper.setProperty(objStream, "width", dec_ctx->width);
							aneHelper.setProperty(objStream, "height", dec_ctx->height);
							aneHelper.setProperty(objStream, "codedWidth", dec_ctx->coded_width);
							aneHelper.setProperty(objStream, "codedHeight", dec_ctx->coded_height);
							aneHelper.setProperty(objStream, "hasBframes", dec_ctx->has_b_frames);


							sar = av_guess_sample_aspect_ratio(probeContext.fmt_ctx, stream, NULL);
							if (sar.den) {
								aneHelper.setProperty(objStream, "sampleAspectRatio", lexical_cast<string>(sar.num) + ":" + lexical_cast<string>(sar.den));
								av_reduce(&dar.num, &dar.den, dec_ctx->width  * sar.num, dec_ctx->height * sar.den, 1024 * 1024);
								aneHelper.setProperty(objStream, "displayAspectRatio", lexical_cast<string>(dar.num) + ":" + lexical_cast<string>(dar.den));
							}

							s = av_get_pix_fmt_name(dec_ctx->pix_fmt);

							aneHelper.setProperty(objStream, "pixelFormat", s ? s : "unknown");
							aneHelper.setProperty(objStream, "level", dec_ctx->level);

							if (dec_ctx->color_range != AVCOL_RANGE_UNSPECIFIED)
								aneHelper.setProperty(objStream, "colorRange", av_color_range_name(dec_ctx->color_range));

							s = av_get_colorspace_name(dec_ctx->colorspace);
							aneHelper.setProperty(objStream, "colorSpace", string(s ? s : "unknown"));
							if (dec_ctx->color_trc != AVCOL_TRC_UNSPECIFIED)
								aneHelper.setProperty(objStream, "colorTransfer", av_color_transfer_name(dec_ctx->color_trc));
							if (dec_ctx->color_primaries != AVCOL_PRI_UNSPECIFIED)
								aneHelper.setProperty(objStream, "colorPrimaries", av_color_primaries_name(dec_ctx->color_primaries));
							if (dec_ctx->chroma_sample_location != AVCHROMA_LOC_UNSPECIFIED)
								aneHelper.setProperty(objStream, "chromaLocation", av_chroma_location_name(dec_ctx->chroma_sample_location));
#if FF_API_PRIVATE_OPT
							if (dec_ctx && dec_ctx->timecode_frame_start >= 0) {
								char tcbuf[AV_TIMECODE_STR_SIZE];
								av_timecode_make_mpeg_tc_string(tcbuf, dec_ctx->timecode_frame_start);
								aneHelper.setProperty(objStream, "timecode", tcbuf);
							}
							else {
								aneHelper.setProperty(objStream, "timecode", "N/A");
							}
#endif
							if (dec_ctx)
								aneHelper.setProperty(objStream, "timecode", dec_ctx->refs);

							break;

						case AVMEDIA_TYPE_AUDIO:
							s = av_get_sample_fmt_name(dec_ctx->sample_fmt);

							aneHelper.setProperty(objStream, "sampleFormat", (s) ? s : "unknown");
							aneHelper.setProperty(objStream, "sampleRate", dec_ctx->sample_rate);
							aneHelper.setProperty(objStream, "channels", dec_ctx->channels);

							char channel_layout[128];
							av_get_channel_layout_string(channel_layout, sizeof(channel_layout), dec_ctx->channels, dec_ctx->channel_layout);
							//av_get_channel_layout
							if (dec_ctx->channel_layout)
								aneHelper.setProperty(objStream, "channelLayout", channel_layout);
							else
								aneHelper.setProperty(objStream, "channelLayout", "unknown");
							aneHelper.setProperty(objStream, "bitsPerSample", av_get_bits_per_sample(dec_ctx->codec_id));

							break;

						case AVMEDIA_TYPE_SUBTITLE:
							if (dec_ctx->width)
								aneHelper.setProperty(objStream, "width", dec_ctx->width);
							if (dec_ctx->height)
								aneHelper.setProperty(objStream, "height", dec_ctx->height);
							break;
						default:
							break;

					}

				}
				else {
					aneHelper.setProperty(objStream, "codecType", "unknown");
				}
				double v;
				int rnded;
				if (stream->r_frame_rate.num > 0) {
					v = double(stream->r_frame_rate.num) / stream->r_frame_rate.den;
					rnded = round(v * 1000);
					aneHelper.setProperty(objStream, "realFrameRate", double(rnded) / 1000);
				}

				if (stream->avg_frame_rate.num > 0) {
					v = double(stream->avg_frame_rate.num) / stream->avg_frame_rate.den;
					rnded = round(v * 1000);
					aneHelper.setProperty(objStream, "averageFrameRate", double(rnded) / 1000);
				}

				aneHelper.setProperty(objStream, "timeBase", lexical_cast<string>(stream->time_base.num) + ":" + lexical_cast<string>(stream->time_base.den));

				if (probeContext.fmt_ctx->iformat->flags & AVFMT_SHOW_IDS)
					aneHelper.setProperty(objStream, "id", (probeContext.fmt_ctx->iformat->flags & AVFMT_SHOW_IDS) ? lexical_cast<string>(stream->id) : "N/A");
				if (stream->duration > 0) {
					v = double(stream->duration) / stream->time_base.den;
					rnded = round(v * 1000);
					aneHelper.setProperty(objStream, "duration", double(rnded) / 1000);
					aneHelper.setProperty(objStream, "durationTimestamp", stream->duration);
				}
				aneHelper.setProperty(objStream, "startPTS", stream->start_time);
				v = double(stream->start_time) *  av_q2d(stream->time_base);
				rnded = round(v * 100000);


				aneHelper.setProperty(objStream, "startTime", double(rnded) / 100000);

				if (dec_ctx->rc_max_rate > 0)
					aneHelper.setProperty(objStream, "maxBitRate", dec_ctx->rc_max_rate);
				if (dec_ctx->bits_per_raw_sample > 0)
					aneHelper.setProperty(objStream, "bitsPerRawSample", dec_ctx->bits_per_raw_sample);
				if (stream->nb_frames > 0)
					aneHelper.setProperty(objStream, "numFrames", stream->nb_frames);
				if (dec_ctx->bit_rate > 0)
					aneHelper.setProperty(objStream, "bitRate", dec_ctx->bit_rate);

				AVDictionaryEntry *tag = NULL;

				auto streamTags = aneHelper.createFREObject("Object");

				while ((tag = av_dict_get(stream->metadata, "", tag, AV_DICT_IGNORE_SUFFIX)))
					aneHelper.setProperty(streamTags, string(tag->key), tag->value);

				aneHelper.setProperty(streamTags, "tags", streamTags);

				switch (dec_ctx->codec_type) {
					case AVMEDIA_TYPE_VIDEO:
						FRESetArrayElementAt(vecVideoStreams, currVideoStream, objStream);
						break;
					case AVMEDIA_TYPE_AUDIO:
						FRESetArrayElementAt(vecAudioStreams, currAudioStream, objStream);
						break;
					case AVMEDIA_TYPE_SUBTITLE:
						FRESetArrayElementAt(vecSubtitleStreams, currSubtitleStream, objStream);
						break;
					default:
						break;
				}

			}
		}

		aneHelper.setProperty(probe, "videoStreams", vecVideoStreams);
		aneHelper.setProperty(probe, "audioStreams", vecAudioStreams);
		aneHelper.setProperty(probe, "subtitleStreams", vecSubtitleStreams);

		auto objFormat = aneHelper.createFREObject("com.tuarua.ffprobe.Format");

		aneHelper.setProperty(objFormat, "filename", probeContext.fmt_ctx->filename);
		aneHelper.setProperty(objFormat, "numStreams", probeContext.fmt_ctx->nb_streams);
		aneHelper.setProperty(objFormat, "numPrograms", probeContext.fmt_ctx->nb_programs);

		aneHelper.setProperty(objFormat, "formatName", probeContext.fmt_ctx->iformat->name);
		aneHelper.setProperty(objFormat, "formatLongName", probeContext.fmt_ctx->iformat->long_name);
		aneHelper.setProperty(objFormat, "startTime", (double(probeContext.fmt_ctx->start_time)) / 1000000);
		aneHelper.setProperty(objFormat, "duration", (double(probeContext.fmt_ctx->duration)) / 1000000);

		int64_t size = probeContext.fmt_ctx->pb ? avio_size(probeContext.fmt_ctx->pb) : -1;
		aneHelper.setProperty(objFormat, "size", size);
		aneHelper.setProperty(objFormat, "bitRate", probeContext.fmt_ctx->bit_rate);
		aneHelper.setProperty(objFormat, "probeScore", av_format_get_probe_score(probeContext.fmt_ctx));

		//Tags
		AVDictionaryEntry *tag = NULL;

		auto formatTags = aneHelper.createFREObject("Object");
		while ((tag = av_dict_get(probeContext.fmt_ctx->metadata, "", tag, AV_DICT_IGNORE_SUFFIX)))
			aneHelper.setProperty(objFormat, string(tag->key), tag->value);

		aneHelper.setProperty(objFormat, "tags", formatTags);
		aneHelper.setProperty(probe, "format", objFormat);

	}
	return probe;
}
static const char *get_level_str(int level) {
	switch (level) {
		case AV_LOG_QUIET:
			return "quiet";
		case AV_LOG_DEBUG:
			return "debug";
		case AV_LOG_VERBOSE:
			return "verbose";
		case AV_LOG_INFO:
			return "info";
		case AV_LOG_WARNING:
			return "warning";
		case AV_LOG_ERROR:
			return "error";
		case AV_LOG_FATAL:
			return "fatal";
		case AV_LOG_PANIC:
			return "panic";
		default:
			return "";
	}
}

extern void avaneFlashLog(const char *msg) {
	trace(std::string(msg));
}

extern void avaneLogProgress(double size, int secs, int us, double bitrate, double speed, float fps, int frame_number) {
	//build a json object
	using json = nlohmann::json;
	json j;
	j["speed"] = speed;
	j["bitrate"] = bitrate;
	j["secs"] = secs;
	j["us"] = us;
	j["size"] = size;
	j["fps"] = fps;
	j["frame"] = frame_number;
	aneHelper.dispatchEvent(dllContext, "ON_ENCODE_PROGRESS", j.dump());
}

char * toCString(std::string str) {
	char * cStr = new char[str.length() + 1];
	strcpy(cStr, str.c_str());
	return cStr;
}

void avaneLog(void *ptr, int level, const char *fmt, va_list vl) {
	if (logLevel > 0) {
		static char message[8192];
		const char *module = NULL;
		using namespace std;
		using namespace boost;
		if (ptr) {
			AVClass *avc = *(AVClass**)ptr;
			if (avc->item_name)
				module = avc->item_name(ptr);
		}
		string logStr;
		string logHtml;

#ifdef _WIN32
		vsnprintf_s(message, sizeof message, sizeof message, fmt, vl);
#else
		vsprintf(message, fmt, vl);
#endif

		string messageTrimmed = string(message);
		trim(messageTrimmed);

		logStr = " [ffmpeg][" + (module ? string(module) : "") + "][" + lexical_cast<string>(get_level_str(level)) + "] : " + messageTrimmed;
		logHtml = " <p class=\"" + lexical_cast<string>(get_level_str(level)) + "\">" + (module ? string(module) + ":" : "") + lexical_cast<string>(get_level_str(level)) + ": " + messageTrimmed + "</p>";

		if (level <= logLevel && !messageTrimmed.empty()) {
			logInfo(logStr);
			logInfoHtml(logHtml);
		}

		if (level == 16 )
			logError(string(message));

		if (level == 8)
			logFatal(string(message));
	}
}


void threadEncode(int p) {
	int ret = -1;
	boost::mutex mutex;
	using boost::this_thread::get_id;
	using namespace std;
	mutex.lock();

	char ** charVec = new char*[inputContext.commandLine.size()];
	for (size_t i = 0; i < inputContext.commandLine.size(); i++) {
		charVec[i] = new char[inputContext.commandLine[i].size() + 1];
		strcpy(charVec[i], inputContext.commandLine[i].c_str());
	}

	setvbuf(stderr, NULL, _IONBF, 0);
	av_log_set_flags(AV_LOG_SKIP_REPEATED);
	av_log_set_callback(&avaneLog);

	avcodec_register_all();
#if CONFIG_AVDEVICE
	avdevice_register_all();
#endif
	avfilter_register_all();
	av_register_all();
	avformat_network_init();

	ret = ffmpeg_parse_options((int)inputContext.commandLine.size(), charVec);

	avane_set_pause_transcode(0);
	isEncoding = true;
	string returnVal = "";
	aneHelper.dispatchEvent(dllContext, "ON_ENCODE_START", returnVal);
	if (ret < 0) {
	}
	else {
		ret = avane_main_transcode();
		trace("avane_main_transcode is finished");
	}
	isEncoding = false;

	if (ret < 0)
		aneHelper.dispatchEvent(dllContext, "ON_ENCODE_ERROR", returnVal);
	else
		aneHelper.dispatchEvent(dllContext, "ON_ENCODE_FINISH", returnVal);

	avane_main_cleanup();

	mutex.unlock();
}

FRE_FUNCTION(encode) {
	FREObject args = argv[0];
	uint32_t numItems = aneHelper.getArrayLength(args);

	inputContext.commandLine.clear();
	for (unsigned int k = 0; k < numItems; ++k) {
		FREObject valueAS = nullptr;
		FREGetArrayElementAt(args, k, &valueAS);
		auto valueAsString = aneHelper.getString(valueAS);
		inputContext.commandLine.push_back(valueAsString);
	}

	//trigger the thread
	threads[0] = move(createThread(&threadEncode, 1));
	return aneHelper.getFREObject(true);
}

FRE_FUNCTION(cancelEncode) {
	if (isEncoding)
		avane_set_cancel_transcode(1);
	isEncoding = false;
	return aneHelper.getFREObject(true);
}

FRE_FUNCTION(pauseEncode) {
	avane_set_pause_transcode((aneHelper.getBool(argv[0])) ? 1 : 0);
	return aneHelper.getFREObject(true);
}

FRE_FUNCTION(setLogLevel) {
	logLevel = aneHelper.getInt32(argv[0]);
	return nullptr;
}


#ifdef _WIN32
void DisplayDeviceInformation(IEnumMoniker *pEnum, bool isVideo, FREObject obj) {
		IMoniker *pMoniker = NULL;

		while (pEnum->Next(1, &pMoniker, nullptr) == S_OK) {
			auto addObject = false;
			IPropertyBag *pPropBag;
			auto hr = pMoniker->BindToStorage(nullptr, nullptr, IID_PPV_ARGS(&pPropBag));
			if (FAILED(hr)) {
				pMoniker->Release();
				continue;
			}

			auto objDevice = aneHelper.createFREObject("com.tuarua.ffmpeg.gets.CaptureDevice");
			aneHelper.setProperty(objDevice, "format", "dshow");
			aneHelper.setProperty(objDevice, "isVideo", isVideo == 1);
			aneHelper.setProperty(objDevice, "isAudio", isVideo == 0);

			VARIANT var;
			VariantInit(&var);

			hr = pPropBag->Read(L"Description", &var, 0);
			if (SUCCEEDED(hr)) {
				auto desc = getStringFromBstr(var.bstrVal);
				aneHelper.setProperty(objDevice, "description", desc);
				VariantClear(&var);
				addObject = true;
			}

			hr = pPropBag->Read(L"FriendlyName", &var, 0);

			if (SUCCEEDED(hr)) {
				auto name = getStringFromBstr(var.bstrVal);
				aneHelper.setProperty(objDevice, "name", name);
				VariantClear(&var);
				addObject = true;
			}

			hr = pPropBag->Read(L"DevicePath", &var, 0);
			if (SUCCEEDED(hr)) {
				// The device path is not intended for display.
				auto path = getStringFromBstr(var.bstrVal);
				aneHelper.setProperty(objDevice, "path", path);
				VariantClear(&var);
			}

			pPropBag->Release();
			pMoniker->Release();

			if (addObject)
				FRESetArrayElementAt(obj, aneHelper.getArrayLength(obj), objDevice);

		}
	}

	FRE_FUNCTION(getCaptureDevices) {
		auto vec = aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.CaptureDevice>");
		HRESULT hr;
		IEnumMoniker *pEnum;

		hr = EnumerateDevices(CLSID_VideoInputDeviceCategory, &pEnum);
		if (SUCCEEDED(hr)) {
			DisplayDeviceInformation(pEnum, true, vec);
			pEnum->Release();
		}
		hr = EnumerateDevices(CLSID_AudioInputDeviceCategory, &pEnum);
		if (SUCCEEDED(hr)) {
			DisplayDeviceInformation(pEnum, false, vec);
			pEnum->Release();
		}

		return vec;
	}

#elif __APPLE__
FRE_FUNCTION(getCaptureDevices) {
	auto vec = aneHelper.createFREObject("Vector.<com.tuarua.ffmpeg.gets.CaptureDevice>");
	ObjCInterface oci;
	vec = oci.getCaptureDevices();
	return vec;
}
#endif

void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet) {
	static FRENamedFunction extensionFunctions[] = {
			{reinterpret_cast<const uint8_t*>("isSupported"),nullptr, &isSupported}
			,{reinterpret_cast<const uint8_t*>("setLogLevel"),nullptr, &setLogLevel}
			,{reinterpret_cast<const uint8_t*>("getLayouts"),nullptr, &getLayouts}
			,{reinterpret_cast<const uint8_t*>("getColors"),nullptr, &getColors}
			,{reinterpret_cast<const uint8_t*>("getProtocols"),nullptr, &getProtocols}
			,{reinterpret_cast<const uint8_t*>("getFilters"),nullptr, &getFilters}
			,{reinterpret_cast<const uint8_t*>("getPixelFormats"),nullptr, &getPixelFormats}
			,{reinterpret_cast<const uint8_t*>("getBitStreamFilters"),nullptr, &getBitStreamFilters}
			,{reinterpret_cast<const uint8_t*>("getDecoders"),nullptr, &getDecoders}
			,{reinterpret_cast<const uint8_t*>("getEncoders"),nullptr, &getEncoders}
			,{reinterpret_cast<const uint8_t*>("getCodecs"),nullptr, &getCodecs}
			,{reinterpret_cast<const uint8_t*>("getHardwareAccelerations"),nullptr, &getHardwareAccelerations}
			,{reinterpret_cast<const uint8_t*>("getDevices"),nullptr, &getDevices}
			,{reinterpret_cast<const uint8_t*>("getAvailableFormats"),nullptr, &getAvailableFormats}
			,{reinterpret_cast<const uint8_t*>("getBuildConfiguration"),nullptr, &getBuildConfiguration}
			,{reinterpret_cast<const uint8_t*>("getLicense"),nullptr, &getLicense}
			,{reinterpret_cast<const uint8_t*>("getVersion"),nullptr, &getVersion}
			,{reinterpret_cast<const uint8_t*>("getSampleFormats"),nullptr, &getSampleFormats}
			,{reinterpret_cast<const uint8_t*>("triggerProbeInfo"),nullptr, &triggerProbeInfo}
			,{reinterpret_cast<const uint8_t*>("getProbeInfo"),nullptr, &getProbeInfo}
			,{reinterpret_cast<const uint8_t*>("encode"),nullptr, &encode}
			,{reinterpret_cast<const uint8_t*>("cancelEncode"),nullptr, &cancelEncode}
			,{reinterpret_cast<const uint8_t*>("pauseEncode"),nullptr, &pauseEncode}
			,{reinterpret_cast<const uint8_t*>("getCaptureDevices"),nullptr, &getCaptureDevices }
	};
	*numFunctionsToSet = sizeof(extensionFunctions) / sizeof(FRENamedFunction);
	*functionsToSet = extensionFunctions;
	dllContext = ctx;
}

void contextFinalizer(FREContext ctx) {
}
void TRAVAExtInizer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer) {
	*ctxInitializer = &contextInitializer;
	*ctxFinalizer = &contextFinalizer;
}

void TRAVAExtFinizer(void* extData) {
	FREContext nullCTX;
	nullCTX = 0;
	contextFinalizer(nullCTX);
}

}
