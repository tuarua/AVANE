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
// iOS Simulator
#include "FlashRuntimeExtensions.h"
bool isSupportedInOS = true;
std::string pathSlash = "/";

#elif TARGET_OS_MAC
// Other kinds of Mac OS
#include <Adobe AIR/Adobe AIR.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
bool isSupportedInOS = true;
std::string pathSlash = "/";

#else
#   error "Unknown Apple platform"
#endif

#endif


#include <boost/thread.hpp>




#include "ANEhelper.h"
#include "Constants.hpp"

unsigned int numAvailableThreads = boost::thread::hardware_concurrency();
boost::thread threads[1];

boost::thread createThread(void(*otherFunction)(int p), int p) {
	boost::thread t(*otherFunction, p);
	return boost::move(t);
}



extern "C" {

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
		AVFormatContext *fmt_ctx = NULL;
		std::string fileName;
		std::string playList = "";
	}Probe;
	Probe probeContext;

	typedef struct {
		std::vector<std::string> commandLine;
	}Input;
	Input inputContext;

	static AVInputFormat *iformat = NULL;
	static char *stream_specifier; //pass as arg

	int logLevel = 32;
	bool isEncoding = false;
	//static int nb_streams; ??
	static int *selected_streams;

	extern void trace(std::string msg) {
		if (logLevel > 0)
			FREDispatchStatusEventAsync(dllContext, (uint8_t*)msg.c_str(), (const uint8_t*) "TRACE");
	}
	extern void logError(std::string msg) {
		FREDispatchStatusEventAsync(dllContext, (uint8_t*)msg.c_str(), (const uint8_t*)"Encode.ERROR_MESSAGE");
	}
	extern void logInfo(std::string msg) {
		if (logLevel > 0)
			FREDispatchStatusEventAsync(dllContext, (uint8_t*)msg.c_str(), (const uint8_t*) "INFO");
	}
	extern void logInfoHtml(std::string msg) {
		if (logLevel > 0)
			FREDispatchStatusEventAsync(dllContext, (uint8_t*)msg.c_str(), (const uint8_t*) "INFO_HTML");
	}

	FREObject isSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		return getFREObjectFromBool(isSupportedInOS);
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
		probeContext.fmt_ctx = NULL;
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
		FREDispatchStatusEventAsync(dllContext, (uint8_t*)returnVal.c_str(), (ret == 0) ? (const uint8_t*)"ON_PROBE_INFO" : (const uint8_t*)"NO_PROBE_INFO");
		mutex.unlock();
	}

	FREObject triggerProbeInfo(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		probeContext.fileName = getStringFromFREObject(argv[0]);
		probeContext.playList = getStringFromFREObject(argv[1]);

		threads[0] = boost::move(createThread(&threadProbe, 1));
		return getFREObjectFromBool(true);
	}

	FREObject getProbeInfo(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace boost;
		using namespace std;

		FREObject probe = NULL;
		FRENewObject((const uint8_t*)"com.tuarua.ffprobe.Probe", 0, NULL, &probe, NULL);

		if (probeContext.fmt_ctx) {

			//streams
			FREObject vecVideoStreams = NULL, vecAudioStreams = NULL, vecSubtitleStreams = NULL;

			FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffprobe.VideoStream>", 0, NULL, &vecVideoStreams, NULL);
			FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffprobe.AudioStream>", 0, NULL, &vecAudioStreams, NULL);
			FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffprobe.SubtitleStream>", 0, NULL, &vecSubtitleStreams, NULL);

			int i = 0, j = 0, numVideoStreams = 0, numAudioStreams = 0, numSubtitleStreams = 0, currVideoStream = -1, currAudioStream = -1, currSubtitleStream = -1;

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

					FREObject objStream;

					if ((dec_ctx = stream->codec)) {
						const char *profile = NULL;
						dec = dec_ctx->codec;

						switch (dec_ctx->codec_type) {
						case AVMEDIA_TYPE_VIDEO:
							currVideoStream++;
							FRENewObject((const uint8_t*)"com.tuarua.ffprobe.VideoStream", 0, NULL, &objStream, NULL);
							break;
						case AVMEDIA_TYPE_AUDIO:
							currAudioStream++;
							FRENewObject((const uint8_t*)"com.tuarua.ffprobe.AudioStream", 0, NULL, &objStream, NULL);
							break;
						case AVMEDIA_TYPE_SUBTITLE:
							currSubtitleStream++;
							FRENewObject((const uint8_t*)"com.tuarua.ffprobe.SubtitleStream", 0, NULL, &objStream, NULL);
							break;
						default:
							break;
						}

						FRESetObjectProperty(objStream, (const uint8_t*)"index", getFREObjectFromUint32(stream->index), NULL);

						if (dec) {
							FRESetObjectProperty(objStream, (const uint8_t*)"codecName", getFREObjectFromString(dec->name), NULL);
							FRESetObjectProperty(objStream, (const uint8_t*)"codecLongName", getFREObjectFromString((dec->long_name) ? dec->long_name : "unknown"), NULL);
						}
						else if ((cd = avcodec_descriptor_get(stream->codecpar->codec_id))) {
							FRESetObjectProperty(objStream, (const uint8_t*)"codecName", getFREObjectFromString(cd->name), NULL);
							FRESetObjectProperty(objStream, (const uint8_t*)"codecLongName", getFREObjectFromString(cd->long_name), NULL);
						}
						else {
							FRESetObjectProperty(objStream, (const uint8_t*)"codecName", getFREObjectFromString("unknown"), NULL);
							FRESetObjectProperty(objStream, (const uint8_t*)"codecLongName", getFREObjectFromString("unknown"), NULL);
						}


						if (dec && (profile = av_get_profile_name(dec, dec_ctx->profile))) {
							FRESetObjectProperty(objStream, (const uint8_t*)"profile", getFREObjectFromString(profile), NULL);
						}
						else {
							if (dec_ctx->profile != FF_PROFILE_UNKNOWN) {
								char profile_num[12];
								snprintf(profile_num, sizeof(profile_num), "%d", dec_ctx->profile);
								FRESetObjectProperty(objStream, (const uint8_t*)"codecLongName", getFREObjectFromString(profile_num), NULL);
							}
							else {
								FRESetObjectProperty(objStream, (const uint8_t*)"profile", getFREObjectFromString("unknown"), NULL);
							}
						}

						s = av_get_media_type_string(dec_ctx->codec_type);
						FRESetObjectProperty(objStream, (const uint8_t*)"codecType", getFREObjectFromString((s) ? s : "unknown"), NULL);
						FRESetObjectProperty(objStream, (const uint8_t*)"codecTimeBase", getFREObjectFromString(lexical_cast<string>(dec_ctx->time_base.num) + "/" + lexical_cast<std::string>(dec_ctx->time_base.den)), NULL);


						/* AVI/FourCC tag */
						av_get_codec_tag_string(val_str, sizeof(val_str), dec_ctx->codec_tag);
						FRESetObjectProperty(objStream, (const uint8_t*)"codecTagString", getFREObjectFromString(lexical_cast<string>(val_str)), NULL);
						FRESetObjectProperty(objStream, (const uint8_t*)"codecTag", getFREObjectFromUint32(dec_ctx->codec_tag), NULL);


						switch (dec_ctx->codec_type) {
						case AVMEDIA_TYPE_VIDEO:

							FRESetObjectProperty(objStream, (const uint8_t*)"width", getFREObjectFromInt32(dec_ctx->width), NULL);
							FRESetObjectProperty(objStream, (const uint8_t*)"height", getFREObjectFromInt32(dec_ctx->height), NULL);
							FRESetObjectProperty(objStream, (const uint8_t*)"codedWidth", getFREObjectFromInt32(dec_ctx->coded_width), NULL);
							FRESetObjectProperty(objStream, (const uint8_t*)"codedHeight", getFREObjectFromInt32(dec_ctx->coded_height), NULL);
							FRESetObjectProperty(objStream, (const uint8_t*)"hasBframes", getFREObjectFromInt32(dec_ctx->has_b_frames), NULL);

							sar = av_guess_sample_aspect_ratio(probeContext.fmt_ctx, stream, NULL);
							if (sar.den) {
								FRESetObjectProperty(objStream, (const uint8_t*)"sampleAspectRatio", getFREObjectFromString(lexical_cast<string>(sar.num) + ":" + lexical_cast<string>(sar.den)), NULL);
								av_reduce(&dar.num, &dar.den, dec_ctx->width  * sar.num, dec_ctx->height * sar.den, 1024 * 1024);
								FRESetObjectProperty(objStream, (const uint8_t*)"displayAspectRatio", getFREObjectFromString(lexical_cast<string>(dar.num) + ":" + lexical_cast<string>(dar.den)), NULL);
							}

							s = av_get_pix_fmt_name(dec_ctx->pix_fmt);
							FRESetObjectProperty(objStream, (const uint8_t*)"pixelFormat", getFREObjectFromString((s) ? s : "unknown"), NULL);
							FRESetObjectProperty(objStream, (const uint8_t*)"level", getFREObjectFromInt32(dec_ctx->level), NULL);

							if (dec_ctx->color_range != AVCOL_RANGE_UNSPECIFIED)
								FRESetObjectProperty(objStream, (const uint8_t*)"colorRange", getFREObjectFromString(av_color_range_name(dec_ctx->color_range)), NULL);

							s = av_get_colorspace_name(dec_ctx->colorspace);
							FRESetObjectProperty(objStream, (const uint8_t*)"colorSpace", getFREObjectFromString(string((s) ? s : "unknown")), NULL);
							if (dec_ctx->color_trc != AVCOL_TRC_UNSPECIFIED)
								FRESetObjectProperty(objStream, (const uint8_t*)"colorTransfer", getFREObjectFromString(av_color_transfer_name(dec_ctx->color_trc)), NULL);
							if (dec_ctx->color_primaries != AVCOL_PRI_UNSPECIFIED)
								FRESetObjectProperty(objStream, (const uint8_t*)"colorPrimaries", getFREObjectFromString(av_color_primaries_name(dec_ctx->color_primaries)), NULL);
							if (dec_ctx->chroma_sample_location != AVCHROMA_LOC_UNSPECIFIED)
								FRESetObjectProperty(objStream, (const uint8_t*)"chromaLocation", getFREObjectFromString(av_chroma_location_name(dec_ctx->chroma_sample_location)), NULL);
#if FF_API_PRIVATE_OPT
							if (dec_ctx && dec_ctx->timecode_frame_start >= 0) {
								char tcbuf[AV_TIMECODE_STR_SIZE];
								av_timecode_make_mpeg_tc_string(tcbuf, dec_ctx->timecode_frame_start);
								FRESetObjectProperty(objStream, (const uint8_t*)"timecode", getFREObjectFromString(tcbuf), NULL);
							}
							else {
								FRESetObjectProperty(objStream, (const uint8_t*)"timecode", getFREObjectFromString("N/A"), NULL);
							}
#endif
							if (dec_ctx)
								FRESetObjectProperty(objStream, (const uint8_t*)"refs", getFREObjectFromInt32(dec_ctx->refs), NULL);

							break;

						case AVMEDIA_TYPE_AUDIO:
							s = av_get_sample_fmt_name(dec_ctx->sample_fmt);
							FRESetObjectProperty(objStream, (const uint8_t*)"sampleFormat", getFREObjectFromString((s) ? s : "unknown"), NULL);
							FRESetObjectProperty(objStream, (const uint8_t*)"sampleRate", getFREObjectFromInt32(dec_ctx->sample_rate), NULL);
							FRESetObjectProperty(objStream, (const uint8_t*)"channels", getFREObjectFromInt32(dec_ctx->channels), NULL);
							char channel_layout[128];
							av_get_channel_layout_string(channel_layout, sizeof(channel_layout), dec_ctx->channels, dec_ctx->channel_layout);
							//av_get_channel_layout
							if (dec_ctx->channel_layout)
								FRESetObjectProperty(objStream, (const uint8_t*)"channelLayout", getFREObjectFromString(channel_layout), NULL);
							else
								FRESetObjectProperty(objStream, (const uint8_t*)"channelLayout", getFREObjectFromString("unknown"), NULL);
							FRESetObjectProperty(objStream, (const uint8_t*)"bitsPerSample", getFREObjectFromInt32(av_get_bits_per_sample(dec_ctx->codec_id)), NULL);
							break;

						case AVMEDIA_TYPE_SUBTITLE:
							if (dec_ctx->width)
								FRESetObjectProperty(objStream, (const uint8_t*)"width", getFREObjectFromInt32(dec_ctx->width), NULL);
							if (dec_ctx->height)
								FRESetObjectProperty(objStream, (const uint8_t*)"height", getFREObjectFromInt32(dec_ctx->height), NULL);
							break;
						default:
							break;

						}

					}
					else {
						FRESetObjectProperty(objStream, (const uint8_t*)"codecType", getFREObjectFromString("unknown"), NULL);
					}
					double v;
					int rnded;
					if (stream->r_frame_rate.num > 0) {
						v = double(stream->r_frame_rate.num) / stream->r_frame_rate.den;
						rnded = round(v * 1000);
						FRESetObjectProperty(objStream, (const uint8_t*)"realFrameRate", getFREObjectFromDouble(double(rnded) / 1000), NULL);
					}

					if (stream->avg_frame_rate.num > 0) {
						v = double(stream->avg_frame_rate.num) / stream->avg_frame_rate.den;
						rnded = round(v * 1000);
						FRESetObjectProperty(objStream, (const uint8_t*)"averageFrameRate", getFREObjectFromDouble(double(rnded) / 1000), NULL);
					}
					FRESetObjectProperty(objStream, (const uint8_t*)"timeBase", getFREObjectFromString(lexical_cast<string>(stream->time_base.num) + ":" + lexical_cast<string>(stream->time_base.den)), NULL);
					if (probeContext.fmt_ctx->iformat->flags & AVFMT_SHOW_IDS)
						FRESetObjectProperty(objStream, (const uint8_t*)"id", getFREObjectFromString((probeContext.fmt_ctx->iformat->flags & AVFMT_SHOW_IDS) ? lexical_cast<string>(stream->id) : "N/A"), NULL);

					if (stream->duration > 0) {
						v = double(stream->duration) / stream->time_base.den;
						rnded = round(v * 1000);
						FRESetObjectProperty(objStream, (const uint8_t*)"duration", getFREObjectFromDouble(double(rnded) / 1000), NULL);
						FRESetObjectProperty(objStream, (const uint8_t*)"durationTimestamp", getFREObjectFromDouble(double(stream->duration)), NULL);
					}
					FRESetObjectProperty(objStream, (const uint8_t*)"startPTS", getFREObjectFromDouble(double(stream->start_time)), NULL);
					v = double(stream->start_time) *  av_q2d(stream->time_base);
					rnded = round(v * 100000);
					FRESetObjectProperty(objStream, (const uint8_t*)"startTime", getFREObjectFromDouble(double(rnded) / 100000), NULL);
					if (dec_ctx->rc_max_rate > 0)
						FRESetObjectProperty(objStream, (const uint8_t*)"maxBitRate", getFREObjectFromDouble(double(dec_ctx->rc_max_rate)), NULL);
					if (dec_ctx->bits_per_raw_sample > 0)
						FRESetObjectProperty(objStream, (const uint8_t*)"bitsPerRawSample", getFREObjectFromDouble(double(dec_ctx->bits_per_raw_sample)), NULL);
					if (stream->nb_frames > 0)
						FRESetObjectProperty(objStream, (const uint8_t*)"numFrames", getFREObjectFromDouble(double(stream->nb_frames)), NULL);

					if (dec_ctx->bit_rate > 0)
						FRESetObjectProperty(objStream, (const uint8_t*)"bitRate", getFREObjectFromDouble(double(dec_ctx->bit_rate)), NULL);

					AVDictionaryEntry *tag = NULL;
					FREObject streamTags = NULL;
					FRENewObject((const uint8_t*)"Object", 0, NULL, &streamTags, NULL);
					while ((tag = av_dict_get(stream->metadata, "", tag, AV_DICT_IGNORE_SUFFIX)))
						FRESetObjectProperty(streamTags, (const uint8_t*)tag->key, getFREObjectFromString(tag->value), NULL);

					FRESetObjectProperty(objStream, (const uint8_t*)"tags", streamTags, NULL);

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

			FRESetObjectProperty(probe, (const uint8_t*)"videoStreams", vecVideoStreams, NULL);
			FRESetObjectProperty(probe, (const uint8_t*)"audioStreams", vecAudioStreams, NULL);
			FRESetObjectProperty(probe, (const uint8_t*)"subtitleStreams", vecSubtitleStreams, NULL);

			FREObject objFormat = NULL;
			FRENewObject((const uint8_t*)"com.tuarua.ffprobe.Format", 0, NULL, &objFormat, NULL);
			FRESetObjectProperty(objFormat, (const uint8_t*)"filename", getFREObjectFromString(probeContext.fmt_ctx->filename), NULL);
			FRESetObjectProperty(objFormat, (const uint8_t*)"numStreams", getFREObjectFromUint32(probeContext.fmt_ctx->nb_streams), NULL);
			FRESetObjectProperty(objFormat, (const uint8_t*)"numPrograms", getFREObjectFromUint32(probeContext.fmt_ctx->nb_programs), NULL);

			FRESetObjectProperty(objFormat, (const uint8_t*)"formatName", getFREObjectFromString(probeContext.fmt_ctx->iformat->name), NULL);
			if (probeContext.fmt_ctx->iformat->long_name) FRESetObjectProperty(objFormat, (const uint8_t*)"formatLongName", getFREObjectFromString(probeContext.fmt_ctx->iformat->long_name), NULL);

			FRESetObjectProperty(objFormat, (const uint8_t*)"startTime", getFREObjectFromDouble((double(probeContext.fmt_ctx->start_time)) / 1000000), NULL);
			FRESetObjectProperty(objFormat, (const uint8_t*)"duration", getFREObjectFromDouble((double(probeContext.fmt_ctx->duration)) / 1000000), NULL);

			int64_t size = probeContext.fmt_ctx->pb ? avio_size(probeContext.fmt_ctx->pb) : -1;
			FRESetObjectProperty(objFormat, (const uint8_t*)"size", getFREObjectFromInt32(int32_t(size)), NULL);

			FRESetObjectProperty(objFormat, (const uint8_t*)"bitRate", getFREObjectFromInt32(int32_t(probeContext.fmt_ctx->bit_rate)), NULL);
			FRESetObjectProperty(objFormat, (const uint8_t*)"probeScore", getFREObjectFromUint32(av_format_get_probe_score(probeContext.fmt_ctx)), NULL);

			//Tags
			AVDictionaryEntry *tag = NULL;
			FREObject formatTags = NULL;
			FRENewObject((const uint8_t*)"Object", 0, NULL, &formatTags, NULL);
			while ((tag = av_dict_get(probeContext.fmt_ctx->metadata, "", tag, AV_DICT_IGNORE_SUFFIX)))
				FRESetObjectProperty(formatTags, (const uint8_t*)tag->key, getFREObjectFromString(tag->value), NULL);

			FRESetObjectProperty(objFormat, (const uint8_t*)"tags", formatTags, NULL);
			FRESetObjectProperty(probe, (const uint8_t*)"format", objFormat, NULL);

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
		FREDispatchStatusEventAsync(dllContext, (uint8_t*)j.dump().c_str(), (const uint8_t*) "ON_ENCODE_PROGRESS");
	}

	char * toCString(std::string str) {
		char * cStr = new char[str.length() + 1];
		std::strcpy(cStr, str.c_str());
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
			boost::algorithm::trim(messageTrimmed);

			logStr = " [ffmpeg][" + (module ? string(module) : "") + "][" + lexical_cast<string>(get_level_str(level)) + "] : " + messageTrimmed;
			logHtml = " <p class=\"" + lexical_cast<string>(get_level_str(level)) + "\">" + (module ? string(module) + ":" : "") + lexical_cast<string>(get_level_str(level)) + ": " + messageTrimmed + "</p>";

			if (level <= logLevel && !messageTrimmed.empty()) {
				logInfo(logStr);
				logInfoHtml(logHtml);
			}

			if (level == 16 || level == 8)
				logError(string(message));
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
		std::string returnVal = "";
		FREDispatchStatusEventAsync(dllContext, (uint8_t*)returnVal.c_str(), (const uint8_t*) "ON_ENCODE_START");
		if (ret < 0) {
		}
		else {
			ret = avane_main_transcode();
			trace("avane_main_transcode is finished");
		}
		isEncoding = false;

		if (ret < 0)
			FREDispatchStatusEventAsync(dllContext, (uint8_t*)returnVal.c_str(), (const uint8_t*) "ON_ENCODE_ERROR");
		else
			FREDispatchStatusEventAsync(dllContext, (uint8_t*)returnVal.c_str(), (const uint8_t*) "ON_ENCODE_FINISH");

		avane_main_cleanup();

		mutex.unlock();
	}

	FREObject encode(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		FREObject args = argv[0];
		uint32_t numItems = getFREObjectArrayLength(args);

		inputContext.commandLine.clear();
		for (unsigned int k = 0; k < numItems; ++k) {
			FREObject valueAS = NULL;
			FREGetArrayElementAt(args, k, &valueAS);
			std::string valueAsString = getStringFromFREObject(valueAS);
			inputContext.commandLine.push_back(valueAsString);
		}

		//trigger the thread
		threads[0] = boost::move(createThread(&threadEncode, 1));
		return getFREObjectFromBool(true);
	}

	FREObject cancelEncode(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		if (isEncoding)
			avane_set_cancel_transcode(1);
		isEncoding = false;
		return getFREObjectFromBool(true);
	}
	FREObject pauseEncode(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		avane_set_pause_transcode((getBoolFromFREObject(argv[0])) ? 1 : 0);
		return getFREObjectFromBool(1);
	}
	FREObject setLogLevel(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		logLevel = getInt32FromFREObject(argv[0]);
		return NULL;
	}


#ifdef _WIN32
	void DisplayDeviceInformation(IEnumMoniker *pEnum, bool isVideo, FREObject obj) {
		IMoniker *pMoniker = NULL;

		while (pEnum->Next(1, &pMoniker, NULL) == S_OK) {
			bool addObject = false;
			IPropertyBag *pPropBag;
			HRESULT hr = pMoniker->BindToStorage(0, 0, IID_PPV_ARGS(&pPropBag));
			if (FAILED(hr)) {
				pMoniker->Release();
				continue;
			}

			FREObject objDevice;
			FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.CaptureDevice", 0, NULL, &objDevice, NULL);
			FRESetObjectProperty(objDevice, (const uint8_t*)"format", getFREObjectFromString("dshow"), NULL);

			if(isVideo)
				FRESetObjectProperty(objDevice, (const uint8_t*)"isVideo", getFREObjectFromBool(true), NULL);
			else
				FRESetObjectProperty(objDevice, (const uint8_t*)"isAudio", getFREObjectFromBool(true), NULL);


			VARIANT var;
			VariantInit(&var);

			hr = pPropBag->Read(L"Description", &var, 0);
			if (SUCCEEDED(hr)) {
				std::string desc = getStringFromBstr(var.bstrVal);
				FRESetObjectProperty(objDevice, (const uint8_t*)"description", getFREObjectFromString(desc), NULL);
				VariantClear(&var);
				addObject = true;
			}

			hr = pPropBag->Read(L"FriendlyName", &var, 0);

			if (SUCCEEDED(hr)) {
				std::string name = getStringFromBstr(var.bstrVal);
				FRESetObjectProperty(objDevice, (const uint8_t*)"name", getFREObjectFromString(name), NULL);
				VariantClear(&var);
				addObject = true;
			}

			hr = pPropBag->Read(L"DevicePath", &var, 0);
			if (SUCCEEDED(hr)) {
				// The device path is not intended for display.
				std::string path = getStringFromBstr(var.bstrVal);
				FRESetObjectProperty(objDevice, (const uint8_t*)"path", getFREObjectFromString(path), NULL);
				VariantClear(&var);
			}
			
			pPropBag->Release();
			pMoniker->Release();

			if (addObject)
				FRESetArrayElementAt(obj, getFREObjectArrayLength(obj), objDevice);

		}
	}

	FREObject getCaptureDevices(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		FREObject vecDevices = NULL;
		FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffmpeg.gets.CaptureDevice>", 0, NULL, &vecDevices, NULL);
		HRESULT hr;
		IEnumMoniker *pEnum;

		hr = EnumerateDevices(CLSID_VideoInputDeviceCategory, &pEnum);
		if (SUCCEEDED(hr)) {
			DisplayDeviceInformation(pEnum, true, vecDevices);
			pEnum->Release();
		}
		hr = EnumerateDevices(CLSID_AudioInputDeviceCategory, &pEnum);
		if (SUCCEEDED(hr)) {
			DisplayDeviceInformation(pEnum, false, vecDevices);
			pEnum->Release();
		}

		return vecDevices;
	}
#elif
	FREObject getCaptureDevices(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		FREObject vecDevices = NULL;
		FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffmpeg.gets.CaptureDevice>", 0, NULL, &vecDevices, NULL);
		return vecDevices;
	}
#endif
	
    
    void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet) {
        static FRENamedFunction extensionFunctions[] = {
            {(const uint8_t*) "isSupported",NULL, &isSupported}
            ,{(const uint8_t*) "setLogLevel",NULL, &setLogLevel}
            ,{(const uint8_t*) "getLayouts",NULL, &getLayouts}
            ,{(const uint8_t*) "getColors",NULL, &getColors}
            ,{(const uint8_t*) "getProtocols",NULL, &getProtocols}
            ,{(const uint8_t*) "getFilters",NULL, &getFilters}
            ,{(const uint8_t*) "getPixelFormats",NULL, &getPixelFormats}
            ,{(const uint8_t*) "getBitStreamFilters",NULL, &getBitStreamFilters}
            ,{(const uint8_t*) "getDecoders",NULL, &getDecoders}
            ,{(const uint8_t*) "getEncoders",NULL, &getEncoders}
            ,{(const uint8_t*) "getCodecs",NULL, &getCodecs}
            ,{(const uint8_t*) "getHardwareAccelerations",NULL, &getHardwareAccelerations}
            ,{(const uint8_t*) "getDevices",NULL, &getDevices}
            ,{(const uint8_t*) "getAvailableFormats",NULL, &getAvailableFormats}
            ,{(const uint8_t*) "getBuildConfiguration",NULL, &getBuildConfiguration}
            ,{(const uint8_t*) "getLicense",NULL, &getLicense}
            ,{(const uint8_t*) "getVersion",NULL, &getVersion}
            ,{(const uint8_t*) "getSampleFormats",NULL, &getSampleFormats}
            ,{(const uint8_t*) "triggerProbeInfo",NULL, &triggerProbeInfo}
            ,{(const uint8_t*) "getProbeInfo",NULL, &getProbeInfo}
            ,{(const uint8_t*) "encode",NULL, &encode}
            ,{(const uint8_t*) "cancelEncode",NULL, &cancelEncode}
            ,{(const uint8_t*) "pauseEncode",NULL, &pauseEncode}
			,{(const uint8_t*) "getCaptureDevices",NULL, &getCaptureDevices }
        };
        *numFunctionsToSet = sizeof(extensionFunctions) / sizeof(FRENamedFunction);
        *functionsToSet = extensionFunctions;
        dllContext = ctx;
    }
    
    void contextFinalizer(FREContext ctx) {
        return;
    }
    void TRAVAExtInizer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer) {
        *ctxInitializer = &contextInitializer;
        *ctxFinalizer = &contextFinalizer;
    }
    
    void TRAVAExtFinizer(void* extData) {
        FREContext nullCTX;
        nullCTX = 0;
        contextFinalizer(nullCTX);
        return;
    }
    
}
