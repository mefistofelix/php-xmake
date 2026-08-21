set_toolchains("msvc")
set_runtimes("MD")
set_config("sdk", path.join(os.scriptdir(),[[in\msvc]]))
-- set_config("vs_toolset", "14.44.35207")
-- set_config("vs_sdkver", "10.0.22621.0")
set_config("vs_toolset", "14.50.35717")
set_config("vs_sdkver", "10.0.28000.0")

set_config("builddir", "out")

on_toolchain_prepare(function (toolchain)
    if toolchain:name() ~= "msvc" then return end
    os.mkdir("in")
    os.vrunv("curl.exe", {"-Ls", "--skip-existing", "-o", "in/hx.exe", "https://github.com/mefistofelix/hx/releases/latest/download/hx.exe"})
    os.vrunv("in/hx.exe", {"https://github.com/mefistofelix/msvcup/releases/latest/download/msvcup.exe", "in/msvcup.exe"})
    os.vrunv("in/msvcup.exe", {"install", "msvc sdk", "in/msvc"})
end)

target("minilua")
    before_config(function () os.vrunv("in/hx.exe", {"github://true-async/php-src?ref=true-async-stable", "in/php-src"}) end)
    set_enabled(true)
    set_default(false)
    set_kind("binary")
    set_targetdir(get_config("builddir"))
    add_files("in/php-src/ext/opcache/jit/ir/dynasm/minilua.c")

target("gen_ir_fold_hash")
    before_config(function () os.vrunv("in/hx.exe", {"github://true-async/php-src?ref=true-async-stable", "in/php-src"}) end)
    set_enabled(true)
    set_default(false)
    set_kind("binary")
    set_targetdir(get_config("builddir"))
    add_files("in/php-src/ext/opcache/jit/ir/gen_ir_fold_hash.c")
    add_defines("IR_TARGET_X64")

target("zlib")
    before_config(function () os.vrunv("in/hx.exe", {"github://madler/zlib?ref=v1.3.2", "in/deps/zlib"}) end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    add_includedirs("in/deps/zlib", {public = true})
    add_defines("ZLIB_BUILD", "NO_FSEEKO", "_CRT_SECURE_NO_DEPRECATE", "_CRT_NONSTDC_NO_DEPRECATE")
    add_files("in/deps/zlib/*.c")

target("brotli")
    before_config(function () os.vrunv("in/hx.exe", {"github://google/brotli?ref=v1.2.0", "in/deps/brotli"}) end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    add_includedirs("in/deps/brotli/c/include", {public = true})
    add_defines("_CRT_SECURE_NO_WARNINGS")
    add_files("in/deps/brotli/c/common/*.c", "in/deps/brotli/c/dec/*.c", "in/deps/brotli/c/enc/*.c")

target("zstd")
    before_config(function () os.vrunv("in/hx.exe", {"github://facebook/zstd?ref=v1.5.7", "in/deps/zstd"}) end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    add_includedirs("in/deps/zstd/lib", {public = true})
    add_defines("ZSTD_MULTITHREAD", "ZSTD_LEGACY_SUPPORT=5", "ZSTD_DISABLE_ASM", "ZSTD_HEAPMODE=0", "_CRT_SECURE_NO_WARNINGS")
    add_files("in/deps/zstd/lib/common/*.c", "in/deps/zstd/lib/compress/*.c",
        "in/deps/zstd/lib/decompress/*.c", "in/deps/zstd/lib/dictBuilder/*.c", "in/deps/zstd/lib/legacy/*.c")

target("bzip2")
    before_config(function () os.vrunv("in/hx.exe", {"-delpathseg", "1", "https://sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz", "in/deps/bzip2"}) end)
    set_enabled(true)
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
    before_config(function () os.vrunv("in/hx.exe", {"github://tukaani-project/xz?ref=v5.8.3", "in/deps/xz"}) end)
    set_enabled(true)
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
    add_files("in/deps/xz/src/common/tuklib_cpucores.c", "in/deps/xz/src/common/tuklib_physmem.c")
    add_files("in/deps/xz/src/liblzma/common/*.c", "in/deps/xz/src/liblzma/delta/*.c",
        "in/deps/xz/src/liblzma/lz/*.c", "in/deps/xz/src/liblzma/simple/*.c")
    add_files("in/deps/xz/src/liblzma/check/check.c", "in/deps/xz/src/liblzma/check/crc32_fast.c",
        "in/deps/xz/src/liblzma/check/crc64_fast.c", "in/deps/xz/src/liblzma/check/sha256.c")
    add_files("in/deps/xz/src/liblzma/lzma/*.c|*tablegen.c",
        "in/deps/xz/src/liblzma/rangecoder/price_table.c")

target("libssh2")
    before_config(function () os.vrunv("in/hx.exe", {"github://libssh2/libssh2?ref=libssh2-1.11.1", "in/deps/libssh2"}) end)
    set_enabled(true)
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
    add_rules("c.unity_build")
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
    before_config(function () os.vrunv("in/hx.exe", {"github://nghttp2/nghttp2?ref=v1.69.0", "in/deps/nghttp2"}) end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    set_configdir("out/nghttp2/include/nghttp2")
    add_configfiles("in/deps/nghttp2/lib/includes/nghttp2/nghttp2ver.h.in",
        {pattern = "@([%u%d_]+)@", variables = {PACKAGE_VERSION = "1.69.0", PACKAGE_VERSION_NUM = "0x014500"}})
    add_includedirs("out/nghttp2/include", "in/deps/nghttp2/lib/includes", {public = true})
    add_defines("NGHTTP2_STATICLIB", {public = true})
    add_defines(
        "BUILDING_NGHTTP2",
        "HAVE_GETTICKCOUNT64",
        "HAVE_WINDOWS_H",
        "ssize_t=int"
    )
    add_files("in/deps/nghttp2/lib/*.c")

target("nghttp3")
    before_config(function () os.vrunv("in/hx.exe", {"--recursive", "github://ngtcp2/nghttp3?ref=dbfc24286138cb0b6490160e7ca87fe1ce6722a0", "in/deps/nghttp3"}) end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    set_languages("c11")
    set_configdir("out/nghttp3/include/nghttp3")
    add_configfiles("in/deps/nghttp3/lib/includes/nghttp3/version.h.in",
        {pattern = "@([%u%d_]+)@", variables = {PACKAGE_VERSION = "1.18.0", PACKAGE_VERSION_NUM = "0x011200"}})
    add_includedirs("out/nghttp3/include", "in/deps/nghttp3/lib/includes", {public = true})
    add_defines("NGHTTP3_STATICLIB", {public = true})
    add_defines("BUILDING_NGHTTP3")
    add_files(
        "in/deps/nghttp3/lib/*.c",
        "in/deps/nghttp3/lib/sfparse/sfparse.c"
    )

target("ngtcp2")
    before_config(function () os.vrunv("in/hx.exe", {"github://ngtcp2/ngtcp2?ref=v1.25.0", "in/deps/ngtcp2"}) end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    set_languages("c11")
    add_deps("openssl")
    set_configdir("out/ngtcp2/include/ngtcp2")
    add_configfiles("in/deps/ngtcp2/lib/includes/ngtcp2/version.h.in",
        {pattern = "@([%u%d_]+)@", variables = {PACKAGE_VERSION = "1.25.0", PACKAGE_VERSION_NUM = "0x011900"}})
    add_includedirs(
        "out/ngtcp2/include",
        "in/deps/ngtcp2/lib/includes",
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
        "in/deps/ngtcp2/lib/*.c",
        "in/deps/ngtcp2/crypto/ossl/ossl.c",
        "in/deps/ngtcp2/crypto/shared.c"
    )

target("libcurl")
    before_config(function () os.vrunv("in/hx.exe", {"github://curl/curl?ref=curl-8_21_0", "in/deps/libcurl"}) end)
    set_enabled(true)
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
    add_rules("c.unity_build")
    add_files(
        "in/deps/libcurl/lib/*.c",
        "in/deps/libcurl/lib/**/*.c"
    )
    remove_files("in/deps/libcurl/lib/dllmain.c")

target("libsodium")
    before_config(function () os.vrunv("in/hx.exe", {"github://jedisct1/libsodium?ref=1.0.22", "in/deps/libsodium"}) end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    set_configdir("out/libsodium/include/sodium")
    add_configfiles("in/deps/libsodium/builds/msvc/version.h", {onlycopy = true})
    add_includedirs("out/libsodium/include", "in/deps/libsodium/src/libsodium/include", {public = true})
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
    before_config(function () os.vrunv("in/hx.exe", {"github://libuv/libuv?ref=v1.52.1", "in/deps/libuv"}) end)
    set_enabled(true)
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
    before_config(function ()
        os.vrunv("in/hx.exe", {"github://unicode-org/icu?ref=release-77-1", "in/deps/ICU"})
        os.vrunv("in/hx.exe", {"-repath", "icudt*.dat", "https://github.com/unicode-org/icu/releases/download/release-77-1/icu4c-77_1-data-bin-l.zip", "in/deps/ICU/icu4c/source/data/in"})
        os.vrunv("in/hx.exe", {"-repath", "genccode.exe,icu*.dll", "https://github.com/unicode-org/icu/releases/download/release-77-1/icu4c-77_1-Win64-MSVC2022.zip", "in/icu4c"})
    end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    set_languages("cxx17")
    set_exceptions("no-cxx")
    add_files("in/deps/ICU/icu4c/source/common/ucnv.cpp", {
        defines = {"U_COMMON_IMPLEMENTATION", "U_PLATFORM_USES_ONLY_WIN32_API=1"}
    })
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
    add_files("in/deps/ICU/icu4c/source/common/*.cpp|ucnv.cpp", {
        defines = {"U_COMMON_IMPLEMENTATION", "U_PLATFORM_USES_ONLY_WIN32_API=1"}
    })
    add_files("in/deps/ICU/icu4c/source/i18n/*.cpp", {
        defines = {"U_I18N_IMPLEMENTATION"}
    })
    add_files("in/deps/ICU/icu4c/source/data/in/icudt77l.dat", {callback = function (sourcefile, sources, depend)
        local output = sourcefile:sub(1, -5) .. "_dat.obj"
        table.insert(depend.files, "in/icu4c/genccode.exe")
        os.vrunv("in/icu4c/genccode.exe", {"-q", "-o", "--skip-dll-export", "-e", "icudt77", "-d", path.directory(output), sourcefile})
        sources[1] = output
    end})

target("libiconv")
    before_config(function () os.vrunv("in/hx.exe", {"-delpathseg", "1", "https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.19.tar.gz", "in/deps/libiconv"}) end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_files("in/deps/libiconv/lib/config.h.in", {callback = function (_, sources, depend)
        local output = "in/deps/libiconv/lib/config.h"
        io.writefile(output, [[
            #define ENABLE_EXTRA 0
            #define HAVE_LANGINFO_CODESET 0
            #define HAVE_MBRTOWC 1
            #define HAVE_MBSINIT 1
            #define HAVE_WCRTOMB 1
            #define ICONV_CONST
            #define WORDS_LITTLEENDIAN 1
        ]])
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
    set_configdir("out/libiconv")
    add_configfiles("in/deps/libiconv/include/iconv.h.build.in", {filename = "iconv.h", prefixdir = "include",
        pattern = "@([%u%d_]+)@", variables = {HAVE_VISIBILITY = "0", DLL_VARIABLE = "", EILSEQ = "", ICONV_CONST = "", USE_MBSTATE_T = "1", BROKEN_WCHAR_H = "0"}})
    add_configfiles("in/deps/libiconv/libcharset/include/localcharset.h.build.in", {filename = "localcharset.h", prefixdir = "libcharset/include",
        pattern = "@([%u%d_]+)@", variables = {HAVE_VISIBILITY = "0"}})
    add_includedirs("out/libiconv/include", "in/deps/libiconv/include", {public = true})
    add_includedirs("in/deps/libiconv/lib", "out/libiconv/libcharset/include", "in/deps/libiconv/libcharset/include")
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
    before_config(function () os.vrunv("in/hx.exe", {"-delpathseg", "1", "https://ftp.gnu.org/pub/gnu/gettext/gettext-1.0.tar.gz", "in/deps/libintl"}) end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_files("in/deps/libintl/gettext-runtime/intl/config.h.in", {callback = function (sourcefile, sources, depend)
        local output = "in/deps/libintl/gettext-runtime/intl/config.h"
        local config = io.readfile(sourcefile)
        for name in ("ENABLE_NLS FLEXIBLE_ARRAY_MEMBER HAVE_ICONV HAVE_MBRTOWC HAVE_STDBOOL_H HAVE_STDINT_H_WITH_UINTMAX HAVE_STDINT_H HAVE_WCRTOMB HAVE_WINT_T USE_WINDOWS_THREADS"):gmatch("%S+") do
            config = config:gsub("#undef " .. name .. "([%c])", "#define " .. name .. " 1%1")
        end
        config = config:gsub("#undef ICONV_CONST", "#define ICONV_CONST")
        for name in ("mbrtowc mbsinit tdelete tfind tsearch twalk"):gmatch("%S+") do config = config:gsub("#undef rpl_" .. name, "#define rpl_" .. name .. " _libintl_" .. name) end
        for name in ("tdelete tfind tsearch twalk"):gmatch("%S+") do config = config:gsub("#undef " .. name, "#define " .. name .. " _libintl_" .. name) end
        io.writefile(output, config)
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
    add_files("in/deps/libintl/gettext-runtime/intl/libgnuintl.in.h", {callback = function (sourcefile, sources, depend)
        local intl = "in/deps/libintl/gettext-runtime/intl"
        local public = io.readfile(sourcefile):gsub("@[^@\r\n]+@", "0")
        local gnuintl = intl .. "/libgnuintl.h"
        local libintl = intl .. "/libintl.h"
        io.writefile(gnuintl, public)
        io.writefile(libintl, public)
        table.insert(depend.files, gnuintl)
        table.insert(depend.files, libintl)
        table.remove(sources, 1)
    end})
    add_files(
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/search.in.h",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/unistd.in.h",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/locale.in.h",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/float.in.h",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/alloca.in.h",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/string.in.h",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/stdckdint.in.h",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/sched.in.h",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/pthread.in.h",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/wchar.in.h",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/uchar.in.h",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/unicase.in.h",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/unictype.in.h",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/uninorm.in.h",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/unitypes.in.h",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/uniwidth.in.h",
        {callback = function (sourcefile, sources, depend)
            local name = path.filename(sourcefile):gsub("%.in%.h$", "")
            local output = path.join(path.directory(sourcefile), name .. ".h")
                local function render(text, replacements, ones, fallback)
                for i = 1, #(replacements or {}), 2 do text = text:gsub(replacements[i], replacements[i + 1]) end
                for item in (ones or ""):gmatch("%S+") do text = text:gsub("@" .. item .. "@", "1") end
                if fallback ~= nil then text = text:gsub("@[^@\r\n]+@", fallback) end
                return text
            end
            local text = io.readfile(sourcefile)
            if name == "unicase" or name == "unictype" or name == "uninorm" then
                text = render(text, {"@HAVE_UNISTRING_WOE32DLL_H@", "0"}, nil, "")
            elseif name ~= "unitypes" and name ~= "uniwidth" then
                local prelude = "#include \"c++defs.h\"\n#include \"arg-nonnull.h\"\n#include \"warn-on-use.h\"\n"
                local ones = {
                    search = "GNULIB_TSEARCH",
                    unistd = "GNULIB_GETCWD REPLACE_GETCWD",
                    locale = "HAVE_WINDOWS_LOCALE_T GNULIB_LOCALECONV GNULIB_SETLOCALE_NULL GNULIB_GETLOCALENAME_L_UNSAFE GNULIB_LOCALENAME_UNSAFE",
                    string = "GNULIB_STRINGEQ",
                    pthread = "GNULIB_PTHREAD_ONCE REPLACE_PTHREAD_ONCE",
                    wchar = "HAVE_WCHAR_H GNULIB_MBSINIT GNULIB_MBSZERO GNULIB_MBRTOWC GNULIB_WCWIDTH GNULIB_WGETCWD GNULIB_FREE_POSIX HAVE_WINT_T HAVE_MBSINIT HAVE_MBRTOWC HAVE_WCRTOMB REPLACE_MBSINIT REPLACE_MBRTOWC",
                    uchar = "HAVE_UCHAR_H CXX_HAVE_UCHAR_H CXX_HAS_UCHAR_TYPES SMALL_WCHAR_T GNULIB_C32ISALNUM GNULIB_C32ISALPHA GNULIB_C32ISBLANK GNULIB_C32ISCNTRL GNULIB_C32ISDIGIT GNULIB_C32ISGRAPH GNULIB_C32ISLOWER GNULIB_C32ISPRINT GNULIB_C32ISPUNCT GNULIB_C32ISSPACE GNULIB_C32ISUPPER GNULIB_C32ISXDIGIT GNULIB_C32TOLOWER GNULIB_C32WIDTH GNULIB_MBRTOC32 HAVE_MBRTOC32 REPLACE_MBRTOC32"
                }
                local prefix = ({search = prelude, unistd = prelude, locale = prelude, string = prelude, pthread = prelude, wchar = prelude, uchar = prelude,
                    sched = "#include \"c++defs.h\"\n#include \"warn-on-use.h\"\n"})[name] or ""
                local replacements = {"@GUARD_PREFIX@", "GL", "@PRAGMA_SYSTEM_HEADER@", "", "@PRAGMA_COLUMNS@", ""}
                if name ~= "alloca" then
                    local next_h = "@NEXT_" .. name:upper() .. "_H@"
                    local native = name == "locale" or name == "float" or name == "string" or name == "wchar" or name == "uchar"
                    if native then
                        local ucrt = path.join(get_config("sdk"), "Windows Kits", "10", "Include", get_config("vs_sdkver"), "ucrt", name .. ".h"):gsub("\\", "/")
                        table.insert(replacements, "@INCLUDE_NEXT@")
                        table.insert(replacements, "include")
                        table.insert(replacements, next_h)
                        table.insert(replacements, "\"" .. ucrt .. "\"")
                    else
                        table.insert(replacements, "@INCLUDE_NEXT@ " .. next_h)
                        table.insert(replacements, "include <" .. name .. ".h>")
                    end
                end
                text = prefix .. render(text, replacements, ones[name], "0")
            end
            io.writefile(output, text)
            table.insert(depend.files, output)
            table.remove(sources, 1)
        end})
    add_files("in/deps/libintl/gettext-runtime/intl/libintl.rc", {callback = function (sourcefile, sources, depend)
        local resource = path.join(get_config("builddir"), "libintl.rc")
        local res = path.join(get_config("builddir"), "libintl.res")
        local object = path.join(get_config("builddir"), "libintl.res.obj")
        local sdk = path.join(get_config("sdk"), "Windows Kits", "10")
        local sdk_include = path.join(sdk, "Include", get_config("vs_sdkver"))
        local rc = path.join(sdk, "bin", get_config("vs_sdkver"), "x64", "rc.exe")
        local cvtres = path.join(get_config("sdk"), "VC", "Tools", "MSVC", get_config("vs_toolset"), "bin", "Hostx64", "x64", "cvtres.exe")
        table.insert(depend.files, rc)
        table.insert(depend.files, cvtres)
        io.writefile(resource, (io.readfile(sourcefile):gsub("PACKAGE_VERSION_STRING", "\"1.0\"")
            :gsub("PACKAGE_VERSION_MAJOR", "1"):gsub("PACKAGE_VERSION_MINOR", "0"):gsub("PACKAGE_VERSION_SUBMINOR", "0")))
        os.vrunv(rc, {"-nologo", "-I" .. path.join(sdk_include, "um"), "-I" .. path.join(sdk_include, "shared"), "-Fo" .. res, resource})
        os.vrunv(cvtres, {"/nologo", "/machine:x64", "/readonly", "/out:" .. object, res})
        sources[1] = object
    end})
    add_deps("libiconv")
    add_includedirs("in/deps/libintl/gettext-runtime/intl", {public = true})
    add_includedirs("in/deps/libintl/gettext-runtime/intl/gnulib-lib")
    add_defines("BUILDING_LIBINTL", "BUILDING_LIBRARY", "HAVE_CONFIG_H", "LIBDIR=\".\"", "LOCALEDIR=\".\"",
        "_GL_SMALL_WCHAR_T=1", "_CRT_SECURE_NO_WARNINGS", "_WIN32_WINNT=0x0601")
    add_syslinks("advapi32", {public = true})
    add_files("in/deps/libintl/gettext-runtime/intl/*.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/*.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/glthread/*.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/unicase/*.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/unictype/*.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/uniwidth/*.c")
    remove_files("in/deps/libintl/gettext-runtime/intl/intl-exports.c", "in/deps/libintl/gettext-runtime/intl/os2compat.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/frexp*.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/isnan.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/isnand.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/isw*.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/itold.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/lc-charset-dispatch.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/localeconv.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/mbtowc-lock.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/memchr.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/setlocale-lock.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/signbit*.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/stdio-read.c",
        "in/deps/libintl/gettext-runtime/intl/gnulib-lib/stdio-write.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/strncpy.c", "in/deps/libintl/gettext-runtime/intl/gnulib-lib/wmem*.c")

target("libxml2")
    before_config(function () os.vrunv("in/hx.exe", {"github://winlibs/libxml2?ref=libxml2-2.11.9-7", "in/deps/libxml2"}) end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    set_configdir("out/libxml2")
    add_configfiles("in/deps/libxml2/include/win32config.h", {filename = "config.h", onlycopy = true})
    add_configfiles("in/deps/libxml2/include/libxml/xmlversion.h.in", {prefixdir = "include/libxml", pattern = "@([%u%d_]+)@", variables = {
        VERSION = "2.11.9", LIBXML_VERSION_NUMBER = "21109", LIBXML_VERSION_EXTRA = "", MODULE_EXTENSION = ".dll",
        WITH_TRIO = 0, WITH_THREAD_ALLOC = 0, WITH_XPTR_LOCS = 0, WITH_ICU = 0, WITH_ISO8859X = 0, WITH_MEM_DEBUG = 0, WITH_ZLIB = 0, WITH_LZMA = 0,
        WITH_THREADS = 1, WITH_TREE = 1, WITH_OUTPUT = 1, WITH_PUSH = 1, WITH_READER = 1, WITH_PATTERN = 1, WITH_WRITER = 1, WITH_SAX1 = 1,
        WITH_FTP = 1, WITH_HTTP = 1, WITH_VALID = 1, WITH_HTML = 1, WITH_LEGACY = 1, WITH_C14N = 1, WITH_CATALOG = 1, WITH_XPATH = 1,
        WITH_XPTR = 1, WITH_XINCLUDE = 1, WITH_ICONV = 1, WITH_DEBUG = 1, WITH_REGEXPS = 1, WITH_SCHEMAS = 1, WITH_SCHEMATRON = 1, WITH_MODULES = 1}})
    add_deps("libiconv")
    add_includedirs("out/libxml2/include", "in/deps/libxml2/include", {public = true})
    add_includedirs("out/libxml2", "in/deps/libxml2")
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
    before_config(function () os.vrunv("in/hx.exe", {"github://winlibs/libxslt?ref=libxslt-1.1.43-2", "in/deps/libxslt"}) end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    set_configdir("out/libxslt")
    add_configfiles("in/deps/libxslt/libxslt/xsltconfig.h.in", {prefixdir = "libxslt", pattern = "@([%u%d_]+)@", variables = {
        VERSION = "1.1.43", LIBXSLT_VERSION_NUMBER = "10143", LIBXSLT_VERSION_EXTRA = "", WITH_TRIO = "0",
        WITH_XSLT_DEBUG = "1", WITH_DEBUGGER = "1", WITH_MODULES = "1", WITH_PROFILER = "1", LIBXSLT_DEFAULT_PLUGINS_PATH = "NULL"}})
    add_configfiles("in/deps/libxslt/libexslt/exsltconfig.h.in", {prefixdir = "libexslt", pattern = "@([%u%d_]+)@", variables = {
        LIBEXSLT_VERSION = "0.8.24", LIBEXSLT_VERSION_NUMBER = "824", LIBEXSLT_VERSION_EXTRA = "", WITH_CRYPTO = "0"}})
    add_deps("libxml2")
    add_includedirs("out/libxslt", "in/deps/libxslt", {public = true})
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
    before_config(function () os.vrunv("in/hx.exe", {"github://kkos/oniguruma?ref=v6.9.10", "in/deps/libonig"}) end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    set_configdir("out/oniguruma")
    add_configfiles("in/deps/libonig/src/config.h.win64", {filename = "config.h", onlycopy = true})
    add_includedirs("out/oniguruma", "in/deps/libonig/src", {public = true})
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
    before_config(function () os.vrunv("in/hx.exe", {"-delpathseg", "1", "https://www.sqlite.org/2026/sqlite-amalgamation-3530200.zip", "in/deps/sqlite3"}) end)
    set_enabled(true)
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
    before_config(function () os.vrunv("in/hx.exe", {"github://pnggroup/libpng?ref=v1.6.58", "in/deps/libpng"}) end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_deps("zlib")
    add_files("in/deps/libpng/scripts/pnglibconf.h.prebuilt", {callback = function (sourcefile, sources, depend)
        local zlib = "in/deps/zlib/zlib.h"
        local output = "out/libpng/pnglibconf.h"
        table.insert(depend.files, zlib)
        local zlib_vernum = io.readfile(zlib):match("#define ZLIB_VERNUM (0x%x+)")
        local config = io.readfile(sourcefile):gsub("#define PNG_ZLIB_VERNUM 0 /%* unknown %*/", "#define PNG_ZLIB_VERNUM " .. zlib_vernum)
        os.mkdir("out/libpng")
        io.writefile(output, config)
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
    add_includedirs("in/deps/libpng", "out/libpng", {public = true})
    add_defines("PNG_INTEL_SSE_OPT=1", "_CRT_NONSTDC_NO_DEPRECATE", "_CRT_SECURE_NO_DEPRECATE")
    add_files("in/deps/libpng/png*.c", "in/deps/libpng/intel/*.c")
    remove_files("in/deps/libpng/pngtest.c")


target("libjpeg")
    before_config(function ()
        os.vrunv("in/hx.exe", {"github://libjpeg-turbo/libjpeg-turbo?ref=3.1.4.1", "in/deps/libjpeg-turbo"})
        os.vrunv("in/hx.exe", {"https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases/download/SP_54221_64bit/strawberry-perl-5.42.2.1-64bit-portable.zip", "in/perl"})
    end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    set_toolset("as", "nasm@$(projectdir)/in/perl/c/bin/nasm.exe")
    add_files("in/deps/libjpeg-turbo/src/jconfig.h.in", {callback = function (sourcefile, sources, depend)
        local output = "out/libjpeg/jconfig.h"
        os.mkdir("out/libjpeg")
        io.writefile(output, (io.readfile(sourcefile)
            :gsub("@JPEG_LIB_VERSION@", "80")
            :gsub("@VERSION@", "3.1.4.1")
            :gsub("@LIBJPEG_TURBO_VERSION_NUMBER@", "3001004")
            :gsub("#cmakedefine C_ARITH_CODING_SUPPORTED 1", "#define C_ARITH_CODING_SUPPORTED 1")
            :gsub("#cmakedefine D_ARITH_CODING_SUPPORTED 1", "#define D_ARITH_CODING_SUPPORTED 1")
            :gsub("#cmakedefine WITH_SIMD 1", "#define WITH_SIMD 1")
            :gsub("#cmakedefine RIGHT_SHIFT_IS_UNSIGNED 1", "/* #undef RIGHT_SHIFT_IS_UNSIGNED */")))
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
    add_files("in/deps/libjpeg-turbo/src/jconfigint.h.in", {callback = function (sourcefile, sources, depend)
        local output = "out/libjpeg/jconfigint.h"
        os.mkdir("out/libjpeg")
        io.writefile(output, (io.readfile(sourcefile)
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
            :gsub("#cmakedefine WITH_SIMD 1", "#define WITH_SIMD 1")))
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
    add_files("in/deps/libjpeg-turbo/src/jversion.h.in", {callback = function (sourcefile, sources, depend)
        local output = "out/libjpeg/jversion.h"
        os.mkdir("out/libjpeg")
        io.writefile(output, (io.readfile(sourcefile):gsub("@COPYRIGHT_YEAR@", "1991-2026")))
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
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
    before_config(function () os.vrunv("in/hx.exe", {"github://freetype/freetype?ref=VER-2-14-3", "in/deps/freetype"}) end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    set_configdir("out/freetype/include/freetype/config")
    add_configfiles("in/deps/freetype/include/freetype/config/ftoption.h", {
        pattern = "/%* #define (FT_CONFIG_OPTION_USE_HARFBUZZ[A-Z_]*) %*/",
        variables = {FT_CONFIG_OPTION_USE_HARFBUZZ = "#define FT_CONFIG_OPTION_USE_HARFBUZZ",
            FT_CONFIG_OPTION_USE_HARFBUZZ_DYNAMIC = "#define FT_CONFIG_OPTION_USE_HARFBUZZ_DYNAMIC"}})
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
    before_config(function () os.vrunv("in/hx.exe", {"github://webmproject/libwebp?ref=v1.6.0", "in/deps/libwebp"}) end)
    set_enabled(true)
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
    before_config(function () os.vrunv("in/hx.exe", {"https://download.osgeo.org/libtiff/tiff-4.7.2.tar.xz", "in/deps/libtiff"}) end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_deps("zlib", "libjpeg", "liblzma", "zstd", "libwebp")
    add_files("in/deps/libtiff/tiff-4.7.2/libtiff/tiffconf.h.cmake.in", {callback = function (sourcefile, sources, depend)
        local output = "out/libtiff/tiffconf.h"
        os.mkdir("out/libtiff")
        local conf = io.readfile(sourcefile)
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
        io.writefile(output, conf)
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
    add_files("in/deps/libtiff/tiff-4.7.2/libtiff/tif_config.h.cmake.in", {callback = function (sourcefile, sources, depend)
        local output = "out/libtiff/tif_config.h"
        os.mkdir("out/libtiff")
        local config = io.readfile(sourcefile)
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
        io.writefile(output, config)
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
    add_files("in/deps/libtiff/tiff-4.7.2/libtiff/tiffvers.h", {callback = function (sourcefile, sources, depend)
        local output = "out/libtiff/tiffvers.h"
        os.mkdir("out/libtiff")
        io.writefile(output, io.readfile(sourcefile))
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
    add_includedirs("out/libtiff", "in/deps/libtiff/tiff-4.7.2/libtiff", {public = true})
    add_defines("NDEBUG", "TIFF_DO_NOT_USE_NON_EXT_ALLOC_FUNCTIONS", "_CRT_SECURE_NO_DEPRECATE", "_CRT_NONSTDC_NO_DEPRECATE", "_CRT_SECURE_NO_WARNINGS", "_CRT_NONSTDC_NO_WARNINGS")
    add_files("in/deps/libtiff/tiff-4.7.2/libtiff/tif_*.c")
    remove_files("in/deps/libtiff/tiff-4.7.2/libtiff/tif_unix.c")
    add_files("in/deps/libtiff/tiff-4.7.2/libtiff/tif_open.c", "in/deps/libtiff/tiff-4.7.2/libtiff/tif_win32.c", {defines = {"ALLOW_TIFF_NON_EXT_ALLOC_FUNCTIONS"}})
    add_files("in/deps/libtiff/tiff-4.7.2/libtiff/tif_win32_versioninfo.rc")


target("libjxl")
    before_config(function ()
        os.vrunv("in/hx.exe", {"github://libjxl/libjxl?ref=v0.11.2", "in/deps/libjxl"})
        os.vrunv("in/hx.exe", {"github://google/highway?ref=457c891775a7397bdb0376bb1031e6e027af1c48", "in/deps/libjxl/third_party/highway"})
        os.vrunv("in/hx.exe", {"https://skia.googlesource.com/skcms/+archive/b2e692629c1fb19342517d7fb61f1cf83d075492.tar.gz", "in/deps/libjxl/third_party/skcms"})
    end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_languages("cxx17")
    set_optimize("fastest")
    add_deps("brotli")
    set_configdir("out/libjxl/include/jxl")
    add_configfiles("in/deps/libjxl/lib/jxl/version.h.in", {pattern = "@([%u%d_]+)@", variables = {
        JPEGXL_MAJOR_VERSION = "0", JPEGXL_MINOR_VERSION = "11", JPEGXL_PATCH_VERSION = "2"}})
    add_files("in/deps/libjxl/lib/jxl/version.h.in", {callback = function (_, sources, depend)
        local export = "out/libjxl/include/jxl/jxl_export.h"
        local cms_export = "out/libjxl/include/jxl/jxl_cms_export.h"
        os.mkdir("out/libjxl/include/jxl")
        io.writefile(export, [[#ifndef JXL_EXPORT_H
            #define JXL_EXPORT_H
            #define JXL_EXPORT
            #define JXL_NO_EXPORT
            #define JXL_DEPRECATED __declspec(deprecated)
            #define JXL_DEPRECATED_EXPORT JXL_EXPORT JXL_DEPRECATED
            #define JXL_DEPRECATED_NO_EXPORT JXL_NO_EXPORT JXL_DEPRECATED
            #endif
        ]])
        io.writefile(cms_export, [[#ifndef JXL_CMS_EXPORT_H
            #define JXL_CMS_EXPORT_H
            #define JXL_CMS_EXPORT
            #define JXL_CMS_NO_EXPORT
            #define JXL_CMS_DEPRECATED __declspec(deprecated)
            #define JXL_CMS_DEPRECATED_EXPORT JXL_CMS_EXPORT JXL_CMS_DEPRECATED
            #define JXL_CMS_DEPRECATED_NO_EXPORT JXL_CMS_NO_EXPORT JXL_CMS_DEPRECATED
            #endif
        ]])
        table.insert(depend.files, export)
        table.insert(depend.files, cms_export)
        table.remove(sources, 1)
    end})
    add_includedirs("out/libjxl/include", "in/deps/libjxl/lib/include", "in/deps/libjxl", "in/deps/libjxl/third_party/highway", {public = true})
    add_includedirs("in/deps/libjxl/third_party/skcms")
    add_defines("JXL_STATIC_DEFINE", "JXL_CMS_STATIC_DEFINE", "HWY_STATIC_DEFINE", {public = true})
    add_defines("JXL_INTERNAL_LIBRARY_BUILD", "JPEGXL_ENABLE_SKCMS=1", "JPEGXL_ENABLE_TRANSCODE_JPEG=1", "JPEGXL_ENABLE_BOXES=1", "FJXL_ENABLE_AVX512=0", "SKCMS_DISABLE_HSW", "SKCMS_DISABLE_SKX", "TOOLCHAIN_MISS_SYS_AUXV_H", "TOOLCHAIN_MISS_ASM_HWCAP_H", "_CRT_SECURE_NO_WARNINGS")
    add_files("in/deps/libjxl/lib/jxl/**.cc")
    remove_files("in/deps/libjxl/lib/jxl/**_test.cc", "in/deps/libjxl/lib/jxl/**_gbench.cc", "in/deps/libjxl/lib/jxl/**testonly.cc", "in/deps/libjxl/lib/jxl/**test_*.cc")
    add_files("in/deps/libjxl/third_party/skcms/skcms.cc", "in/deps/libjxl/third_party/skcms/src/skcms_TransformBaseline.cc")
    add_files("in/deps/libjxl/third_party/highway/hwy/abort.cc", "in/deps/libjxl/third_party/highway/hwy/aligned_allocator.cc", "in/deps/libjxl/third_party/highway/hwy/nanobenchmark.cc", "in/deps/libjxl/third_party/highway/hwy/per_target.cc", "in/deps/libjxl/third_party/highway/hwy/print.cc", "in/deps/libjxl/third_party/highway/hwy/targets.cc", "in/deps/libjxl/third_party/highway/hwy/timer.cc")


target("avif")
    before_config(function ()
        os.vrunv("in/hx.exe", {"github://AOMediaCodec/libavif?ref=v1.4.2", "in/deps/libavif"})
        os.vrunv("in/hx.exe", {"https://aomedia.googlesource.com/aom/+archive/refs/tags/v3.14.1.tar.gz", "in/deps/aom"})
        os.vrunv("in/hx.exe", {"https://chromium.googlesource.com/libyuv/libyuv/+archive/644251f252a84bf8ce91ff0aca86a9b16b069ab8.tar.gz", "in/deps/libyuv"})
        os.vrunv("in/hx.exe", {"github://winlibs/libheif?ref=libheif-1.23.1", "in/deps/libheif"})
        os.vrunv("in/hx.exe", {"https://code.videolan.org/videolan/dav1d/-/archive/1.5.3/dav1d-1.5.3.tar.gz", "in/deps/dav1d"})
        os.vrunv("in/hx.exe", {"https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases/download/SP_54221_64bit/strawberry-perl-5.42.2.1-64bit-portable.zip", "in/perl"})
    end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_languages("c11", "cxx20")
    set_optimize("fastest")
    set_toolset("as", "nasm@$(projectdir)/in/perl/c/bin/nasm.exe")
    add_deps("libjpeg")
    set_configdir("out/avif")
    add_configfiles("in/deps/libheif/libheif/api/libheif/heif_version.h.in", {prefixdir = "include/libheif", pattern = "@([%u%d_]+)@", variables = {
        PROJECT_VERSION_MAJOR = "1", PROJECT_VERSION_MINOR = "23", PROJECT_VERSION_PATCH = "1", PLUGIN_DIRECTORY = ""}})
    add_files("in/deps/aom/cmake/aom_config_defaults.cmake", {callback = function (sourcefile, sources, depend)
        local out = "out/avif/config"
        local rtcd_config = out .. "/aom_config_rtcd.h"
        local assembly_config = out .. "/aom_config.asm"
        os.mkdir(out)
        local values = {}
        for name, value in io.readfile(sourcefile):gmatch("set_aom_[%w_]+%(%s*([%w_]+)%s+([%d]+)") do values[name] = value end
        for name in ("AOM_ARCH_X86_64 HAVE_MMX HAVE_SSE HAVE_SSE2 HAVE_SSE3 HAVE_SSSE3 HAVE_SSE4_1 HAVE_SSE4_2 HAVE_AVX HAVE_AVX2 HAVE_AVX512 CONFIG_OS_SUPPORT CONFIG_PIC"):gmatch("%S+") do values[name] = "1" end
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
        io.writefile(rtcd_config, table.concat(header, "\n") .. "\n")
        io.writefile(assembly_config, table.concat(assembly, "\n") .. "\n")
        io.writefile(out .. "/aom_config.c", [[#include "aom/aom_codec.h"
            static const char* const cfg = "cmake ../ -G \"Visual Studio 18 2026\" -DAOM_TARGET_CPU=x86_64 -DENABLE_DOCS=0 -DENABLE_EXAMPLES=0 -DENABLE_NASM=1 -DENABLE_TESTDATA=0 -DENABLE_TESTS=0 -DENABLE_TOOLS=0 -DENABLE_SSE2=1 -DENABLE_SSE3=1 -DENABLE_SSSE3=1 -DENABLE_SSE4_1=1 -DENABLE_SSE4_2=1 -DENABLE_AVX=1 -DENABLE_AVX2=1";
            const char *aom_codec_build_config(void) { return cfg; }
        ]])
        io.writefile(out .. "/aom_av1_no_op.c", "// Generated no-op source.\n")
        io.writefile(out .. "/aom_dsp_no_op.c", "// Generated no-op source.\n")
        table.insert(depend.files, rtcd_config)
        table.insert(depend.files, assembly_config)
        sources[1] = out .. "/aom_config.c"
        table.insert(sources, out .. "/aom_av1_no_op.c")
        table.insert(sources, out .. "/aom_dsp_no_op.c")
    end})
    add_files("in/deps/aom/CHANGELOG", {callback = function (sourcefile, sources, depend)
        local perl = "in/perl/perl/bin/perl.exe"
        local script = "in/deps/aom/cmake/version.pl"
        local output = "out/avif/config/aom_version.h"
        table.insert(depend.files, perl)
        table.insert(depend.files, script)
        os.vrunv(perl, {script, "--version_data=" .. sourcefile, "--version_filename=" .. output})
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
    add_files("in/deps/aom/aom_dsp/aom_dsp_rtcd_defs.pl", "in/deps/aom/aom_scale/aom_scale_rtcd.pl", "in/deps/aom/av1/common/av1_rtcd_defs.pl", {callback = function (sourcefile, sources, depend)
        local perl = "in/perl/perl/bin/perl.exe"
        local script = "in/deps/aom/cmake/rtcd.pl"
        local config = "out/avif/config/aom_config_rtcd.h"
        local sym, output
        if sourcefile:find("aom_dsp_rtcd_defs", 1, true) then sym, output = "aom_dsp_rtcd", "out/avif/config/aom_dsp_rtcd.h"
        elseif sourcefile:find("aom_scale_rtcd", 1, true) then sym, output = "aom_scale_rtcd", "out/avif/config/aom_scale_rtcd.h"
        else sym, output = "av1_rtcd", "out/avif/config/av1_rtcd.h" end
        table.insert(depend.files, perl)
        table.insert(depend.files, script)
        table.insert(depend.files, config)
        os.vrunv(perl, {script, "--arch=x86_64", "--sym=" .. sym, "--config=" .. config, sourcefile}, {stdout = output})
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
    add_files("out/avif/config/aom_config_rtcd.h", {callback = function (sourcefile, sources, depend)
        local output = "out/avif/config/aom_config.h"
        io.writefile(output, (io.readfile(sourcefile):gsub("#define CONFIG_LIBYUV 0", "#define CONFIG_LIBYUV 1")))
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
    add_files("in/deps/dav1d/dav1d-1.5.3/meson.build", {callback = function (_, sources, depend)
        local out = "out/avif/dav1d"
        os.mkdir(out)
        io.writefile(out .. "/config.h", [[#define ARCH_AARCH64 0
            #define ARCH_ARM 0
            #define ARCH_LOONGARCH 0
            #define ARCH_LOONGARCH32 0
            #define ARCH_LOONGARCH64 0
            #define ARCH_PPC64LE 0
            #define ARCH_RISCV 0
            #define ARCH_RV32 0
            #define ARCH_RV64 0
            #define ARCH_X86 1
            #define ARCH_X86_32 0
            #define ARCH_X86_64 1
            #define CONFIG_8BPC 1
            #define CONFIG_16BPC 1
            #define CONFIG_LOG 1
            #define CONFIG_MACOS_KPERF 0
            #define ENDIANNESS_BIG 0
            #define HAVE_ALIGNED_ALLOC 0
            #define HAVE_ASM 1
            #define HAVE_AS_ARCH_DIRECTIVE 0
            #define HAVE_AS_FUNC 0
            #define HAVE_DLSYM 0
            #define HAVE_DOTPROD 0
            #define HAVE_ELF_AUX_INFO 0
            #define HAVE_GETAUXVAL 0
            #define HAVE_I8MM 0
            #define HAVE_IO_H 1
            #define HAVE_MEMALIGN 0
            #define HAVE_POSIX_MEMALIGN 0
            #define HAVE_PTHREAD_GETAFFINITY_NP 0
            #define HAVE_PTHREAD_NP_H 0
            #define HAVE_PTHREAD_SETAFFINITY_NP 0
            #define HAVE_PTHREAD_SETNAME_NP 0
            #define HAVE_PTHREAD_SET_NAME_NP 0
            #define HAVE_SVE2 0
            #define HAVE_SYS_TYPES_H 1
            #define HAVE_UNISTD_H 0
            #define TRIM_DSP_FUNCTIONS 1
            #define _CRT_DECLARE_NONSTDC_NAMES 1
            #define _WIN32_WINNT 0x0601
            #define fseeko _fseeki64
            #define ftello _ftelli64
        ]])
        io.writefile(out .. "/config.asm", [[%define private_prefix dav1d
            %define ARCH_X86_64 1
            %define ARCH_X86_32 0
            %define STACK_ALIGNMENT 16
            %define PIC 1
            %define FORCE_VEX_ENCODING 0
        ]])
        io.writefile(out .. "/vcs_version.h", "#define DAV1D_VERSION \"1.5.3\"\n")
        table.insert(depend.files, out .. "/config.h")
        table.insert(depend.files, out .. "/config.asm")
        table.insert(depend.files, out .. "/vcs_version.h")
        table.remove(sources, 1)
    end})
    add_files("in/deps/dav1d/dav1d-1.5.3/src/*_tmpl.c", {callback = function (sourcefile, sources)
        local name = path.filename(sourcefile)
        local out8 = "out/avif/dav1d/dav1d_8_" .. name
        local out16 = "out/avif/dav1d/dav1d_16_" .. name
        os.mkdir("out/avif/dav1d")
        io.writefile(out8, "#define BITDEPTH 8\n#include \"" .. sourcefile .. "\"\n")
        io.writefile(out16, "#define BITDEPTH 16\n#include \"" .. sourcefile .. "\"\n")
        sources[1] = out8
        table.insert(sources, out16)
    end})
    add_includedirs("in/deps/libavif/include", "in/deps/libheif/libheif/api", "out/avif/include", {public = true})
    add_includedirs("out/avif", "out/avif/dav1d", "in/deps/aom", "in/deps/libyuv/include", "in/deps/libheif/libheif", "in/deps/dav1d/dav1d-1.5.3/include", "in/deps/dav1d/dav1d-1.5.3/include/compat/msvc", "in/deps/dav1d/dav1d-1.5.3", "$(projectdir)", "out/libjpeg", "in/deps/libjpeg-turbo/src")
    add_defines("LIBHEIF_STATIC_BUILD", "WITH_UNCOMPRESSED_CODEC=1", {public = true})
    add_defines("AVIF_CODEC_AOM=1", "AVIF_CODEC_AOM_ENCODE=1", "AVIF_CODEC_AOM_DECODE=1", "AVIF_CODEC_DAV1D=1", "AVIF_LIBYUV_ENABLED=1", "LIBHEIF_EXPORTS", "HAVE_VISIBILITY=1", "HAVE_BIT=1", "IS_BIG_ENDIAN=0", "ENABLE_MULTITHREADING_SUPPORT=1", "ENABLE_PARALLEL_TILE_DECODING=1", "HAVE_AOM_DECODER=1", "HAVE_AOM_ENCODER=1", "HAVE_DAV1D=1", "HAVE_JPEG_DECODER=1", "HAVE_JPEG_ENCODER=1", "_WIN32_WINNT=0x0601", "_CRT_SECURE_NO_WARNINGS", "_CRT_NONSTDC_NO_WARNINGS")
    add_asflags("-fwin64", "-I$(projectdir)/in/deps/aom/", "-I$(projectdir)/out/avif/", "-I$(projectdir)/in/deps/dav1d/dav1d-1.5.3/src/", "-I$(projectdir)/out/avif/dav1d/", {force = true})
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
        "in/deps/libheif/libheif/*.cc",
        "in/deps/libheif/libheif/api/libheif/*.cc",
        "in/deps/libheif/libheif/codecs/*.cc",
        "in/deps/libheif/libheif/codecs/uncompressed/*.cc",
        "in/deps/libheif/libheif/color-conversion/*.cc",
        "in/deps/libheif/libheif/image/*.cc",
        "in/deps/libheif/libheif/image-items/*.cc",
        "in/deps/libheif/libheif/sequences/*.cc",
        "in/deps/dav1d/dav1d-1.5.3/src/*.c",
        "in/deps/dav1d/dav1d-1.5.3/src/x86/cpu.c",
        "in/deps/dav1d/dav1d-1.5.3/src/win32/thread.c",
        "in/deps/dav1d/dav1d-1.5.3/src/x86/*.asm",
        "in/deps/aom/aom_dsp/x86/*.asm",
        "in/deps/aom/av1/encoder/x86/*.asm",
        "in/deps/aom/aom_ports/float.asm"
    )
    remove_files(
        "in/deps/libavif/src/codec_avm.c", "in/deps/libavif/src/codec_libgav1.c", "in/deps/libavif/src/codec_rav1e.c", "in/deps/libavif/src/codec_svt.c",
        "in/deps/libheif/libheif/plugins_*.cc", "in/deps/libheif/libheif/api/libheif/heif_experimental.cc",
        "in/deps/aom/aom_dsp/butteraugli.c", "in/deps/aom/aom_dsp/fastssim.c", "in/deps/aom/aom_dsp/psnrhvs.c", "in/deps/aom/aom_dsp/vmaf.c",
        "in/deps/aom/aom_util/debug_util.c", "in/deps/aom/av1/common/x86/cdef_block_ssse3.c",
        "in/deps/aom/av1/decoder/accounting.c", "in/deps/aom/av1/decoder/inspection.c",
        "in/deps/aom/av1/encoder/av1_temporal_denoiser.c", "in/deps/aom/av1/encoder/blockiness.c", "in/deps/aom/av1/encoder/deltaq4_model.c", "in/deps/aom/av1/encoder/optical_flow.c", "in/deps/aom/av1/encoder/saliency_map.c", "in/deps/aom/av1/encoder/sparse_linear_solver.c", "in/deps/aom/av1/encoder/thirdpass.c", "in/deps/aom/av1/encoder/tune_butteraugli.c", "in/deps/aom/av1/encoder/tune_vmaf.c",
        "in/deps/aom/av1/encoder/x86/av1_temporal_denoiser_sse2.c", "in/deps/aom/av1/encoder/x86/av1_ssim_opt_x86_64.asm",
        "in/deps/libyuv/source/*neon*.cc", "in/deps/libyuv/source/*sme*.cc", "in/deps/libyuv/source/row_sve.cc",
        "in/deps/dav1d/dav1d-1.5.3/src/*_tmpl.c", "in/deps/dav1d/dav1d-1.5.3/src/x86/filmgrain_common.asm"
    )
    add_files("in/deps/libheif/libheif/plugins/decoder_aom.cc", "in/deps/libheif/libheif/plugins/encoder_aom.cc", "in/deps/libheif/libheif/plugins/decoder_dav1d.cc", "in/deps/libheif/libheif/plugins/decoder_jpeg.cc", "in/deps/libheif/libheif/plugins/encoder_jpeg.cc", "in/deps/libheif/libheif/plugins/encoder_mask.cc", "in/deps/libheif/libheif/plugins/nalu_utils.cc", "in/deps/libheif/libheif/plugins/encoder_uncompressed.cc", "in/deps/libheif/libheif/plugins/decoder_uncompressed.cc")
    add_files("in/deps/aom/**/*_avx.c", {cxflags = {"/arch:AVX"}})
    add_files("in/deps/aom/**/*_avx2.c", {cxflags = {"/arch:AVX2"}})


target("libsasl")
    before_config(function () os.vrunv("in/hx.exe", {"github://cyrusimap/cyrus-sasl?ref=cyrus-sasl-2.1.28", "in/deps/libsasl"}) end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_files("in/deps/libsasl/include/*.h", {callback = function (sourcefile, sources, depend)
        local name = path.filename(sourcefile)
        local output = "out/libsasl/include/" .. name
        local nested = "out/libsasl/include/sasl/" .. name
        os.mkdir("out/libsasl/include/sasl")
        local content = io.readfile(sourcefile)
        if name == "prop.h" then
                content = content:gsub("#ifdef WIN32\n# ifdef LIBSASL_EXPORTS", "#if defined(WIN32) && !defined(LIBSASL_STATIC)\n# ifdef LIBSASL_EXPORTS")
        end
        io.writefile(output, content)
        io.writefile(nested, content)
        table.insert(depend.files, output)
        table.insert(depend.files, nested)
        table.remove(sources, 1)
    end})
    add_files("in/deps/libsasl/win32/include/md5global.h", {callback = function (sourcefile, sources, depend)
        local output = "out/libsasl/include/md5global.h"
        local nested = "out/libsasl/include/sasl/md5global.h"
        os.mkdir("out/libsasl/include/sasl")
        local content = io.readfile(sourcefile)
        io.writefile(output, content)
        io.writefile(nested, content)
        table.insert(depend.files, output)
        table.insert(depend.files, nested)
        table.remove(sources, 1)
    end})
    add_includedirs("out/libsasl/include", {public = true})
    add_includedirs("in/deps/libsasl/win32/include", "in/deps/libsasl/include", "in/deps/libsasl/lib", "in/deps/libsasl/common")
    add_defines("LIBSASL_STATIC", {public = true})
    add_defines("NO_STATIC_PLUGINS", "WIN32", "UNICODE", "_UNICODE", "_CRT_SECURE_NO_WARNINGS", "GCC_FALLTHROUGH=")
    add_syslinks("ws2_32", "advapi32", {public = true})
    add_files("in/deps/libsasl/lib/*.c", "in/deps/libsasl/common/plugin_common.c")
    add_files("in/deps/libsasl/lib/saslutil.c", {callback = function (sourcefile, sources)
        local output = "out/libsasl/saslutil.c"
        os.mkdir("out/libsasl")
        io.writefile(output, (io.readfile(sourcefile):gsub("__declspec%(dllexport%) ", "")))
        sources[1] = output
    end})
    remove_files("in/deps/libsasl/lib/dlopen.c", "in/deps/libsasl/lib/getaddrinfo.c", "in/deps/libsasl/lib/getnameinfo.c", "in/deps/libsasl/lib/snprintf.c", "in/deps/libsasl/lib/saslutil.c")


target("openldap")
    before_config(function ()
        os.vrunv("in/hx.exe", {"-delpathseg", "1", "https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.6.13.tgz", "in/deps/openldap"})
        os.vrunv("in/hx.exe", {"github://garyhouston/rxspencer?ref=v3.9.0", "in/deps/rxspencer"})
    end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_deps("openssl", "libsasl")
    add_files("in/deps/openldap/include/portable.hin", "in/deps/openldap/include/lber_types.hin", "in/deps/openldap/include/ldap_features.hin", {callback = function (sourcefile, sources, depend)
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
        for line in values:gmatch("[^\r\n]+") do local n, v = line:match("^%s*([^=]+)=(.*)$"); if n then defs[n] = v end end
        local output = "out/openldap/include/" .. path.filename(sourcefile):gsub("%.hin$", ".h")
        os.mkdir("out/openldap/include")
        io.writefile(output, (io.readfile(sourcefile):gsub("#undef%s+([%w_]+)", function (name)
            return defs[name] and ("#define " .. name .. " " .. defs[name]) or ("/* #undef " .. name .. " */")
        end)))
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
    add_files("in/deps/openldap/include/ldap_config.hin", {callback = function (sourcefile, sources, depend)
        local output = "out/openldap/include/ldap_config.h"
        os.mkdir("out/openldap/include")
        io.writefile(output, (io.readfile(sourcefile):gsub("%%[A-Z]+DIR%%", ".")))
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
    add_files("in/deps/openldap/include/ac/socket.h", "in/deps/openldap/include/ac/time.h", {callback = function (sourcefile, sources, depend)
        local name = path.filename(sourcefile)
        local output = "out/openldap/include/ac/" .. name
        local content = io.readfile(sourcefile)
        os.mkdir("out/openldap/include/ac")
        if name == "socket.h" then
            content = content:gsub("#define EWOULDBLOCK WSAEWOULDBLOCK", "#undef EWOULDBLOCK\n#undef EINPROGRESS\n#undef ETIMEDOUT\n#undef ENOTCONN\n#define EWOULDBLOCK WSAEWOULDBLOCK")
        else
            content = content:gsub("#if defined%(_WIN32%) && !defined%(HAVE_CLOCK_GETTIME%)", "#if defined(_WIN32) && !defined(HAVE_CLOCK_GETTIME) && (!defined(_MSC_VER) || _MSC_VER < 1900)")
        end
        io.writefile(output, content)
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
    add_includedirs("out/openldap/include", "in/deps/openldap/include", {public = true})
    add_includedirs("in/deps/openldap/libraries/libldap", "in/deps/openldap/libraries/liblber", "in/deps/rxspencer", "in/deps/openssl/include")
    add_defines("strcasecmp=_stricmp", "strncasecmp=_strnicmp")
    add_syslinks("ws2_32", "advapi32", "crypt32", "secur32", "bcrypt", {public = true})
    add_files("in/deps/openldap/libraries/libldap/*.c", {defines = {"LDAP_LIBRARY"}})
    remove_files("in/deps/openldap/libraries/libldap/apitest.c", "in/deps/openldap/libraries/libldap/dntest.c", "in/deps/openldap/libraries/libldap/ftest.c", "in/deps/openldap/libraries/libldap/ltest.c", "in/deps/openldap/libraries/libldap/t61.c", "in/deps/openldap/libraries/libldap/test.c", "in/deps/openldap/libraries/libldap/testavl.c", "in/deps/openldap/libraries/libldap/testtavl.c", "in/deps/openldap/libraries/libldap/urltest.c")
    add_files("in/deps/openldap/libraries/liblber/*.c", {defines = {"LBER_LIBRARY"}})
    remove_files("in/deps/openldap/libraries/liblber/dtest.c", "in/deps/openldap/libraries/liblber/etest.c", "in/deps/openldap/libraries/liblber/idtest.c", "in/deps/openldap/libraries/liblber/stdio.c")
    add_files("in/deps/rxspencer/regcomp.c", "in/deps/rxspencer/regerror.c", "in/deps/rxspencer/regexec.c", "in/deps/rxspencer/regfree.c", {defines = {"POSIX_MISTAKE", "REDEBUG"}})
    add_files("in/deps/openldap/build/version.h", {callback = function (sourcefile, sources)
        local output = "out/openldap/version.c"
        os.mkdir("out/openldap")
        io.writefile(output, io.readfile(sourcefile) .. '\n#include "portable.h"\nconst char __Version[] = "OpenLDAP 2.6.13";\n')
        sources[1] = output
    end})


target("libpq")
    before_config(function () os.vrunv("in/hx.exe", {"github://postgres/postgres?ref=REL_16_14", "in/deps/libpq"}) end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_deps("openssl")
    add_files("in/deps/libpq/src/include/pg_config.h.in", "in/deps/libpq/src/include/pg_config_ext.h.in", {callback = function (sourcefile, sources, depend)
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
        for item in values:gmatch("[^;\r\n]+") do local name, value = item:match("^%s*([^=]+)=(.*)$"); if name then defs[name] = value end end
        local output = "out/libpq/include/" .. path.filename(sourcefile):gsub("%.in$", "")
        os.mkdir("out/libpq/include")
        io.writefile(output, (io.readfile(sourcefile):gsub("#(%s*)undef%s+([%w_]+)", function (_, name)
            return defs[name] and ("#define " .. name .. " " .. defs[name]) or ("/* #undef " .. name .. " */")
        end)))
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
    add_files("in/deps/libpq/src/include/port/win32.h", {callback = function (sourcefile, sources, depend)
        local output = "out/libpq/include/pg_config_os.h"
        os.mkdir("out/libpq/include")
        io.writefile(output, io.readfile(sourcefile))
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
    add_files("in/deps/libpq/src/tools/msvc/Solution.pm", {callback = function (_, sources, depend)
        local output = "out/libpq/port/pg_config_paths.h"
        local paths = "PGBINDIR=/bin PGSHAREDIR=/share SYSCONFDIR=/etc INCLUDEDIR=/include PKGINCLUDEDIR=/include INCLUDEDIRSERVER=/include/server LIBDIR=/lib PKGLIBDIR=/lib LOCALEDIR=/share/locale DOCDIR=/doc HTMLDIR=/doc MANDIR=/man"
        os.mkdir("out/libpq/port")
        paths = paths:gsub(" ?(%S+)=([^%s]+)", '#define %1 "%2"\n')
        io.writefile(output, paths)
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
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


target("libffi")
    before_config(function () os.vrunv("in/hx.exe", {"github://winlibs/libffi?ref=libffi-3.6.0", "in/deps/libffi"}) end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_files("in/deps/libffi/src/x86/win64_intel.S", {callback = function (sourcefile, sources, depend)
        local output = "out/libffi/win64.asm"
        local target = import("core.project.project").target("libffi")
        local cc = import("core.tool.compiler").compargv("in/deps/libffi/src/types.c", "out/libffi/probe.obj", {target = target})
        if type(cc) == "string" then table.insert(depend.files, cc) end
        os.mkdir("out/libffi")
        io.writefile(output, os.iorunv(cc, {"/EP", "/DFFI_BUILDING", "/DFFI_STATIC_BUILD", "/Iin/deps/libffi", "/Iin/deps/libffi/include", "/Iin/deps/libffi/src/x86", sourcefile}))
        sources[1] = output
    end})
    add_includedirs("in/deps/libffi/include", "in/deps/libffi/src/x86", "in/deps/libffi", {public = true})
    add_defines("FFI_STATIC_BUILD", {public = true})
    add_defines("FFI_BUILDING", "WIN32", "_LIB")
    add_files("in/deps/libffi/src/closures.c", "in/deps/libffi/src/java_raw_api.c", "in/deps/libffi/src/tramp.c", "in/deps/libffi/src/prep_cif.c", "in/deps/libffi/src/raw_api.c", "in/deps/libffi/src/types.c", "in/deps/libffi/src/x86/ffi.c", "in/deps/libffi/src/x86/ffiw64.c")



target("wineditline")
    before_config(function () os.vrunv("in/hx.exe", {"github://ptosco/wineditline?ref=wineditline-2.208", "in/deps/wineditline"}) end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_includedirs("in/deps/wineditline/src", {public = true})
    add_rules("c.unity_build")
    add_files("in/deps/wineditline/src/editline.c", "in/deps/wineditline/src/fn_complete.c", "in/deps/wineditline/src/history.c")


target("libzip")
    before_config(function () os.vrunv("in/hx.exe", {"github://nih-at/libzip?ref=v1.11.4", "in/deps/libzip"}) end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_deps("zlib", "bzip2", "liblzma")
    add_files("in/deps/libzip/CMakeLists.txt", {callback = function (_, sources, depend)
        local zipconf = "out/libzip/zipconf.h"
        local config = "out/libzip/config.h"
        os.mkdir("out/libzip")
        io.writefile(zipconf, [[#ifndef _HAD_ZIPCONF_H
            #define _HAD_ZIPCONF_H
            #define LIBZIP_VERSION "1.11.4"
            #define LIBZIP_VERSION_MAJOR 1
            #define LIBZIP_VERSION_MINOR 11
            #define LIBZIP_VERSION_MICRO 4
            #if !defined(__STDC_FORMAT_MACROS)
            #define __STDC_FORMAT_MACROS 1
            #endif
            #include <inttypes.h>
            typedef int8_t zip_int8_t;
            typedef uint8_t zip_uint8_t;
            typedef int16_t zip_int16_t;
            typedef uint16_t zip_uint16_t;
            typedef int32_t zip_int32_t;
            typedef uint32_t zip_uint32_t;
            typedef int64_t zip_int64_t;
            typedef uint64_t zip_uint64_t;
            #define ZIP_INT8_MIN (-ZIP_INT8_MAX-1)
            #define ZIP_INT8_MAX 0x7f
            #define ZIP_UINT8_MAX 0xff
            #define ZIP_INT16_MIN (-ZIP_INT16_MAX-1)
            #define ZIP_INT16_MAX 0x7fff
            #define ZIP_UINT16_MAX 0xffff
            #define ZIP_INT32_MIN (-ZIP_INT32_MAX-1L)
            #define ZIP_INT32_MAX 0x7fffffffL
            #define ZIP_UINT32_MAX 0xffffffffLU
            #define ZIP_INT64_MIN (-ZIP_INT64_MAX-1LL)
            #define ZIP_INT64_MAX 0x7fffffffffffffffLL
            #define ZIP_UINT64_MAX 0xffffffffffffffffULL
            #endif
        ]])
        io.writefile(config, [[#ifndef HAD_CONFIG_H
            #define HAD_CONFIG_H
            #include "zipconf.h"
            #define ENABLE_FDOPEN
            #define HAVE__CLOSE
            #define HAVE__DUP
            #define HAVE__FDOPEN
            #define HAVE__FILENO
            #define HAVE__FSEEKI64
            #define HAVE__FSTAT64
            #define HAVE__SETMODE
            #define HAVE__SNPRINTF
            #define HAVE__SNPRINTF_S
            #define HAVE__SNWPRINTF_S
            #define HAVE__STAT64
            #define HAVE__STRDUP
            #define HAVE__STRICMP
            #define HAVE__STRTOI64
            #define HAVE__STRTOUI64
            #define HAVE__UNLINK
            #define HAVE_CRYPTO
            #define HAVE_LIBBZ2
            #define HAVE_LIBLZMA
            #define HAVE_LOCALTIME_S
            #define HAVE_MEMCPY_S
            #define HAVE_SNPRINTF
            #define HAVE_SNPRINTF_S
            #define HAVE_STDBOOL_H
            #define HAVE_STRERROR_S
            #define HAVE_STRNCPY_S
            #define HAVE_STRTOLL
            #define HAVE_STRTOULL
            #define HAVE_WINDOWS_CRYPTO
            #define SIZEOF_OFF_T 4
            #define SIZEOF_SIZE_T 8
            #define PACKAGE "libzip"
            #define VERSION "1.11.4"
            #endif
        ]])
        table.insert(depend.files, zipconf)
        table.insert(depend.files, config)
        table.remove(sources, 1)
    end})
    add_includedirs("out/libzip", "in/deps/libzip/lib", {public = true})
    add_defines("ZIP_STATIC", {public = true})
    add_defines("WIN32_LEAN_AND_MEAN", "_CRT_SECURE_NO_WARNINGS", "_CRT_NONSTDC_NO_DEPRECATE")
    add_syslinks("bcrypt", {public = true})
    add_files("in/deps/libzip/lib/*.c")
    add_files("in/deps/libzip/lib/zip.h", {callback = function (sourcefile, sources, depend)
        local output = "out/libzip/zip_err_str.c"
        local zipint = "in/deps/libzip/lib/zipint.h"
        table.insert(depend.files, zipint)
        local data = [[#include "zipint.h"
            #define L ZIP_ET_LIBZIP
            #define N ZIP_ET_NONE
            #define S ZIP_ET_SYS
            #define Z ZIP_ET_ZLIB
            #define E ZIP_DETAIL_ET_ENTRY
            #define G ZIP_DETAIL_ET_GLOBAL
            const struct _zip_err_info _zip_err_str[] = {
        ]]
        for kind, text in io.readfile(sourcefile):gmatch("#define%s+ZIP_ER_[%w_]+%s+%d+%s+/%*%s*([LNSZ])%s+(.-)%s*%*/") do
            data = data .. ("    { %s, %q },\n"):format(kind, text)
        end
        data = data .. [[};
            const int _zip_err_str_count = sizeof(_zip_err_str) / sizeof(_zip_err_str[0]);
            const struct _zip_err_info _zip_err_details[] = {
        ]]
        for kind, text in io.readfile(zipint):gmatch("#define%s+ZIP_ER_DETAIL_[%w_]+%s+%d+%s+/%*%s*([EG])%s+(.-)%s*%*/") do
            data = data .. ("    { %s, %q },\n"):format(kind, text)
        end
        io.writefile(output, data .. [[};
            const int _zip_err_details_count = sizeof(_zip_err_details) / sizeof(_zip_err_details[0]);
        ]])
        sources[1] = output
    end})
    remove_files("in/deps/libzip/lib/zip_algorithm_zstd.c", "in/deps/libzip/lib/zip_crypto_commoncrypto.c", "in/deps/libzip/lib/zip_crypto_gnutls.c", "in/deps/libzip/lib/zip_crypto_mbedtls.c", "in/deps/libzip/lib/zip_crypto_openssl.c", "in/deps/libzip/lib/zip_random_unix.c", "in/deps/libzip/lib/zip_random_uwp.c", "in/deps/libzip/lib/zip_source_file_stdio_named.c")


target("mpir")
    before_config(function () os.vrunv("in/hx.exe", {"github://winlibs/mpir?ref=mpir-3.0.0-2", "in/deps/mpir"}) end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_files("in/deps/mpir/build.vc/cfg.h", {callback = function (sourcefile, sources, depend)
        local output = "out/mpir/include/mpir/config.h"
        os.mkdir("out/mpir/include/mpir")
        io.writefile(output, "/* generated by gen_config_h.bat */\n" .. io.readfile(sourcefile))
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
    add_files("in/deps/mpir/mpn/generic/gmp-mparam.h", {callback = function (sourcefile, sources, depend)
        local output = "out/mpir/include/mpir/gmp-mparam.h"
        os.mkdir("out/mpir/include/mpir")
        io.writefile(output, io.readfile(sourcefile))
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
    add_files("in/deps/mpir/longlong_pre.h", {callback = function (sourcefile, sources, depend)
        local inc = "in/deps/mpir/mpn/x86_64w/longlong_inc.h"
        local post = "in/deps/mpir/longlong_post.h"
        local output = "out/mpir/include/mpir/longlong.h"
        table.insert(depend.files, inc)
        table.insert(depend.files, post)
        os.mkdir("out/mpir/include/mpir")
        io.writefile(output, io.readfile(sourcefile) .. io.readfile(inc) .. io.readfile(post))
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
    add_files("in/deps/mpir/gmp-h.in", {callback = function (sourcefile, sources, depend)
        local mpir = "out/mpir/include/mpir/mpir.h"
        local gmp = "out/mpir/include/mpir/gmp.h"
        os.mkdir("out/mpir/include/mpir")
        local header = "/* generated from gmp-h.in by gen_mpir_h.bat */\n"
        local source = io.readfile(sourcefile):gsub("\r\n", "\n") .. "\n"
        for line in source:gmatch("([^\n]*)\n") do
            if line:find("@GMP_NAIL_BITS@", 1, true) then
                header = header .. [[#ifdef _WIN32
                    #  ifdef _WIN64
                    #    define _LONG_LONG_LIMB  1
                    #    define GMP_LIMB_BITS   64
                    #  else
                    #    define GMP_LIMB_BITS   32
                    #  endif
                    #  define __GMP_BITS_PER_MP_LIMB  GMP_LIMB_BITS
                    #  define SIZEOF_MP_LIMB_T (GMP_LIMB_BITS >> 3)
                    #  define GMP_NAIL_BITS                       0
                    #endif
                ]]
            elseif line ~= "" and not line:find("@[A-Z0-9_]+@") then
                header = header .. line .. "\n"
            end
        end
        io.writefile(mpir, header)
        io.writefile(gmp, header)
        table.insert(depend.files, mpir)
        table.insert(depend.files, gmp)
        table.remove(sources, 1)
    end})
    add_includedirs("out/mpir/include/mpir", "in/deps/mpir", {public = true})
    add_defines("NDEBUG", "WIN32", "_LIB", "HAVE_CONFIG_H", "_WIN64")
    add_files("in/deps/mpir/*.c", "in/deps/mpir/fft/*.c", "in/deps/mpir/mpf/*.c", "in/deps/mpir/mpq/*.c", "in/deps/mpir/mpz/*.c", "in/deps/mpir/printf/*.c", "in/deps/mpir/scanf/*.c", "in/deps/mpir/mpn/generic/*.c")
    remove_files("in/deps/mpir/compat.c", "in/deps/mpir/cpuid.c", "in/deps/mpir/tal-debug.c", "in/deps/mpir/tal-notreent.c", "in/deps/mpir/mpn/generic/udiv_w_sdiv.c")


target("openssl")
    before_config(function ()
        os.vrunv("in/hx.exe", {"github://openssl/openssl?ref=openssl-3.5.7", "in/deps/openssl"})
        os.vrunv("in/hx.exe", {"https://github.com/StrawberryPerl/Perl-Dist-Strawberry/releases/download/SP_54221_64bit/strawberry-perl-5.42.2.1-64bit-portable.zip", "in/perl"})
    end)
    set_enabled(true)
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_toolset("as", "nasm@$(projectdir)/in/perl/c/bin/nasm.exe")
    -- add_rules("c.unity_build")
    add_files("in/deps/openssl/Configure", {callback = function (sourcefile, sources, depend)
        local root = "in/deps/openssl"
        local perl = "in/perl/perl/bin/perl.exe"
        local output = "in/deps/openssl/configdata.pm"
        table.insert(depend.files, perl)
        table.insert(depend.files, "in/deps/openssl/VERSION.dat")
        for _, file in ipairs(os.files("in/deps/openssl/Configurations/*.conf")) do table.insert(depend.files, file) end
        os.vrunv(perl, {path.filename(sourcefile), "VC-WIN64A", "no-shared", "no-module", "no-tests", "no-docs"},
            {curdir = root, addenvs = {PATH = path.relative("in/perl/c/bin", root)}})
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
    add_files("in/deps/openssl/util/mkbuildinf.pl", {callback = function (sourcefile, sources, depend)
        local root = "in/deps/openssl"
        local perl = "in/perl/perl/bin/perl.exe"
        local config = "in/deps/openssl/configdata.pm"
        local output = "in/deps/openssl/crypto/buildinf.h"
        table.insert(depend.files, perl)
        table.insert(depend.files, config)
        os.vrunv(perl, {path.relative(sourcefile, root), "cl /MD /O2", "VC-WIN64A"},
            {curdir = root, stdout = output})
        table.insert(depend.files, output)
        table.remove(sources, 1)
    end})
    add_files("in/deps/openssl/**/*.[ch].in", {callback = function (sourcefile, sources, depend)
        local root = "in/deps/openssl"
        local perl = "in/perl/perl/bin/perl.exe"
        local config = "in/deps/openssl/configdata.pm"
        local dofile = "in/deps/openssl/util/dofile.pl"
        local output = sourcefile:sub(1, -4)
        table.insert(depend.files, perl)
        table.insert(depend.files, config)
        table.insert(depend.files, dofile)
        for _, file in ipairs(os.files("in/deps/openssl/util/perl/**/*.pm")) do table.insert(depend.files, file) end
        for _, file in ipairs(os.files("in/deps/openssl/providers/common/der/*.pm")) do table.insert(depend.files, file) end
        os.vrunv(perl,
            {"-I.", "-Iutil/perl", "-Iproviders/common/der", "-Mconfigdata", "-MOpenSSL::paramnames", "-Moids_to_c",
             "util/dofile.pl", "-omakefile", path.relative(sourcefile, root)},
            {curdir = root, stdout = output})
        if output:endswith(".c") then
            sources[1] = output
        else
            table.insert(depend.files, output)
            table.remove(sources, 1)
        end
    end})
    add_files("in/deps/openssl/**/*x86_64*.pl|crypto/perlasm/**", {callback = function (sourcefile, sources, depend)
        local root = "in/deps/openssl"
        local perl = "in/perl/perl/bin/perl.exe"
        local relative = path.relative(sourcefile, root):gsub("\\", "/")
        local output = "in/deps/openssl/" .. relative:gsub("/asm/", "/"):gsub("%.pl$", ".asm")
        table.insert(depend.files, perl)
        for _, file in ipairs(os.files("in/deps/openssl/crypto/perlasm/*.pl")) do table.insert(depend.files, file) end
        os.vrunv(perl, {relative, "nasm", path.relative(output, root):gsub("\\", "/")}, {curdir = root})
        sources[1] = output
    end})

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


target("php")
    before_config(function ()
        os.vrunv("in/hx.exe", {"-delpathseg", "1", "github://php/php-sdk-binary-tools", "in/php-sdk"})
        os.vrunv("in/hx.exe", {"github://true-async/php-src?ref=true-async-stable", "in/php-src"})
    end)
    set_enabled(true)
    set_default(false)
    set_kind("shared")
    set_basename("php8ts")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_cflags(
        "/Zc:inline",
        "/Zc:__cplusplus",
        "/d2FuncCache1",
        "/Zc:preprocessor",
        "/Zc:wchar_t",
        "/GF",
        "/Ox",
        "/wd4995",
        "/wd4996",
        {force = true}
    )
    add_deps("minilua", "gen_ir_fold_hash", {links = false})

    set_configdir("out/php")
    add_configfiles("in/php-src/win32/build/config.w32.h.in", {
        filename = "config.w32.base.h",
        prefixdir = "main",
        pattern = "@([%u%d_]+)@",
        variables = {PREFIX = [[C:\\php]]}
    })
    add_configfiles("php-config.w32.h.in", {
        filename = "config.w32.h",
        prefixdir = "main",
        pattern = "@([%u%d_]+)@",
        variables = {
            PHP_BUILD_ARCH = get_config("arch"),
            PHP_LINKER_MAJOR = get_config("vs_toolset"):match("^(%d+)"),
            PHP_LINKER_MINOR = get_config("vs_toolset"):match("^%d+%.(%d+)")
        }
    })
    add_configfiles("in/php-src/main/internal_functions.c.in", {
        filename = "internal_functions.c",
        prefixdir = "main",
        pattern = "@([%u_]+)@",
        variables = {
            EXT_INCLUDE_CODE = [[#include "ext/ctype/php_ctype.h"
#include "ext/date/php_date.h"
#include "ext/hash/php_hash.h"
#include "ext/json/php_json.h"
#include "ext/lexbor/php_lexbor.h"
#include "ext/pcre/php_pcre.h"
#include "ext/random/php_random.h"
#include "ext/reflection/php_reflection.h"
#include "ext/spl/php_spl.h"
#include "ext/standard/php_standard.h"
#include "ext/opcache/zend_accelerator_module.h"
#include "ext/uri/php_uri.h"]],
            EXT_MODULE_PTRS = [[	phpext_ctype_ptr,
	phpext_date_ptr,
	phpext_hash_ptr,
	phpext_json_ptr,
	phpext_lexbor_ptr,
	phpext_pcre_ptr,
	phpext_random_ptr,
	phpext_reflection_ptr,
	phpext_spl_ptr,
	phpext_standard_ptr,
	phpext_opcache_ptr,
	phpext_uri_ptr,]]
        }
    })

    add_includedirs(
        "out/php/Zend",
        "out/php/main",
        "out/php/win32",
        "out/php",
        "in/php-src",
        "in/php-src/main",
        "in/php-src/Zend",
        "in/php-src/TSRM",
        "in/php-src/ext",
        {public = true}
    )
    add_includedirs(
        "in/php-src/ext/date/lib",
        "in/php-src/ext/hash/sha3/generic64lc",
        "in/php-src/ext/json",
        "in/php-src/ext/lexbor",
        "in/php-src/ext/opcache",
        "in/php-src/ext/opcache/jit",
        "in/php-src/ext/opcache/jit/ir",
        "in/php-src/ext/pcre/pcre2lib",
        "in/php-src/ext/uri/uriparser/include"
    )

    add_defines(
        "ZTS=1",
        "FD_SETSIZE=256",
        "_WINDOWS",
        "WINDOWS=1",
        "ZEND_WIN32=1",
        "PHP_WIN32=1",
        "WIN32",
        "_MBCS",
        "_USE_MATH_DEFINES",
        "ENABLE_INTSAFE_SIGNED_FUNCTIONS",
        {public = true}
    )
    add_defines(
        "NDEBUG",
        "ZEND_DEBUG=0",
        "ZEND_ENABLE_STATIC_TSRMLS_CACHE=1",
        "_USRDLL",
        "PHP_EXPORTS",
        "LIBZEND_EXPORTS",
        "TSRM_EXPORTS",
        "SAPI_EXPORTS",
        "WINVER=0x0602",
        "HAVE_TIMELIB_CONFIG_H=1",
        "PCRE2_CODE_UNIT_WIDTH=8",
        "PCRE2_STATIC"
    )
    add_syslinks(
        "kernel32",
        "ole32",
        "user32",
        "advapi32",
        "shell32",
        "ws2_32",
        "Dnsapi",
        "psapi",
        "bcrypt",
        "Pathcch",
        "Mswsock",
        "iphlpapi"
    )
    add_files("in/php-src/ext/pcre/php_pcre.def")

    add_files(
        "in/php-src/Zend/*.c",
        "in/php-src/Zend/Optimizer/*.c",
        "in/php-src/main/*.c",
        "in/php-src/main/io/*.c",
        "in/php-src/main/poll/*.c",
        "in/php-src/main/streams/*.c",
        "in/php-src/win32/*.c",
        "in/php-src/TSRM/*.c"
    )
    remove_files(
        "in/php-src/Zend/Optimizer/ssa_integrity.c",
        "in/php-src/Zend/zend_dtrace.c",
        "in/php-src/Zend/zend_gdb.c",
        "in/php-src/Zend/zend_ini_parser.c",
        "in/php-src/Zend/zend_ini_scanner.c",
        "in/php-src/Zend/zend_language_parser.c",
        "in/php-src/Zend/zend_language_scanner.c",
        "in/php-src/Zend/zend_max_execution_timer.c",
        "in/php-src/Zend/zend_signal.c",
        "in/php-src/main/debug_gdb_scripts.c",
        "in/php-src/main/explicit_bzero.c",
        "in/php-src/main/fastcgi.c",
        "in/php-src/main/internal_functions.c",
        "in/php-src/main/io/php_io_copy_freebsd.c",
        "in/php-src/main/io/php_io_copy_linux.c",
        "in/php-src/main/io/php_io_copy_macos.c",
        "in/php-src/main/io/php_io_copy_solaris.c",
        "in/php-src/main/poll/poll_backend_epoll.c",
        "in/php-src/main/poll/poll_backend_eventport.c",
        "in/php-src/main/poll/poll_backend_kqueue.c",
        "in/php-src/main/poll/poll_backend_poll.c",
        "in/php-src/win32/cp_enc_map.c",
        "in/php-src/win32/cp_enc_map_gen.c"
    )
    add_files("in/php-src/main/internal_functions.c.in", {callback = function (_, sources)
        sources[1] = "out/php/main/internal_functions.c"
    end})

    add_files("in/php-src/Zend/zend_ini_parser.y", {callback = function (sourcefile, sources, depend)
        local output = "out/php/Zend/zend_ini_parser.c"
        local header = "out/php/Zend/zend_ini_parser.h"
        local tool = "in/php-sdk/usr/bin/bison.exe"
        os.mkdir(path.directory(output))
        os.vrunv(tool, {"--no-lines", "--verbose", "--defines=" .. header, "--output=" .. output, sourcefile})
        sources[1] = output
        table.insert(depend.files, tool)
        table.insert(depend.files, header)
    end})
    add_files("in/php-src/Zend/zend_language_parser.y", {callback = function (sourcefile, sources, depend)
        local output = "out/php/Zend/zend_language_parser.c"
        local header = "out/php/Zend/zend_language_parser.h"
        local tool = "in/php-sdk/usr/bin/bison.exe"
        os.mkdir(path.directory(output))
        os.vrunv(tool, {"--no-lines", "--verbose", "--defines=" .. header, "--output=" .. output, sourcefile})
        for _, file in ipairs({output, header}) do
            local content = io.readfile(file):gsub("int zendparse%(", "ZEND_API int zendparse(")
            io.writefile(file, content)
        end
        sources[1] = output
        table.insert(depend.files, tool)
        table.insert(depend.files, header)
    end})
    add_files("in/php-src/Zend/zend_ini_scanner.l", {callback = function (sourcefile, sources, depend)
        local output = "out/php/Zend/zend_ini_scanner.c"
        local header = "out/php/Zend/zend_ini_scanner_defs.h"
        local tool = "in/php-sdk/usr/bin/re2c.exe"
        os.mkdir(path.directory(output))
        os.vrunv(tool, {"--no-generation-date", "-W", "--case-inverted", "-cbdFt", header, "-o", output, sourcefile})
        sources[1] = output
        table.insert(depend.files, tool)
        table.insert(depend.files, header)
        table.insert(depend.files, "out/php/Zend/zend_ini_parser.h")
    end})
    add_files("in/php-src/Zend/zend_language_scanner.l", {callback = function (sourcefile, sources, depend)
        local output = "out/php/Zend/zend_language_scanner.c"
        local header = "out/php/Zend/zend_language_scanner_defs.h"
        local tool = "in/php-sdk/usr/bin/re2c.exe"
        os.mkdir(path.directory(output))
        os.vrunv(tool, {"--no-generation-date", "-W", "--case-inverted", "-cbdFt", header, "-o", output, sourcefile})
        sources[1] = output
        table.insert(depend.files, tool)
        table.insert(depend.files, header)
        table.insert(depend.files, "out/php/Zend/zend_language_parser.h")
    end})

    add_files("in/php-src/ext/ctype/*.c")
    add_files("in/php-src/ext/date/*.c", "in/php-src/ext/date/lib/*.c")
    add_files("in/php-src/ext/hash/*.c", "in/php-src/ext/hash/murmur/*.c", "in/php-src/ext/hash/sha3/generic64lc/*.c", {
        defines = {"KeccakP200_excluded", "KeccakP400_excluded", "KeccakP800_excluded"}
    })

    add_files("in/php-src/ext/json/json.c", "in/php-src/ext/json/json_encoder.c")
    add_files("in/php-src/ext/json/json_parser.y", {callback = function (sourcefile, sources, depend)
        local output = "out/php/ext/json/json_parser.tab.c"
        local header = "out/php/ext/json/json_parser.tab.h"
        local tool = "in/php-sdk/usr/bin/bison.exe"
        os.mkdir(path.directory(output))
        os.vrunv(tool, {"--no-lines", "--defines=" .. header, "--output=" .. output, sourcefile})
        sources[1] = output
        table.insert(depend.files, tool)
        table.insert(depend.files, header)
    end})
    add_files("in/php-src/ext/json/json_scanner.re", {callback = function (sourcefile, sources, depend)
        local output = "out/php/ext/json/json_scanner.c"
        local header = "out/php/ext/json/php_json_scanner_defs.h"
        local tool = "in/php-sdk/usr/bin/re2c.exe"
        os.mkdir(path.directory(output))
        os.vrunv(tool, {"--no-generation-date", "-W", "-t", header, "-bci", "-o", output, sourcefile})
        sources[1] = output
        table.insert(depend.files, tool)
        table.insert(depend.files, header)
        table.insert(depend.files, "out/php/ext/json/json_parser.tab.h")
    end})

    add_files("in/php-src/ext/lexbor/*.c", "in/php-src/ext/lexbor/**/*.c", {defines = {"LEXBOR_BUILDING"}, cxflags = {"/utf-8"}})
    remove_files(
        "in/php-src/ext/lexbor/lexbor/core/bst_map.c",
        "in/php-src/ext/lexbor/lexbor/core/in.c",
        "in/php-src/ext/lexbor/lexbor/core/utils.c",
        "in/php-src/ext/lexbor/lexbor/dom/collection.c",
        "in/php-src/ext/lexbor/lexbor/dom/exception.c",
        "in/php-src/ext/lexbor/lexbor/dom/interfaces/event_target.c",
        "in/php-src/ext/lexbor/lexbor/html/node.c",
        "in/php-src/ext/lexbor/lexbor/html/tree/template_insertion.c",
        "in/php-src/ext/lexbor/lexbor/ports/posix/lexbor/core/memory.c"
    )

    add_files("in/php-src/ext/pcre/*.c", "in/php-src/ext/pcre/pcre2lib/*.c", {defines = {"HAVE_CONFIG_H", "HAVE_MEMMOVE"}})
    remove_files(
        "in/php-src/ext/pcre/pcre2lib/pcre2_jit_match.c",
        "in/php-src/ext/pcre/pcre2lib/pcre2_jit_misc.c",
        "in/php-src/ext/pcre/pcre2lib/pcre2_printint.c",
        "in/php-src/ext/pcre/pcre2lib/pcre2_ucptables.c"
    )
    add_files("in/php-src/ext/random/*.c")
    add_files("in/php-src/ext/reflection/*.c")
    add_files("in/php-src/ext/spl/*.c")

    add_files("in/php-src/ext/standard/*.c", "in/php-src/ext/standard/libavifinfo/*.c")
    remove_files("in/php-src/ext/standard/url_scanner_ex.c", "in/php-src/ext/standard/var_unserializer.c")
    add_files("in/php-src/ext/standard/url_scanner_ex.re", {
        includedirs = {"in/php-src/ext/standard"},
        callback = function (sourcefile, sources, depend)
        local output = "out/php/ext/standard/url_scanner_ex.c"
        local tool = "in/php-sdk/usr/bin/re2c.exe"
        os.mkdir(path.directory(output))
        os.vrunv(tool, {"--no-generation-date", "-W", "-b", "-o", output, sourcefile})
        sources[1] = output
        table.insert(depend.files, tool)
    end})
    add_files("in/php-src/ext/standard/var_unserializer.re", {
        includedirs = {"in/php-src/ext/standard"},
        callback = function (sourcefile, sources, depend)
        local output = "out/php/ext/standard/var_unserializer.c"
        local tool = "in/php-sdk/usr/bin/re2c.exe"
        os.mkdir(path.directory(output))
        os.vrunv(tool, {"--no-generation-date", "-W", "-b", "-o", output, sourcefile})
        sources[1] = output
        table.insert(depend.files, tool)
    end})

    add_files("in/php-src/ext/uri/*.c", "in/php-src/ext/uri/uriparser/src/*.c", {defines = {"URI_STATIC_BUILD", "LEXBOR_STATIC"}})

    add_files("in/php-src/ext/opcache/*.c", "in/php-src/ext/opcache/jit/*.c", "in/php-src/ext/opcache/jit/tls/*.c", "in/php-src/ext/opcache/jit/ir/*.c", {
        defines = {"IR_TARGET_X64", "IR_PHP"}
    })
    remove_files(
        "in/php-src/ext/opcache/jit/ir/gen_ir_fold_hash.c",
        "in/php-src/ext/opcache/jit/ir/ir_disasm.c",
        "in/php-src/ext/opcache/jit/ir/ir_gdb.c",
        "in/php-src/ext/opcache/jit/ir/ir_perf.c",
        "in/php-src/ext/opcache/jit/tls/zend_jit_tls_aarch64.c",
        "in/php-src/ext/opcache/jit/tls/zend_jit_tls_darwin.c",
        "in/php-src/ext/opcache/jit/tls/zend_jit_tls_x86.c",
        "in/php-src/ext/opcache/jit/tls/zend_jit_tls_x86_64.c",
        "in/php-src/ext/opcache/jit/zend_jit_helpers.c",
        "in/php-src/ext/opcache/jit/zend_jit_ir.c",
        "in/php-src/ext/opcache/jit/zend_jit_trace.c",
        "in/php-src/ext/opcache/shared_alloc_mmap.c",
        "in/php-src/ext/opcache/shared_alloc_posix.c",
        "in/php-src/ext/opcache/shared_alloc_shm.c"
    )
    add_files("in/php-src/ext/opcache/jit/ir/ir_emit.c", {
        defines = {"IR_TARGET_X64", "IR_PHP"},
        build_callback = function (target, _, _, depend)
            local ir = "in/php-src/ext/opcache/jit/ir"
            local source = "in/php-src/ext/opcache/jit/ir/ir_x86.dasc"
            local output = "in/php-src/ext/opcache/jit/ir/ir_emit_x86.h"
            table.insert(depend.files, source)
            for _, file in ipairs(os.files(path.join(ir, "dynasm/**/*.lua"))) do table.insert(depend.files, file) end
            os.vrunv(assert(target:dep("minilua")):targetfile(),
                {"in/php-src/ext/opcache/jit/ir/dynasm/dynasm.lua", "-D", "X64=1", "-D", "X64WIN=1", "-D", "WIN=1", "-o", output, source})
            table.insert(depend.files, output)
        end
    })
    add_files("in/php-src/ext/opcache/jit/ir/ir.c", {
        defines = {"IR_TARGET_X64", "IR_PHP"},
        build_callback = function (target, _, _, depend)
            local ir = "in/php-src/ext/opcache/jit/ir"
            local source = path.join(ir, "ir_fold.h")
            local output = path.join(ir, "ir_fold_hash.h")
            table.insert(depend.files, source)
            table.insert(depend.files, path.join(ir, "ir.h"))
            os.vrunv(assert(target:dep("gen_ir_fold_hash")):targetfile(), {}, {stdin = source, stdout = output})
            table.insert(depend.files, output)
        end
    })

    add_asflags("/DBOOST_CONTEXT_EXPORT=EXPORT", {force = true})
    add_files("in/php-src/Zend/asm/*x86_64_ms*.asm")

    add_files("in/php-src/win32/build/wsyslog.mc", {
        callback = function (_, sources, depend)
            sources[1] = "out/php/win32/wsyslog.rc"
            table.insert(depend.files, "out/php/win32/wsyslog.h")
            table.insert(depend.files, "out/php/win32/MSG00001.bin")
        end,
        build_callback = function (target, sourcefile, _, depend)
            local outputdir = "out/php/win32"
            local vcvars = assert(target:toolchain("msvc")):config("vcvars")
            local tool = path.join(assert(vcvars.WindowsSdkVerBinPath), target:arch(), "mc.exe")
            os.mkdir(outputdir)
            os.vrunv(tool, {"-h", outputdir, "-r", outputdir, "-x", outputdir, sourcefile})
            table.insert(depend.files, tool)
        end
    })
    add_files("in/php-src/win32/build/template.rc", {defines = {
        [[FILE_DESCRIPTION="PHP Script Interpreter"]],
        [[FILE_NAME="php8ts.dll"]],
        [[INTERNAL_NAME="PHP Script Interpreter"]]
    }})

target("php-cli")
    set_enabled(true)
    set_default(false)
    set_kind("binary")
    set_basename("php")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_cflags(
        "/Zc:inline",
        "/Zc:__cplusplus",
        "/d2FuncCache1",
        "/Zc:preprocessor",
        "/Zc:wchar_t",
        "/GF",
        "/Ox",
        "/wd4995",
        "/wd4996",
        {force = true}
    )
    add_deps("php")
    add_defines("NDEBUG", "ZEND_DEBUG=0", "ZEND_ENABLE_STATIC_TSRMLS_CACHE=1")
    add_syslinks("ws2_32", "shell32")
    add_ldflags("/stack:67108864", {force = true})
    add_files("in/php-src/sapi/cli/*.c")
    remove_files("in/php-src/sapi/cli/cli_win32.c")
    add_files("in/php-src/win32/build/template.rc", {defines = {
        [[FILE_DESCRIPTION="PHP Command Line Interface"]],
        [[FILE_NAME="php.exe"]],
        [[INTERNAL_NAME="CLI SAPI"]],
        "WANT_LOGO"
    }})

target("php-win")
    set_enabled(true)
    set_default(false)
    set_kind("binary")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_cflags(
        "/Zc:inline",
        "/Zc:__cplusplus",
        "/d2FuncCache1",
        "/Zc:preprocessor",
        "/Zc:wchar_t",
        "/GF",
        "/Ox",
        "/wd4995",
        "/wd4996",
        {force = true}
    )
    add_deps("php")
    add_defines("NDEBUG", "ZEND_DEBUG=0", "ZEND_ENABLE_STATIC_TSRMLS_CACHE=1")
    add_syslinks("shell32")
    add_ldflags("/stack:67108864", {force = true})
    add_files(
        "in/php-src/sapi/cli/cli_win32.c",
        "in/php-src/sapi/cli/php_cli_process_title.c",
        "in/php-src/sapi/cli/ps_title.c"
    )
    add_files("in/php-src/win32/build/template.rc", {defines = {
        [[FILE_DESCRIPTION="CLI"]],
        [[FILE_NAME="php-win.exe"]],
        [[INTERNAL_NAME="CLI_WIN32 SAPI"]],
        "WANT_LOGO"
    }})

target("php-cgi")
    set_enabled(true)
    set_default(false)
    set_kind("binary")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    add_cflags(
        "/Zc:inline",
        "/Zc:__cplusplus",
        "/d2FuncCache1",
        "/Zc:preprocessor",
        "/Zc:wchar_t",
        "/GF",
        "/Ox",
        "/wd4995",
        "/wd4996",
        {force = true}
    )
    add_deps("php")
    add_defines("NDEBUG", "ZEND_DEBUG=0", "ZEND_ENABLE_STATIC_TSRMLS_CACHE=1")
    add_syslinks("ws2_32", "kernel32", "advapi32")
    add_ldflags("/stack:67108864", {force = true})
    add_files("in/php-src/sapi/cgi/cgi_main.c", "in/php-src/main/fastcgi.c")
    add_files("in/php-src/win32/build/template.rc", {defines = {
        [[FILE_DESCRIPTION="CGI / FastCGI"]],
        [[FILE_NAME="php-cgi.exe"]],
        [[INTERNAL_NAME="CGI SAPI"]],
        "WANT_LOGO"
    }})
