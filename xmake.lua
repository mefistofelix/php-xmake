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
        os.run("hx %s/fbclient-4.0.7-vs18-x64.zip in/deps/fbclient",bp)
        os.run("hx %s/freetype-2.14.3-vs18-x64.zip in/deps/freetype",bp)
        os.run("hx %s/glib-2.88.1-1-vs18-x64.zip in/deps/glib",bp)
        os.run("hx %s/libargon2-20190702-vs18-x64.zip in/deps/libargon2",bp)
        os.run("hx %s/libavif-1.4.2-vs18-x64.zip in/deps/libavif",bp)
        os.run("hx %s/libenchant2-2.8.16-1-vs18-x64.zip in/deps/libenchant2",bp)
        os.run("hx %s/libffi-3.6.0-vs18-x64.zip in/deps/libffi",bp)
        os.run("hx %s/libheif-1.23.1-vs18-x64.zip in/deps/libheif",bp)
        os.run("hx -delpathseg 1 https://ftp.gnu.org/pub/gnu/gettext/gettext-1.0.tar.gz in/deps/libintl")
        os.run("hx %s/libjpeg-turbo-3.1.4.1-vs18-x64.zip in/deps/libjpeg-turbo",bp)
        os.run("hx %s/libjxl-0.11.2-vs18-x64.zip in/deps/libjxl",bp)
        os.run("hx %s/liblmdb-0.9.35-vs18-x64.zip in/deps/liblmdb",bp)
        os.run("hx github://kkos/oniguruma?ref=v6.9.10 in/deps/libonig")
        os.run("hx %s/libpng-1.6.58-vs18-x64.zip in/deps/libpng",bp)
        os.run("hx %s/libpq-16.14-vs18-x64.zip in/deps/libpq",bp)
        os.run("hx %s/libqdbm-1.8.78-vs18-x64.zip in/deps/libqdbm",bp)
        os.run("hx %s/libsasl-2.1.28-vs18-x64.zip in/deps/libsasl",bp)
        os.run("hx %s/libtidy-5.8.0-vs18-x64.zip in/deps/libtidy",bp)
        os.run("hx %s/libtiff-4.7.2rc2-vs18-x64.zip in/deps/libtiff",bp)
        os.run("hx %s/libultrahdr-1.4.0-1-vs18-x64.zip in/deps/libultrahdr",bp)
        os.run("hx %s/libwebp-1.6.0-vs18-x64.zip in/deps/libwebp",bp)
        os.run("hx github://winlibs/libxml2?ref=libxml2-2.11.9-7 in/deps/libxml2")
        os.run("hx %s/libxpm-3.5.19-vs18-x64.zip in/deps/libxpm",bp)
        os.run("hx github://winlibs/libxslt?ref=libxslt-1.1.43-2 in/deps/libxslt")
        os.run("hx %s/libzip-1.11.4-vs18-x64.zip in/deps/libzip",bp)
        os.run("hx %s/mpir-3.0.0-2-vs18-x64.zip in/deps/mpir",bp) --xmiss
        os.run("hx %s/net-snmp-5.9.4-vs18-x64.zip in/deps/net-snmp",bp) -- xmiss
        os.run("hx %s/openldap-2.6.13-2-vs18-x64.zip in/deps/openldap",bp) -- xmiss
        os.run("hx %s/sqlite3-3.53.2-vs18-x64.zip in/deps/sqlite3",bp) --xold
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
    set_enabled(true)
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
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    on_prepare(function ()
        io.writefile(
            "in/deps/libintl/gettext-runtime/intl/config.h",
            (io.readfile("in/deps/libintl/gettext-runtime/intl/config.h.in")
                :gsub("#undef ENABLE_NLS", "#define ENABLE_NLS 1")
                :gsub("#undef FLEXIBLE_ARRAY_MEMBER", "#define FLEXIBLE_ARRAY_MEMBER 1")
                :gsub("#undef HAVE_C_STATIC_ASSERT", "#define HAVE_C_STATIC_ASSERT 1")
                :gsub("#undef HAVE_ICONV", "#define HAVE_ICONV 1")
                :gsub("#undef HAVE_LONG_LONG_INT", "#define HAVE_LONG_LONG_INT 1")
                :gsub("#undef HAVE_MBRTOWC", "#define HAVE_MBRTOWC 1")
                :gsub("#undef HAVE_MBSINIT", "#define HAVE_MBSINIT 1")
                :gsub("#undef HAVE_MBSTATE_T", "#define HAVE_MBSTATE_T 1")
                :gsub("#undef HAVE_STDBOOL_H", "#define HAVE_STDBOOL_H 1")
                :gsub("#undef HAVE_STDINT_H_WITH_UINTMAX", "#define HAVE_STDINT_H_WITH_UINTMAX 1")
                :gsub("#undef HAVE_STDINT_H([%c])", "#define HAVE_STDINT_H 1%1")
                :gsub("#undef HAVE_UNSIGNED_LONG_LONG_INT", "#define HAVE_UNSIGNED_LONG_LONG_INT 1")
                :gsub("#undef HAVE_WCHAR_H", "#define HAVE_WCHAR_H 1")
                :gsub("#undef HAVE_WCRTOMB", "#define HAVE_WCRTOMB 1")
                :gsub("#undef HAVE_WINT_T", "#define HAVE_WINT_T 1")
                :gsub("#undef ICONV_CONST", "#define ICONV_CONST")
                :gsub("#undef PACKAGE([%c])", "#define PACKAGE \"gettext\"%1")
                :gsub("#undef PACKAGE_NAME", "#define PACKAGE_NAME \"libintl\"")
                :gsub("#undef PACKAGE_VERSION", "#define PACKAGE_VERSION \"1.0\"")
                :gsub("#undef rpl_mbrtowc", "#define rpl_mbrtowc _libintl_mbrtowc")
                :gsub("#undef rpl_mbsinit", "#define rpl_mbsinit _libintl_mbsinit")
                :gsub("#undef rpl_tdelete", "#define rpl_tdelete _libintl_tdelete")
                :gsub("#undef rpl_tfind", "#define rpl_tfind _libintl_tfind")
                :gsub("#undef rpl_tsearch", "#define rpl_tsearch _libintl_tsearch")
                :gsub("#undef rpl_twalk", "#define rpl_twalk _libintl_twalk")
                :gsub("#undef tdelete", "#define tdelete _libintl_tdelete")
                :gsub("#undef tfind", "#define tfind _libintl_tfind")
                :gsub("#undef tsearch", "#define tsearch _libintl_tsearch")
                :gsub("#undef twalk", "#define twalk _libintl_twalk")
                :gsub("#undef USE_WINDOWS_THREADS", "#define USE_WINDOWS_THREADS 1")
                :gsub("#undef VERSION", "#define VERSION \"1.0\""))
        )
        local header = io.readfile("in/deps/libintl/gettext-runtime/intl/libgnuintl.in.h")
            :gsub("@HAVE_POSIX_PRINTF@", "0")
            :gsub("@HAVE_ASPRINTF@", "0")
            :gsub("@HAVE_SNPRINTF@", "0")
            :gsub("@HAVE_WPRINTF@", "0")
            :gsub("@HAVE_NEWLOCALE@", "0")
            :gsub("@ENHANCE_LOCALE_FUNCS@", "0")
            :gsub("@WOE32DLL@", "0")
        io.writefile("in/deps/libintl/gettext-runtime/intl/libgnuintl.h", header)
        io.writefile("in/deps/libintl/gettext-runtime/intl/libintl.h", header)
        io.writefile(
            "in/deps/libintl/gettext-runtime/intl/gnulib-lib/search.h",
            [[#include "c++defs.h"
#include "arg-nonnull.h"
#include "warn-on-use.h"
]] .. (io.readfile("in/deps/libintl/gettext-runtime/intl/gnulib-lib/search.in.h")
                :gsub("@GUARD_PREFIX@", "GL")
                :gsub("@PRAGMA_SYSTEM_HEADER@", "")
                :gsub("@PRAGMA_COLUMNS@", "")
                :gsub("@HAVE_SEARCH_H@", "0")
                :gsub("@INCLUDE_NEXT@ @NEXT_SEARCH_H@", "include <search.h>")
                :gsub("@GNULIB_TSEARCH@", "1")
                :gsub("@HAVE_TSEARCH@", "0")
                :gsub("@HAVE_TWALK@", "0")
                :gsub("@HAVE_TYPE_VISIT@", "0")
                :gsub("@[^@\r\n]+@", "0"))
        )
        io.writefile(
            "in/deps/libintl/gettext-runtime/intl/gnulib-lib/unistd.h",
            [[#include "c++defs.h"
#include "arg-nonnull.h"
#include "warn-on-use.h"
]] .. (io.readfile("in/deps/libintl/gettext-runtime/intl/gnulib-lib/unistd.in.h")
                :gsub("@GUARD_PREFIX@", "GL")
                :gsub("@PRAGMA_SYSTEM_HEADER@", "")
                :gsub("@PRAGMA_COLUMNS@", "")
                :gsub("@HAVE_UNISTD_H@", "0")
                :gsub("@INCLUDE_NEXT@ @NEXT_UNISTD_H@", "include <unistd.h>")
                :gsub("@GNULIB_GETCWD@", "1")
                :gsub("@REPLACE_GETCWD@", "1")
                :gsub("@[^@\r\n]+@", "0"))
        )
        local locale_h = path.absolute(path.join(
            get_config("sdk"), "Windows Kits", "10", "Include",
            get_config("vs_sdkver"), "ucrt", "locale.h")):gsub("\\", "/")
        io.writefile(
            "in/deps/libintl/gettext-runtime/intl/gnulib-lib/locale.h",
            [[#include "c++defs.h"
#include "arg-nonnull.h"
#include "warn-on-use.h"
]] .. (io.readfile("in/deps/libintl/gettext-runtime/intl/gnulib-lib/locale.in.h")
                :gsub("@GUARD_PREFIX@", "GL")
                :gsub("@PRAGMA_SYSTEM_HEADER@", "")
                :gsub("@PRAGMA_COLUMNS@", "")
                :gsub("@INCLUDE_NEXT@", "include")
                :gsub("@NEXT_LOCALE_H@", "\"" .. locale_h .. "\"")
                :gsub("@HAVE_LOCALE_T@", "0")
                :gsub("@HAVE_WINDOWS_LOCALE_T@", "1")
                :gsub("@GNULIB_LOCALECONV@", "1")
                :gsub("@GNULIB_SETLOCALE@", "0")
                :gsub("@GNULIB_SETLOCALE_NULL@", "1")
                :gsub("@GNULIB_NEWLOCALE@", "0")
                :gsub("@GNULIB_DUPLOCALE@", "0")
                :gsub("@GNULIB_FREELOCALE@", "0")
                :gsub("@GNULIB_GETLOCALENAME_L@", "0")
                :gsub("@GNULIB_GETLOCALENAME_L_UNSAFE@", "1")
                :gsub("@GNULIB_LOCALENAME_UNSAFE@", "1")
                :gsub("@HAVE_NEWLOCALE@", "0")
                :gsub("@HAVE_DUPLOCALE@", "0")
                :gsub("@HAVE_FREELOCALE@", "0")
                :gsub("@HAVE_GETLOCALENAME_L@", "0")
                :gsub("@HAVE_XLOCALE_H@", "0")
                :gsub("@REPLACE_LOCALECONV@", "0")
                :gsub("@REPLACE_SETLOCALE@", "0")
                :gsub("@REPLACE_NEWLOCALE@", "0")
                :gsub("@REPLACE_DUPLOCALE@", "0")
                :gsub("@REPLACE_FREELOCALE@", "0")
                :gsub("@REPLACE_GETLOCALENAME_L@", "0")
                :gsub("@REPLACE_STRUCT_LCONV@", "0")
                :gsub("@LOCALENAME_ENHANCE_LOCALE_FUNCS@", "0")
                :gsub("@[^@\r\n]+@", "0"))
        )
        local float_h = path.absolute(path.join(
            get_config("sdk"), "Windows Kits", "10", "Include",
            get_config("vs_sdkver"), "ucrt", "float.h")):gsub("\\", "/")
        io.writefile(
            "in/deps/libintl/gettext-runtime/intl/gnulib-lib/float.h",
            (io.readfile("in/deps/libintl/gettext-runtime/intl/gnulib-lib/float.in.h")
                :gsub("@GUARD_PREFIX@", "GL")
                :gsub("@INCLUDE_NEXT@", "include")
                :gsub("@PRAGMA_SYSTEM_HEADER@", "")
                :gsub("@PRAGMA_COLUMNS@", "")
                :gsub("@NEXT_FLOAT_H@", "\"" .. float_h .. "\"")
                :gsub("@REPLACE_ITOLD@", "0"))
        )
        io.writefile(
            "in/deps/libintl/gettext-runtime/intl/gnulib-lib/alloca.h",
            (io.readfile("in/deps/libintl/gettext-runtime/intl/gnulib-lib/alloca.in.h")
                :gsub("@HAVE_ALLOCA_H@", "0"))
        )
        io.writefile(
            "in/deps/libintl/gettext-runtime/intl/gnulib-lib/stdckdint.h",
            (io.readfile("in/deps/libintl/gettext-runtime/intl/gnulib-lib/stdckdint.in.h")
                :gsub("@GUARD_PREFIX@", "GL")
                :gsub("@INCLUDE_NEXT@ @NEXT_STDCKDINT_H@", "include <stdckdint.h>")
                :gsub("@PRAGMA_SYSTEM_HEADER@", "")
                :gsub("@PRAGMA_COLUMNS@", "")
                :gsub("@HAVE_C_STDCKDINT_H@", "0")
                :gsub("@HAVE_WORKING_C_STDCKDINT_H@", "0")
                :gsub("@HAVE_CXX_STDCKDINT_H@", "0")
                :gsub("@HAVE_WORKING_CXX_STDCKDINT_H@", "0"))
        )
        io.writefile(
            "in/deps/libintl/gettext-runtime/intl/gnulib-lib/sched.h",
            [[#include "c++defs.h"
#include "warn-on-use.h"
]] .. (io.readfile("in/deps/libintl/gettext-runtime/intl/gnulib-lib/sched.in.h")
                :gsub("@GUARD_PREFIX@", "GL")
                :gsub("@HAVE_SCHED_H@", "0")
                :gsub("@HAVE_SYS_CDEFS_H@", "0")
                :gsub("@INCLUDE_NEXT@ @NEXT_SCHED_H@", "include <sched.h>")
                :gsub("@PRAGMA_SYSTEM_HEADER@", "")
                :gsub("@PRAGMA_COLUMNS@", "")
                :gsub("@HAVE_STRUCT_SCHED_PARAM@", "0")
                :gsub("@GNULIB_SCHED_YIELD@", "0")
                :gsub("@HAVE_SCHED_YIELD@", "0")
                :gsub("@REPLACE_SCHED_YIELD@", "0")
                :gsub("@[^@\r\n]+@", "0"))
        )
        io.writefile(
            "in/deps/libintl/gettext-runtime/intl/gnulib-lib/pthread.h",
            [[#include "c++defs.h"
#include "arg-nonnull.h"
#include "warn-on-use.h"
]] .. (io.readfile("in/deps/libintl/gettext-runtime/intl/gnulib-lib/pthread.in.h")
                :gsub("@GUARD_PREFIX@", "GL")
                :gsub("@HAVE_PTHREAD_H@", "0")
                :gsub("@INCLUDE_NEXT@ @NEXT_PTHREAD_H@", "include <pthread.h>")
                :gsub("@PRAGMA_SYSTEM_HEADER@", "")
                :gsub("@PRAGMA_COLUMNS@", "")
                :gsub("@GNULIB_PTHREAD_ONCE@", "1")
                :gsub("@HAVE_PTHREAD_T@", "0")
                :gsub("@HAVE_PTHREAD_ONCE@", "0")
                :gsub("@REPLACE_PTHREAD_ONCE@", "1")
                :gsub("@[^@\r\n]+@", "0"))
        )
        local wchar_h = path.absolute(path.join(
            get_config("sdk"), "Windows Kits", "10", "Include",
            get_config("vs_sdkver"), "ucrt", "wchar.h")):gsub("\\", "/")
        io.writefile(
            "in/deps/libintl/gettext-runtime/intl/gnulib-lib/wchar.h",
            [[#include "c++defs.h"
#include "arg-nonnull.h"
#include "warn-on-use.h"
]] .. (io.readfile("in/deps/libintl/gettext-runtime/intl/gnulib-lib/wchar.in.h")
                :gsub("@GUARD_PREFIX@", "GL")
                :gsub("@PRAGMA_SYSTEM_HEADER@", "")
                :gsub("@PRAGMA_COLUMNS@", "")
                :gsub("@HAVE_FEATURES_H@", "0")
                :gsub("@INCLUDE_NEXT@", "include")
                :gsub("@NEXT_WCHAR_H@", "\"" .. wchar_h .. "\"")
                :gsub("@HAVE_WCHAR_H@", "1")
                :gsub("@HAVE_CRTDEFS_H@", "0")
                :gsub("@GNULIBHEADERS_OVERRIDE_WINT_T@", "0")
                :gsub("@GNULIB_MBSINIT@", "1")
                :gsub("@GNULIB_MBSZERO@", "1")
                :gsub("@GNULIB_MBRTOWC@", "1")
                :gsub("@GNULIB_WCWIDTH@", "1")
                :gsub("@GNULIB_WGETCWD@", "1")
                :gsub("@GNULIB_FREE_POSIX@", "1")
                :gsub("@HAVE_WINT_T@", "1")
                :gsub("@HAVE_MBSINIT@", "1")
                :gsub("@HAVE_MBRTOWC@", "1")
                :gsub("@HAVE_WCRTOMB@", "1")
                :gsub("@HAVE_DECL_WCWIDTH@", "0")
                :gsub("@REPLACE_MBSTATE_T@", "0")
                :gsub("@REPLACE_MBSINIT@", "1")
                :gsub("@REPLACE_MBRTOWC@", "1")
                :gsub("@REPLACE_WCWIDTH@", "0")
                :gsub("@[^@\r\n]+@", "0"))
        )
        local uchar_h = path.absolute(path.join(
            get_config("sdk"), "Windows Kits", "10", "Include",
            get_config("vs_sdkver"), "ucrt", "uchar.h")):gsub("\\", "/")
        io.writefile(
            "in/deps/libintl/gettext-runtime/intl/gnulib-lib/uchar.h",
            [[#include "c++defs.h"
#include "arg-nonnull.h"
#include "warn-on-use.h"
]] .. (io.readfile("in/deps/libintl/gettext-runtime/intl/gnulib-lib/uchar.in.h")
                :gsub("@GUARD_PREFIX@", "GL")
                :gsub("@HAVE_UCHAR_H@", "1")
                :gsub("@CXX_HAVE_UCHAR_H@", "1")
                :gsub("@INCLUDE_NEXT@", "include")
                :gsub("@PRAGMA_SYSTEM_HEADER@", "")
                :gsub("@PRAGMA_COLUMNS@", "")
                :gsub("@NEXT_UCHAR_H@", "\"" .. uchar_h .. "\"")
                :gsub("@CXX_HAS_CHAR8_TYPE@", "0")
                :gsub("@CXX_HAS_UCHAR_TYPES@", "1")
                :gsub("@SMALL_WCHAR_T@", "1")
                :gsub("@GNULIBHEADERS_OVERRIDE_CHAR8_T@", "0")
                :gsub("@GNULIBHEADERS_OVERRIDE_CHAR16_T@", "0")
                :gsub("@GNULIBHEADERS_OVERRIDE_CHAR32_T@", "0")
                :gsub("@GNULIB_C32ISALNUM@", "1")
                :gsub("@GNULIB_C32ISALPHA@", "1")
                :gsub("@GNULIB_C32ISBLANK@", "1")
                :gsub("@GNULIB_C32ISCNTRL@", "1")
                :gsub("@GNULIB_C32ISDIGIT@", "1")
                :gsub("@GNULIB_C32ISGRAPH@", "1")
                :gsub("@GNULIB_C32ISLOWER@", "1")
                :gsub("@GNULIB_C32ISPRINT@", "1")
                :gsub("@GNULIB_C32ISPUNCT@", "1")
                :gsub("@GNULIB_C32ISSPACE@", "1")
                :gsub("@GNULIB_C32ISUPPER@", "1")
                :gsub("@GNULIB_C32ISXDIGIT@", "1")
                :gsub("@GNULIB_C32TOLOWER@", "1")
                :gsub("@GNULIB_C32WIDTH@", "1")
                :gsub("@GNULIB_MBRTOC32@", "1")
                :gsub("@HAVE_MBRTOC32@", "1")
                :gsub("@REPLACE_MBRTOC32@", "1")
                :gsub("@[^@\r\n]+@", "0"))
        )
        io.writefile(
            "in/deps/libintl/gettext-runtime/intl/gnulib-lib/unicase.h",
            (io.readfile("in/deps/libintl/gettext-runtime/intl/gnulib-lib/unicase.in.h")
                :gsub("@HAVE_UNISTRING_WOE32DLL_H@", "0")
                :gsub("@[^@\r\n]+@", ""))
        )
        io.writefile(
            "in/deps/libintl/gettext-runtime/intl/gnulib-lib/unictype.h",
            (io.readfile("in/deps/libintl/gettext-runtime/intl/gnulib-lib/unictype.in.h")
                :gsub("@HAVE_UNISTRING_WOE32DLL_H@", "0")
                :gsub("@[^@\r\n]+@", ""))
        )
        io.writefile(
            "in/deps/libintl/gettext-runtime/intl/gnulib-lib/uninorm.h",
            (io.readfile("in/deps/libintl/gettext-runtime/intl/gnulib-lib/uninorm.in.h")
                :gsub("@HAVE_UNISTRING_WOE32DLL_H@", "0")
                :gsub("@[^@\r\n]+@", ""))
        )
        os.cp(
            "in/deps/libintl/gettext-runtime/intl/gnulib-lib/unitypes.in.h",
            "in/deps/libintl/gettext-runtime/intl/gnulib-lib/unitypes.h"
        )
        os.cp(
            "in/deps/libintl/gettext-runtime/intl/gnulib-lib/uniwidth.in.h",
            "in/deps/libintl/gettext-runtime/intl/gnulib-lib/uniwidth.h"
        )
        local resource = path.join(get_config("builddir"), "libintl.rc")
        local res = path.join(get_config("builddir"), "libintl.res")
        local object = path.join(get_config("builddir"), "libintl.res.obj")
        io.writefile(
            resource,
            (io.readfile("in/deps/libintl/gettext-runtime/intl/libintl.rc")
                :gsub("PACKAGE_VERSION_STRING", "\"1.0\"")
                :gsub("PACKAGE_VERSION_MAJOR", "1")
                :gsub("PACKAGE_VERSION_MINOR", "0")
                :gsub("PACKAGE_VERSION_SUBMINOR", "0"))
        )
        os.vrunv(path.join(
            get_config("sdk"), "Windows Kits", "10", "bin",
            get_config("vs_sdkver"), "x64", "rc.exe"
        ), {"-nologo", "-Fo" .. res, resource})
        os.vrunv(path.join(
            get_config("sdk"), "VC", "Tools", "MSVC", get_config("vs_toolset"),
            "bin", "Hostx64", "x64", "cvtres.exe"
        ), {"/nologo", "/machine:x64", "/readonly", "/out:" .. object, res})
    end)
    add_deps("libiconv")
    add_includedirs("in/deps/libintl/gettext-runtime/intl", {public = true})
    add_includedirs("in/deps/libintl/gettext-runtime/intl/gnulib-lib")
    add_defines(
        "BUILDING_LIBINTL",
        "BUILDING_LIBRARY",
        "HAVE_CONFIG_H",
        "LIBDIR=\".\"",
        "LOCALEDIR=\".\"",
        "_GL_SMALL_WCHAR_T=1",
        "_CRT_SECURE_NO_WARNINGS",
        "_WIN32_WINNT=0x0601"
    )
    add_syslinks("advapi32", {public = true})
    add_files(
        "in/deps/libintl/gettext-runtime/intl/*.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/*.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/glthread/*.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/unicase/*.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/unictype/*.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/uniwidth/*.c"
    )
    add_files("out/libintl.res.obj", {always_added = true})
    remove_files(
        "in/deps/libintl/gettext-runtime/intl/intl-exports.c",
        "in/deps/libintl/gettext-runtime/intl/os2compat.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/frexp.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/frexpl.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/isnan.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/isnand.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/iswblank.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/iswdigit.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/iswpunct.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/iswxdigit.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/itold.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/lc-charset-dispatch.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/localeconv.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/mbtowc-lock.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/memchr.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/setlocale-lock.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/signbitd.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/signbitf.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/signbitl.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/stdio-read.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/stdio-write.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/strncpy.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/wmemcpy.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/wmemset.c"
    )

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
        "in/deps/openssl/crypto/LPdir_*.c",
        "in/deps/openssl/crypto/ec/ecp_nistp*.c",
        "in/deps/openssl/crypto/ec/ecp_nistz256_table.c",
        "in/deps/openssl/crypto/poly1305/poly1305_*.c",
        "in/deps/openssl/crypto/rc5/*.c",
        "in/deps/openssl/demos/**/*.c",
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
    add_files("in/deps/openssl/**/*x86_64*.asm")

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
