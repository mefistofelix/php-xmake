set_toolchains("msvc")
set_config("sdk", path.join(os.scriptdir(),[[in\msvc]]))
-- set_config("vs_toolset", "14.44.35207")
-- set_config("vs_sdkver", "10.0.22621.0")
set_config("vs_toolset", "14.50.35717")
set_config("vs_sdkver", "10.0.28000.0")

set_config("builddir", "out")

rule("cb")
    on_prepare_file(function (target, sourcefile, opt)
        local fcfg = target:fileconfig(sourcefile)
        if not fcfg or not fcfg.cb then
            return
        end
        local cb = fcfg.cb
        local is_function = type(cb) == "function"
        if is_function then
            cb(target, sourcefile, opt)
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

        -- Source dependencies built by this project. No Xmake package recipes.
        os.run("hx github://madler/zlib?ref=v1.3.2 in/deps/zlib-1.3.2")
        os.run("hx github://google/brotli?ref=v1.2.0 in/deps/brotli-1.2.0")
        os.run("hx github://facebook/zstd?ref=v1.5.7 in/deps/zstd-1.5.7")
        os.run("hx github://nghttp2/nghttp2?ref=v1.69.0 in/deps/nghttp2-1.69.0")
        os.run("hx github://libuv/libuv?ref=v1.52.1 in/deps/libuv-1.52.1")

        local bp = "https://downloads.php.net/~windows/php-sdk/deps/vs18/x64"
        os.run("hx %s/ICU-77.1-1-vs18-x64.zip in/deps/ICU-77.1-1",bp)
        os.run("hx %s/apache-2.4.68-vs18-x64.zip in/deps/apache-2.4.68",bp)
        os.run("hx %s/fbclient-4.0.7-vs18-x64.zip in/deps/fbclient-4.0.7",bp)
        os.run("hx %s/freetype-2.14.3-vs18-x64.zip in/deps/freetype-2.14.3",bp)
        os.run("hx %s/glib-2.88.1-1-vs18-x64.zip in/deps/glib-2.88.1-1",bp)
        os.run("hx %s/libargon2-20190702-vs18-x64.zip in/deps/libargon2-20190702",bp)
        os.run("hx %s/libavif-1.4.2-vs18-x64.zip in/deps/libavif-1.4.2",bp)
        os.run("hx %s/libbzip2-1.0.8-1-vs18-x64.zip in/deps/libbzip2-1.0.8-1",bp)
        os.run("hx %s/libcurl-8.21.0-1-vs18-x64.zip in/deps/libcurl-8.21.0-1",bp)
        os.run("hx %s/libenchant2-2.8.16-1-vs18-x64.zip in/deps/libenchant2-2.8.16-1",bp)
        os.run("hx %s/libffi-3.6.0-vs18-x64.zip in/deps/libffi-3.6.0",bp)
        os.run("hx %s/libheif-1.23.1-vs18-x64.zip in/deps/libheif-1.23.1",bp)
        os.run("hx %s/libiconv-1.19-1-vs18-x64.zip in/deps/libiconv-1.19-1",bp)
        os.run("hx %s/libintl-1.0-vs18-x64.zip in/deps/libintl-1.0",bp)
        os.run("hx %s/libjpeg-turbo-3.1.4.1-vs18-x64.zip in/deps/libjpeg-turbo-3.1.4.1",bp)
        os.run("hx %s/libjxl-0.11.2-vs18-x64.zip in/deps/libjxl-0.11.2",bp)
        os.run("hx %s/liblmdb-0.9.35-vs18-x64.zip in/deps/liblmdb-0.9.35",bp)
        os.run("hx %s/liblzma-5.8.3-vs18-x64.zip in/deps/liblzma-5.8.3",bp)
        os.run("hx %s/libonig-6.9.10-vs18-x64.zip in/deps/libonig-6.9.10",bp)
        os.run("hx %s/libpng-1.6.58-vs18-x64.zip in/deps/libpng-1.6.58",bp)
        os.run("hx %s/libpq-16.14-vs18-x64.zip in/deps/libpq-16.14",bp)
        os.run("hx %s/libqdbm-1.8.78-vs18-x64.zip in/deps/libqdbm-1.8.78",bp)
        os.run("hx %s/libsasl-2.1.28-vs18-x64.zip in/deps/libsasl-2.1.28",bp)
        os.run("hx %s/libsodium-1.0.22-vs18-x64.zip in/deps/libsodium-1.0.22",bp)
        os.run("hx %s/libssh2-1.11.1-7-vs18-x64.zip in/deps/libssh2-1.11.1-7",bp)
        os.run("hx %s/libtidy-5.8.0-vs18-x64.zip in/deps/libtidy-5.8.0",bp)
        os.run("hx %s/libtiff-4.7.2rc2-vs18-x64.zip in/deps/libtiff-4.7.2rc2",bp)
        os.run("hx %s/libultrahdr-1.4.0-1-vs18-x64.zip in/deps/libultrahdr-1.4.0-1",bp)
        os.run("hx %s/libwebp-1.6.0-vs18-x64.zip in/deps/libwebp-1.6.0",bp)
        os.run("hx %s/libxml2-2.11.9-7-vs18-x64.zip in/deps/libxml2-2.11.9-7",bp)
        os.run("hx %s/libxpm-3.5.19-vs18-x64.zip in/deps/libxpm-3.5.19",bp)
        os.run("hx %s/libxslt-1.1.43-2-vs18-x64.zip in/deps/libxslt-1.1.43-2",bp)
        os.run("hx %s/libzip-1.11.4-vs18-x64.zip in/deps/libzip-1.11.4",bp)
        os.run("hx %s/mpir-3.0.0-2-vs18-x64.zip in/deps/mpir-3.0.0-2",bp) --xmiss
        os.run("hx %s/net-snmp-5.9.4-vs18-x64.zip in/deps/net-snmp-5.9.4",bp) -- xmiss
        os.run("hx %s/openldap-2.6.13-2-vs18-x64.zip in/deps/openldap-2.6.13-2",bp) -- xmiss
        os.run("hx %s/sqlite3-3.53.2-vs18-x64.zip in/deps/sqlite3-3.53.2",bp) --xold
        os.run("hx %s/wineditline-2.208-vs18-x64.zip in/deps/wineditline-2.208", bp)

        os.run([[msvcup install "msvc sdk" in/msvc]])
    end)

target("minilua")
    set_kind("binary")
    set_targetdir(get_config("builddir"))
    add_files("in/php-src/ext/opcache/jit/ir/dynasm/minilua.c")

target("gen_ir_fold_hash")
    set_kind("binary")
    set_targetdir(get_config("builddir"))
    add_files("in/php-src/ext/opcache/jit/ir/gen_ir_fold_hash.c")

add_defines("IR_TARGET_X86_64")

target("php-asm")
    set_kind("object")
    set_targetdir(get_config("builddir"))
    add_asflags("/DBOOST_CONTEXT_EXPORT=EXPORT", {force = true})
    add_files("in/php-src/Zend/asm/*_xmm_x86_64_ms_masm.asm")

target("php")
    set_kind("object")
    set_targetdir(get_config("builddir"))
    add_files("in/php-src/Zend/zend.c", {
        -- always_added = true,
        rules = "cb",
        cb = function ()
            print("add files 1")
            return "aaa"
        end
    })
