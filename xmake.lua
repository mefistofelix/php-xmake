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
        os.run("hx %s/libiconv-1.19-1-vs18-x64.zip in/deps/libiconv",bp)
        os.run("hx %s/libintl-1.0-vs18-x64.zip in/deps/libintl",bp)
        os.run("hx %s/libjpeg-turbo-3.1.4.1-vs18-x64.zip in/deps/libjpeg-turbo",bp)
        os.run("hx %s/libjxl-0.11.2-vs18-x64.zip in/deps/libjxl",bp)
        os.run("hx %s/liblmdb-0.9.35-vs18-x64.zip in/deps/liblmdb",bp)
        os.run("hx %s/libonig-6.9.10-vs18-x64.zip in/deps/libonig",bp)
        os.run("hx %s/libpng-1.6.58-vs18-x64.zip in/deps/libpng",bp)
        os.run("hx %s/libpq-16.14-vs18-x64.zip in/deps/libpq",bp)
        os.run("hx %s/libqdbm-1.8.78-vs18-x64.zip in/deps/libqdbm",bp)
        os.run("hx %s/libsasl-2.1.28-vs18-x64.zip in/deps/libsasl",bp)
        os.run("hx %s/libtidy-5.8.0-vs18-x64.zip in/deps/libtidy",bp)
        os.run("hx %s/libtiff-4.7.2rc2-vs18-x64.zip in/deps/libtiff",bp)
        os.run("hx %s/libultrahdr-1.4.0-1-vs18-x64.zip in/deps/libultrahdr",bp)
        os.run("hx %s/libwebp-1.6.0-vs18-x64.zip in/deps/libwebp",bp)
        os.run("hx %s/libxml2-2.11.9-7-vs18-x64.zip in/deps/libxml2",bp)
        os.run("hx %s/libxpm-3.5.19-vs18-x64.zip in/deps/libxpm",bp)
        os.run("hx %s/libxslt-1.1.43-2-vs18-x64.zip in/deps/libxslt",bp)
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
