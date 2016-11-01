//
//  Utils.cpp
//  AVANE
//
//  Created by Tua Rua on 25/04/2016.
//  Copyright © 2016 Tua Rua Ltd. All rights reserved.
//

#ifdef _WIN32
#include "FlashRuntimeExtensions.h"
#include <windows.h>
#include <conio.h>

#elif __APPLE__

#include "TargetConditionals.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
// iOS Simulator
#include "FlashRuntimeExtensions.h"

#elif TARGET_OS_MAC
// Other kinds of Mac OS
#include <Adobe AIR/Adobe AIR.h>
#include <stdlib.h>
#include <stdio.h>
#define __ASSERT_MACROS_DEFINE_VERSIONS_WITHOUT_UNDERSCORES 0
#define BOOST_ASIO_SEPARATE_COMPILATION 0

#else
#   error "Unknown Apple platform"
#endif


#endif




#include <boost/algorithm/string/trim.hpp>
#include <boost/algorithm/string/split.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/format.hpp>

#include "ANEhelper.h"


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
	
	#include "libavfilter/avfilter.h"
	#include "ffmpeg.h"
	

    //when moved from opt get rid of _
    const HWAccel hwaccels_[] = {
#if HAVE_VDPAU_X11
        { "vdpau", vdpau_init, HWACCEL_VDPAU, AV_PIX_FMT_VDPAU },
#endif
#if HAVE_DXVA2_LIB
        { "dxva2", dxva2_init, HWACCEL_DXVA2, AV_PIX_FMT_DXVA2_VLD },
#endif
#if CONFIG_VDA
        { "vda",   videotoolbox_init,   HWACCEL_VDA,   AV_PIX_FMT_VDA },
#endif
#if CONFIG_VIDEOTOOLBOX
        { "videotoolbox",   videotoolbox_init,   HWACCEL_VIDEOTOOLBOX,   AV_PIX_FMT_VIDEOTOOLBOX },
#endif
#if CONFIG_LIBMFX
        { "qsv",   qsv_init,   HWACCEL_QSV,   AV_PIX_FMT_QSV },
#endif
        { 0 },
    };

    extern char *hex2str(const uint8_t *data, size_t len) {
        static char *str = NULL;
        size_t i;
        str = (char*)realloc(str, 2 * len + 1);
        *str = 0;
        for (i = 0; i < len; i++)
            sprintf(str + 2 * i, "%02X", data[i]);
        return str;
    }
	
    FREObject getLayouts(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
        using namespace boost;
        using namespace std;
        FREObject objLayouts;
        FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.Layouts", 0, NULL, &objLayouts, NULL);
        
        int i,cnt = 0;
        uint64_t layout, j;
        const char *name, *descr;
        
        FREObject vecIndividual;
        FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffmpeg.gets.Layout>", 0, NULL, &vecIndividual, NULL);
        FREObject vecStandard;
        FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffmpeg.gets.Layout>", 0, NULL, &vecStandard, NULL);
        for (i = 0; i < 63; i++) {
            name = av_get_channel_name((uint64_t)1 << i);
            if (!name)
                continue;
            descr = av_get_channel_description((uint64_t)1 << i);
            FREObject objLayout;
            FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.Layout", 0, NULL, &objLayout, NULL);
            FRESetObjectProperty(objLayout, (const uint8_t*)"name", getFREObjectFromString(name), NULL);
            FRESetObjectProperty(objLayout, (const uint8_t*)"description", getFREObjectFromString(descr), NULL);
            FRESetArrayElementAt(vecIndividual, cnt, objLayout);
            cnt++;
        }
        FRESetObjectProperty(objLayouts, (const uint8_t*)"individual", vecIndividual, NULL);
        
        cnt = 0;
        for (i = 0; !av_get_standard_channel_layout(i, &layout, &name); i++) {
            if (name) {
                FREObject objLayout;
                FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.Layout", 0, NULL, &objLayout, NULL);
                FRESetObjectProperty(objLayout, (const uint8_t*)"name", getFREObjectFromString(name), NULL);
                std::stringstream ss;
                for (j = 1; j; j <<= 1) {
                    if ((layout & j)) {
                        if (layout & (j - 1)) ss << "+";
                        ss << av_get_channel_name(j);
                    }
                }
                FRESetObjectProperty(objLayout, (const uint8_t*)"description", getFREObjectFromString(ss.str()), NULL);
                FRESetArrayElementAt(vecStandard, cnt, objLayout);
                cnt++;
            }
        }
        FRESetObjectProperty(objLayouts, (const uint8_t*)"standard", vecStandard, NULL);
        return objLayouts;
    }
	FREObject getProtocols(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		FREObject objProtocols;
		FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.Protocols", 0, NULL, &objProtocols, NULL);

		FREObject vecInputProtocols;
		FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffmpeg.gets.Protocol>", 0, NULL, &vecInputProtocols, NULL);
		FREObject vecOutputProtocols;
		FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffmpeg.gets.Protocol>", 0, NULL, &vecOutputProtocols, NULL);

		av_register_all();
		avformat_network_init();

		void *opaque = NULL;
		const char *name;
		int cnt = 0;

		name = "000";
		while ((name = avio_enum_protocols(&opaque, 0))) {
			FREObject objProtocol;
			FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.Protocol", 0, NULL, &objProtocol, NULL);
			FRESetObjectProperty(objProtocol, (const uint8_t*)"name", getFREObjectFromString(name), NULL);
			FRESetArrayElementAt(vecInputProtocols, cnt, objProtocol);
			cnt++;
		}
		FRESetObjectProperty(objProtocols, (const uint8_t*)"inputs", vecInputProtocols, NULL);

		cnt = 0;
		name = "000";
		while ((name = avio_enum_protocols(&opaque, 1))) {
			FREObject objProtocol;
			FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.Protocol", 0, NULL, &objProtocol, NULL);
			FRESetObjectProperty(objProtocol, (const uint8_t*)"name", getFREObjectFromString(name), NULL);
			FRESetArrayElementAt(vecOutputProtocols, cnt, objProtocol);
			cnt++;
		}
		FRESetObjectProperty(objProtocols, (const uint8_t*)"outputs", vecOutputProtocols, NULL);
		avformat_network_deinit();
		return objProtocols;
	}
    FREObject getColors(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
        using namespace boost;
        using namespace std;
        FREObject vecColors;
        FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffmpeg.gets.Color>", 0, NULL, &vecColors, NULL);

        const char *name;
        const uint8_t *rgb;
        int i;
        
        for (i = 0; name = av_get_known_color_name(i, &rgb); i++) {
            FREObject objColor;
            FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.Color", 0, NULL, &objColor, NULL);
            FRESetObjectProperty(objColor, (const uint8_t*)"name", getFREObjectFromString(name), NULL);
            FRESetObjectProperty(objColor, (const uint8_t*)"value", getFREObjectFromString("#"+lexical_cast<string>(hex2str(rgb, sizeof(rgb)-1))), NULL);
            FRESetArrayElementAt(vecColors, i, objColor);
        }
        return vecColors;
    }
	FREObject getPixelFormats(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace boost;
		using namespace std;
		FREObject vecFormats;
		FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffmpeg.gets.PixelFormat>", 0, NULL, &vecFormats, NULL);

		const AVPixFmtDescriptor *pix_desc = NULL;
#if !CONFIG_SWSCALE
#   define sws_isSupportedInput(x)  0
#   define sws_isSupportedOutput(x) 0
#endif
		int cnt = 0;
		while ((pix_desc = av_pix_fmt_desc_next(pix_desc))) {
			FREObject objFormat;
			enum AVPixelFormat pix_fmt = av_pix_fmt_desc_get_id(pix_desc);

			FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.PixelFormat", 0, NULL, &objFormat, NULL);
			FRESetObjectProperty(objFormat, (const uint8_t*)"name", getFREObjectFromString(pix_desc->name), NULL);
			if (sws_isSupportedInput(pix_fmt))
				FRESetObjectProperty(objFormat, (const uint8_t*)"isInput", getFREObjectFromBool(1), NULL);
			if (sws_isSupportedOutput(pix_fmt))
				FRESetObjectProperty(objFormat, (const uint8_t*)"isOutput", getFREObjectFromBool(1), NULL);

			if (pix_desc->flags & AV_PIX_FMT_FLAG_HWACCEL)
				FRESetObjectProperty(objFormat, (const uint8_t*)"isHardwareAccelerated", getFREObjectFromBool(1), NULL);
			if (pix_desc->flags & AV_PIX_FMT_FLAG_PAL)
				FRESetObjectProperty(objFormat, (const uint8_t*)"isPalleted", getFREObjectFromBool(1), NULL);
			if (pix_desc->flags & AV_PIX_FMT_FLAG_BITSTREAM)
				FRESetObjectProperty(objFormat, (const uint8_t*)"isBitStream", getFREObjectFromBool(1), NULL);

			FRESetObjectProperty(objFormat, (const uint8_t*)"numComponents", getFREObjectFromUint32(pix_desc->nb_components), NULL);
			FRESetObjectProperty(objFormat, (const uint8_t*)"bitsPerPixel", getFREObjectFromInt32(av_get_bits_per_pixel(pix_desc)), NULL);
			FRESetArrayElementAt(vecFormats, cnt, objFormat);
			cnt++;
		}

		return vecFormats;
	}
	FREObject getFilters(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace std;
		FREObject vecFilters;
		FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffmpeg.gets.Filter>", 0, NULL, &vecFilters, NULL);

#if CONFIG_AVFILTER
		const AVFilter *filter = NULL;
		char descr[64], *descr_cur;
		int i, j;
		int cnt = 0;
		const AVFilterPad *pad;

		avfilter_register_all();

		while ((filter = avfilter_next(filter))) {
			FREObject objFilter;
			FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.Filter", 0, NULL, &objFilter, NULL);

			descr_cur = descr;
			for (i = 0; i < 2; i++) {
				if (i) {
					*(descr_cur++) = '-';
					*(descr_cur++) = '>';
				}
				pad = i ? filter->outputs : filter->inputs;
				for (j = 0; pad && avfilter_pad_get_name(pad, j); j++) {
					if (descr_cur >= descr + sizeof(descr) - 4)
						break;
					AVMediaType af = avfilter_pad_get_type(pad, j);
					switch (af) {
					case AVMEDIA_TYPE_VIDEO:
						*(descr_cur++) = 'V';
						break;
					case AVMEDIA_TYPE_AUDIO:
						*(descr_cur++) = 'A';
						break;
					case AVMEDIA_TYPE_DATA:
						*(descr_cur++) = 'D';
						break;
					case AVMEDIA_TYPE_SUBTITLE:
						*(descr_cur++) = 'S';
						break;
					case AVMEDIA_TYPE_ATTACHMENT:
						*(descr_cur++) = 'T';
						break;
					default:
						*(descr_cur++) = '?';
						break;
					}
				}
				if (!j)
					*(descr_cur++) = ((!i && (filter->flags & AVFILTER_FLAG_DYNAMIC_INPUTS)) ||
						(i && (filter->flags & AVFILTER_FLAG_DYNAMIC_OUTPUTS))) ? 'N' : '|';
			}
			*descr_cur = 0;

			if (filter->flags & AVFILTER_FLAG_SUPPORT_TIMELINE)
				FRESetObjectProperty(objFilter, (const uint8_t*)"hasTimelineSupport", getFREObjectFromBool(1), NULL);
			if (filter->flags & AVFILTER_FLAG_SLICE_THREADS)
				FRESetObjectProperty(objFilter, (const uint8_t*)"hasSliceThreading", getFREObjectFromBool(1), NULL);
			if (filter->process_command)
				FRESetObjectProperty(objFilter, (const uint8_t*)"hasCommandSupport", getFREObjectFromBool(1), NULL);
			FRESetObjectProperty(objFilter, (const uint8_t*)"name", getFREObjectFromString(filter->name), NULL);
			FRESetObjectProperty(objFilter, (const uint8_t*)"description", getFREObjectFromString(filter->description), NULL);
			FRESetObjectProperty(objFilter, (const uint8_t*)"type", getFREObjectFromString(descr), NULL);
			FRESetArrayElementAt(vecFilters, cnt, objFilter);
			cnt++;
		}
#endif

		return vecFilters;
	}
    
    FREObject getBitStreamFilters(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
        FREObject vecBSFs;
        FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffmpeg.gets.BitStreamFilter>", 0, NULL, &vecBSFs, NULL);
        int len = 0;
        int cnt = 0;
        AVBitStreamFilter *bsf = NULL;
        while ((bsf = av_bitstream_filter_next(bsf)))
            len++;
        FRESetArrayLength(vecBSFs, len);
        while ((bsf = av_bitstream_filter_next(bsf))) {
            FREObject objBSF;
            FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.BitStreamFilter", 0, NULL, &objBSF, NULL);
            FRESetObjectProperty(objBSF, (const uint8_t*)"name", getFREObjectFromString(bsf->name), NULL);
            FRESetArrayElementAt(vecBSFs, cnt, objBSF);
            cnt++;
        }
        
        return vecBSFs;
    }
    static const AVCodec *next_codec_for_id(enum AVCodecID id, const AVCodec *prev, int encoder) {
        while ((prev = av_codec_next(prev))) {
            if (prev->id == id && (encoder ? av_codec_is_encoder(prev) : av_codec_is_decoder(prev)))
                return prev;
        }
        return NULL;
    }
    static int compare_codec_desc(const void *a, const void *b) {
        const AVCodecDescriptor * const *da = (const AVCodecDescriptor **)a;
        const AVCodecDescriptor * const *db = (const AVCodecDescriptor **)b;
        return (*da)->type != (*db)->type ? FFDIFFSIGN((*da)->type, (*db)->type) : strcmp((*da)->name, (*db)->name);
    }
    static unsigned get_codecs_sorted(const AVCodecDescriptor ***rcodecs) {
        const AVCodecDescriptor *desc = NULL;
        const AVCodecDescriptor **codecs;
        unsigned nb_codecs = 0, i = 0;
        
        while ((desc = avcodec_descriptor_next(desc)))
            nb_codecs++;
        if (!(codecs = (const AVCodecDescriptor **)(av_calloc(nb_codecs, sizeof(*codecs)))))
            av_log(NULL, AV_LOG_ERROR, "Out of memory\n");
        desc = NULL;
        while ((desc = avcodec_descriptor_next(desc)))
            codecs[i++] = desc;
        av_assert0(i == nb_codecs);
        qsort(codecs, nb_codecs, sizeof(*codecs), compare_codec_desc);
        *rcodecs = codecs;
        return nb_codecs;
    }
    FREObject buildEncoderDecoder(int encoder) {
        using namespace std;
        FREObject vec;
        if (encoder)
            FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffmpeg.gets.Encoder>", 0, NULL, &vec, NULL);
        else
            FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffmpeg.gets.Decoder>", 0, NULL, &vec, NULL);
        
        const AVCodecDescriptor **codecs;
        unsigned i, nb_codecs = get_codecs_sorted(&codecs);
        FRESetArrayLength(vec, nb_codecs);
        int cnt = 0;
        
        avcodec_register_all();
        
        for (i = 0; i < nb_codecs; i++) {
            const AVCodecDescriptor *desc = codecs[i];
            const AVCodec *codec = NULL;
            
            while ((codec = next_codec_for_id(desc->id, codec, encoder))) {
                FREObject obj = NULL;
                if (encoder)
                    FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.Encoder", 0, NULL, &obj, NULL);
				else
                    FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.Decoder", 0, NULL, &obj, NULL);
                FRESetObjectProperty(obj, (const uint8_t*)"name", getFREObjectFromString(codec->name), NULL);
                if (strcmp(codec->name, desc->name))
                    FRESetObjectProperty(obj, (const uint8_t*)"nameLong", getFREObjectFromString(string(codec->long_name) + " (codec " + string(desc->name)+ ")"), NULL);
				else
                    FRESetObjectProperty(obj, (const uint8_t*)"nameLong", getFREObjectFromString(codec->long_name), NULL);
                switch (desc->type) {
                    case AVMEDIA_TYPE_VIDEO:
                        FRESetObjectProperty(obj, (const uint8_t*)"isVideo", getFREObjectFromBool(1), NULL);
                        break;
                    case AVMEDIA_TYPE_AUDIO:
                        FRESetObjectProperty(obj, (const uint8_t*)"isAudio", getFREObjectFromBool(1), NULL);
                        break;
                    case AVMEDIA_TYPE_SUBTITLE:
                        FRESetObjectProperty(obj, (const uint8_t*)"isSubtitles", getFREObjectFromBool(1), NULL);
                        break;
                    default:
                        break;
                }
                
                if (codec->capabilities & AV_CODEC_CAP_FRAME_THREADS)
					FRESetObjectProperty(obj, (const uint8_t*)"hasFrameLevelMultiThreading", getFREObjectFromBool(1), NULL);
                if (codec->capabilities & AV_CODEC_CAP_SLICE_THREADS)
					FRESetObjectProperty(obj, (const uint8_t*)"hasSliceLevelMultiThreading", getFREObjectFromBool(1), NULL);
                if (codec->capabilities & AV_CODEC_CAP_EXPERIMENTAL)
					FRESetObjectProperty(obj, (const uint8_t*)"isExperimental", getFREObjectFromBool(1), NULL);
                if (codec->capabilities & AV_CODEC_CAP_DRAW_HORIZ_BAND)
					FRESetObjectProperty(obj, (const uint8_t*)"supportsDrawHorizBand", getFREObjectFromBool(1), NULL);
                if (codec->capabilities & AV_CODEC_CAP_DR1)
					FRESetObjectProperty(obj, (const uint8_t*)"supportsDirectRendering", getFREObjectFromBool(1), NULL);
                
                FRESetArrayElementAt(vec, cnt, obj);
                cnt++;
            }
        }
        FRESetArrayLength(vec, cnt);
        av_free(codecs);
        
        return vec;
    }
    FREObject getDecoders(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
        return buildEncoderDecoder(0);
    }
    FREObject getEncoders(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
        return buildEncoderDecoder(1);
    }
    FREObject getCodecs(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
        using namespace std;
        FREObject vecCodecs;
        FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffmpeg.gets.Codec>", 0, NULL, &vecCodecs, NULL);
        const AVCodecDescriptor **codecs;
        unsigned i, nb_codecs = get_codecs_sorted(&codecs);
        FRESetArrayLength(vecCodecs, nb_codecs);
        
        avcodec_register_all();
        
        for (i = 0; i < nb_codecs; i++) {
            const AVCodecDescriptor *desc = codecs[i];
            
            if (strstr(desc->name, "_deprecated"))
                continue;
            FREObject objCodec = NULL;
            FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.Codec", 0, NULL, &objCodec, NULL);
            FRESetObjectProperty(objCodec, (const uint8_t*)"name", getFREObjectFromString(desc->name), NULL);
            FRESetObjectProperty(objCodec, (const uint8_t*)"nameLong", getFREObjectFromString(desc->long_name), NULL);
            if (avcodec_find_decoder(desc->id))
				FRESetObjectProperty(objCodec, (const uint8_t*)"hasDecoder", getFREObjectFromBool(1), NULL);
            if (avcodec_find_encoder(desc->id))
				FRESetObjectProperty(objCodec, (const uint8_t*)"hasEncoder", getFREObjectFromBool(1), NULL);
            switch (desc->type) {
                case AVMEDIA_TYPE_VIDEO:
                    FRESetObjectProperty(objCodec, (const uint8_t*)"isVideo", getFREObjectFromBool(1), NULL);
                    break;
                case AVMEDIA_TYPE_AUDIO:
                    FRESetObjectProperty(objCodec, (const uint8_t*)"isAudio", getFREObjectFromBool(1), NULL);
                    break;
                case AVMEDIA_TYPE_SUBTITLE:
                    FRESetObjectProperty(objCodec, (const uint8_t*)"isSubtitles", getFREObjectFromBool(1), NULL);
                    break;
                default:
                    break;
            }
            if ((desc->props & AV_CODEC_PROP_LOSSY))
				FRESetObjectProperty(objCodec, (const uint8_t*)"isLossy", getFREObjectFromBool(1), NULL);
            if ((desc->props & AV_CODEC_PROP_LOSSLESS))
				FRESetObjectProperty(objCodec, (const uint8_t*)"isLossless", getFREObjectFromBool(1), NULL);
            if ((desc->props & AV_CODEC_PROP_INTRA_ONLY))
				FRESetObjectProperty(objCodec, (const uint8_t*)"isIntraFrameOnly", getFREObjectFromBool(1), NULL);
            
            FRESetArrayElementAt(vecCodecs, i, objCodec);
            
        }
        
        av_free(codecs);
        
        return vecCodecs;
    }
    
    FREObject getHardwareAccelerations(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
        FREObject vecHWAccels;
        FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffmpeg.gets.HardwareAcceleration>", 0, NULL, &vecHWAccels, NULL);
        int numHWAccels = FF_ARRAY_ELEMS(hwaccels_) - 1;
        FRESetArrayLength(vecHWAccels, numHWAccels);
        for (int i = 0; i < numHWAccels; i++) {
            FREObject objHW;
            FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.HardwareAcceleration", 0, NULL, &objHW, NULL);
            FRESetObjectProperty(objHW, (const uint8_t*)"name", getFREObjectFromString(hwaccels_[i].name), NULL);
            FRESetArrayElementAt(vecHWAccels, i, objHW);
        }
        return vecHWAccels;
    }
	static int is_device(const AVClass *avclass) {
		if (!avclass) return 0;
		return AV_IS_INPUT_DEVICE(avclass->category) || AV_IS_OUTPUT_DEVICE(avclass->category);
	}
	FREObject getAvailableFormatsDevices(int device_only) {
		using namespace std;

		AVInputFormat *ifmt = NULL;
		AVOutputFormat *ofmt = NULL;
		const char *last_name;
		int is_dev;
		last_name = "000";
		int cnt = 0;

		FREObject vecFormats;
		if (device_only)
			FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffmpeg.gets.Device>", 0, NULL, &vecFormats, NULL);
		else
			FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffmpeg.gets.AvailableFormat>", 0, NULL, &vecFormats, NULL);

		av_register_all();
		avformat_network_init();

		for (;;) {
			int decode = 0;
			int encode = 0;
			const char *name = NULL;
			const char *long_name = NULL;

			while ((ofmt = av_oformat_next(ofmt))) {
				is_dev = is_device(ofmt->priv_class);
				if (!is_dev && device_only)
					continue;
				if ((!name || strcmp(ofmt->name, name) < 0) &&
					strcmp(ofmt->name, last_name) > 0) {
					name = ofmt->name;
					long_name = ofmt->long_name;
					encode = 1;
				}
			}
			while ((ifmt = av_iformat_next(ifmt))) {
				is_dev = is_device(ifmt->priv_class);
				if (!is_dev && device_only)
					continue;
				if ((!name || strcmp(ifmt->name, name) < 0) &&
					strcmp(ifmt->name, last_name) > 0) {
					name = ifmt->name;
					long_name = ifmt->long_name;
					encode = 0;
				}
				if (name && strcmp(ifmt->name, name) == 0)
					decode = 1;
			}
			if (!name)
				break;
			last_name = name;

			FREObject objFormat = NULL;
			if (device_only)
				FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.Device", 0, NULL, &objFormat, NULL);
			else
				FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.AvailableFormat", 0, NULL, &objFormat, NULL);

			FRESetObjectProperty(objFormat, (const uint8_t*)"name", getFREObjectFromString(name), NULL);
			FRESetObjectProperty(objFormat, (const uint8_t*)"nameLong", getFREObjectFromString((long_name) ? long_name : name), NULL);
			if (decode)
				FRESetObjectProperty(objFormat, (const uint8_t*)"demuxing", getFREObjectFromBool(1), NULL);
			if (encode)
				FRESetObjectProperty(objFormat, (const uint8_t*)"muxing", getFREObjectFromBool(1), NULL);

			FRESetArrayElementAt(vecFormats, cnt, objFormat);

			cnt++;
		}
		avformat_network_deinit();
		return vecFormats;
	}
	FREObject getDevices(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
#if CONFIG_AVDEVICE
		avdevice_register_all();
#endif
		return getAvailableFormatsDevices(1);
	}
	FREObject getAvailableFormats(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		return getAvailableFormatsDevices(0);
	}
	FREObject getBuildConfiguration(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		return getFREObjectFromString(std::string(FFMPEG_CONFIGURATION));
	}
	FREObject getLicense(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		std::string license = "";
#if CONFIG_NONFREE
		license = "This version of ffmpeg has nonfree parts compiled in.\nTherefore it is not legally redistributable.";
#elif CONFIG_GPLV3
		license = "ffmpeg is free software; you can redistribute it and/or modify\nit under the terms of the GNU General Public License"
			"as published by the Free Software Foundation; either version 3 of the License, or \n(at your option) any later version.\n"
			"ffmpeg is distributed in the hope that it will be useful, \nbut WITHOUT ANY WARRANTY; without even the implied warranty of\n"
			"MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.See the\nGNU General Public License for more details.\n\n"
			"You should have received a copy of the GNU General Public License\nalong with ffmpeg.If not, see <http://www.gnu.org/licenses/>.";
#elif CONFIG_GPL
		license = "ffmpeg is free software; you can redistribute it and/or modify\nit under the terms of the GNU General Public License as published by\n"
"the Free Software Foundation; either version 2 of the License, or \n""(at your option) any later version.\n\n"
"ffmpeg is distributed in the hope that it will be useful,\nbut WITHOUT ANY WARRANTY; without even the implied warranty of\n"
			"MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\nGNU General Public License for more details.\nYou should have received a copy of the GNU General Public License\nalong with ffmpeg; if not, write to the Free Software\nFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA\n";
#elif CONFIG_LGPLV3
		license = "ffmpeg is free software; you can redistribute it and/or modify\nit under the terms of the GNU Lesser General Public License as published by\nthe Free Software Foundation; either version 3 of the License, or\n(at your option) any later version.\n\n"
			"ffmpeg is distributed in the hope that it will be useful,\nbut WITHOUT ANY WARRANTY; without even the implied warranty of\n"
			"MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\nGNU Lesser General Public License for more details.\n\n"
			"You should have received a copy of the GNU Lesser General Public License\nalong with ffmpeg.If not, see <http://www.gnu.org/licenses/>.";
#else
		license = "ffmpeg is free software; you can redistribute it and/or\nmodify it under the terms of the GNU Lesser General Public\nLicense as published by the Free Software Foundation; either\nversion 2.1 of the License, or (at your option) any later version.\n\nffmpeg is distributed in the hope that it will be useful,\n"
			"but WITHOUT ANY WARRANTY; without even the implied warranty of\nMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU\nLesser General Public License for more details.\n\nYou should have received a copy of the GNU Lesser General Public\n"
			"License along with ffmpeg; if not, write to the Free Software\nFoundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA\n";
#endif
		return getFREObjectFromString(license);
	}

	FREObject getVersion(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace boost;
		std::stringstream ss;
		ss << "ffmpeg " << std::string(FFMPEG_VERSION) << std::endl;
#if CONFIG_AVUTIL 
		ss << "libavutil " << format("%2d.%3d.%3d") % LIBAVUTIL_VERSION_MAJOR % LIBAVUTIL_VERSION_MINOR % LIBAVUTIL_VERSION_MICRO << std::endl;
#endif
#if CONFIG_AVCODEC 
		ss << "libavcodec " << format("%2d.%3d.%3d") % LIBAVCODEC_VERSION_MAJOR % LIBAVCODEC_VERSION_MINOR % LIBAVCODEC_VERSION_MICRO << std::endl;
#endif
#if CONFIG_AVFORMAT 
		ss << "libavformat " << format("%2d.%3d.%3d") % LIBAVFORMAT_VERSION_MAJOR % LIBAVFORMAT_VERSION_MINOR % LIBAVFORMAT_VERSION_MICRO << std::endl;
#endif
#if (CONFIG_AVDEVICE) 
		ss << "libavdevice " << format("%2d.%3d.%3d") % LIBAVDEVICE_VERSION_MAJOR % LIBAVDEVICE_VERSION_MINOR % LIBAVDEVICE_VERSION_MICRO << std::endl;
#endif
#if (CONFIG_AVFILTER) 
		ss << "libavfilter " << format("%2d.%3d.%3d") % LIBAVFILTER_VERSION_MAJOR % LIBAVFILTER_VERSION_MINOR % LIBAVFILTER_VERSION_MICRO << std::endl;
#endif
#if (CONFIG_AVRESAMPLE) 
		ss << "libavresample " << format("%2d.%3d.%3d") % LIBAVRESAMPLE_VERSION_MAJOR % LIBAVRESAMPLE_VERSION_MINOR % LIBAVRESAMPLE_VERSION_MICRO << std::endl;
#endif
#if (CONFIG_SWSCALE) 
		ss << "libavswscale " << format("%2d.%3d.%3d") % LIBSWSCALE_VERSION_MAJOR % LIBSWSCALE_VERSION_MINOR % LIBSWSCALE_VERSION_MICRO << std::endl;
#endif
#if (CONFIG_SWRESAMPLE) 
		ss << "libswresample " << format("%2d.%3d.%3d") % LIBSWRESAMPLE_VERSION_MAJOR % LIBSWRESAMPLE_VERSION_MINOR % LIBSWRESAMPLE_VERSION_MICRO << std::endl;
#endif
#if (CONFIG_POSTPROC) 
		ss << "libpostproc " << format("%2d.%3d.%3d") % LIBPOSTPROC_VERSION_MAJOR % LIBPOSTPROC_VERSION_MINOR % LIBPOSTPROC_VERSION_MICRO << std::endl;
#endif	
		return getFREObjectFromString(ss.str());
	}
	

	FREObject getSampleFormats(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace std;
        using namespace boost;
		FREObject vecFormats;
		
        
        FRENewObject((const uint8_t*)"Vector.<com.tuarua.ffmpeg.gets.SampleFormat>", 0, NULL, &vecFormats, NULL);
		
		int i;
		int cnt = 0;
		char fmt_str[128];
		for (i = -1; i < AV_SAMPLE_FMT_NB; i++) {
			FREObject objFormat;
			FRENewObject((const uint8_t*)"com.tuarua.ffmpeg.gets.SampleFormat", 0, NULL, &objFormat, NULL);
			FRESetArrayElementAt(vecFormats, cnt, objFormat);
			vector<string> partsList;
			string str = string(av_get_sample_fmt_string(fmt_str, sizeof(fmt_str), (AVSampleFormat)i));
			split(partsList, str, boost::is_any_of(" "));
			
			if (partsList.at(0) == "name") continue;
			cnt++;
			FRESetObjectProperty(objFormat, (const uint8_t*)"name", getFREObjectFromString(partsList.at(0)), NULL);
			for (std::vector<string>::const_iterator p = partsList.begin(); p != partsList.end(); ++p) {
				if (p->empty()) continue;
				FRESetObjectProperty(objFormat, (const uint8_t*)"depth", getFREObjectFromString(p->data()), NULL);
			}
		}
		
		return vecFormats;
	}
	


}

