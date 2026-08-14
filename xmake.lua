set_toolchains("msvc")
set_runtimes("MD")
set_config("sdk", path.join(os.scriptdir(),[[in\msvc]]))
-- set_config("vs_toolset", "14.44.35207")
-- set_config("vs_sdkver", "10.0.22621.0")
set_config("vs_toolset", "14.50.35717")
set_config("vs_sdkver", "10.0.28000.0")

set_config("builddir", "out")

task("prepare")
    set_menu({ usage = "xmake prepare" })
    on_run(function()
        os.run("curl.exe -OJLs --skip-existing %s",
            "https://github.com/mefistofelix/hx/releases/latest/download/hx.exe")
        os.run("hx %s",
            "https://github.com/mefistofelix/msvcup/releases/latest/download/msvcup.exe")
        os.run("hx -delpathseg 1 %s in/php-sdk",
            "github://php/php-sdk-binary-tools")
        os.run("hx %s in/perl",
            "https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases/download/SP_54221_64bit/strawberry-perl-5.42.2.1-64bit-portable.zip")

        os.run("hx github://true-async/php-src?ref=true-async-stable in/php-src")
        os.run("hx github://true-async/php-async in/php-src/ext/async")
        os.run("hx github://true-async/server in/php-src/ext/http_server")

        os.run("hx github://madler/zlib?ref=v1.3.2 in/deps/zlib")
        os.run("hx github://google/brotli?ref=v1.2.0 in/deps/brotli")
        os.run("hx github://facebook/zstd?ref=v1.5.7 in/deps/zstd")
        os.run("hx -delpathseg 1 https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz in/deps/bzip2")
        os.run("hx github://tukaani-project/xz?ref=v5.8.3 in/deps/xz")
        os.run("hx github://nghttp2/nghttp2?ref=v1.69.0 in/deps/nghttp2")
        os.run("hx github://libssh2/libssh2?ref=libssh2-1.11.1 in/deps/libssh2")
        os.run("hx github://ngtcp2/ngtcp2?ref=v1.25.0 in/deps/ngtcp2")
        os.run("hx --recursive github://ngtcp2/nghttp3?ref=dbfc24286138cb0b6490160e7ca87fe1ce6722a0 in/deps/nghttp3")
        os.run("hx github://openssl/openssl?ref=openssl-3.5.7 in/deps/openssl")
        os.run("hx github://curl/curl?ref=curl-8_21_0 in/deps/libcurl")
        os.run("hx github://jedisct1/libsodium?ref=1.0.22 in/deps/libsodium")
        os.run("hx github://libuv/libuv?ref=v1.52.1 in/deps/libuv")
        os.run("hx -delpathseg 1 https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.19.tar.gz in/deps/libiconv")

        local bp = "https://downloads.php.net/~windows/php-sdk/deps/vs18/x64"
        os.run("hx github://unicode-org/icu?ref=release-77-1 in/deps/ICU")
        os.run("hx -repath icudt77l.dat https://github.com/unicode-org/icu/releases/download/release-77-1/icu4c-77_1-data-bin-l.zip in/deps/ICU/icu4c/source/data/in")
        os.run("hx -repath genccode.exe,icutu77.dll,icuuc77.dll,icuin77.dll,icudt77.dll https://github.com/unicode-org/icu/releases/download/release-77-1/icu4c-77_1-Win64-MSVC2022.zip in/tools/icu")
        os.run("hx %s/apache-2.4.68-vs18-x64.zip in/deps/apache",bp)
        os.run("hx github://freetype/freetype?ref=VER-2-14-3 in/deps/freetype")
        os.run("hx %s/glib-2.88.1-1-vs18-x64.zip in/deps/glib",bp)
        os.run("hx %s/libargon2-20190702-vs18-x64.zip in/deps/libargon2",bp)
        os.run("hx github://AOMediaCodec/libavif?ref=v1.4.2 in/deps/libavif")
        os.run("hx https://aomedia.googlesource.com/aom/+archive/refs/tags/v3.14.1.tar.gz in/deps/aom")
        os.run("hx https://chromium.googlesource.com/libyuv/libyuv/+archive/644251f252a84bf8ce91ff0aca86a9b16b069ab8.tar.gz in/deps/libyuv")
        os.run("hx %s/libenchant2-2.8.16-1-vs18-x64.zip in/deps/libenchant2",bp)
        os.run("hx %s/libffi-3.6.0-vs18-x64.zip in/deps/libffi",bp)
        os.run("hx %s/libheif-1.23.1-vs18-x64.zip in/deps/libheif",bp)
        os.run("hx -delpathseg 1 https://ftp.gnu.org/pub/gnu/gettext/gettext-1.0.tar.gz in/deps/libintl")
        os.run("hx github://libjpeg-turbo/libjpeg-turbo?ref=3.1.4.1 in/deps/libjpeg-turbo")
        os.run("hx %s/libjxl-0.11.2-vs18-x64.zip in/deps/libjxl",bp)
        os.run("hx github://kkos/oniguruma?ref=v6.9.10 in/deps/libonig")
        os.run("hx github://pnggroup/libpng?ref=v1.6.58 in/deps/libpng")
        os.run("hx github://postgres/postgres?ref=REL_16_14 in/deps/libpq")
        os.run("hx github://cyrusimap/cyrus-sasl?ref=cyrus-sasl-2.1.28 in/deps/libsasl")
        os.run("hx %s/libtidy-5.8.0-vs18-x64.zip in/deps/libtidy",bp)
        os.run("hx https://download.osgeo.org/libtiff/tiff-4.7.2.tar.xz in/deps/libtiff")
        os.run("hx %s/libultrahdr-1.4.0-1-vs18-x64.zip in/deps/libultrahdr",bp)
        os.run("hx github://webmproject/libwebp?ref=v1.6.0 in/deps/libwebp")
        os.run("hx github://winlibs/libxml2?ref=libxml2-2.11.9-7 in/deps/libxml2")
        os.run("hx github://winlibs/libxslt?ref=libxslt-1.1.43-2 in/deps/libxslt")
        os.run("hx %s/libzip-1.11.4-vs18-x64.zip in/deps/libzip",bp)
        os.run("hx %s/mpir-3.0.0-2-vs18-x64.zip in/deps/mpir",bp) --xmiss
        os.run("hx %s/net-snmp-5.9.4-vs18-x64.zip in/deps/net-snmp",bp) -- xmiss
        os.run("hx -delpathseg 1 https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.6.13.tgz in/deps/openldap")
        os.run("hx github://garyhouston/rxspencer?ref=v3.9.0 in/deps/rxspencer")
        os.run("hx -delpathseg 1 https://www.sqlite.org/2026/sqlite-amalgamation-3530200.zip in/deps/sqlite3")
        os.run("hx %s/wineditline-2.208-vs18-x64.zip in/deps/wineditline", bp)

        os.run([[msvcup install "msvc sdk" in/msvc]])
    end)

target("minilua")
    set_enabled(false)
    set_kind("binary")
    set_targetdir(get_config("builddir"))
    add_files("in/php-src/ext/opcache/jit/ir/dynasm/minilua.c")

target("gen_ir_fold_hash")
    set_enabled(false)
    set_kind("binary")
    set_targetdir(get_config("builddir"))
    add_files("in/php-src/ext/opcache/jit/ir/gen_ir_fold_hash.c")
    add_defines("IR_TARGET_X86_64")

target("zlib")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    add_includedirs("in/deps/zlib", {public = true})
    add_defines("ZLIB_BUILD", "NO_FSEEKO", "_CRT_SECURE_NO_DEPRECATE", "_CRT_NONSTDC_NO_DEPRECATE")
    add_rules("c.unity_build")
    add_files("in/deps/zlib/*.c")
    add_files("in/deps/zlib/gz*.c", "in/deps/zlib/inf*.c", "in/deps/zlib/zutil.c", {unity_ignored = true})

target("brotli")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    add_includedirs("in/deps/brotli/c/include", {public = true})
    add_defines("_CRT_SECURE_NO_WARNINGS")
    add_rules("c.unity_build")
    add_files("in/deps/brotli/c/common/*.c", "in/deps/brotli/c/dec/*.c", "in/deps/brotli/c/enc/*.c")
    add_files("in/deps/brotli/c/enc/compress_fragment_two_pass.c",
        "in/deps/brotli/c/enc/entropy_encode.c", {unity_group = "secondary"})
    add_files("in/deps/brotli/c/enc/static_dict.c", {unity_ignored = true})

target("zstd")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    add_includedirs("in/deps/zstd/lib", {public = true})
    add_defines("ZSTD_MULTITHREAD", "ZSTD_LEGACY_SUPPORT=5", "ZSTD_DISABLE_ASM", "ZSTD_HEAPMODE=0", "_CRT_SECURE_NO_WARNINGS")
    add_rules("c.unity_build")
    add_files("in/deps/zstd/lib/common/*.c", "in/deps/zstd/lib/compress/*.c",
        "in/deps/zstd/lib/decompress/*.c", "in/deps/zstd/lib/dictBuilder/*.c", "in/deps/zstd/lib/legacy/*.c")
    add_files("in/deps/zstd/lib/dictBuilder/fastcover.c", {unity_ignored = true})
    add_files("in/deps/zstd/lib/legacy/*.c", {unity_ignored = true})

target("bzip2")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_includedirs("in/deps/bzip2", {public = true})
    add_defines("WIN32", "_FILE_OFFSET_BITS=64")
    add_rules("c.unity_build")
    add_files("in/deps/bzip2/*.c")
    remove_files("in/deps/bzip2/bzip2*.c", "in/deps/bzip2/dlltest.c", "in/deps/bzip2/mk251.c",
        "in/deps/bzip2/spewG.c", "in/deps/bzip2/unzcrash.c")

target("liblzma")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_includedirs("in/deps/xz/src/liblzma/api", {public = true})
    add_includedirs("in/deps/xz/src/liblzma/common", "in/deps/xz/src/liblzma/check",
        "in/deps/xz/src/liblzma/lz", "in/deps/xz/src/liblzma/rangecoder",
        "in/deps/xz/src/liblzma/lzma", "in/deps/xz/src/liblzma/delta",
        "in/deps/xz/src/liblzma/simple", "in/deps/xz/src/common")
    add_defines("LZMA_API_STATIC", {public = true})
    add_defines("HAVE_STDBOOL_H", "HAVE__BOOL", "HAVE_STDINT_H", "HAVE_INTTYPES_H",
        "HAVE_CHECK_CRC32", "HAVE_CHECK_CRC64", "HAVE_CHECK_SHA256", "MYTHREAD_VISTA",
        "TUKLIB_SYMBOL_PREFIX=lzma_", "TUKLIB_FAST_UNALIGNED_ACCESS", "HAVE_IMMINTRIN_H",
        "HAVE__MM_MOVEMASK_EPI8", "HAVE_USABLE_CLMUL", "HAVE_VISIBILITY=0",
        "HAVE_MF_HC3", "HAVE_MF_HC4", "HAVE_MF_BT2", "HAVE_MF_BT3", "HAVE_MF_BT4",
        "HAVE_ENCODERS", "HAVE_DECODERS", "HAVE_LZIP_DECODER",
        "HAVE_ENCODER_LZMA1", "HAVE_ENCODER_LZMA2", "HAVE_ENCODER_DELTA",
        "HAVE_ENCODER_X86", "HAVE_ENCODER_ARM", "HAVE_ENCODER_ARMTHUMB", "HAVE_ENCODER_ARM64",
        "HAVE_ENCODER_POWERPC", "HAVE_ENCODER_IA64", "HAVE_ENCODER_SPARC", "HAVE_ENCODER_RISCV",
        "HAVE_DECODER_LZMA1", "HAVE_DECODER_LZMA2", "HAVE_DECODER_DELTA",
        "HAVE_DECODER_X86", "HAVE_DECODER_ARM", "HAVE_DECODER_ARMTHUMB", "HAVE_DECODER_ARM64",
        "HAVE_DECODER_POWERPC", "HAVE_DECODER_IA64", "HAVE_DECODER_SPARC", "HAVE_DECODER_RISCV")
    add_rules("c.unity_build")
    add_files("in/deps/xz/src/common/tuklib_cpucores.c", "in/deps/xz/src/common/tuklib_physmem.c")
    add_files("in/deps/xz/src/liblzma/common/*.c", "in/deps/xz/src/liblzma/delta/*.c",
        "in/deps/xz/src/liblzma/lz/*.c", "in/deps/xz/src/liblzma/simple/*.c")
    add_files("in/deps/xz/src/liblzma/check/check.c", "in/deps/xz/src/liblzma/check/crc32_fast.c",
        "in/deps/xz/src/liblzma/check/crc64_fast.c", "in/deps/xz/src/liblzma/check/sha256.c")
    add_files("in/deps/xz/src/liblzma/lzma/*.c|*tablegen.c",
        "in/deps/xz/src/liblzma/rangecoder/price_table.c")
    add_files("in/deps/xz/src/common/tuklib_physmem.c", "in/deps/xz/src/liblzma/check/crc64_fast.c",
        "in/deps/xz/src/liblzma/common/block_encoder.c", "in/deps/xz/src/liblzma/common/filter_encoder.c",
        "in/deps/xz/src/liblzma/common/microlzma_encoder.c",
        "in/deps/xz/src/liblzma/common/stream_buffer_encoder.c",
        "in/deps/xz/src/liblzma/common/stream_decoder_mt.c",
        "in/deps/xz/src/liblzma/delta/delta_decoder.c", "in/deps/xz/src/liblzma/lz/lz_encoder.c",
        "in/deps/xz/src/liblzma/lzma/lzma2_encoder.c", {unity_group = "conflict_1"})
    add_files("in/deps/xz/src/liblzma/common/alone_decoder.c",
        "in/deps/xz/src/liblzma/common/index_hash.c",
        "in/deps/xz/src/liblzma/common/stream_decoder.c",
        "in/deps/xz/src/liblzma/lzma/lzma_decoder.c", {unity_group = "conflict_2"})
    add_files("in/deps/xz/src/liblzma/common/auto_decoder.c",
        "in/deps/xz/src/liblzma/common/index_decoder.c",
        "in/deps/xz/src/liblzma/common/stream_encoder.c", {unity_group = "conflict_3"})
    add_files("in/deps/xz/src/liblzma/common/alone_encoder.c",
        "in/deps/xz/src/liblzma/common/index_encoder.c",
        "in/deps/xz/src/liblzma/lz/lz_encoder_mf.c",
        "in/deps/xz/src/liblzma/lzma/lzma_encoder*.c", {unity_group = "conflict_4"})

target("libssh2")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_includedirs("in/deps/libssh2/include", {public = true})
    add_includedirs(
        "in/deps/libssh2/src",
        "in/deps/openssl/include"
    )
    add_defines("LIBSSH2_OPENSSL")
    add_syslinks("ws2_32", "crypt32", "bcrypt", {public = true})
    add_files("in/deps/libssh2/src/*.c")
    remove_files(
        "in/deps/libssh2/src/agent_win.c",
        "in/deps/libssh2/src/blowfish.c",
        "in/deps/libssh2/src/libgcrypt.c",
        "in/deps/libssh2/src/mbedtls.c",
        "in/deps/libssh2/src/openssl.c",
        "in/deps/libssh2/src/os400qc3.c",
        "in/deps/libssh2/src/wincng.c"
    )

target("nghttp2")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    on_prepare(function ()
        io.writefile(
            "in/deps/nghttp2/lib/includes/nghttp2/nghttp2ver.h",
            (io.readfile("in/deps/nghttp2/lib/includes/nghttp2/nghttp2ver.h.in")
                :gsub("@PACKAGE_VERSION@", "1.69.0")
                :gsub("@PACKAGE_VERSION_NUM@", "0x014500"))
        )
    end)
    add_includedirs("in/deps/nghttp2/lib/includes", {public = true})
    add_defines("NGHTTP2_STATICLIB", {public = true})
    add_defines(
        "BUILDING_NGHTTP2",
        "HAVE_GETTICKCOUNT64",
        "HAVE_WINDOWS_H",
        "ssize_t=int"
    )
    add_files("in/deps/nghttp2/lib/*.c")

target("nghttp3")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    set_languages("c11")
    on_prepare(function ()
        io.writefile(
            "in/deps/nghttp3/lib/includes/nghttp3/version.h",
            (io.readfile("in/deps/nghttp3/lib/includes/nghttp3/version.h.in")
                :gsub("@PACKAGE_VERSION@", "1.18.0")
                :gsub("@PACKAGE_VERSION_NUM@", "0x011200"))
        )
    end)
    add_includedirs("in/deps/nghttp3/lib/includes", {public = true})
    add_defines("NGHTTP3_STATICLIB", {public = true})
    add_defines("BUILDING_NGHTTP3")
    add_files(
        "in/deps/nghttp3/lib/*.c",
        "in/deps/nghttp3/lib/sfparse/sfparse.c"
    )

target("ngtcp2")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    set_languages("c11")
    on_prepare(function ()
        io.writefile(
            "in/deps/ngtcp2/lib/includes/ngtcp2/version.h",
            (io.readfile("in/deps/ngtcp2/lib/includes/ngtcp2/version.h.in")
                :gsub("@PACKAGE_VERSION@", "1.25.0")
                :gsub("@PACKAGE_VERSION_NUM@", "0x011900"))
        )
    end)
    add_includedirs("in/deps/ngtcp2/lib/includes", {public = true})
    add_defines("NGTCP2_STATICLIB", {public = true})
    add_defines("BUILDING_NGTCP2")
    add_files("in/deps/ngtcp2/lib/*.c")

target("ngtcp2_crypto_ossl")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    set_languages("c11")
    add_deps("ngtcp2", "openssl")
    add_includedirs(
        "in/deps/ngtcp2/crypto/includes",
        "in/deps/openssl/include",
        {public = true}
    )
    add_includedirs(
        "in/deps/ngtcp2/crypto",
        "in/deps/ngtcp2/lib"
    )
    add_defines("NGTCP2_STATICLIB", {public = true})
    add_defines("BUILDING_NGTCP2")
    add_syslinks(
        "ws2_32",
        "gdi32",
        "advapi32",
        "crypt32",
        "user32",
        "bcrypt",
        {public = true}
    )
    add_files(
        "in/deps/ngtcp2/crypto/ossl/ossl.c",
        "in/deps/ngtcp2/crypto/shared.c"
    )

target("libcurl")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_deps(
        "brotli",
        "libssh2",
        "nghttp2",
        "openssl",
        "zlib",
        "zstd"
    )
    add_includedirs("in/deps/libcurl/include", {public = true})
    add_includedirs(
        "in/deps/libcurl/lib",
        "in/deps/openssl/include"
    )
    add_defines("CURL_STATICLIB", {public = true})
    add_defines(
        "BUILDING_LIBCURL",
        "HAVE_BROTLI",
        "HAVE_LIBZ",
        "HAVE_ZSTD",
        "USE_IPV6",
        "USE_LIBSSH2",
        "USE_NGHTTP2",
        "USE_OPENSSL",
        "USE_WIN32_IDN"
    )
    add_syslinks(
        "advapi32",
        "bcrypt",
        "crypt32",
        "iphlpapi",
        "normaliz",
        "winmm",
        "wldap32",
        "ws2_32",
        {public = true}
    )
    add_files(
        "in/deps/libcurl/lib/*.c",
        "in/deps/libcurl/lib/**/*.c"
    )
    remove_files("in/deps/libcurl/lib/dllmain.c")

target("libsodium")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    on_prepare(function ()
        os.cp(
            "in/deps/libsodium/builds/msvc/version.h",
            "in/deps/libsodium/src/libsodium/include/sodium/version.h"
        )
    end)
    add_includedirs("in/deps/libsodium/src/libsodium/include", {public = true})
    add_includedirs("in/deps/libsodium/src/libsodium/include/sodium")
    add_defines("SODIUM_STATIC", {public = true})
    add_defines(
        "NATIVE_LITTLE_ENDIAN",
        "NDEBUG",
        "UNICODE",
        "WIN32",
        "WIN64",
        "_CRT_SECURE_NO_WARNINGS",
        "_LIB",
        "_UNICODE",
        "inline=__inline"
    )
    add_cflags("/UndefIntOverflow-", {force = true})
    add_syslinks("advapi32", {public = true})
    add_files("in/deps/libsodium/src/libsodium/**/*.c")

target("libuv")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_includedirs("in/deps/libuv/include", {public = true})
    add_includedirs("in/deps/libuv/src")
    add_defines(
        "WIN32_LEAN_AND_MEAN",
        "_CRT_DECLARE_NONSTDC_NAMES=0",
        "_WIN32_WINNT=0x0A00"
    )
    add_cflags("/we4013", {force = true})
    add_syslinks(
        "psapi",
        "user32",
        "advapi32",
        "iphlpapi",
        "userenv",
        "ws2_32",
        "dbghelp",
        "ole32",
        "shell32",
        {public = true}
    )
    add_files(
        "in/deps/libuv/src/*.c",
        "in/deps/libuv/src/win/*.c"
    )

target("icu")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    set_languages("cxx17")
    set_exceptions("no-cxx")
    on_prepare(function ()
        os.vrunv("$(projectdir)/in/tools/icu/genccode.exe", {
            "-q", "-o", "--skip-dll-export", "-e", "icudt77",
            "-d", "in/deps/ICU/icu4c/source/data/in",
            "in/deps/ICU/icu4c/source/data/in/icudt77l.dat"
        })
    end)
    add_includedirs(
        "in/deps/ICU/icu4c/source/common",
        "in/deps/ICU/icu4c/source/i18n",
        {public = true}
    )
    add_defines("U_STATIC_IMPLEMENTATION", {public = true})
    add_defines(
        "NDEBUG",
        "U_ATTRIBUTE_DEPRECATED=",
        "WIN32",
        "WIN64",
        "WINVER=0x0601",
        "_CRT_SECURE_NO_DEPRECATE",
        "_HAS_EXCEPTIONS=0",
        "_WIN32_WINNT=0x0601"
    )
    add_cxxflags("/utf-8", {force = true})
    add_syslinks("advapi32", {public = true})
    add_files("in/deps/ICU/icu4c/source/common/*.cpp", {
        defines = {"U_COMMON_IMPLEMENTATION", "U_PLATFORM_USES_ONLY_WIN32_API=1"}
    })
    add_files("in/deps/ICU/icu4c/source/i18n/*.cpp", {
        defines = {"U_I18N_IMPLEMENTATION"}
    })
    add_files("in/deps/ICU/icu4c/source/data/in/icudt77l_dat.obj", {always_added = true})

target("libiconv")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    on_prepare(function ()
        io.writefile("in/deps/libiconv/lib/config.h", [[
            #define ENABLE_EXTRA 0
            #define HAVE_LANGINFO_CODESET 0
            #define HAVE_MBRTOWC 1
            #define HAVE_MBSINIT 1
            #define HAVE_WCRTOMB 1
            #define ICONV_CONST
            #define WORDS_LITTLEENDIAN 1
        ]])
        io.writefile(
            "in/deps/libiconv/include/iconv.h",
            (io.readfile("in/deps/libiconv/include/iconv.h.build.in")
                :gsub("@HAVE_VISIBILITY@", "0")
                :gsub("@DLL_VARIABLE@", "")
                :gsub("@EILSEQ@", "")
                :gsub("@ICONV_CONST@", "")
                :gsub("@USE_MBSTATE_T@", "1")
                :gsub("@BROKEN_WCHAR_H@", "0"))
        )
        io.writefile(
            "in/deps/libiconv/libcharset/include/localcharset.h",
            (io.readfile("in/deps/libiconv/libcharset/include/localcharset.h.build.in")
                :gsub("@HAVE_VISIBILITY@", "0"))
        )
    end)
    add_includedirs("in/deps/libiconv/include", {public = true})
    add_includedirs(
        "in/deps/libiconv/lib",
        "in/deps/libiconv/libcharset/include"
    )
    add_defines(
        "BUILDING_LIBCHARSET",
        "BUILDING_LIBICONV"
    )
    add_files(
        "in/deps/libiconv/lib/iconv.c",
        "in/deps/libiconv/libcharset/lib/localcharset.c",
        "in/deps/libiconv/lib/compat.c"
    )

target("libintl")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    on_prepare(function ()
        local function render_template(input, replacements, ones, fallback)
            local text = io.readfile(input)
            for i = 1, #(replacements or {}), 2 do text = text:gsub(replacements[i], replacements[i + 1]) end
            for name in (ones or ""):gmatch("%S+") do text = text:gsub("@" .. name .. "@", "1") end
            if fallback ~= nil then text = text:gsub("@[^@\r\n]+@", fallback) end
            return text
        end

        local intl = "in/deps/libintl/gettext-runtime/intl"
        local gnulib = intl .. "/gnulib-lib"
        local prelude = "#include \"c++defs.h\"\n#include \"arg-nonnull.h\"\n#include \"warn-on-use.h\"\n"
        local function ucrt(name)
            return path.absolute(path.join(get_config("sdk"), "Windows Kits", "10", "Include", get_config("vs_sdkver"), "ucrt", name)):gsub("\\", "/")
        end
        local function header(name, replacements, ones, prefix, fallback)
            local common = {"@GUARD_PREFIX@", "GL", "@PRAGMA_SYSTEM_HEADER@", "", "@PRAGMA_COLUMNS@", ""}
            for _, value in ipairs(replacements or {}) do common[#common + 1] = value end
            io.writefile(gnulib .. "/" .. name .. ".h",
                (prefix or "") .. render_template(gnulib .. "/" .. name .. ".in.h", common, ones, fallback or "0"))
        end
        local function next_header(name, ones, prefix, native)
            local next_h = "@NEXT_" .. name:upper() .. "_H@"
            local replacements = native and {"@INCLUDE_NEXT@", "include", next_h, "\"" .. ucrt(name .. ".h") .. "\""}
                or {"@INCLUDE_NEXT@ " .. next_h, "include <" .. name .. ".h>"}
            header(name, replacements, ones, prefix)
        end

        local config = io.readfile(intl .. "/config.h.in")
        for name in ("ENABLE_NLS FLEXIBLE_ARRAY_MEMBER HAVE_ICONV HAVE_MBRTOWC HAVE_STDBOOL_H HAVE_STDINT_H_WITH_UINTMAX HAVE_STDINT_H HAVE_WCRTOMB HAVE_WINT_T USE_WINDOWS_THREADS"):gmatch("%S+") do
            config = config:gsub("#undef " .. name .. "([%c])", "#define " .. name .. " 1%1")
        end
        config = config:gsub("#undef ICONV_CONST", "#define ICONV_CONST")
        for name in ("mbrtowc mbsinit tdelete tfind tsearch twalk"):gmatch("%S+") do config = config:gsub("#undef rpl_" .. name, "#define rpl_" .. name .. " _libintl_" .. name) end
        for name in ("tdelete tfind tsearch twalk"):gmatch("%S+") do config = config:gsub("#undef " .. name, "#define " .. name .. " _libintl_" .. name) end
        io.writefile(intl .. "/config.h", config)

        local public = render_template(intl .. "/libgnuintl.in.h", nil, nil, "0")
        io.writefile(intl .. "/libgnuintl.h", public)
        io.writefile(intl .. "/libintl.h", public)

        next_header("search", "GNULIB_TSEARCH", prelude)
        next_header("unistd", "GNULIB_GETCWD REPLACE_GETCWD", prelude)
        next_header("locale", "HAVE_WINDOWS_LOCALE_T GNULIB_LOCALECONV GNULIB_SETLOCALE_NULL GNULIB_GETLOCALENAME_L_UNSAFE GNULIB_LOCALENAME_UNSAFE", prelude, true)
        next_header("float", nil, nil, true)
        header("alloca")
        next_header("string", "GNULIB_STRINGEQ", prelude, true)
        next_header("stdckdint")
        next_header("sched", nil, "#include \"c++defs.h\"\n#include \"warn-on-use.h\"\n")
        next_header("pthread", "GNULIB_PTHREAD_ONCE REPLACE_PTHREAD_ONCE", prelude)
        next_header("wchar", "HAVE_WCHAR_H GNULIB_MBSINIT GNULIB_MBSZERO GNULIB_MBRTOWC GNULIB_WCWIDTH GNULIB_WGETCWD GNULIB_FREE_POSIX HAVE_WINT_T HAVE_MBSINIT HAVE_MBRTOWC HAVE_WCRTOMB REPLACE_MBSINIT REPLACE_MBRTOWC", prelude, true)
        next_header("uchar", "HAVE_UCHAR_H CXX_HAVE_UCHAR_H CXX_HAS_UCHAR_TYPES SMALL_WCHAR_T GNULIB_C32ISALNUM GNULIB_C32ISALPHA GNULIB_C32ISBLANK GNULIB_C32ISCNTRL GNULIB_C32ISDIGIT GNULIB_C32ISGRAPH GNULIB_C32ISLOWER GNULIB_C32ISPRINT GNULIB_C32ISPUNCT GNULIB_C32ISSPACE GNULIB_C32ISUPPER GNULIB_C32ISXDIGIT GNULIB_C32TOLOWER GNULIB_C32WIDTH GNULIB_MBRTOC32 HAVE_MBRTOC32 REPLACE_MBRTOC32", prelude, true)

        for _, name in ipairs({"unicase", "unictype", "uninorm"}) do
            io.writefile(gnulib .. "/" .. name .. ".h", render_template(gnulib .. "/" .. name .. ".in.h", {"@HAVE_UNISTRING_WOE32DLL_H@", "0"}, nil, ""))
        end
        os.cp(gnulib .. "/unitypes.in.h", gnulib .. "/unitypes.h")
        os.cp(gnulib .. "/uniwidth.in.h", gnulib .. "/uniwidth.h")

        local resource = path.join(get_config("builddir"), "libintl.rc")
        local res = path.join(get_config("builddir"), "libintl.res")
        local object = path.join(get_config("builddir"), "libintl.res.obj")
        local resource_text = io.readfile(intl .. "/libintl.rc"):gsub("PACKAGE_VERSION_STRING", "\"1.0\"")
            :gsub("PACKAGE_VERSION_MAJOR", "1"):gsub("PACKAGE_VERSION_MINOR", "0"):gsub("PACKAGE_VERSION_SUBMINOR", "0")
        io.writefile(resource, resource_text)
        local sdk = path.join(get_config("sdk"), "Windows Kits", "10")
        local sdk_include = path.join(sdk, "Include", get_config("vs_sdkver"))
        os.vrunv(path.join(sdk, "bin", get_config("vs_sdkver"), "x64", "rc.exe"),
            {"-nologo", "-I" .. path.join(sdk_include, "um"), "-I" .. path.join(sdk_include, "shared"), "-Fo" .. res, resource})
        os.vrunv(path.join(get_config("sdk"), "VC", "Tools", "MSVC", get_config("vs_toolset"), "bin", "Hostx64", "x64", "cvtres.exe"),
            {"/nologo", "/machine:x64", "/readonly", "/out:" .. object, res})
    end)
    add_deps("libiconv")
    add_includedirs("in/deps/libintl/gettext-runtime/intl", {public = true})
    add_includedirs("in/deps/libintl/gettext-runtime/intl/gnulib-lib")
    add_defines("BUILDING_LIBINTL", "BUILDING_LIBRARY", "HAVE_CONFIG_H", "LIBDIR=\".\"", "LOCALEDIR=\".\"",
        "_GL_SMALL_WCHAR_T=1", "_CRT_SECURE_NO_WARNINGS", "_WIN32_WINNT=0x0601")
    add_syslinks("advapi32", {public = true})
    add_files("in/deps/libintl/gettext-runtime/intl/*.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/*.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/glthread/*.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/unicase/*.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/unictype/*.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/uniwidth/*.c")
    add_files("out/libintl.res.obj", {always_added = true})
    remove_files("in/deps/libintl/gettext-runtime/intl/intl-exports.c", "in/deps/libintl/gettext-runtime/intl/os2compat.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/frexp*.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/isnan.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/isnand.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/isw*.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/itold.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/lc-charset-dispatch.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/localeconv.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/mbtowc-lock.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/memchr.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/setlocale-lock.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/signbit*.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/stdio-read.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/stdio-write.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/strncpy.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/wmem*.c")

target("libxml2")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    on_prepare(function ()
        os.cp("in/deps/libxml2/include/win32config.h", "in/deps/libxml2/config.h")
        io.writefile(
            "in/deps/libxml2/include/libxml/xmlversion.h",
            (io.readfile("in/deps/libxml2/include/libxml/xmlversion.h.in")
                :gsub("@VERSION@", "2.11.9")
                :gsub("@LIBXML_VERSION_NUMBER@", "21109")
                :gsub("@LIBXML_VERSION_EXTRA@", "")
                :gsub("@MODULE_EXTENSION@", ".dll")
                :gsub("@WITH_TRIO@", "0")
                :gsub("@WITH_THREAD_ALLOC@", "0")
                :gsub("@WITH_XPTR_LOCS@", "0")
                :gsub("@WITH_ICU@", "0")
                :gsub("@WITH_ISO8859X@", "0")
                :gsub("@WITH_MEM_DEBUG@", "0")
                :gsub("@WITH_ZLIB@", "0")
                :gsub("@WITH_LZMA@", "0")
                :gsub("@[^@\r\n]+@", "1"))
        )
    end)
    add_deps("libiconv")
    add_includedirs("in/deps/libxml2/include", {public = true})
    add_includedirs("in/deps/libxml2")
    add_defines("LIBXML_STATIC", {public = true})
    add_defines(
        "LIBXML_STATIC_FOR_DLL",
        "NDEBUG",
        "NOLIBTOOL",
        "_CRT_NONSTDC_NO_DEPRECATE",
        "_CRT_SECURE_NO_DEPRECATE",
        "_MBCS",
        "_REENTRANT",
        "_WINDOWS"
    )
    add_syslinks(
        "kernel32",
        "ws2_32",
        {public = true}
    )
    add_files("in/deps/libxml2/*.c")
    remove_files(
        "in/deps/libxml2/run*.c",
        "in/deps/libxml2/test*.c",
        "in/deps/libxml2/trio*.c",
        "in/deps/libxml2/xmlcatalog.c",
        "in/deps/libxml2/xmllint.c",
        "in/deps/libxml2/xzlib.c"
    )

target("libxslt")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    on_prepare(function ()
        io.writefile(
            "in/deps/libxslt/libxslt/xsltconfig.h",
            (io.readfile("in/deps/libxslt/libxslt/xsltconfig.h.in")
                :gsub("@VERSION@", "1.1.43")
                :gsub("@LIBXSLT_VERSION_NUMBER@", "10143")
                :gsub("@LIBXSLT_VERSION_EXTRA@", "")
                :gsub("@WITH_TRIO@", "0")
                :gsub("@WITH_XSLT_DEBUG@", "1")
                :gsub("@WITH_DEBUGGER@", "1")
                :gsub("@WITH_MODULES@", "1")
                :gsub("@WITH_PROFILER@", "1")
                :gsub("@LIBXSLT_DEFAULT_PLUGINS_PATH@", "NULL"))
        )
        io.writefile(
            "in/deps/libxslt/libexslt/exsltconfig.h",
            (io.readfile("in/deps/libxslt/libexslt/exsltconfig.h.in")
                :gsub("@LIBEXSLT_VERSION@", "0.8.24")
                :gsub("@LIBEXSLT_VERSION_NUMBER@", "824")
                :gsub("@LIBEXSLT_VERSION_EXTRA@", "")
                :gsub("@WITH_CRYPTO@", "0"))
        )
    end)
    add_deps("libxml2")
    add_includedirs("in/deps/libxslt", {public = true})
    add_includedirs(
        "in/deps/libxslt/libexslt",
        "in/deps/libxslt/libxslt"
    )
    add_defines(
        "LIBEXSLT_STATIC",
        "LIBXSLT_STATIC",
        {public = true}
    )
    add_defines(
        "NDEBUG",
        "_CRT_NONSTDC_NO_DEPRECATE",
        "_CRT_SECURE_NO_DEPRECATE",
        "_MBCS",
        "_REENTRANT",
        "_WINDOWS"
    )
    add_syslinks("kernel32", {public = true})
    add_files(
        "in/deps/libxslt/libexslt/*.c",
        "in/deps/libxslt/libxslt/*.c"
    )

target("oniguruma")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    on_prepare(function ()
        os.cp("in/deps/libonig/src/config.h.win64", "in/deps/libonig/src/config.h")
    end)
    add_includedirs("in/deps/libonig/src", {public = true})
    add_defines("ONIG_STATIC", {public = true})
    add_defines(
        "HAVE_CONFIG_H",
        "USE_BINARY_COMPATIBLE_POSIX_API",
        "USE_POSIX_API"
    )
    add_files("in/deps/libonig/src/*.c")
    remove_files(
        "in/deps/libonig/src/koi8.c",
        "in/deps/libonig/src/mktable.c",
        "in/deps/libonig/src/unicode_egcb_data.c",
        "in/deps/libonig/src/unicode_fold_data.c",
        "in/deps/libonig/src/unicode_property_data.c",
        "in/deps/libonig/src/unicode_property_data_posix.c",
        "in/deps/libonig/src/unicode_wb_data.c"
    )


target("sqlite3")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_includedirs("in/deps/sqlite3", {public = true})
    add_defines(
        "SQLITE_ENABLE_COLUMN_METADATA",
        "SQLITE_ENABLE_FTS3",
        "SQLITE_ENABLE_FTS4",
        "SQLITE_ENABLE_FTS5"
    )
    add_files("in/deps/sqlite3/sqlite3.c")


target("libpng")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_deps("zlib")
    on_prepare(function ()
        local zlib_vernum = io.readfile("in/deps/zlib/zlib.h"):match("#define ZLIB_VERNUM (0x%x+)")
        local config = io.readfile("in/deps/libpng/scripts/pnglibconf.h.prebuilt")
            :gsub("#define PNG_ZLIB_VERNUM 0 /%* unknown %*/", "#define PNG_ZLIB_VERNUM " .. zlib_vernum)
        os.mkdir("out/libpng")
        io.writefile("out/libpng/pnglibconf.h", config)
    end)
    add_includedirs("in/deps/libpng", "out/libpng", {public = true})
    add_defines("PNG_INTEL_SSE_OPT=1", "_CRT_NONSTDC_NO_DEPRECATE", "_CRT_SECURE_NO_DEPRECATE")
    add_files("in/deps/libpng/png*.c", "in/deps/libpng/intel/*.c")
    remove_files("in/deps/libpng/pngtest.c")


target("libjpeg")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    set_toolset("as", "nasm@$(projectdir)/in/perl/c/bin/nasm.exe")
    on_prepare(function ()
        os.mkdir("out/libjpeg")
        local config = io.readfile("in/deps/libjpeg-turbo/src/jconfig.h.in")
            :gsub("@JPEG_LIB_VERSION@", "80")
            :gsub("@VERSION@", "3.1.4.1")
            :gsub("@LIBJPEG_TURBO_VERSION_NUMBER@", "3001004")
            :gsub("#cmakedefine C_ARITH_CODING_SUPPORTED 1", "#define C_ARITH_CODING_SUPPORTED 1")
            :gsub("#cmakedefine D_ARITH_CODING_SUPPORTED 1", "#define D_ARITH_CODING_SUPPORTED 1")
            :gsub("#cmakedefine WITH_SIMD 1", "#define WITH_SIMD 1")
            :gsub("#cmakedefine RIGHT_SHIFT_IS_UNSIGNED 1", "/* #undef RIGHT_SHIFT_IS_UNSIGNED */")
        io.writefile("out/libjpeg/jconfig.h", config)
        local configint = io.readfile("in/deps/libjpeg-turbo/src/jconfigint.h.in")
            :gsub("@BUILD@", "20260804")
            :gsub("@HIDDEN@", "")
            :gsub("@INLINE@", "__forceinline")
            :gsub("@THREAD_LOCAL@", "__declspec(thread)")
            :gsub("@CMAKE_PROJECT_NAME@", "libjpeg-turbo")
            :gsub("@VERSION@", "3.1.4.1")
            :gsub("@SIZE_T@", "8")
            :gsub("#cmakedefine HAVE_BUILTIN_CTZL", "/* #undef HAVE_BUILTIN_CTZL */")
            :gsub("#cmakedefine HAVE_INTRIN_H", "#define HAVE_INTRIN_H 1")
            :gsub("#cmakedefine C_ARITH_CODING_SUPPORTED 1", "#define C_ARITH_CODING_SUPPORTED 1")
            :gsub("#cmakedefine D_ARITH_CODING_SUPPORTED 1", "#define D_ARITH_CODING_SUPPORTED 1")
            :gsub("#cmakedefine WITH_SIMD 1", "#define WITH_SIMD 1")
        io.writefile("out/libjpeg/jconfigint.h", configint)
        local version = io.readfile("in/deps/libjpeg-turbo/src/jversion.h.in")
            :gsub("@COPYRIGHT_YEAR@", "1991-2026")
        io.writefile("out/libjpeg/jversion.h", version)
    end)
    add_includedirs("out/libjpeg", "in/deps/libjpeg-turbo/src", {public = true})
    add_includedirs("in/deps/libjpeg-turbo/simd", "in/deps/libjpeg-turbo/simd/x86_64")
    add_defines("_CRT_NONSTDC_NO_WARNINGS")
    add_asflags(
        "-fwin64", "-DWIN64", "-D__x86_64__",
        "-I$(projectdir)/in/deps/libjpeg-turbo/simd/nasm/",
        "-I$(projectdir)/in/deps/libjpeg-turbo/simd/x86_64/",
        {force = true}
    )
    add_files(
        "in/deps/libjpeg-turbo/src/jcapimin.c",
        "in/deps/libjpeg-turbo/src/jchuff.c",
        "in/deps/libjpeg-turbo/src/jcicc.c",
        "in/deps/libjpeg-turbo/src/jcinit.c",
        "in/deps/libjpeg-turbo/src/jclhuff.c",
        "in/deps/libjpeg-turbo/src/jcmarker.c",
        "in/deps/libjpeg-turbo/src/jcmaster.c",
        "in/deps/libjpeg-turbo/src/jcomapi.c",
        "in/deps/libjpeg-turbo/src/jcparam.c",
        "in/deps/libjpeg-turbo/src/jcphuff.c",
        "in/deps/libjpeg-turbo/src/jctrans.c",
        "in/deps/libjpeg-turbo/src/jdapimin.c",
        "in/deps/libjpeg-turbo/src/jdatadst.c",
        "in/deps/libjpeg-turbo/src/jdatasrc.c",
        "in/deps/libjpeg-turbo/src/jdhuff.c",
        "in/deps/libjpeg-turbo/src/jdicc.c",
        "in/deps/libjpeg-turbo/src/jdinput.c",
        "in/deps/libjpeg-turbo/src/jdlhuff.c",
        "in/deps/libjpeg-turbo/src/jdmarker.c",
        "in/deps/libjpeg-turbo/src/jdmaster.c",
        "in/deps/libjpeg-turbo/src/jdphuff.c",
        "in/deps/libjpeg-turbo/src/jdtrans.c",
        "in/deps/libjpeg-turbo/src/jerror.c",
        "in/deps/libjpeg-turbo/src/jfdctflt.c",
        "in/deps/libjpeg-turbo/src/jmemmgr.c",
        "in/deps/libjpeg-turbo/src/jmemnobs.c",
        "in/deps/libjpeg-turbo/src/jpeg_nbits.c",
        "in/deps/libjpeg-turbo/src/jaricom.c",
        "in/deps/libjpeg-turbo/src/jcarith.c",
        "in/deps/libjpeg-turbo/src/jdarith.c",
        "in/deps/libjpeg-turbo/src/wrapper/j*.c",
        "in/deps/libjpeg-turbo/simd/x86_64/jsimd.c",
        "in/deps/libjpeg-turbo/simd/x86_64/*.asm"
    )
    remove_files(
        "in/deps/libjpeg-turbo/simd/x86_64/jccolext-*.asm",
        "in/deps/libjpeg-turbo/simd/x86_64/jcgryext-*.asm",
        "in/deps/libjpeg-turbo/simd/x86_64/jdcolext-*.asm",
        "in/deps/libjpeg-turbo/simd/x86_64/jdmrgext-*.asm"
    )


target("freetype")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    on_prepare(function ()
        os.mkdir("out/freetype/include/freetype/config")
        local options = io.readfile("in/deps/freetype/include/freetype/config/ftoption.h")
            :gsub("/%* #define FT_CONFIG_OPTION_USE_HARFBUZZ %*/", "#define FT_CONFIG_OPTION_USE_HARFBUZZ")
            :gsub("/%* #define FT_CONFIG_OPTION_USE_HARFBUZZ_DYNAMIC %*/", "#define FT_CONFIG_OPTION_USE_HARFBUZZ_DYNAMIC")
        io.writefile("out/freetype/include/freetype/config/ftoption.h", options)
    end)
    add_includedirs("out/freetype/include", "in/deps/freetype/include", {public = true})
    add_defines("FT2_BUILD_LIBRARY", "NDEBUG", "_CRT_SECURE_NO_WARNINGS", "_CRT_NONSTDC_NO_WARNINGS")
    add_files(
        "in/deps/freetype/src/autofit/autofit.c",
        "in/deps/freetype/src/base/ftbase.c",
        "in/deps/freetype/src/base/ftbbox.c",
        "in/deps/freetype/src/base/ftbdf.c",
        "in/deps/freetype/src/base/ftbitmap.c",
        "in/deps/freetype/src/base/ftcid.c",
        "in/deps/freetype/src/base/ftfstype.c",
        "in/deps/freetype/src/base/ftgasp.c",
        "in/deps/freetype/src/base/ftglyph.c",
        "in/deps/freetype/src/base/ftgxval.c",
        "in/deps/freetype/src/base/ftinit.c",
        "in/deps/freetype/src/base/ftmm.c",
        "in/deps/freetype/src/base/ftotval.c",
        "in/deps/freetype/src/base/ftpatent.c",
        "in/deps/freetype/src/base/ftpfr.c",
        "in/deps/freetype/src/base/ftstroke.c",
        "in/deps/freetype/src/base/ftsynth.c",
        "in/deps/freetype/src/base/fttype1.c",
        "in/deps/freetype/src/base/ftwinfnt.c",
        "in/deps/freetype/src/bdf/bdf.c",
        "in/deps/freetype/src/bzip2/ftbzip2.c",
        "in/deps/freetype/src/cache/ftcache.c",
        "in/deps/freetype/src/cff/cff.c",
        "in/deps/freetype/src/cid/type1cid.c",
        "in/deps/freetype/src/gzip/ftgzip.c",
        "in/deps/freetype/src/lzw/ftlzw.c",
        "in/deps/freetype/src/pcf/pcf.c",
        "in/deps/freetype/src/pfr/pfr.c",
        "in/deps/freetype/src/psaux/psaux.c",
        "in/deps/freetype/src/pshinter/pshinter.c",
        "in/deps/freetype/src/psnames/psnames.c",
        "in/deps/freetype/src/raster/raster.c",
        "in/deps/freetype/src/sdf/sdf.c",
        "in/deps/freetype/src/sfnt/sfnt.c",
        "in/deps/freetype/src/smooth/smooth.c",
        "in/deps/freetype/src/svg/svg.c",
        "in/deps/freetype/src/truetype/truetype.c",
        "in/deps/freetype/src/type1/type1.c",
        "in/deps/freetype/src/type42/type42.c",
        "in/deps/freetype/src/winfonts/winfnt.c",
        "in/deps/freetype/builds/windows/ftsystem.c",
        "in/deps/freetype/builds/windows/ftdebug.c",
        "in/deps/freetype/src/base/ftver.rc"
    )


target("libwebp")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_includedirs("in/deps/libwebp/src", {public = true})
    add_includedirs("in/deps/libwebp")
    add_defines("WIN32", "NDEBUG", "_CRT_SECURE_NO_WARNINGS", "WIN32_LEAN_AND_MEAN", "HAVE_WINCODEC_H", "WEBP_USE_THREAD")
    add_files(
        "in/deps/libwebp/src/dec/*.c",
        "in/deps/libwebp/src/demux/*.c",
        "in/deps/libwebp/src/dsp/*.c",
        "in/deps/libwebp/src/enc/*.c",
        "in/deps/libwebp/src/mux/*.c",
        "in/deps/libwebp/src/utils/*.c",
        "in/deps/libwebp/sharpyuv/*.c"
    )


target("libtiff")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_deps("zlib", "libjpeg", "liblzma", "zstd", "libwebp")
    on_prepare(function ()
        os.mkdir("out/libtiff")
        local conf = io.readfile("in/deps/libtiff/tiff-4.7.2/libtiff/tiffconf.h.cmake.in")
            :gsub("@TIFF_INT16_T@", "int16_t")
            :gsub("@TIFF_INT32_T@", "int32_t")
            :gsub("@TIFF_INT64_T@", "int64_t")
            :gsub("@TIFF_INT8_T@", "int8_t")
            :gsub("@TIFF_UINT16_T@", "uint16_t")
            :gsub("@TIFF_UINT32_T@", "uint32_t")
            :gsub("@TIFF_UINT64_T@", "uint64_t")
            :gsub("@TIFF_UINT8_T@", "uint8_t")
            :gsub("@TIFF_SSIZE_T@", "int64_t")
            :gsub("@HOST_BIG_ENDIAN@", "0")
            :gsub("#cmakedefine HAVE_IEEEFP 1", "#define HAVE_IEEEFP 1")
            :gsub("#cmakedefine CCITT_SUPPORT 1", "#define CCITT_SUPPORT 1")
            :gsub("#cmakedefine JPEG_SUPPORT 1", "#define JPEG_SUPPORT 1")
            :gsub("#cmakedefine LOGLUV_SUPPORT 1", "#define LOGLUV_SUPPORT 1")
            :gsub("#cmakedefine LZW_SUPPORT 1", "#define LZW_SUPPORT 1")
            :gsub("#cmakedefine NEXT_SUPPORT 1", "#define NEXT_SUPPORT 1")
            :gsub("#cmakedefine OJPEG_SUPPORT 1", "#define OJPEG_SUPPORT 1")
            :gsub("#cmakedefine PACKBITS_SUPPORT 1", "#define PACKBITS_SUPPORT 1")
            :gsub("#cmakedefine PIXARLOG_SUPPORT 1", "#define PIXARLOG_SUPPORT 1")
            :gsub("#cmakedefine THUNDER_SUPPORT 1", "#define THUNDER_SUPPORT 1")
            :gsub("#cmakedefine ZIP_SUPPORT 1", "#define ZIP_SUPPORT 1")
            :gsub("#cmakedefine STRIPCHOP_DEFAULT TIFF_STRIPCHOP", "#define STRIPCHOP_DEFAULT TIFF_STRIPCHOP")
            :gsub("#cmakedefine SUBIFD_SUPPORT 1", "#define SUBIFD_SUPPORT 1")
            :gsub("#cmakedefine DEFAULT_EXTRASAMPLE_AS_ALPHA 1", "#define DEFAULT_EXTRASAMPLE_AS_ALPHA 1")
            :gsub("#cmakedefine CHECK_JPEG_YCBCR_SUBSAMPLING 1", "#define CHECK_JPEG_YCBCR_SUBSAMPLING 1")
            :gsub("#cmakedefine MDI_SUPPORT 1", "#define MDI_SUPPORT 1")
            :gsub("#cmakedefine ([%w_]+) 1", "/* #undef %1 */")
            :gsub("#cmakedefine ([%w_]+)", "/* #undef %1 */")
        io.writefile("out/libtiff/tiffconf.h", conf)
        local config = io.readfile("in/deps/libtiff/tiff-4.7.2/libtiff/tif_config.h.cmake.in")
            :gsub("@LIBJPEG_12_PATH@", "")
            :gsub("@PACKAGE_NAME@", "LibTIFF Software")
            :gsub("@PACKAGE_BUGREPORT@", "tiff@lists.osgeo.org")
            :gsub("@PACKAGE_TARNAME@", "tiff")
            :gsub("@PACKAGE_URL@", "")
            :gsub("@SIZEOF_SIZE_T@", "8")
            :gsub("@STRIP_SIZE_DEFAULT@", "8192")
            :gsub("@TIFF_MAX_DIR_COUNT@", "1048576")
            :gsub("#cmakedefine CCITT_SUPPORT 1", "#define CCITT_SUPPORT 1")
            :gsub("#cmakedefine CHECK_JPEG_YCBCR_SUBSAMPLING 1", "#define CHECK_JPEG_YCBCR_SUBSAMPLING 1")
            :gsub("#cmakedefine CXX_SUPPORT 1", "#define CXX_SUPPORT 1")
            :gsub("#cmakedefine HAVE_ASSERT_H 1", "#define HAVE_ASSERT_H 1")
            :gsub("#cmakedefine HAVE_FCNTL_H 1", "#define HAVE_FCNTL_H 1")
            :gsub("#cmakedefine HAVE_IO_H 1", "#define HAVE_IO_H 1")
            :gsub("#cmakedefine HAVE_SYS_TYPES_H 1", "#define HAVE_SYS_TYPES_H 1")
            :gsub("#cmakedefine HAVE_JPEGTURBO_DUAL_MODE_8_12 1", "#define HAVE_JPEGTURBO_DUAL_MODE_8_12 1")
            :gsub("#cmakedefine LZMA_SUPPORT 1", "#define LZMA_SUPPORT 1")
            :gsub("#cmakedefine STRIP_SIZE_DEFAULT 8192", "#define STRIP_SIZE_DEFAULT 8192")
            :gsub("#cmakedefine USE_WIN32_FILEIO 1", "#define USE_WIN32_FILEIO 1")
            :gsub("#cmakedefine WEBP_SUPPORT 1", "#define WEBP_SUPPORT 1")
            :gsub("#cmakedefine ZSTD_SUPPORT 1", "#define ZSTD_SUPPORT 1")
            :gsub("#cmakedefine01 HAVE_DECL_OPTARG", "#define HAVE_DECL_OPTARG 0")
            :gsub("#cmakedefine01 WORDS_BIGENDIAN", "#define WORDS_BIGENDIAN 0")
            :gsub("#cmakedefine ([%w_]+) 1", "/* #undef %1 */")
            :gsub("#cmakedefine ([%w_]+)", "/* #undef %1 */")
        io.writefile("out/libtiff/tif_config.h", config)
        io.writefile("out/libtiff/tiffvers.h", io.readfile("in/deps/libtiff/tiff-4.7.2/libtiff/tiffvers.h"))
    end)
    add_includedirs("out/libtiff", "in/deps/libtiff/tiff-4.7.2/libtiff", {public = true})
    add_defines("NDEBUG", "TIFF_DO_NOT_USE_NON_EXT_ALLOC_FUNCTIONS", "_CRT_SECURE_NO_DEPRECATE", "_CRT_NONSTDC_NO_DEPRECATE", "_CRT_SECURE_NO_WARNINGS", "_CRT_NONSTDC_NO_WARNINGS")
    add_files("in/deps/libtiff/tiff-4.7.2/libtiff/tif_*.c")
    remove_files("in/deps/libtiff/tiff-4.7.2/libtiff/tif_unix.c")
    add_files("in/deps/libtiff/tiff-4.7.2/libtiff/tif_open.c", "in/deps/libtiff/tiff-4.7.2/libtiff/tif_win32.c", {defines = {"ALLOW_TIFF_NON_EXT_ALLOC_FUNCTIONS"}})
    add_files("in/deps/libtiff/tiff-4.7.2/libtiff/tif_win32_versioninfo.rc")


target("libavif")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_languages("c11", "cxx17")
    set_optimize("fastest")
    set_toolset("as", "nasm@$(projectdir)/in/perl/c/bin/nasm.exe")
    on_prepare(function (target)
        os.mkdir("out/libavif/config")
        local values = {}
        for name, value in io.readfile("in/deps/aom/cmake/aom_config_defaults.cmake"):gmatch("set_aom_[%w_]+%(%s*([%w_]+)%s+([%d]+)") do
            values[name] = value
        end
        for name in ("AOM_ARCH_X86_64 HAVE_MMX HAVE_SSE HAVE_SSE2 HAVE_SSE3 HAVE_SSSE3 HAVE_SSE4_1 HAVE_SSE4_2 HAVE_AVX HAVE_AVX2 HAVE_AVX512 CONFIG_OS_SUPPORT CONFIG_PIC"):gmatch("%S+") do
            values[name] = "1"
        end
        values.CONFIG_WEBM_IO = "0"
        values.CONFIG_LIBYUV = "0"
        local names = {}
        for name in pairs(values) do table.insert(names, name) end
        table.sort(names)
        local header = {"#ifndef AOM_CONFIG_H_", "#define AOM_CONFIG_H_"}
        local assembly = {}
        for _, name in ipairs(names) do
            table.insert(header, "#define " .. name .. " " .. values[name])
            table.insert(assembly, name .. " equ " .. values[name])
        end
        table.insert(header, "#endif  // AOM_CONFIG_H_")
        io.writefile("out/libavif/config/aom_config.h", table.concat(header, "\n") .. "\n")
        io.writefile("out/libavif/config/aom_config.asm", table.concat(assembly, "\n") .. "\n")
        io.writefile("out/libavif/config/aom_config.c", [[#include "aom/aom_codec.h"
static const char* const cfg = "cmake ../ -G \"Visual Studio 18 2026\" -DAOM_TARGET_CPU=x86_64 -DENABLE_DOCS=0 -DENABLE_EXAMPLES=0 -DENABLE_NASM=1 -DENABLE_TESTDATA=0 -DENABLE_TESTS=0 -DENABLE_TOOLS=0 -DENABLE_SSE2=1 -DENABLE_SSE3=1 -DENABLE_SSSE3=1 -DENABLE_SSE4_1=1 -DENABLE_SSE4_2=1 -DENABLE_AVX=1 -DENABLE_AVX2=1";
const char *aom_codec_build_config(void) { return cfg; }
]])
        io.writefile("out/libavif/config/aom_av1_no_op.c", "// Generated no-op source.\n")
        io.writefile("out/libavif/config/aom_dsp_no_op.c", "// Generated no-op source.\n")
        local perl = "$(projectdir)/in/perl/perl/bin/perl.exe"
        os.vrunv(perl, {"in/deps/aom/cmake/version.pl", "--version_data=in/deps/aom/CHANGELOG", "--version_filename=out/libavif/config/aom_version.h"})
        os.vrunv(perl, {"in/deps/aom/cmake/rtcd.pl", "--arch=x86_64", "--sym=aom_dsp_rtcd", "--config=out/libavif/config/aom_config.h", "in/deps/aom/aom_dsp/aom_dsp_rtcd_defs.pl"}, {stdout = "out/libavif/config/aom_dsp_rtcd.h"})
        os.vrunv(perl, {"in/deps/aom/cmake/rtcd.pl", "--arch=x86_64", "--sym=aom_scale_rtcd", "--config=out/libavif/config/aom_config.h", "in/deps/aom/aom_scale/aom_scale_rtcd.pl"}, {stdout = "out/libavif/config/aom_scale_rtcd.h"})
        os.vrunv(perl, {"in/deps/aom/cmake/rtcd.pl", "--arch=x86_64", "--sym=av1_rtcd", "--config=out/libavif/config/aom_config.h", "in/deps/aom/av1/common/av1_rtcd_defs.pl"}, {stdout = "out/libavif/config/av1_rtcd.h"})
        io.writefile("out/libavif/config/aom_config.h", (io.readfile("out/libavif/config/aom_config.h"):gsub("#define CONFIG_LIBYUV 0", "#define CONFIG_LIBYUV 1")))
        target:add("files", "out/libavif/config/aom_config.c", "out/libavif/config/aom_av1_no_op.c", "out/libavif/config/aom_dsp_no_op.c")
    end)
    add_includedirs("in/deps/libavif/include", {public = true})
    add_includedirs("out/libavif", "in/deps/aom", "in/deps/libyuv/include")
    add_defines("AVIF_CODEC_AOM=1", "AVIF_CODEC_AOM_ENCODE=1", "AVIF_CODEC_AOM_DECODE=1", "AVIF_LIBYUV_ENABLED=1", "_WIN32_WINNT=0x0601", "_CRT_SECURE_NO_WARNINGS", "_CRT_NONSTDC_NO_WARNINGS")
    add_asflags("-fwin64", "-I$(projectdir)/in/deps/aom/", "-I$(projectdir)/out/libavif/", {force = true})
    add_files(
        "in/deps/libavif/src/*.c",
        "in/deps/aom/aom/src/*.c",
        "in/deps/aom/aom_dsp/*.c",
        "in/deps/aom/aom_dsp/flow_estimation/*.c",
        "in/deps/aom/aom_dsp/flow_estimation/x86/*.c",
        "in/deps/aom/aom_dsp/x86/*.c",
        "in/deps/aom/aom_mem/*.c",
        "in/deps/aom/aom_scale/*.c",
        "in/deps/aom/aom_scale/generic/*.c",
        "in/deps/aom/aom_util/*.c",
        "in/deps/aom/av1/*.c",
        "in/deps/aom/av1/common/*.c",
        "in/deps/aom/av1/common/x86/*.c",
        "in/deps/aom/av1/decoder/*.c",
        "in/deps/aom/av1/encoder/*.c",
        "in/deps/aom/av1/encoder/x86/*.c",
        "in/deps/aom/third_party/fastfeat/*.c",
        "in/deps/aom/third_party/vector/*.c",
        "in/deps/aom/common/args_helper.c",
        "in/deps/libyuv/source/*.cc",
        "in/deps/aom/aom_dsp/x86/*.asm",
        "in/deps/aom/av1/encoder/x86/*.asm",
        "in/deps/aom/aom_ports/float.asm"
    )
    remove_files(
        "in/deps/libavif/src/codec_avm.c", "in/deps/libavif/src/codec_dav1d.c", "in/deps/libavif/src/codec_libgav1.c", "in/deps/libavif/src/codec_rav1e.c", "in/deps/libavif/src/codec_svt.c",
        "in/deps/aom/aom_dsp/butteraugli.c", "in/deps/aom/aom_dsp/fastssim.c", "in/deps/aom/aom_dsp/psnrhvs.c", "in/deps/aom/aom_dsp/vmaf.c",
        "in/deps/aom/aom_util/debug_util.c", "in/deps/aom/av1/common/x86/cdef_block_ssse3.c",
        "in/deps/aom/av1/decoder/accounting.c", "in/deps/aom/av1/decoder/inspection.c",
        "in/deps/aom/av1/encoder/av1_temporal_denoiser.c", "in/deps/aom/av1/encoder/blockiness.c", "in/deps/aom/av1/encoder/deltaq4_model.c", "in/deps/aom/av1/encoder/optical_flow.c", "in/deps/aom/av1/encoder/saliency_map.c", "in/deps/aom/av1/encoder/sparse_linear_solver.c", "in/deps/aom/av1/encoder/thirdpass.c", "in/deps/aom/av1/encoder/tune_butteraugli.c", "in/deps/aom/av1/encoder/tune_vmaf.c",
        "in/deps/aom/av1/encoder/x86/av1_temporal_denoiser_sse2.c", "in/deps/aom/av1/encoder/x86/av1_ssim_opt_x86_64.asm",
        "in/deps/libyuv/source/*neon*.cc", "in/deps/libyuv/source/*sme*.cc", "in/deps/libyuv/source/row_sve.cc"
    )
    add_files("in/deps/aom/**/*_avx.c", {cxflags = {"/arch:AVX"}})
    add_files("in/deps/aom/**/*_avx2.c", {cxflags = {"/arch:AVX2"}})


target("libsasl")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    on_prepare(function ()
        os.mkdir("out/libsasl/include/sasl")
        os.cp("in/deps/libsasl/include/*.h", "out/libsasl/include")
        os.cp("in/deps/libsasl/include/*.h", "out/libsasl/include/sasl")
        os.cp("in/deps/libsasl/win32/include/md5global.h", "out/libsasl/include")
        os.cp("in/deps/libsasl/win32/include/md5global.h", "out/libsasl/include/sasl")
        local prop = io.readfile("in/deps/libsasl/include/prop.h"):gsub("#ifdef WIN32\n# ifdef LIBSASL_EXPORTS", "#if defined(WIN32) && !defined(LIBSASL_STATIC)\n# ifdef LIBSASL_EXPORTS")
        io.writefile("out/libsasl/include/prop.h", prop)
        io.writefile("out/libsasl/include/sasl/prop.h", prop)
        local saslutil = io.readfile("in/deps/libsasl/lib/saslutil.c"):gsub("__declspec%(dllexport%) ", "")
        io.writefile("out/libsasl/saslutil.c", saslutil)
    end)
    add_includedirs("out/libsasl/include", {public = true})
    add_includedirs("in/deps/libsasl/win32/include", "in/deps/libsasl/include", "in/deps/libsasl/lib", "in/deps/libsasl/common")
    add_defines("LIBSASL_STATIC", {public = true})
    add_defines("NO_STATIC_PLUGINS", "WIN32", "UNICODE", "_UNICODE", "_CRT_SECURE_NO_WARNINGS", "GCC_FALLTHROUGH=")
    add_syslinks("ws2_32", "advapi32", {public = true})
    add_files("in/deps/libsasl/lib/*.c", "in/deps/libsasl/common/plugin_common.c", "out/libsasl/saslutil.c", {always_added = true})
    remove_files("in/deps/libsasl/lib/dlopen.c", "in/deps/libsasl/lib/getaddrinfo.c", "in/deps/libsasl/lib/getnameinfo.c", "in/deps/libsasl/lib/snprintf.c", "in/deps/libsasl/lib/saslutil.c")


target("openldap")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_deps("openssl", "libsasl")
    on_prepare(function ()
        local out = "out/openldap/include"
        os.mkdir(path.join(out, "ac"))
        local defs = {}
        for name in ([=[THREADSAFE _THREADSAFE THREAD_SAFE _THREAD_SAFE HAVE_ASSERT_H HAVE_CLOSESOCKET HAVE_CONIO_H HAVE_CYRUS_SASL HAVE_DIRECT_H HAVE_ERRNO_H HAVE_FCNTL_H HAVE_FSTAT HAVE_GETADDRINFO HAVE_GETHOSTNAME HAVE_GETOPT HAVE_GMTIME_R HAVE_INET_NTOP HAVE_INTTYPES_H HAVE_IOCTL HAVE_IO_H HAVE_LIMITS_H HAVE_LOCALE_H HAVE_LOCALTIME_R HAVE_LONG_LONG HAVE_MALLOC_H HAVE_MEMCPY HAVE_MEMMOVE HAVE_MEMORY_H HAVE_MKTEMP HAVE_MKVERSION HAVE_NT_EVENT_LOG HAVE_NT_SERVICE_MANAGER HAVE_NT_THREADS HAVE_OPENSSL HAVE_OPENSSL_BN_H HAVE_OPENSSL_CRL HAVE_OPENSSL_CRYPTO_H HAVE_OPENSSL_SSL_H HAVE_PROCESS_H HAVE_PTRDIFF_T HAVE_READ HAVE_RECV HAVE_RECVFROM HAVE_REGEX_H HAVE_SASL_SASL_H HAVE_SASL_VERSION HAVE_SIGNAL HAVE_SNPRINTF HAVE_SPAWNLP HAVE_STDDEF_H HAVE_STDINT_H HAVE_STDLIB_H HAVE_STRDUP HAVE_STRERROR HAVE_STRFTIME HAVE_STRINGS_H HAVE_STRING_H HAVE_STRPBRK HAVE_STRRCHR HAVE_STRSPN HAVE_STRSTR HAVE_STRTOL HAVE_STRTOLL HAVE_STRTOUL HAVE_STRTOULL HAVE_SYS_ERRLIST HAVE_SYS_FILE_H HAVE_SYS_STAT_H HAVE_SYS_TYPES_H HAVE_TLS HAVE_UTIME_H HAVE_VPRINTF HAVE_VSNPRINTF HAVE_WINSOCK HAVE_WINSOCK2 HAVE_WINSOCK2_H HAVE_WINSOCK_H HAVE_WRITE HAVE_YIELDING_SELECT HAVE__VSNPRINTF LDAP_API_FEATURE_X_OPENLDAP_REENTRANT LDAP_API_FEATURE_X_OPENLDAP_THREAD_SAFE LDAP_DEBUG LDAP_PF_INET6 LDAP_PROCTITLE STDC_HEADERS USE_MP_LONG_LONG]=]):gmatch("%S+") do defs[name] = "1" end
        local values = [=[
EXEEXT=".exe"
LBER_INT_T=int
LBER_LEN_T=__int64
LBER_SOCKET_T=int
LBER_TAG_T=__int64
LDAP_VENDOR_VERSION=20613
LDAP_VENDOR_VERSION_MAJOR=2
LDAP_VENDOR_VERSION_MINOR=6
LDAP_VENDOR_VERSION_PATCH=13
OPENLDAP_PACKAGE="OpenLDAP"
OPENLDAP_VERSION="2.6.13"
PACKAGE_BUGREPORT=""
PACKAGE_NAME=""
PACKAGE_STRING=""
PACKAGE_TARNAME=""
PACKAGE_VERSION=""
RETSIGTYPE=void
SIZEOF_INT=4
SIZEOF_LONG=4
SIZEOF_LONG_LONG=8
SIZEOF_SHORT=2
SIZEOF_WCHAR_T=2
ber_socklen_t=int
caddr_t=char *
gid_t=int
uid_t=int
]=]
        for line in values:gmatch("[^\r\n]+") do local n, v = line:match("^([^=]+)=(.*)$"); if n then defs[n] = v end end
        local function render(input, output)
            local data = io.readfile(input):gsub("#undef%s+([%w_]+)", function (name)
                return defs[name] and ("#define " .. name .. " " .. defs[name]) or ("/* #undef " .. name .. " */")
            end)
            io.writefile(output, data)
        end
        render("in/deps/openldap/include/portable.hin", path.join(out, "portable.h"))
        render("in/deps/openldap/include/lber_types.hin", path.join(out, "lber_types.h"))
        render("in/deps/openldap/include/ldap_features.hin", path.join(out, "ldap_features.h"))
        local config = io.readfile("in/deps/openldap/include/ldap_config.hin"):gsub("%%[A-Z]+DIR%%", ".")
        io.writefile(path.join(out, "ldap_config.h"), config)
        local socket = io.readfile("in/deps/openldap/include/ac/socket.h"):gsub("#define EWOULDBLOCK WSAEWOULDBLOCK", "#undef EWOULDBLOCK\n#undef EINPROGRESS\n#undef ETIMEDOUT\n#undef ENOTCONN\n#define EWOULDBLOCK WSAEWOULDBLOCK")
        io.writefile(path.join(out, "ac/socket.h"), socket)
        local time = io.readfile("in/deps/openldap/include/ac/time.h"):gsub("#if defined%(_WIN32%) && !defined%(HAVE_CLOCK_GETTIME%)", "#if defined(_WIN32) && !defined(HAVE_CLOCK_GETTIME) && (!defined(_MSC_VER) || _MSC_VER < 1900)")
        io.writefile(path.join(out, "ac/time.h"), time)
        local version = io.readfile("in/deps/openldap/build/version.h") .. '\n#include "portable.h"\nconst char __Version[] = "OpenLDAP 2.6.13";\n'
        io.writefile("out/openldap/version.c", version)
    end)
    add_includedirs("out/openldap/include", "in/deps/openldap/include", {public = true})
    add_includedirs("in/deps/openldap/libraries/libldap", "in/deps/openldap/libraries/liblber", "in/deps/rxspencer", "in/deps/openssl/include")
    add_defines("strcasecmp=_stricmp", "strncasecmp=_strnicmp")
    add_syslinks("ws2_32", "advapi32", "crypt32", "secur32", "bcrypt", {public = true})
    add_files("in/deps/openldap/libraries/libldap/*.c", {defines = {"LDAP_LIBRARY"}})
    remove_files("in/deps/openldap/libraries/libldap/apitest.c", "in/deps/openldap/libraries/libldap/dntest.c", "in/deps/openldap/libraries/libldap/ftest.c", "in/deps/openldap/libraries/libldap/ltest.c", "in/deps/openldap/libraries/libldap/t61.c", "in/deps/openldap/libraries/libldap/test.c", "in/deps/openldap/libraries/libldap/testavl.c", "in/deps/openldap/libraries/libldap/testtavl.c", "in/deps/openldap/libraries/libldap/urltest.c")
    add_files("in/deps/openldap/libraries/liblber/*.c", {defines = {"LBER_LIBRARY"}})
    remove_files("in/deps/openldap/libraries/liblber/dtest.c", "in/deps/openldap/libraries/liblber/etest.c", "in/deps/openldap/libraries/liblber/idtest.c", "in/deps/openldap/libraries/liblber/stdio.c")
    add_files("in/deps/rxspencer/regcomp.c", "in/deps/rxspencer/regerror.c", "in/deps/rxspencer/regexec.c", "in/deps/rxspencer/regfree.c", {defines = {"POSIX_MISTAKE", "REDEBUG"}})
    add_files("out/openldap/version.c", {always_added = true})


target("libpq")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_deps("openssl")
    on_prepare(function ()
        local out = "out/libpq"
        os.mkdir(path.join(out, "include"))
        os.mkdir(path.join(out, "port"))

        local defs = {}
        for name in ([=[ENABLE_THREAD_SAFETY HAVE_ASN1_STRING_GET0_DATA HAVE_ATOMICS HAVE_BIO_METH_NEW HAVE_DECL_STRNLEN HAVE_FSEEKO HAVE_HMAC_CTX_FREE HAVE_HMAC_CTX_NEW HAVE_INET_PTON HAVE_INT_TIMEZONE HAVE_LOCALE_T HAVE_LONG_LONG_INT_64 HAVE_MBSTOWCS_L HAVE_MEMORY_H HAVE_OPENSSL_INIT_SSL HAVE_SOCKLEN_T HAVE_SPINLOCKS HAVE_SSL_CTX_SET_CERT_CB HAVE_SSL_CTX_SET_NUM_TICKETS HAVE_STDINT_H HAVE_STDLIB_H HAVE_STRING_H HAVE_STRNLEN HAVE_SYS_STAT_H HAVE_SYS_TYPES_H HAVE_UNISTD_H HAVE_WCSTOMBS_L HAVE_X509_GET_SIGNATURE_INFO HAVE_X509_GET_SIGNATURE_NID HAVE__CONFIGTHREADLOCALE HAVE__CPUID PG_USE_STDBOOL STDC_HEADERS USE_LDAP USE_OPENSSL USE_SSE42_CRC32C_WITH_RUNTIME_CHECK USE_WIN32_SEMAPHORES USE_WIN32_SHARED_MEMORY]=]):gmatch("%S+") do defs[name] = "1" end
        for name in ([=[HAVE_DECL_FDATASYNC HAVE_DECL_F_FULLFSYNC HAVE_DECL_LLVMCREATEGDBREGISTRATIONLISTENER HAVE_DECL_LLVMCREATEPERFJITEVENTLISTENER HAVE_DECL_LLVMGETHOSTCPUFEATURES HAVE_DECL_LLVMGETHOSTCPUNAME HAVE_DECL_LLVMORCGETSYMBOLADDRESSIN HAVE_DECL_MEMSET_S HAVE_DECL_POSIX_FADVISE HAVE_DECL_PREADV HAVE_DECL_PWRITEV HAVE_DECL_STRCHRNUL HAVE_DECL_STRLCAT HAVE_DECL_STRLCPY HAVE_DECL_TIMINGSAFE_BCMP]=]):gmatch("%S+") do defs[name] = "0" end
        local values = [=[
ALIGNOF_DOUBLE=8;ALIGNOF_INT=4;ALIGNOF_LONG=4;ALIGNOF_LONG_LONG_INT=8;ALIGNOF_SHORT=2;BLCKSZ=8192;DEF_PGPORT=5432;DEF_PGPORT_STR="5432";DLSUFFIX=".dll"
CONFIGURE_ARGS="--enable-thread-safety --with-ldap --without-zlib --with-ssl=openssl";INT64_MODIFIER="ll";MAXIMUM_ALIGNOF=8;MEMSET_LOOP_LIMIT=1024;OPENSSL_API_COMPAT=0x10001000L
PACKAGE_BUGREPORT="pgsql-bugs@lists.postgresql.org";PACKAGE_NAME="PostgreSQL";PACKAGE_STRING="PostgreSQL 16.14";PACKAGE_TARNAME="postgresql";PACKAGE_URL="https://www.postgresql.org/";PACKAGE_VERSION="16.14"
PG_INT64_TYPE=long long int;PG_KRB_SRVNAM="postgres";PG_MAJORVERSION="16";PG_MAJORVERSION_NUM=16;PG_MINORVERSION_NUM=14;PG_VERSION="16.14";PG_VERSION_NUM=160014;PG_VERSION_STR="PostgreSQL 16.14, compiled by Visual C++, 64-bit"
RELSEG_SIZE=131072;SIZEOF_BOOL=1;SIZEOF_LONG=4;SIZEOF_SIZE_T=8;SIZEOF_VOID_P=8;XLOG_BLCKSZ=8192;inline=__inline;pg_restrict=__restrict
]=]
        for item in values:gmatch("[^;\r\n]+") do local name, value = item:match("^([^=]+)=(.*)$"); if name then defs[name] = value end end

        local function render(input, output)
            local data = io.readfile(input):gsub("#(%s*)undef%s+([%w_]+)", function (_, name)
                return defs[name] and ("#define " .. name .. " " .. defs[name]) or ("/* #undef " .. name .. " */")
            end)
            io.writefile(output, data)
        end
        render("in/deps/libpq/src/include/pg_config.h.in", path.join(out, "include/pg_config.h"))
        render("in/deps/libpq/src/include/pg_config_ext.h.in", path.join(out, "include/pg_config_ext.h"))
        os.cp("in/deps/libpq/src/include/port/win32.h", path.join(out, "include/pg_config_os.h"))
        local paths = "PGBINDIR=/bin PGSHAREDIR=/share SYSCONFDIR=/etc INCLUDEDIR=/include PKGINCLUDEDIR=/include INCLUDEDIRSERVER=/include/server LIBDIR=/lib PKGLIBDIR=/lib LOCALEDIR=/share/locale DOCDIR=/doc HTMLDIR=/doc MANDIR=/man"
        paths = paths:gsub(" ?(%S+)=([^%s]+)", '#define %1 "%2"\n')
        io.writefile(path.join(out, "port/pg_config_paths.h"), paths)
    end)
    add_includedirs("out/libpq/include", "in/deps/libpq/src/interfaces/libpq", "in/deps/libpq/src/include", {public = true})
    add_includedirs("out/libpq/port", "in/deps/libpq/src/port", "in/deps/libpq/src/include/port/win32", "in/deps/libpq/src/include/port/win32_msvc", "in/deps/openssl/include")
    add_defines("FRONTEND", "WIN32", "WINDOWS", "__WINDOWS__", "__WIN32__", "_CRT_SECURE_NO_DEPRECATE", "_CRT_NONSTDC_NO_DEPRECATE", "SO_MAJOR_VERSION=5")
    add_syslinks("ws2_32", "secur32", "wldap32", "shell32", "advapi32", {public = true})
    add_files("in/deps/libpq/src/interfaces/libpq/*.c")
    remove_files("in/deps/libpq/src/interfaces/libpq/fe-gssapi-common.c", "in/deps/libpq/src/interfaces/libpq/fe-secure-gssapi.c")
    add_files(
        "in/deps/libpq/src/common/base64.c", "in/deps/libpq/src/common/cryptohash_openssl.c", "in/deps/libpq/src/common/encnames.c", "in/deps/libpq/src/common/hmac_openssl.c",
        "in/deps/libpq/src/common/ip.c", "in/deps/libpq/src/common/link-canary.c", "in/deps/libpq/src/common/md5_common.c", "in/deps/libpq/src/common/pg_prng.c",
        "in/deps/libpq/src/common/saslprep.c", "in/deps/libpq/src/common/scram-common.c", "in/deps/libpq/src/common/string.c", "in/deps/libpq/src/common/unicode_norm.c", "in/deps/libpq/src/common/wchar.c")
    add_files(
        "in/deps/libpq/src/port/chklocale.c", "in/deps/libpq/src/port/dirmod.c", "in/deps/libpq/src/port/explicit_bzero.c", "in/deps/libpq/src/port/getpeereid.c",
        "in/deps/libpq/src/port/inet_aton.c", "in/deps/libpq/src/port/inet_net_ntop.c", "in/deps/libpq/src/port/noblock.c", "in/deps/libpq/src/port/open.c",
        "in/deps/libpq/src/port/pgsleep.c", "in/deps/libpq/src/port/pg_strong_random.c", "in/deps/libpq/src/port/pgstrcasecmp.c", "in/deps/libpq/src/port/snprintf.c",
        "in/deps/libpq/src/port/strerror.c", "in/deps/libpq/src/port/strlcat.c", "in/deps/libpq/src/port/strlcpy.c", "in/deps/libpq/src/port/system.c",
        "in/deps/libpq/src/port/timingsafe_bcmp.c", "in/deps/libpq/src/port/win32common.c", "in/deps/libpq/src/port/win32error.c", "in/deps/libpq/src/port/win32gai_strerror.c",
        "in/deps/libpq/src/port/win32gettimeofday.c", "in/deps/libpq/src/port/win32ntdll.c", "in/deps/libpq/src/port/win32setlocale.c", "in/deps/libpq/src/port/win32stat.c")


target("php")
    set_enabled(false)
    set_kind("object")
    set_targetdir(get_config("builddir"))
    add_files("in/php-src/Zend/zend.c")

    add_asflags("/DBOOST_CONTEXT_EXPORT=EXPORT", {force = true})
    add_files("in/php-src/Zend/asm/*_xmm_x86_64_ms_masm.asm")

target("openssl")
    set_enabled(false)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_toolset("as", "nasm@$(projectdir)/in/perl/c/bin/nasm.exe")
    -- add_rules("c.unity_build")
    on_prepare(function ()
        if true then return end -- disabled to debug fast
        import("async")
        import("core.base.option")

        local root = path.absolute("in/deps/openssl")
        local perl = "$(projectdir)/in/perl/perl/bin/perl.exe"
        local jobs = option.get("jobs") or os.default_njob()

        os.vrunv(perl,
            {"Configure", "VC-WIN64A", "no-shared", "no-module", "no-tests", "no-docs"},
            {curdir = root, addenvs = {PATH = path.absolute("in/perl/c/bin")}})

        os.vrunv(perl, {"util/mkbuildinf.pl", "cl /MD /O2", "VC-WIN64A"},
            {curdir = root, stdout = path.join(root, "crypto/buildinf.h")})

        os.vrunv(perl, {"apps/progs.pl", "-C", "apps\\openssl"},
            {curdir = root, stdout = path.join(root, "apps/progs.c")})
        os.vrunv(perl, {"apps/progs.pl", "-H", "apps\\openssl"},
            {curdir = root, stdout = path.join(root, "apps/progs.h")})

        local templates = os.files(path.join(root, "**/*.[ch].in"))
        async.runjobs("openssl_test.templates", function (index)
            local input = templates[index]
            local output = input:sub(1, -4)
            os.vrunv(perl,
                {"-I.", "-Iutil/perl", "-Iproviders/common/der", "-Mconfigdata",
                 "-MOpenSSL::paramnames", "-Moids_to_c", "util/dofile.pl", "-omakefile",
                 path.relative(input, root)},
                {curdir = root, stdout = output})
        end, {total = #templates, comax = jobs})

        local generators = os.files(path.join(root, "**/*x86_64*.pl|crypto/perlasm/**"))
        async.runjobs("openssl_test.perlasm", function (index)
            local generator = generators[index]
            local relative = path.relative(generator, root):gsub("\\", "/")
            local output = relative:gsub("/asm/", "/"):gsub("%.pl$", ".asm")
            os.vrunv(perl, {relative, "nasm", output}, {curdir = root})
        end, {total = #generators, comax = jobs})
    end)

    add_files(
        "in/deps/openssl/**/*.c|engines/*.c",
        "in/deps/openssl/engines/e_capi.c",
        "in/deps/openssl/engines/e_padlock.c"
    )
    remove_files(
        "in/deps/openssl/**/*acvp*.c",
        "in/deps/openssl/**/*md2*.c",
        "in/deps/openssl/crypto/*cap.c",
        "in/deps/openssl/crypto/LPdir_*.c", "in/deps/openssl/crypto/aes/aes_core.c", "in/deps/openssl/crypto/aes/aes_cbc.c", "in/deps/openssl/crypto/aes/aes_x86core.c",
        "in/deps/openssl/crypto/ec/ecp_nistp*.c", "in/deps/openssl/crypto/**/*_ppc.c", "in/deps/openssl/crypto/**/*_riscv.c", "in/deps/openssl/crypto/**/*s390x*.c", "in/deps/openssl/crypto/**/*sparc*.c",
        "in/deps/openssl/crypto/ec/ecp_nistz256_table.c", "in/deps/openssl/crypto/bn/asm/x86_64-gcc.c", "in/deps/openssl/crypto/des/ncbc_enc.c",
        "in/deps/openssl/crypto/poly1305/poly1305_*.c",
        "in/deps/openssl/crypto/rc5/*.c",
        "in/deps/openssl/apps/*.c", "in/deps/openssl/apps/**/*.c", "in/deps/openssl/demos/**/*.c",
        "in/deps/openssl/doc/**/*.c",
        "in/deps/openssl/fuzz/*.c",
        "in/deps/openssl/ms/applink.c",
        "in/deps/openssl/providers/common/securitycheck_fips.c",
        "in/deps/openssl/providers/fips/*.c",
        "in/deps/openssl/providers/implementations/ciphers/cipher_rc5*.c",
        "in/deps/openssl/providers/implementations/macs/blake2_mac_impl.c",
        "in/deps/openssl/providers/implementations/rands/fips_crng_test.c",
        "in/deps/openssl/providers/implementations/rands/seeding/rand_cpu_arm64.c",
        "in/deps/openssl/providers/implementations/rands/seeding/rand_v*.c",
        "in/deps/openssl/ssl/record/methods/ktls_meth.c",
        "in/deps/openssl/test/**.c"
    )

    add_asflags("-Ox", "-f", "win64", "-DNEAR", "-g", {force = true})
    add_files("in/deps/openssl/**/*x86_64*.asm", "in/deps/openssl/**/*avx*.asm")

    add_includedirs(
        "in/deps/openssl/apps/include",
        "in/deps/openssl/include",
        "in/deps/openssl",
        "in/deps/openssl/crypto",
        "in/deps/openssl/providers/common/include",
        "in/deps/openssl/providers/common/include/prov",
        "in/deps/openssl/providers/implementations/include",
        "in/deps/openssl/providers/fips/include"
    )
    add_defines(
        "AES_ASM",
        "BSAES_ASM",
        "CMLL_ASM",
        "ECP_NISTZ256_ASM",
        [[ENGINESDIR="C:\\Program Files\\OpenSSL\\lib\\engines-3"]],
        "GHASH_ASM",
        "KECCAK1600_ASM",
        "L_ENDIAN",
        "MD5_ASM",
        [[MODULESDIR="C:\\Program Files\\OpenSSL\\lib\\ossl-modules"]],
        "NDEBUG",
        "OPENSSL_BN_ASM_GF2m",
        "OPENSSL_BN_ASM_MONT",
        "OPENSSL_BN_ASM_MONT5",
        "OPENSSL_BUILDING_OPENSSL",
        "OPENSSL_CPUID_OBJ",
        "OPENSSL_IA32_SSE2",
        "OPENSSL_PIC",
        "OPENSSL_SUPPRESS_DEPRECATED=",
        "OPENSSL_SYS_WIN32",
        [[OPENSSLDIR="C:\\Program Files\\Common Files\\SSL"]],
        "PADLOCK_ASM",
        "POLY1305_ASM",
        "RC4_ASM",
        "SHA1_ASM",
        "SHA256_ASM",
        "SHA512_ASM",
        "STATIC_LEGACY",
        "UNICODE",
        "VPAES_ASM",
        "WHIRLPOOL_ASM",
        "WIN32_LEAN_AND_MEAN",
        "X25519_ASM",
        "_CRT_SECURE_NO_DEPRECATE",
        "_UNICODE",
        "_WINSOCK_DEPRECATED_NO_WARNINGS"
    )
    -- add_cflags("/Gs0", "/GF", "/Gy", "/W3", "/wd4090", {force = true})

    -- add_syslinks("ws2_32", "gdi32", "advapi32", "crypt32", "user32", {public = true})
