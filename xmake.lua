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
            fileconfig.cb(target, sourcefile, opt, import("core.project.depend"), os.vrunv)
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
        os.run("hx github://tukaani-project/xz?ref=v5.8.3 in/deps/xz")
        os.run("hx github://nghttp2/nghttp2?ref=v1.69.0 in/deps/nghttp2")
        os.run("hx github://ngtcp2/ngtcp2?ref=v1.25.0 in/deps/ngtcp2")
        os.run("hx github://ngtcp2/nghttp3?ref=v1.18.0 in/deps/nghttp3")
        os.run("hx github://openssl/openssl?ref=openssl-3.5.7 in/deps/openssl")
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

target("openssl")
    set_kind("static")
    set_targetdir(get_config("builddir"))
    set_optimize("fastest")
    set_toolset("as", "nasm@$(projectdir)/in/perl/c/bin/nasm.exe")
    add_includedirs("in/deps/openssl/include", {public = true})
    add_includedirs("in/deps/openssl", "in/deps/openssl/crypto",
        "in/deps/openssl/providers/common/include", "in/deps/openssl/providers/common/include/prov",
        "in/deps/openssl/providers/implementations/include", "in/deps/openssl/providers/fips/include")
    add_defines("L_ENDIAN", "OPENSSL_PIC", "OPENSSL_BUILDING_OPENSSL", "OPENSSL_SYS_WIN32",
        "WIN32_LEAN_AND_MEAN", "UNICODE", "_UNICODE", "_CRT_SECURE_NO_DEPRECATE",
        "_WINSOCK_DEPRECATED_NO_WARNINGS", "NDEBUG", "STATIC_LEGACY",
        "AES_ASM", "BSAES_ASM", "CMLL_ASM", "ECP_NISTZ256_ASM", "GHASH_ASM",
        "KECCAK1600_ASM", "MD5_ASM", "OPENSSL_BN_ASM_GF2m", "OPENSSL_BN_ASM_MONT",
        "OPENSSL_BN_ASM_MONT5", "OPENSSL_CPUID_OBJ", "OPENSSL_IA32_SSE2", "PADLOCK_ASM",
        "POLY1305_ASM", "RC4_ASM", "SHA1_ASM", "SHA256_ASM", "SHA512_ASM", "VPAES_ASM",
        "WHIRLPOOL_ASM", "X25519_ASM", [[OPENSSLDIR="C:\Program Files\Common Files\SSL"]],
        [[ENGINESDIR="C:\Program Files\OpenSSL\lib\engines-3"]],
        [[MODULESDIR="C:\Program Files\OpenSSL\lib\ossl-modules"]])
    add_cflags("/Gs0", "/GF", "/Gy", {force = true})
    add_asflags("-Ox", "-f", "win64", "-DNEAR", "-g", {force = true})
    add_syslinks("ws2_32", "gdi32", "advapi32", "crypt32", "user32", {public = true})
    add_rules("c.unity_build")
    add_files("in/deps/openssl/crypto/params_idx.c.in", {rules = {"cb"}, cb = function (target, sourcefile, opt, depend, runv)
        local root = path.join(os.projectdir(), "in/deps/openssl")
        local perl = path.join(os.projectdir(), "in/perl/perl/bin/perl.exe")
        local runenvs = {PATH = path.join(os.projectdir(), "in/perl/c/bin") .. ";" .. os.getenv("PATH")}
        local regular_outputs = {
            "include/crypto/bn_conf.h", "include/crypto/dso_conf.h", "include/openssl/asn1.h",
            "include/openssl/asn1t.h", "include/openssl/bio.h", "include/openssl/cmp.h",
            "include/openssl/cms.h", "include/openssl/comp.h", "include/openssl/conf.h",
            "include/openssl/crmf.h", "include/openssl/crypto.h", "include/openssl/ct.h",
            "include/openssl/err.h", "include/openssl/ess.h", "include/openssl/fipskey.h",
            "include/openssl/lhash.h", "include/openssl/ocsp.h", "include/openssl/opensslv.h",
            "include/openssl/pkcs12.h", "include/openssl/pkcs7.h", "include/openssl/safestack.h",
            "include/openssl/srp.h", "include/openssl/ssl.h", "include/openssl/ui.h",
            "include/openssl/x509.h", "include/openssl/x509_acert.h",
            "include/openssl/x509_vfy.h", "include/openssl/x509v3.h"
        }
        local param_outputs = {
            "crypto/params_idx.c", "include/internal/param_names.h", "include/openssl/core_names.h"
        }
        local der_names = {"digests", "dsa", "ec", "ecx", "ml_dsa", "rsa", "slh_dsa", "sm2", "wrap"}
        local assembly_outputs = {
            [[crypto\aes\aes-x86_64.asm]], [[crypto\aes\aesni-mb-x86_64.asm]],
            [[crypto\aes\aesni-sha1-x86_64.asm]], [[crypto\aes\aesni-sha256-x86_64.asm]],
            [[crypto\aes\aesni-x86_64.asm]], [[crypto\aes\aesni-xts-avx512.asm]],
            [[crypto\aes\bsaes-x86_64.asm]], [[crypto\aes\vpaes-x86_64.asm]],
            [[crypto\bn\rsaz-2k-avx512.asm]], [[crypto\bn\rsaz-2k-avxifma.asm]],
            [[crypto\bn\rsaz-3k-avx512.asm]], [[crypto\bn\rsaz-3k-avxifma.asm]],
            [[crypto\bn\rsaz-4k-avx512.asm]], [[crypto\bn\rsaz-4k-avxifma.asm]],
            [[crypto\bn\rsaz-avx2.asm]], [[crypto\bn\rsaz-x86_64.asm]],
            [[crypto\bn\x86_64-gf2m.asm]], [[crypto\bn\x86_64-mont.asm]],
            [[crypto\bn\x86_64-mont5.asm]], [[crypto\camellia\cmll-x86_64.asm]],
            [[crypto\chacha\chacha-x86_64.asm]], [[crypto\ec\ecp_nistz256-x86_64.asm]],
            [[crypto\ec\x25519-x86_64.asm]], [[crypto\md5\md5-x86_64.asm]],
            [[crypto\modes\aes-gcm-avx512.asm]], [[crypto\modes\aesni-gcm-x86_64.asm]],
            [[crypto\modes\ghash-x86_64.asm]], [[crypto\poly1305\poly1305-x86_64.asm]],
            [[crypto\rc4\rc4-md5-x86_64.asm]], [[crypto\rc4\rc4-x86_64.asm]],
            [[crypto\sha\keccak1600-x86_64.asm]], [[crypto\sha\sha1-mb-x86_64.asm]],
            [[crypto\sha\sha1-x86_64.asm]], [[crypto\sha\sha256-mb-x86_64.asm]],
            [[crypto\sha\sha256-x86_64.asm]], [[crypto\sha\sha512-x86_64.asm]],
            [[crypto\whrlpool\wp-x86_64.asm]], [[crypto\x86_64cpuid.asm]],
            [[engines\e_padlock-x86_64.asm]]
        }
        local expected_outputs = {
            path.join(root, "configdata.pm"), path.join(root, "include/openssl/configuration.h"),
            path.join(root, "crypto/buildinf.h")
        }
        for _, output in ipairs(regular_outputs) do
            table.insert(expected_outputs, path.join(root, output))
        end
        for _, output in ipairs(param_outputs) do
            table.insert(expected_outputs, path.join(root, output))
        end
        for _, name in ipairs(der_names) do
            table.insert(expected_outputs, path.join(root, "providers/common/der/der_" .. name .. "_gen.c"))
            table.insert(expected_outputs, path.join(root, "providers/common/include/prov/der_" .. name .. ".h"))
        end
        for _, output in ipairs(assembly_outputs) do
            table.insert(expected_outputs, path.join(root, output))
        end
        local missing = false
        for _, output in ipairs(expected_outputs) do
            if not os.isfile(output) then
                missing = true
                break
            end
        end
        local generator_inputs = {path.join(root, "Configure")}
        table.join2(generator_inputs, os.files(path.join(root, "Configurations/**.conf")))
        table.join2(generator_inputs, os.files(path.join(root, "**/build.info")))
        table.join2(generator_inputs, os.files(path.join(root, "util/**.pl")))
        table.join2(generator_inputs, os.files(path.join(root, "util/**.pm")))
        for _, output in ipairs(regular_outputs) do
            table.insert(generator_inputs, path.join(root, output .. ".in"))
        end
        for _, output in ipairs(param_outputs) do
            table.insert(generator_inputs, path.join(root, output .. ".in"))
        end
        table.join2(generator_inputs, os.files(path.join(root, "providers/common/der/*.asn1")))
        table.join2(generator_inputs, os.files(path.join(root, "providers/common/der/*.c.in")))
        table.join2(generator_inputs, os.files(path.join(root, "providers/common/include/prov/*.h.in")))
        depend.on_changed(function ()
            runv(perl, {"Configure", "VC-WIN64A", "no-shared", "no-module", "no-apps", "no-tests", "no-docs"},
                {curdir = root, envs = runenvs})
            for _, output in ipairs(regular_outputs) do
                runv(perl, {"-I.", "-Mconfigdata", "util/dofile.pl", "-omakefile", output .. ".in"},
                    {curdir = root, stdout = path.join(root, output)})
            end
            for _, output in ipairs(param_outputs) do
                runv(perl, {"-I.", "-Iutil/perl", "-Mconfigdata", "-MOpenSSL::paramnames",
                    "util/dofile.pl", "-omakefile", output .. ".in"},
                    {curdir = root, stdout = path.join(root, output)})
            end
            for _, name in ipairs(der_names) do
                local outputs = {
                    "providers/common/der/der_" .. name .. "_gen.c",
                    "providers/common/include/prov/der_" .. name .. ".h"
                }
                for _, output in ipairs(outputs) do
                    runv(perl, {"-I.", "-Iproviders/common/der", "-Mconfigdata", "-Moids_to_c",
                        "util/dofile.pl", "-omakefile", output .. ".in"},
                        {curdir = root, stdout = path.join(root, output)})
                end
            end
            runv(perl, {"util/mkbuildinf.pl", "cl /MD /O2", "VC-WIN64A"},
                {curdir = root, stdout = path.join(root, "crypto/buildinf.h")})
            local perlasm = [[
use strict;
use warnings;
for my $output (@ARGV) {
    (my $source = $output) =~ s/[.]asm$/.s/;
    my $generators = $configdata::unified_info{generate}{$source};
    die "No unique perlasm generator for $output\n"
        unless ref($generators) eq "ARRAY" && @$generators == 1;
    system($^X, $generators->[0], "nasm", $output) == 0
        or die "Perlasm generation failed for $output\n";
}
]]
            local argv = {"-I.", "-Mconfigdata", "-e", perlasm}
            table.join2(argv, assembly_outputs)
            runv(perl, argv, {curdir = root})
        end, {
            files = generator_inputs,
            values = {"VC-WIN64A", "no-shared", "no-module", "no-apps", "no-tests", "no-docs"},
            dependfile = target:dependfile(sourcefile) .. ".openssl",
            changed = missing or target:is_rebuilt()
        })
    end})
    add_files("in/deps/openssl/crypto/bio/bf_buff.c")
    add_files("in/deps/openssl/crypto/bio/bf_lbuf.c", {unity_group = "conflict_1"})
    add_files("in/deps/openssl/crypto/bio/bf_nbio.c", {unity_group = "conflict_2"})
    add_files("in/deps/openssl/crypto/bio/bf_null.c", {unity_group = "conflict_3"})
    add_files("in/deps/openssl/crypto/bio/bf_prefix.c", {unity_group = "conflict_4"})
    add_files("in/deps/openssl/crypto/bio/bf_readbuff.c", {unity_group = "conflict_5"})
    add_files("in/deps/openssl/crypto/bio/bio_addr.c", {unity_group = "conflict_6"})
    add_files("in/deps/openssl/crypto/bio/bio_cb.c", {unity_group = "conflict_7"})
    add_files("in/deps/openssl/crypto/bio/bio_dump.c", {unity_group = "conflict_8"})
    add_files("in/deps/openssl/crypto/bio/bio_lib.c", {unity_group = "conflict_9"})
    add_files("in/deps/openssl/crypto/bio/bio_meth.c", {unity_group = "conflict_10"})
    add_files("in/deps/openssl/crypto/bio/bio_sock.c", {unity_group = "conflict_11"})
    add_files("in/deps/openssl/crypto/bio/bio_sock2.c", {unity_group = "conflict_12"})
    add_files("in/deps/openssl/crypto/bio/bss_acpt.c", {unity_group = "conflict_13"})
    add_files("in/deps/openssl/crypto/bio/bss_bio.c", {unity_group = "conflict_14"})
    add_files("in/deps/openssl/crypto/bio/bss_conn.c", {unity_group = "conflict_15"})
    add_files("in/deps/openssl/crypto/bio/bss_core.c", {unity_group = "conflict_16"})
    add_files("in/deps/openssl/crypto/bio/bss_dgram.c", {unity_group = "conflict_17"})
    add_files("in/deps/openssl/crypto/bio/bss_dgram_pair.c", {unity_group = "conflict_18"})
    add_files("in/deps/openssl/crypto/bio/bss_fd.c", {unity_group = "conflict_19"})
    add_files("in/deps/openssl/crypto/bio/bss_file.c", {unity_group = "conflict_20"})
    add_files("in/deps/openssl/crypto/bio/bss_log.c", {unity_group = "conflict_21"})
    add_files("in/deps/openssl/crypto/bio/bss_mem.c", {unity_group = "conflict_22"})
    add_files("in/deps/openssl/crypto/bio/bss_null.c", {unity_group = "conflict_23"})
    add_files("in/deps/openssl/crypto/bio/bss_sock.c", {unity_group = "conflict_24"})
    add_files("in/deps/openssl/crypto/bio/ossl_core_bio.c", {unity_group = "conflict_25"})
    add_files("in/deps/openssl/crypto/**.c", "in/deps/openssl/ssl/**.c",
        "in/deps/openssl/providers/**.c")
    add_files("in/deps/openssl/engines/e_capi.c", "in/deps/openssl/engines/e_padlock.c")
    remove_files("in/deps/openssl/crypto/bn/asm/*.c", "in/deps/openssl/crypto/chacha/*.c",
        "in/deps/openssl/crypto/md2/*.c", "in/deps/openssl/crypto/rc4/*.c",
        "in/deps/openssl/crypto/rc5/*.c", "in/deps/openssl/providers/fips/**.c")
    remove_files("in/deps/openssl/crypto/aes/aes_cbc.c", "in/deps/openssl/crypto/aes/aes_core.c",
        "in/deps/openssl/crypto/aes/aes_x86core.c", "in/deps/openssl/crypto/*cap.c",
        "in/deps/openssl/crypto/bn/bn_ppc.c", "in/deps/openssl/crypto/bn/bn_s390x.c",
        "in/deps/openssl/crypto/bn/bn_sparc.c", "in/deps/openssl/crypto/camellia/camellia.c",
        "in/deps/openssl/crypto/camellia/cmll_cbc.c", "in/deps/openssl/crypto/des/ncbc_enc.c",
        "in/deps/openssl/crypto/dllmain.c", "in/deps/openssl/crypto/ec/ecp_nistp*.c",
        "in/deps/openssl/crypto/ec/ecp_nistz256_table.c", "in/deps/openssl/crypto/ec/ecp_ppc.c",
        "in/deps/openssl/crypto/ec/ecp_s390x_nistp.c", "in/deps/openssl/crypto/ec/ecp_sm2p256*.c",
        "in/deps/openssl/crypto/ec/ecx_s390x.c", "in/deps/openssl/crypto/evp/legacy_md2.c",
        "in/deps/openssl/crypto/hmac/hmac_s390x.c", "in/deps/openssl/crypto/LPdir_*.c",
        "in/deps/openssl/crypto/mem_clr.c", "in/deps/openssl/crypto/poly1305/poly1305_base2_44.c",
        "in/deps/openssl/crypto/poly1305/poly1305_ieee754.c",
        "in/deps/openssl/crypto/poly1305/poly1305_ppc.c", "in/deps/openssl/crypto/rand/rand_egd.c",
        "in/deps/openssl/crypto/rsa/rsa_acvp_test_params.c", "in/deps/openssl/crypto/sha/keccak1600.c",
        "in/deps/openssl/crypto/sha/sha_ppc.c", "in/deps/openssl/crypto/sha/sha_riscv.c",
        "in/deps/openssl/crypto/sm3/sm3_riscv.c", "in/deps/openssl/crypto/whrlpool/wp_block.c",
        "in/deps/openssl/providers/common/securitycheck_fips.c",
        "in/deps/openssl/providers/implementations/ciphers/cipher_rc5.c",
        "in/deps/openssl/providers/implementations/ciphers/cipher_rc5_hw.c",
        "in/deps/openssl/providers/implementations/digests/md2_prov.c",
        "in/deps/openssl/providers/implementations/kem/template_kem.c",
        "in/deps/openssl/providers/implementations/keymgmt/template_kmgmt.c",
        "in/deps/openssl/providers/implementations/macs/blake2_mac_impl.c",
        "in/deps/openssl/providers/implementations/rands/fips_crng_test.c",
        "in/deps/openssl/providers/implementations/rands/seeding/rand_cpu_arm64.c",
        "in/deps/openssl/providers/implementations/rands/seeding/rand_vms.c",
        "in/deps/openssl/providers/implementations/rands/seeding/rand_vxworks.c",
        "in/deps/openssl/ssl/record/methods/ktls_meth.c")
    add_files("in/deps/openssl/crypto/asn1/a_gentm.c", "in/deps/openssl/crypto/async/arch/async_null.c",
        {unity_group = "conflict_1"})
    add_files("in/deps/openssl/crypto/asn1/a_int.c", "in/deps/openssl/crypto/async/arch/async_posix.c",
        {unity_group = "conflict_2"})
    add_files("in/deps/openssl/crypto/asn1/a_object.c", "in/deps/openssl/crypto/async/arch/async_win.c",
        {unity_group = "conflict_3"})
    add_files("in/deps/openssl/crypto/asn1/a_time.c", "in/deps/openssl/crypto/async/async_wait.c",
        {unity_group = "conflict_4"})
    add_files("in/deps/openssl/crypto/asn1/a_type.c", {unity_group = "conflict_5"})
    add_files("in/deps/openssl/crypto/asn1/a_utctm.c", {unity_group = "conflict_6"})
    add_files("in/deps/openssl/crypto/asn1/asn_mime.c", {unity_group = "conflict_7"})
    add_files("in/deps/openssl/crypto/asn1/asn1_lib.c", {unity_group = "conflict_8"})
    add_files("in/deps/openssl/crypto/asn1/tasn_dec.c", {unity_group = "conflict_9"})
    add_files("in/deps/openssl/crypto/asn1/tasn_enc.c", {unity_group = "conflict_10"})
    add_files("in/deps/openssl/crypto/asn1/tasn_fre.c", {unity_group = "conflict_11"})
    add_files("in/deps/openssl/crypto/asn1/tasn_new.c", {unity_group = "conflict_12"})
    add_files("in/deps/openssl/crypto/asn1/tasn_prn.c", {unity_group = "conflict_13"})
    add_files("in/deps/openssl/crypto/asn1/tasn_scn.c", {unity_group = "conflict_14"})
    add_files("in/deps/openssl/crypto/asn1/tasn_utl.c", {unity_group = "conflict_15"})
    add_files("in/deps/openssl/crypto/asn1/x_int64.c", {unity_group = "conflict_16"})
    add_files("in/deps/openssl/crypto/dso/dso_dlfcn.c", {unity_group = "conflict_1"})
    add_files("in/deps/openssl/crypto/dso/dso_lib.c", {unity_group = "conflict_2"})
    add_files("in/deps/openssl/crypto/dso/dso_openssl.c", {unity_group = "conflict_3"})
    add_files("in/deps/openssl/crypto/dso/dso_vms.c", {unity_group = "conflict_4"})
    add_files("in/deps/openssl/crypto/dso/dso_win32.c", {unity_group = "conflict_5"})
    add_files("in/deps/openssl/crypto/ec/curve25519.c",
        "in/deps/openssl/crypto/ec/curve448/arch_64/f_impl64.c", {unity_group = "conflict_1"})
    add_files("in/deps/openssl/crypto/ec/ec_asn1.c", {unity_group = "conflict_2"})
    add_files("in/deps/openssl/crypto/ec/ec_backend.c", {unity_group = "conflict_3"})
    add_files("in/deps/openssl/crypto/ec/ec_check.c", {unity_group = "conflict_4"})
    add_files("in/deps/openssl/crypto/ec/ec_curve.c", {unity_group = "conflict_5"})
    add_files("in/deps/openssl/crypto/ec/ec_cvt.c", {unity_group = "conflict_6"})
    add_files("in/deps/openssl/crypto/ec/ec_key.c", {unity_group = "conflict_7"})
    add_files("in/deps/openssl/crypto/ec/ec_kmeth.c", {unity_group = "conflict_8"})
    add_files("in/deps/openssl/crypto/ec/ec_lib.c", {unity_group = "conflict_9"})
    add_files("in/deps/openssl/crypto/ec/ec_mult.c", {unity_group = "conflict_10"})
    add_files("in/deps/openssl/crypto/ec/ec_oct.c", {unity_group = "conflict_11"})
    add_files("in/deps/openssl/crypto/ec/ec_pmeth.c", {unity_group = "conflict_12"})
    add_files("in/deps/openssl/crypto/ec/ec_print.c", {unity_group = "conflict_13"})
    add_files("in/deps/openssl/crypto/ec/ec2_oct.c", {unity_group = "conflict_14"})
    add_files("in/deps/openssl/crypto/ec/ec2_smpl.c", {unity_group = "conflict_15"})
    add_files("in/deps/openssl/crypto/ec/ecdh_kdf.c", {unity_group = "conflict_16"})
    add_files("in/deps/openssl/crypto/ec/ecdh_ossl.c", {unity_group = "conflict_17"})
    add_files("in/deps/openssl/crypto/ec/ecdsa_ossl.c", {unity_group = "conflict_18"})
    add_files("in/deps/openssl/crypto/ec/ecdsa_sign.c", {unity_group = "conflict_19"})
    add_files("in/deps/openssl/crypto/ec/ecdsa_vrf.c", {unity_group = "conflict_20"})
    add_files("in/deps/openssl/crypto/ec/ecp_mont.c", {unity_group = "conflict_21"})
    add_files("in/deps/openssl/crypto/ec/ecp_nist.c", {unity_group = "conflict_22"})
    add_files("in/deps/openssl/crypto/ec/ecp_nistz256.c", {unity_group = "conflict_23"})
    add_files("in/deps/openssl/crypto/ec/ecp_oct.c", {unity_group = "conflict_24"})
    add_files("in/deps/openssl/crypto/ec/ecp_smpl.c", {unity_group = "conflict_25"})
    add_files("in/deps/openssl/crypto/ec/ecx_meth.c", {unity_group = "conflict_26"})
    add_files("in/deps/openssl/crypto/params_idx.c",
        "in/deps/openssl/providers/common/der/der_digests_gen.c",
        "in/deps/openssl/providers/common/der/der_dsa_gen.c",
        "in/deps/openssl/providers/common/der/der_ec_gen.c",
        "in/deps/openssl/providers/common/der/der_ecx_gen.c",
        "in/deps/openssl/providers/common/der/der_ml_dsa_gen.c",
        "in/deps/openssl/providers/common/der/der_rsa_gen.c",
        "in/deps/openssl/providers/common/der/der_slh_dsa_gen.c",
        "in/deps/openssl/providers/common/der/der_sm2_gen.c",
        "in/deps/openssl/providers/common/der/der_wrap_gen.c")
    add_files("in/deps/openssl/crypto/aes/aes-x86_64.asm",
        "in/deps/openssl/crypto/aes/aesni-mb-x86_64.asm",
        "in/deps/openssl/crypto/aes/aesni-sha1-x86_64.asm",
        "in/deps/openssl/crypto/aes/aesni-sha256-x86_64.asm",
        "in/deps/openssl/crypto/aes/aesni-x86_64.asm",
        "in/deps/openssl/crypto/aes/aesni-xts-avx512.asm",
        "in/deps/openssl/crypto/aes/bsaes-x86_64.asm",
        "in/deps/openssl/crypto/aes/vpaes-x86_64.asm",
        "in/deps/openssl/crypto/bn/rsaz-2k-avx512.asm",
        "in/deps/openssl/crypto/bn/rsaz-2k-avxifma.asm",
        "in/deps/openssl/crypto/bn/rsaz-3k-avx512.asm",
        "in/deps/openssl/crypto/bn/rsaz-3k-avxifma.asm",
        "in/deps/openssl/crypto/bn/rsaz-4k-avx512.asm",
        "in/deps/openssl/crypto/bn/rsaz-4k-avxifma.asm",
        "in/deps/openssl/crypto/bn/rsaz-avx2.asm",
        "in/deps/openssl/crypto/bn/rsaz-x86_64.asm",
        "in/deps/openssl/crypto/bn/x86_64-gf2m.asm",
        "in/deps/openssl/crypto/bn/x86_64-mont.asm",
        "in/deps/openssl/crypto/bn/x86_64-mont5.asm",
        "in/deps/openssl/crypto/camellia/cmll-x86_64.asm",
        "in/deps/openssl/crypto/chacha/chacha-x86_64.asm",
        "in/deps/openssl/crypto/ec/ecp_nistz256-x86_64.asm",
        "in/deps/openssl/crypto/ec/x25519-x86_64.asm",
        "in/deps/openssl/crypto/md5/md5-x86_64.asm",
        "in/deps/openssl/crypto/modes/aes-gcm-avx512.asm",
        "in/deps/openssl/crypto/modes/aesni-gcm-x86_64.asm",
        "in/deps/openssl/crypto/modes/ghash-x86_64.asm",
        "in/deps/openssl/crypto/poly1305/poly1305-x86_64.asm",
        "in/deps/openssl/crypto/rc4/rc4-md5-x86_64.asm",
        "in/deps/openssl/crypto/rc4/rc4-x86_64.asm",
        "in/deps/openssl/crypto/sha/keccak1600-x86_64.asm",
        "in/deps/openssl/crypto/sha/sha1-mb-x86_64.asm",
        "in/deps/openssl/crypto/sha/sha1-x86_64.asm",
        "in/deps/openssl/crypto/sha/sha256-mb-x86_64.asm",
        "in/deps/openssl/crypto/sha/sha256-x86_64.asm",
        "in/deps/openssl/crypto/sha/sha512-x86_64.asm",
        "in/deps/openssl/crypto/whrlpool/wp-x86_64.asm",
        "in/deps/openssl/crypto/x86_64cpuid.asm",
        "in/deps/openssl/engines/e_padlock-x86_64.asm")
target("php")
    set_enabled(false)
    set_kind("object")
    set_targetdir(get_config("builddir"))
    add_files("in/php-src/Zend/zend.c")

    add_asflags("/DBOOST_CONTEXT_EXPORT=EXPORT", {force = true})
    add_files("in/php-src/Zend/asm/*_xmm_x86_64_ms_masm.asm")
