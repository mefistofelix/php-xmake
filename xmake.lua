set_toolchains("msvc")
set_runtimes("MD")
set_config("sdk", path.join(os.scriptdir(),[[in\msvc]]))
-- set_config("vs_toolset", "14.44.35207")
-- set_config("vs_sdkver", "10.0.22621.0")
set_config("vs_toolset", "14.50.35717")
set_config("vs_sdkver", "10.0.28000.0")

set_config("builddir", "out")

rule("cb")
    on_prepare_file(function (target, sourcefile, opt)
        local fileconfig = target:fileconfig(sourcefile)
        if fileconfig and type(fileconfig.cb) == "function" then
            fileconfig.cb(target, sourcefile, opt)
        end
    end)

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
        os.run("hx github://nghttp2/nghttp2?ref=v1.69.0 in/deps/nghttp2")
        os.run("hx github://ngtcp2/ngtcp2?ref=v1.25.0 in/deps/ngtcp2")
        os.run("hx github://ngtcp2/nghttp3?ref=v1.18.0 in/deps/nghttp3")
        os.run("hx github://openssl/openssl?ref=openssl-3.5 in/deps/openssl")
        os.run("hx github://libuv/libuv?ref=v1.52.1 in/deps/libuv")

        local bp = "https://downloads.php.net/~windows/php-sdk/deps/vs18/x64"
        os.run("hx %s/ICU-77.1-1-vs18-x64.zip in/deps/ICU",bp)
        os.run("hx %s/apache-2.4.68-vs18-x64.zip in/deps/apache",bp)
        os.run("hx %s/fbclient-4.0.7-vs18-x64.zip in/deps/fbclient",bp)
        os.run("hx %s/freetype-2.14.3-vs18-x64.zip in/deps/freetype",bp)
        os.run("hx %s/glib-2.88.1-1-vs18-x64.zip in/deps/glib",bp)
        os.run("hx %s/libargon2-20190702-vs18-x64.zip in/deps/libargon2",bp)
        os.run("hx %s/libavif-1.4.2-vs18-x64.zip in/deps/libavif",bp)
        os.run("hx %s/libcurl-8.21.0-1-vs18-x64.zip in/deps/libcurl",bp)
        os.run("hx %s/libenchant2-2.8.16-1-vs18-x64.zip in/deps/libenchant2",bp)
        os.run("hx %s/libffi-3.6.0-vs18-x64.zip in/deps/libffi",bp)
        os.run("hx %s/libheif-1.23.1-vs18-x64.zip in/deps/libheif",bp)
        os.run("hx %s/libiconv-1.19-1-vs18-x64.zip in/deps/libiconv",bp)
        os.run("hx %s/libintl-1.0-vs18-x64.zip in/deps/libintl",bp)
        os.run("hx %s/libjpeg-turbo-3.1.4.1-vs18-x64.zip in/deps/libjpeg-turbo",bp)
        os.run("hx %s/libjxl-0.11.2-vs18-x64.zip in/deps/libjxl",bp)
        os.run("hx %s/liblmdb-0.9.35-vs18-x64.zip in/deps/liblmdb",bp)
        os.run("hx %s/liblzma-5.8.3-vs18-x64.zip in/deps/liblzma",bp)
        os.run("hx %s/libonig-6.9.10-vs18-x64.zip in/deps/libonig",bp)
        os.run("hx %s/libpng-1.6.58-vs18-x64.zip in/deps/libpng",bp)
        os.run("hx %s/libpq-16.14-vs18-x64.zip in/deps/libpq",bp)
        os.run("hx %s/libqdbm-1.8.78-vs18-x64.zip in/deps/libqdbm",bp)
        os.run("hx %s/libsasl-2.1.28-vs18-x64.zip in/deps/libsasl",bp)
        os.run("hx %s/libsodium-1.0.22-vs18-x64.zip in/deps/libsodium",bp)
        os.run("hx %s/libssh2-1.11.1-7-vs18-x64.zip in/deps/libssh2",bp)
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
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_includedirs("in/deps/bzip2", {public = true})
    add_defines("WIN32", "_FILE_OFFSET_BITS=64")
    add_rules("c.unity_build")
    add_files("in/deps/bzip2/blocksort.c", "in/deps/bzip2/huffman.c", "in/deps/bzip2/crctable.c",
        "in/deps/bzip2/randtable.c", "in/deps/bzip2/compress.c", "in/deps/bzip2/decompress.c",
        "in/deps/bzip2/bzlib.c")

target("php")
    set_enabled(false)
    set_kind("object")
    set_targetdir(get_config("builddir"))
    add_files("in/php-src/Zend/zend.c")

    add_asflags("/DBOOST_CONTEXT_EXPORT=EXPORT", {force = true})
    add_files("in/php-src/Zend/asm/*_xmm_x86_64_ms_masm.asm")
