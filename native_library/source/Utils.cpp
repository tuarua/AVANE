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

#include <ANEhelper.h>

ANEHelper aneHelperU = ANEHelper();

#define FRE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])

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
        {"vda", videotoolbox_init, HWACCEL_VDA, AV_PIX_FMT_VDA},
#endif
#if CONFIG_VIDEOTOOLBOX
        {"videotoolbox", videotoolbox_init, HWACCEL_VIDEOTOOLBOX, AV_PIX_FMT_VIDEOTOOLBOX},
#endif
#if CONFIG_LIBMFX
        { "qsv",   qsv_init,   HWACCEL_QSV,   AV_PIX_FMT_QSV },
#endif
        {0},
};

extern char *hex2str(const uint8_t *data, size_t len) {
    static char *str = NULL;
    size_t i;
    str = (char *) realloc(str, 2 * len + 1);
    *str = 0;
    for (i = 0; i < len; i++)
        sprintf(str + 2 * i, "%02X", data[i]);
    return str;
}


FRE_FUNCTION(getLayouts) {
    using namespace boost;
    using namespace std;

    auto objLayouts = aneHelperU.createFREObject("com.tuarua.ffmpeg.gets.Layouts");

    int i, cnt = 0;
    uint64_t layout, j;
    const char *name, *descr;

    auto vecIndividual = aneHelperU.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Layout>");
    auto vecStandard = aneHelperU.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Layout>");

    for (i = 0; i < 63; i++) {
        name = av_get_channel_name(static_cast<uint64_t>(1) << i);
        if (!name)
            continue;
        descr = av_get_channel_description(static_cast<uint64_t>(1) << i);

        auto objLayout = aneHelperU.createFREObject("com.tuarua.ffmpeg.gets.Layout");
        aneHelperU.setProperty(objLayout, "name", name);
        aneHelperU.setProperty(objLayout, "description", descr);
        FRESetArrayElementAt(vecIndividual, cnt, objLayout);
        cnt++;
    }
    aneHelperU.setProperty(objLayouts, "individual", vecIndividual);

    cnt = 0;
    for (i = 0; !av_get_standard_channel_layout(i, &layout, &name); i++) {
        if (name) {
            auto objLayout = aneHelperU.createFREObject("com.tuarua.ffmpeg.gets.Layout");
            aneHelperU.setProperty(objLayout, "name", name);
            stringstream ss;
            for (j = 1; j; j <<= 1) {
                if ((layout & j)) {
                    if (layout & (j - 1)) ss << "+";
                    ss << av_get_channel_name(j);
                }
            }
            aneHelperU.setProperty(objLayout, "description", ss.str());
            FRESetArrayElementAt(vecStandard, cnt, objLayout);
            cnt++;
        }
    }
    aneHelperU.setProperty(objLayouts, "standard", vecStandard);
    return objLayouts;
}

FRE_FUNCTION(getProtocols) {
    auto objProtocols = aneHelperU.createFREObject("com.tuarua.ffmpeg.gets.Protocols");
    auto vecInputProtocols = aneHelperU.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Protocol>");
    auto vecOutputProtocols = aneHelperU.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Protocol>");

    av_register_all();
    avformat_network_init();

    void *opaque = nullptr;
    const char *name;
    uint32_t cnt = 0;

    name = "000";
    while ((name = avio_enum_protocols(&opaque, 0))) {
        auto objProtocol = aneHelperU.createFREObject("com.tuarua.ffmpeg.gets.Protocol");
        aneHelperU.setProperty(objProtocol, "name", name);
        FRESetArrayElementAt(vecInputProtocols, cnt, objProtocol);
        cnt++;
    }
    aneHelperU.setProperty(objProtocols, "inputs", vecInputProtocols);

    cnt = 0;
    name = "000";
    while ((name = avio_enum_protocols(&opaque, 1))) {
        auto objProtocol = aneHelperU.createFREObject("com.tuarua.ffmpeg.gets.Protocol");
        aneHelperU.setProperty(objProtocol, "name", name);
        FRESetArrayElementAt(vecOutputProtocols, cnt, objProtocol);
        cnt++;
    }
    aneHelperU.setProperty(objProtocols, "outputs", vecOutputProtocols);
    avformat_network_deinit();
    return objProtocols;
}

FRE_FUNCTION(getColors) {
    using namespace boost;
    using namespace std;
    auto vecColors = aneHelperU.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Color>");

    const char *name;
    const uint8_t *rgb;
    int i;

    for (i = 0; name = av_get_known_color_name(i, &rgb); i++) {
        auto objColor = aneHelperU.createFREObject("com.tuarua.ffmpeg.gets.Color");
        aneHelperU.setProperty(objColor, "name", name);
        aneHelperU.setProperty(objColor, "value", "#" + boost::lexical_cast<string>(hex2str(rgb, sizeof(rgb) - 1)));
        FRESetArrayElementAt(vecColors, i, objColor);
    }
    return vecColors;
}

FRE_FUNCTION(getPixelFormats) {
    using namespace boost;
    using namespace std;
    FREObject vecFormats = aneHelperU.createFREObject("Vector.<com.tuarua.ffmpeg.gets.PixelFormat>");

    const AVPixFmtDescriptor *pix_desc = NULL;
#if !CONFIG_SWSCALE
#   define sws_isSupportedInput(x)  0
#   define sws_isSupportedOutput(x) 0
#endif
    int cnt = 0;
    while ((pix_desc = av_pix_fmt_desc_next(pix_desc))) {


        enum AVPixelFormat pix_fmt = av_pix_fmt_desc_get_id(pix_desc);

        auto objFormat = aneHelperU.createFREObject("com.tuarua.ffmpeg.gets.PixelFormat");
        aneHelperU.setProperty(objFormat, "name", pix_desc->name);

        aneHelperU.setProperty(objFormat, "isInput", sws_isSupportedInput(pix_fmt) == 1);
        aneHelperU.setProperty(objFormat, "isOutput", sws_isSupportedOutput(pix_fmt) == 1);

        if (pix_desc->flags & AV_PIX_FMT_FLAG_HWACCEL)
            aneHelperU.setProperty(objFormat, "isHardwareAccelerated", true);
        if (pix_desc->flags & AV_PIX_FMT_FLAG_PAL)
            aneHelperU.setProperty(objFormat, "isPalleted", true);
        if (pix_desc->flags & AV_PIX_FMT_FLAG_BITSTREAM)
            aneHelperU.setProperty(objFormat, "isBitStream", true);

        aneHelperU.setProperty(objFormat, "numComponents", pix_desc->nb_components);
        aneHelperU.setProperty(objFormat, "bitsPerPixel", av_get_bits_per_pixel(pix_desc));

        FRESetArrayElementAt(vecFormats, cnt, objFormat);

        cnt++;
    }

    return vecFormats;
}

FRE_FUNCTION(getFilters) {
    using namespace std;
    auto vecFilters = aneHelperU.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Filter>");

#if CONFIG_AVFILTER
    const AVFilter *filter = NULL;
    char descr[64], *descr_cur;
    int i, j;
    int cnt = 0;
    const AVFilterPad *pad;

    avfilter_register_all();

    while ((filter = avfilter_next(filter))) {
        auto objFilter = aneHelperU.createFREObject("com.tuarua.ffmpeg.gets.Filter");

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
            aneHelperU.setProperty(objFilter, "hasTimelineSupport", true);
        if (filter->flags & AVFILTER_FLAG_SLICE_THREADS)
            aneHelperU.setProperty(objFilter, "hasSliceThreading", true);
        if (filter->process_command)
            aneHelperU.setProperty(objFilter, "hasCommandSupport", true);

        aneHelperU.setProperty(objFilter, "name", filter->name);
        aneHelperU.setProperty(objFilter, "description", filter->description);
        aneHelperU.setProperty(objFilter, "type", descr);

        FRESetArrayElementAt(vecFilters, cnt, objFilter);
        cnt++;
    }
#endif

    return vecFilters;
}

FRE_FUNCTION(getBitStreamFilters) {
    auto vecBSFs = aneHelperU.createFREObject("Vector.<com.tuarua.ffmpeg.gets.BitStreamFilter>");

    auto len = 0;
    auto cnt = 0;
    AVBitStreamFilter *bsf = NULL;
    // ReSharper disable once CppDeprecatedEntity
    while ((bsf = av_bitstream_filter_next(bsf)))
        len++;
    FRESetArrayLength(vecBSFs, len);
    // ReSharper disable once CppDeprecatedEntity
    while ((bsf = av_bitstream_filter_next(bsf))) {
        auto objBSF = aneHelperU.createFREObject("com.tuarua.ffmpeg.gets.BitStreamFilter");
        aneHelperU.setProperty(objBSF, "name", bsf->name);
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
    return nullptr;
}
static int compare_codec_desc(const void *a, const void *b) {
    const AVCodecDescriptor *const *da = (const AVCodecDescriptor **) a;
    const AVCodecDescriptor *const *db = (const AVCodecDescriptor **) b;
    return (*da)->type != (*db)->type ? FFDIFFSIGN((*da)->type, (*db)->type) : strcmp((*da)->name, (*db)->name);
}
static unsigned get_codecs_sorted(const AVCodecDescriptor ***rcodecs) {
    const AVCodecDescriptor *desc = NULL;
    const AVCodecDescriptor **codecs;
    unsigned nb_codecs = 0, i = 0;

    while ((desc = avcodec_descriptor_next(desc)))
        nb_codecs++;
    if (!(codecs = (const AVCodecDescriptor **) (av_calloc(nb_codecs, sizeof(*codecs)))))
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
    auto vec = aneHelperU.createFREObject(encoder ? "Vector.<com.tuarua.ffmpeg.gets.Encoder>" :
            "Vector.<com.tuarua.ffmpeg.gets.Decoder>");

    const AVCodecDescriptor **codecs;
    unsigned i, nb_codecs = get_codecs_sorted(&codecs);
    FRESetArrayLength(vec, nb_codecs);
    int cnt = 0;

    avcodec_register_all();

    for (i = 0; i < nb_codecs; i++) {
        const AVCodecDescriptor *desc = codecs[i];
        const AVCodec *codec = NULL;

        while ((codec = next_codec_for_id(desc->id, codec, encoder))) {
            auto obj = aneHelperU.createFREObject(encoder ? "com.tuarua.ffmpeg.gets.Encoder" : "com.tuarua.ffmpeg.gets.Decoder");

            aneHelperU.setProperty(obj, "name", codec->name);

            if (strcmp(codec->name, desc->name))
                aneHelperU.setProperty(obj, "nameLong", string(codec->long_name) + " (codec " + string(desc->name) + ")");
            else
                aneHelperU.setProperty(obj, "nameLong", codec->long_name);
            switch (desc->type) {
                case AVMEDIA_TYPE_VIDEO:
                    aneHelperU.setProperty(obj, "isVideo", true);
                    break;
                case AVMEDIA_TYPE_AUDIO:
                    aneHelperU.setProperty(obj, "isAudio", true);
                    break;
                case AVMEDIA_TYPE_SUBTITLE:
                    aneHelperU.setProperty(obj, "isSubtitles", true);
                    break;
                default:
                    break;
            }

            if (codec->capabilities & AV_CODEC_CAP_FRAME_THREADS)
                aneHelperU.setProperty(obj, "hasFrameLevelMultiThreading", true);
            if (codec->capabilities & AV_CODEC_CAP_SLICE_THREADS)
                aneHelperU.setProperty(obj, "hasSliceLevelMultiThreading", true);
            if (codec->capabilities & AV_CODEC_CAP_EXPERIMENTAL)
                aneHelperU.setProperty(obj, "isExperimental", true);
            if (codec->capabilities & AV_CODEC_CAP_DRAW_HORIZ_BAND)
                aneHelperU.setProperty(obj, "supportsDrawHorizBand", true);
            if (codec->capabilities & AV_CODEC_CAP_DR1)
                aneHelperU.setProperty(obj, "supportsDirectRendering", true);

            FRESetArrayElementAt(vec, cnt, obj);
            cnt++;
        }
    }
    FRESetArrayLength(vec, cnt);
    av_free(codecs);

    return vec;
}

FRE_FUNCTION(getDecoders) {
    return buildEncoderDecoder(0);
}

FRE_FUNCTION(getEncoders) {
    return buildEncoderDecoder(1);
}

FRE_FUNCTION(getCodecs) {
    using namespace std;
    auto vecCodecs = aneHelperU.createFREObject("Vector.<com.tuarua.ffmpeg.gets.Codec>");
    const AVCodecDescriptor **codecs;
    unsigned i, nb_codecs = get_codecs_sorted(&codecs);
    FRESetArrayLength(vecCodecs, nb_codecs);

    avcodec_register_all();

    for (i = 0; i < nb_codecs; i++) {
        const AVCodecDescriptor *desc = codecs[i];

        if (strstr(desc->name, "_deprecated"))
            continue;

        auto objCodec = aneHelperU.createFREObject("com.tuarua.ffmpeg.gets.Codec");
        aneHelperU.setProperty(objCodec, "name", desc->name);
        aneHelperU.setProperty(objCodec, "nameLong", desc->long_name);


        if (avcodec_find_decoder(desc->id))
            aneHelperU.setProperty(objCodec, "hasDecoder", true);
        if (avcodec_find_encoder(desc->id))
            aneHelperU.setProperty(objCodec, "hasEncoder", true);
        switch (desc->type) {
            case AVMEDIA_TYPE_VIDEO:
                aneHelperU.setProperty(objCodec, "isVideo", true);
                break;
            case AVMEDIA_TYPE_AUDIO:
                aneHelperU.setProperty(objCodec, "isAudio", true);
                break;
            case AVMEDIA_TYPE_SUBTITLE:
                aneHelperU.setProperty(objCodec, "isSubtitles", true);
                break;
            default:
                break;
        }

        if ((desc->props & AV_CODEC_PROP_LOSSY))
            aneHelperU.setProperty(objCodec, "isLossy", true);
        if ((desc->props & AV_CODEC_PROP_LOSSLESS))
            aneHelperU.setProperty(objCodec, "isLossless", true);
        if ((desc->props & AV_CODEC_PROP_INTRA_ONLY))
            aneHelperU.setProperty(objCodec, "isIntraFrameOnly", true);

        FRESetArrayElementAt(vecCodecs, i, objCodec);

    }

    av_free(codecs);

    return vecCodecs;
}

FRE_FUNCTION(getHardwareAccelerations) {
    auto vecHWAccels = aneHelperU.createFREObject("Vector.<com.tuarua.ffmpeg.gets.HardwareAcceleration>");

    int numHWAccels = FF_ARRAY_ELEMS(hwaccels_) - 1;
    FRESetArrayLength(vecHWAccels, numHWAccels);
    for (uint32_t i = 0; i < numHWAccels; i++) {

        auto objHW = aneHelperU.createFREObject("com.tuarua.ffmpeg.gets.HardwareAcceleration");
        aneHelperU.setProperty(objHW, "name", hwaccels_[i].name);
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

    auto vecFormats = aneHelperU.createFREObject(device_only ? "Vector.<com.tuarua.ffmpeg.gets.Device>" :
            "Vector.<com.tuarua.ffmpeg.gets.AvailableFormat>");

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

        auto objFormat = aneHelperU.createFREObject(device_only ? "com.tuarua.ffmpeg.gets.Device" :
                "com.tuarua.ffmpeg.gets.AvailableFormat");

        aneHelperU.setProperty(objFormat, "name", name);
        aneHelperU.setProperty(objFormat, "nameLong", long_name ? long_name : name);
        aneHelperU.setProperty(objFormat, "demuxing", decode == 1);
        aneHelperU.setProperty(objFormat, "muxing", encode == 1);

        FRESetArrayElementAt(vecFormats, cnt, objFormat);

        cnt++;
    }
    avformat_network_deinit();
    return vecFormats;
}

FRE_FUNCTION(getDevices) {
#if CONFIG_AVDEVICE
    avdevice_register_all();
#endif
    return getAvailableFormatsDevices(1);
}

FRE_FUNCTION(getAvailableFormats) {
    return getAvailableFormatsDevices(0);
}

FRE_FUNCTION(getBuildConfiguration) {
    return aneHelperU.getFREObject(FFMPEG_CONFIGURATION);
}

FRE_FUNCTION(getLicense) {
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
    return aneHelperU.getFREObject(license);
}

FRE_FUNCTION(getVersion) {
    using namespace boost;
    std::stringstream ss;
    ss << "ffmpeg " << std::string(FFMPEG_VERSION) << std::endl;
#if CONFIG_AVUTIL
    ss << "libavutil "
       << format("%2d.%3d.%3d") % LIBAVUTIL_VERSION_MAJOR % LIBAVUTIL_VERSION_MINOR % LIBAVUTIL_VERSION_MICRO
       << std::endl;
#endif
#if CONFIG_AVCODEC
    ss << "libavcodec "
       << format("%2d.%3d.%3d") % LIBAVCODEC_VERSION_MAJOR % LIBAVCODEC_VERSION_MINOR % LIBAVCODEC_VERSION_MICRO
       << std::endl;
#endif
#if CONFIG_AVFORMAT
    ss << "libavformat "
       << format("%2d.%3d.%3d") % LIBAVFORMAT_VERSION_MAJOR % LIBAVFORMAT_VERSION_MINOR % LIBAVFORMAT_VERSION_MICRO
       << std::endl;
#endif
#if (CONFIG_AVDEVICE)
    ss << "libavdevice "
       << format("%2d.%3d.%3d") % LIBAVDEVICE_VERSION_MAJOR % LIBAVDEVICE_VERSION_MINOR % LIBAVDEVICE_VERSION_MICRO
       << std::endl;
#endif
#if (CONFIG_AVFILTER)
    ss << "libavfilter "
       << format("%2d.%3d.%3d") % LIBAVFILTER_VERSION_MAJOR % LIBAVFILTER_VERSION_MINOR % LIBAVFILTER_VERSION_MICRO
       << std::endl;
#endif
#if (CONFIG_AVRESAMPLE)
    ss << "libavresample " << format("%2d.%3d.%3d") % LIBAVRESAMPLE_VERSION_MAJOR % LIBAVRESAMPLE_VERSION_MINOR % LIBAVRESAMPLE_VERSION_MICRO << std::endl;
#endif
#if (CONFIG_SWSCALE)
    ss << "libavswscale "
       << format("%2d.%3d.%3d") % LIBSWSCALE_VERSION_MAJOR % LIBSWSCALE_VERSION_MINOR % LIBSWSCALE_VERSION_MICRO
       << std::endl;
#endif
#if (CONFIG_SWRESAMPLE)
    ss << "libswresample "
       << format("%2d.%3d.%3d") % LIBSWRESAMPLE_VERSION_MAJOR % LIBSWRESAMPLE_VERSION_MINOR % LIBSWRESAMPLE_VERSION_MICRO
       << std::endl;
#endif
#if (CONFIG_POSTPROC)
    ss << "libpostproc "
       << format("%2d.%3d.%3d") % LIBPOSTPROC_VERSION_MAJOR % LIBPOSTPROC_VERSION_MINOR % LIBPOSTPROC_VERSION_MICRO
       << std::endl;
#endif
    return aneHelperU.getFREObject(ss.str());
}

FRE_FUNCTION(getSampleFormats) {
    using namespace std;
    using namespace boost;

    auto vecFormats = aneHelperU.createFREObject("Vector.<com.tuarua.ffmpeg.gets.SampleFormat>");

    int i;
    uint32_t cnt = 0;
    char fmt_str[128];
    for (i = -1; i < AV_SAMPLE_FMT_NB; i++) {
        auto objFormat = aneHelperU.createFREObject("com.tuarua.ffmpeg.gets.SampleFormat");

        FRESetArrayElementAt(vecFormats, cnt, objFormat);
        vector<string> partsList;
        auto str = string(av_get_sample_fmt_string(fmt_str, sizeof(fmt_str), static_cast<AVSampleFormat>(i)));
        split(partsList, str, is_any_of(" "));

        if (partsList.at(0) == "name") continue;
        cnt++;
        aneHelperU.setProperty(objFormat, "name", partsList.at(0));
        for (auto p = partsList.begin(); p != partsList.end(); ++p) {
            if (p->empty()) continue;
            aneHelperU.setProperty(objFormat, "depth", p->data());
        }
    }

    return vecFormats;
}


}

