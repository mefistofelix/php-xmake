# Project Guidance

## Goal

Build PHP on Windows with a minimal `xmake.lua`. Link third-party dependencies statically, retain compatibility with loadable PHP extension DLLs, use the dynamically linked multithreaded MSVC CRT, and use parallel compilation.

Keep this file and `TODO.md` clear, organized, written in English, and synchronized with the implementation.

## Supported Environment

- Support Windows only for now; do not add cross-platform branches prematurely.
- Select the dynamic multithreaded MSVC runtime globally with `set_runtimes("MD")`; verify that release compile commands use `/MD`. PHP's upstream Windows build uses `/MD` for release and `/MDd` for debug. Here, "static" means that third-party dependencies are linked as static archives, not that the CRT is linked statically.
- Preserve compatibility with externally built PHP extension DLLs. `/MD` matches upstream PHP release builds and avoids crossing DLL boundaries with separate CRT heaps, but it is only one compatibility condition: extensions must also match the PHP API/build ID, architecture, toolset, debug/release mode, and ZTS/NTS mode.
- `set_kind("static")` selects a static archive but does not select the CRT. Library-level threading options such as `ZSTD_MULTITHREAD` and the eventual PHP ZTS/NTS choice are also separate from the CRT selection.
- Prefer relative paths throughout the build.
- Prefer Xmake built-in placeholders and platform/toolchain queries for architecture-dependent values such as `x64`, Windows paths, type sizes, and compiler properties.
- The supported workflow is:

  ```text
  xmake prepare
  xmake
  ```

- `xmake prepare` is run manually before the main build and must be idempotent. It downloads and extracts source trees, prebuilt dependencies, and required external tools.
- Prefer the dependency's authoritative upstream source. When an official GitHub repository contains the required pinned version, prefer `hx github://owner/repository?ref=release-tag`. Do not choose an unofficial mirror, a stale GitHub repository, or a repository missing the required version merely to use GitHub; use the best official repository or release archive instead. Do not download a prebuilt PHP SDK package when the dependency is being compiled by its own Xmake target.
- Whenever a dependency URL, ref, archive, or destination changes in `prepare`, remove the exact existing downloaded dependency directory before validation and run `xmake prepare` from a clean absence. Resolve and verify that the deletion target is the intended direct child of `in/deps` before removing it. Remove obsolete previous download directories too, then run a second no-change `xmake prepare` to validate idempotence.

## Target Model

- Before converting a dependency, inspect its original non-Xmake build system (`CMakeLists.txt`, configure scripts, Makefiles, Visual Studio projects, or equivalent). Treat it as the primary source for the exact source list and exclusions, generated files, platform defines, include paths, output names, runtime flags, optional assembly, and dependency edges. Record the relevant findings in this file before the first build attempt so Xmake conversion is guided by upstream intent instead of trial and error.
- Before accepting verbose declarations, custom Lua, or a workaround, investigate whether Xmake already provides a cleaner declarative API, built-in rule, policy, placeholder, or file-level setting. Prefer the simplest Xmake-native form and document non-obvious semantics that affect future targets.
- Keep `xmake.lua` primarily declarative: it should consist of Xmake configuration, target declarations, and only the target-specific native `on_prepare` callbacks that perform real configuration generation or code generation.
- Do not add arbitrary Lua helper functions, tables, aliases, or variables. Introduce Lua state only when an Xmake API requires it and no direct declarative expression is practical; keep such state local to the owning task or target's `on_prepare` callback.
- A target that needs imperative configuration or code generation must use one target-specific native `on_prepare` callback as its single imperative entry point. Do not store callbacks in custom file configuration, inject Xmake APIs such as `os.vrunv` or imported modules through callback arguments, or split target preparation across extra Lua functions. Use build APIs directly in the native callback and import a module there only when required. A target with no such work must not define an empty callback.
- Xmake directory imports are eager: importing a namespace loads every Lua file beneath it recursively. A small namespace such as `async` is acceptable when its qualified API improves clarity, but do not import the entire `core` namespace for one facility; import the exact module such as `core.base.option`.
- Give every library dependency its own static-library target.
- Treat preprocessor definitions as part of the dependency's ABI and symbol-surface configuration. Before adding them, inspect the upstream public-header import/export macros and static target. Enable only the standard upstream public interface required by PHP; do not expose shared-library export modes, alternate namespaces, experimental/deprecated APIs, or private interfaces accidentally.
- Propagate with `{public = true}` only definitions that consumers of the static archive must see in public headers, such as `LZMA_API_STATIC`. Keep feature-selection, platform, threading, internal namespace, and implementation-detection definitions private to the owning target. When definitions can affect external linkage, inspect the resulting archive or final DLL symbol surface as part of validation.
- Do not mirror an upstream build's internal component libraries as separate Xmake targets by default. Keep one dependency in one target and include all of its components there. Create sublibrary targets only when a single target is proven impractical by duplicate external symbols, incompatible compile settings, unavoidable build ordering/code-generation edges, or another concrete technical constraint. Unity-group splits do not require target splits.
- PHP extensions are part of the main PHP target; do not create a separate target for each extension.
- Add source files with the broadest safe patterns, ideally at dependency or PHP-tree scope.
- Choose source and file-configuration patterns by the broadest correct match and the simplicity of the complete declaration, not by directory boundaries or a requirement for semantic grouping. Compare the total `add_files`, `remove_files`, exclusions, and narrow overrides, and use a recursive or cross-directory glob only when it reduces that total cleanly. Verify every match against the pinned upstream source manifest. Use a character class only for true single-character alternatives, such as `*.[ch].in`; use separate complete-word patterns for longer alternatives.
- When a directory contains mostly target sources plus a small, clearly identifiable set of programs, tests, or generators, prefer a broad `add_files` followed by Xmake's declarative `remove_files` patterns. Keep an explicit positive source list when exclusions would be longer, fragile, or liable to admit unrelated files.
- Prefer a clean two-layer source declaration when only a subset needs file-specific settings: first call `add_files` once with the broadest pattern and no file config, then repeat only the narrower subset with its file config. Xmake deduplicates the matched source paths and applies the narrow config. Do not use exclusion-heavy globs merely to re-add those files.
- Defer further unity-build work until every dependency target and the complete PHP target have a validated baseline build. Compile each source independently for all new integrations; do not add `c.unity_build`, `unity_group`, or `unity_ignored` during this phase. Existing validated dependency targets may retain their current layouts until unity optimization is revisited globally.
- Build the project incrementally, one target at a time, starting with dependencies and ending with the complete PHP target.
- Keep only the current priority target active during focused build/debug cycles. Use `set_enabled(false)` to remove unrelated or unfinished targets completely. Use `set_default(false)` when a target must remain available for an explicit build or as a dependency but should not join the default build. Re-enable a target when it becomes the priority or a dependency of the priority target.

## Code Generation

- Run every required code-generation step from the owning target's native `on_prepare` callback.
- For each target that actually needs configuration generation or code generation, use exactly one target-specific `on_prepare` callback. It owns all generated sources, headers, and configuration files for the target.
- Declare `on_prepare` before the target's source entries so the generation phase is evident before ordinary and generated inputs are declared.
- Do not create a separate callback for each generated file.
- If a callback needs an external executable such as Perl, Bison, RE2C, or the Windows message compiler, make that executable available during `xmake prepare`.
- If a callback needs an executable built by this project, such as `minilua` or `gen_ir_fold_hash`, build/invoke its Xmake target programmatically from the callback using Xmake built-ins.
- Generate C configuration headers and their defines/parameters in the owning target's `on_prepare` callback. Use Xmake detection APIs for platform properties instead of hard-coding them.
- Keep source and generated paths relative. Use Xmake placeholders for platform-dependent path segments where possible.
- Document every code-generation action in the inventory in this file, including owner target, input, output, tool, arguments, assembly use, and intertwined dependencies.

## Documentation and Progress

- This file is the build-policy, target, and code-generation reference. Keep its inventories synchronized with `xmake.lua`.
- Treat durable guidance supplied by the user during development as project policy: evaluate it, incorporate the important parts into this file in English, and revise or replace older rules when the guidance makes them obsolete. Keep one-off test observations in `TODO.md` instead of turning them into permanent policy.
- `TODO.md` is the live implementation plan. Update completed work, the next target, blockers, and validation status whenever the build changes.
- Do not claim a target is working until it has been built successfully.

## Validation and Git Workflow

- Commit all intended source and documentation changes before every Xmake configure or build test.
- After a test, record the result in `TODO.md`; commit that update before the next Xmake test.
- Use matching reference DLLs from `dll_compare` to validate static archive symbol coverage when available. Compare exported DLL names with archive-defined symbols and also inspect architecture, CRT directives, import thunks, and embedded `/EXPORT:` directives as applicable.
- Keep generated files, downloaded sources, tool binaries, caches, and build output ignored.
- Treat warnings and accidental undeclared inputs as build issues to investigate rather than silently accepting them.

## Current Target Inventory

| Target | Build state | Kind | Source inputs | Output | Purpose | Status |
| --- | --- | --- | --- | --- | --- | --- |
| `zlib` | Disabled | Static library | `in/deps/zlib/*.c` | `out/zlib.lib` | First compression dependency | Build validated with `/MD` on MSVC x64 |
| `brotli` | Disabled | Static library | `in/deps/brotli/c/common/*.c`, `in/deps/brotli/c/dec/*.c`, `in/deps/brotli/c/enc/*.c` | `out/brotli.lib` | Complete Brotli common, decoder, and encoder implementation | One target; three compilation units; build validated with `/MD` on MSVC x64 |
| `zstd` | Disabled | Static library | `in/deps/zstd/lib/{common,compress,decompress,dictBuilder,legacy}/*.c` | `out/zstd.lib` | Multithreaded zstd library with level-5 legacy decoding | One main unity group; FastCover and legacy sources isolated; build validated with explicit `/MD` on MSVC x64 |
| `bzip2` | Disabled | Static library | `in/deps/bzip2/*.c` minus upstream programs/tests via `remove_files` | `out/bzip2.lib` | bzip2 compression library for the PHP bz2 extension | Exactly seven library sources in one unity translation unit; declarative selection validated with `/MD` on MSVC x64 |
| `liblzma` | Disabled | Static library | Upstream-default library sources under `in/deps/xz/src/{common,liblzma}` | `out/liblzma.lib` | XZ/LZMA compression for PHP consumers including zip, GD, and fileinfo | One target; five-unit minimum unity partition; build and static-interface validation passed with `/MD` on MSVC x64 |
| `openssl` | Disabled | Static library | Broad C selection plus pattern-selected x86-64 NASM inputs | `out/openssl.lib` | TLS and cryptography | Former `openssl_test` target promoted unchanged except for its name; prior clean build and 6,475-symbol check passed |
| `libssh2` | Disabled | Static library | 26 sources from `in/deps/libssh2/src/*.c` after seven backend/platform removals | `out/libssh2.lib` | OpenSSL-backed SSH transport required by libcurl/PHP | Build and 137-export static-interface validation passed with `/MD` on MSVC x64 |
| `nghttp2` | Disabled | Static library | All 26 C sources under `in/deps/nghttp2/lib/*.c` | `out/nghttp2.lib` | HTTP/2 transport required by libcurl/PHP | Build and 181-export static-interface validation passed with `/MD` on MSVC x64 |
| `libcurl` | Disabled | Static library | 192 sources under `in/deps/libcurl/lib` after removing `dllmain.c` | `out/libcurl.lib` | PHP curl transport library | Complete dependency build and 100-symbol static-interface validation passed with `/MD` on MSVC x64 |
| `libsodium` | Disabled | Static library | All 141 C files under `in/deps/libsodium/src/libsodium` | `out/libsodium.lib` | Modern cryptography used by PHP sodium | Build and 756-export static-interface validation passed with `/MD` on MSVC x64 |
| `libuv` | Disabled | Static library | 12 common and 25 Windows C sources | `out/libuv.lib` | Event loop and async I/O required by True Async | Build and complete 318-API header-surface validation passed with `/MD` on MSVC x64 |
| `minilua` | Disabled | Binary | `in/php-src/ext/opcache/jit/ir/dynasm/minilua.c` | `out/minilua.exe` | Runs DynASM for the PHP JIT IR emitter | Defined; build validation pending |
| `gen_ir_fold_hash` | Disabled | Binary | `in/php-src/ext/opcache/jit/ir/gen_ir_fold_hash.c` | `out/gen_ir_fold_hash.exe` | Generates the JIT IR fold hash header | Defined; build validation pending |
| `php` | Disabled | Object prototype | `in/php-src/Zend/zend.c`, `in/php-src/Zend/asm/*_xmm_x86_64_ms_masm.asm` | `out/` | Becomes the static PHP build after dependency, configuration, codegen, and source integration | Prototype only; real `on_prepare` codegen pending |

The `prepare` task fetches dependencies. Each library must receive its own Xmake static-library target as it is integrated; downloaded or prebuilt archives are not yet build targets.

The zlib target uses the default unity group for `adler32.c`, `compress.c`, `crc32.c`, `deflate.c`, `trees.c`, and `uncompr.c`. It compiles `zutil.c`, all `gz*.c` files, and all `inf*.c` files separately. `gzguts.h`, `inflate.h`, and `inftrees.h` are internal headers without conventional guards; repeated inclusion redefines types, and `gzguts.h` also exposes `COPY` and `GZIP` macros that collide with the deflate/inflate implementation. These observed conflicts make those sources unsafe in a shared translation unit.

### zlib upstream build analysis

- Upstream version: zlib 1.3.2.
- `CMakeLists.txt` and `win32/Makefile.msc` agree on the same 15 root C sources; the Xmake wildcard covers exactly that set.
- The upstream static CMake target defines `ZLIB_BUILD`, `NO_FSEEKO` when the probe fails on MSVC, `_CRT_SECURE_NO_DEPRECATE`, and `_CRT_NONSTDC_NO_DEPRECATE`. It does not enable Unix large-file or hidden-visibility defines on Windows.
- The shipped root `zconf.h` already contains the Windows configuration used by the MSVC Makefile, so the zlib target needs no callback.
- The MSVC Makefile names the static result `zlib.lib`. CMake uses `zs.lib`; this project keeps `zlib.lib` to match the native MSVC convention and the target name.
- The MSVC Makefile declares optional x86/x64 assembly rules but leaves `OBJA` empty. Upstream CMake also leaves contrib acceleration disabled by default, so the initial target intentionally compiles no assembly.

### Brotli upstream build analysis

- Upstream version: Brotli 1.2.0.
- Upstream CMake and Bazel define three component libraries: `brotlicommon`, `brotlidec`, and `brotlienc`, with decoder and encoder depending on common. This project combines all three components into one `brotli` target because they belong to one dependency. The upstream split remains useful for understanding source ownership, but it is not sufficient reason to create Xmake subtargets.
- Each component source list is the broad recursive set under `c/common/*.c`, `c/dec/*.c`, or `c/enc/*.c`. Public headers come from `c/include`.
- MSVC requires `_CRT_SECURE_NO_WARNINGS`. Brotli shared-compilation defines do not apply to these static targets, and the upstream math-library dependency is empty on MSVC.
- No build-time code generation or assembly is enabled. `c/common/dictionary_inc.h` and the encoder's generated lookup headers are committed inputs. `c/common/dictionary.bin` is exposed as Bazel data but is not an input to the CMake library compilation.
- Start the complete dependency with all common, decoder, and encoder sources in one unity translation unit. Split unity groups inside the same target only if a concrete conflict is observed; split targets only if a single archive is technically impossible.
- The full one-unit build proved that encoder files reuse private function names. Keep one `brotli` target but use the minimal three-color split required by the observed conflict graph: the default unity group contains 33 sources; a secondary group contains `compress_fragment_two_pass.c` and `entropy_encode.c`; `static_dict.c` compiles separately. This separates `compress_fragment.c` from its two-pass variant and static dictionary, `encode.c` from the two-pass variant, `brotli_bit_stream.c`/decoder `huffman.c` from entropy encoding, and both fragment implementations from static dictionary.

### zstd upstream build analysis

- Upstream version: zstd 1.5.7.
- CMake, `lib/Makefile`, `lib/libzstd.mk`, and the Visual Studio static-library project define one library from common, compression, decompression, dictionary-builder, and optional legacy modules. Keep all modules in one `zstd` target.
- The Windows project enables `ZSTD_MULTITHREAD=1`, `ZSTD_LEGACY_SUPPORT=5`, `ZSTD_HEAPMODE=0`, and `_CRT_SECURE_NO_WARNINGS`. CMake disables the GNU-style `huf_decompress_amd64.S` path on MSVC with `ZSTD_DISABLE_ASM`; no MASM replacement is part of the upstream static target.
- Include all 8 common, 14 compression, 4 decompression, and 4 dictionary-builder C sources. Include legacy decoders v01 through v07 because upstream CMake and the Visual Studio project enable legacy level 5 by default. Exclude the 3 deprecated-buffer sources because `ZSTD_BUILD_DEPRECATED` defaults to off and the Visual Studio project omits them.
- No build-time code generation is required, so the target has no `on_prepare` callback.
- Keep 29 current sources in the default unity group. Compile `dictBuilder/fastcover.c` separately because it and `cover.c` both include the unguarded internal `cover.h`, which redefines shared structures when merged. Compile each of the seven legacy decoder sources separately: source inspection shows that historical implementations intentionally reuse dozens of private FSE, HUF, and ZSTD function names, making a shared unity translation unit invalid even though they coexist safely as separate objects in one archive.
- Upstream CMake calls the MSVC static archive `zstd_static.lib` only to avoid a shared import-library name collision. This static-only project uses the simpler target-derived name `zstd.lib`.

### bzip2 upstream build analysis

- Upstream version: bzip2 1.0.8, the current stable release. Sourceware is the authoritative upstream and publishes the official release tarball. The available GitHub repository is a mirror, so fetch the Sourceware tarball and strip its single top-level directory with `hx`. Do not retain the redundant prebuilt PHP SDK archive.
- The root `Makefile` and `makefile.msc` agree that the library contains exactly `blocksort.c`, `huffman.c`, `crctable.c`, `randtable.c`, `compress.c`, `decompress.c`, and `bzlib.c`. The root contains only those library sources plus six command-line/test programs, so use one broad `*.c` declaration and remove the five concise patterns `bzip2*.c`, `dlltest.c`, `mk251.c`, `spewG.c`, and `unzcrash.c` with Xmake's native `remove_files` API.
- The upstream MSVC build uses `WIN32`, `_FILE_OFFSET_BITS=64`, `/MD`, and `/Ox`. The project-wide runtime supplies `/MD`. The Xmake-native `set_optimize("fastest")` emits MSVC `/O2`, its portable maximize-speed preset; do not describe it as an exact `/Ox` mapping. No assembly or build-time code generation is required, so the target has no `on_prepare` callback.
- All seven library sources compile successfully in one unity translation unit; no split or isolated source is needed.
- Upstream MSVC calls the archive `libbz2.lib`, while the PHP SDK package calls its static variant `libbz2_a.lib`. Since the final PHP target will depend directly on the Xmake target rather than search by filename, this project keeps the simpler target-derived `bzip2.lib`.

### liblzma upstream build analysis

- Upstream project: XZ Utils from the official `tukaani-project/xz` GitHub repository. Pin tag `v5.8.3`, which matches the previously downloaded PHP SDK package version, and fetch it as source into `in/deps/xz`; do not retain the redundant prebuilt `liblzma` archive.
- The root upstream `CMakeLists.txt` is the authoritative liblzma source declaration. With default options it includes the common API/container implementation, both multithreaded stream coders, LZ/LZMA1/LZMA2, delta, all eight simple BCJ filters, MicroLZMA encoder/decoder, lzip decoder, CRC32, CRC64, internal SHA-256, and Windows CPU-count/physical-memory helpers. Generator/table-generator sources, small CRC variants, command-line tools, and non-MSVC assembly are excluded.
- On Windows x64, upstream selects `MYTHREAD_VISTA`, all five match finders, both encoders and decoders for every supported filter, the three integrity checks, fast unaligned access, MSVC intrinsics with runtime-detected CLMUL CRC, and `HAVE_VISIBILITY=0`. The public static-library interface requires `LZMA_API_STATIC`. Native Windows threading needs no additional link library.
- `LZMA_API_STATIC` is the only propagated definition: it prevents public headers from applying `dllimport` to standard liblzma APIs when a consumer links the static archive. Do not define `DLL_EXPORT`. All `HAVE_*`, match-finder/filter, threading, visibility, and `TUKLIB_SYMBOL_PREFIX=lzma_` definitions are private implementation configuration and must not leak to consumers.
- The CMake path does not generate a configuration header for liblzma. It supplies feature macros directly and uses committed `tuklib_config.h` and public API/version headers, so no code generation and no `on_prepare` callback are required.
- The source directories that contain only default library inputs use broad `*.c` declarations. The check directory is explicit because it also contains mutually exclusive small variants and generator programs; the LZMA directory excludes its table generator. The initial one-unit build proved that many state-machine implementation files reuse translation-unit-scoped `SEQ_*` enumerators, private coder typedefs, and static helper names. Keep one target, derive the minimum compatible unity partition from the observed private-symbol conflict graph, and avoid arbitrary batch sizes.
- Source-level symbol analysis found 39 conflict edges. `alone_decoder.c`, `alone_encoder.c`, `auto_decoder.c`, `block_decoder.c`, and `block_encoder.c` all define `SEQ_CODE`, forming a five-file clique and proving that at least five translation units are required. A five-color partition reaches that lower bound. Its first builds eliminated the source-level collisions but revealed that `lz_decoder.h` and `lz_encoder.h` both define the internal `lzma_lz_options` type. Keep every remaining encoder-header user in the already encoder-compatible fourth exception group: direct user `lz_encoder_mf.c`, plus `lzma_encoder.c` and both `lzma_encoder_optimum_*.c` files through `lzma_encoder_private.h`. Use the wider `lzma_encoder*.c` override because compatible `lzma_encoder_presets.c` is cheaper to include in this group than to exclude from the pattern. Keep `lzma_decoder.c` in the decoder-compatible second group instead of the first encoder group. Do not widen that setting to `lzma*_decoder.c`: `lzma2_decoder.c` would collide with the second group on `SEQ_PROPERTIES` and `SEQ_COPY`. The resulting groups contain 55, 10, 4, 3, and 7 sources; no sixth unit is needed.
- The final archive inspection confirms static-interface intent: its COFF directives contain no `/EXPORT:` entry, its linker members contain no `__imp_lzma*` import thunk, and representative standard APIs such as `lzma_version_number`, `lzma_easy_encoder`, and `lzma_stream_decoder` are present. All five objects request `MSVCRT` and none requests `LIBCMT`, confirming `/MD`. Internal cross-object symbols in a static archive are implementation linkage, not DLL exports; the final PHP DLL must still control its own export list.
- Upstream 5.8.3 now names the MSVC static archive `lzma.lib`, while the PHP SDK package and PHP build probes use `liblzma_a.lib` or `liblzma.lib`. The final PHP target will depend directly on this Xmake target, so the project keeps the logical target-derived `liblzma.lib`.

### OpenSSL upstream build analysis

- Use the official `openssl/openssl` repository pinned to `openssl-3.5.7`.
- The official `openssl` target is the previously validated compact `openssl_test` target with only its target name changed. Do not reintroduce declarations or generation logic from the removed verbose target.
- Its broad source patterns, declarative removals, callback, includes, defines, and x86-64 assembly pattern remain unchanged. It compiles sources independently and does not enable unity.
- The prior clean `openssl_test` build produced one static archive containing all 6,475 names exported by the OpenSSL reference DLLs, with no embedded `/EXPORT:` directive. Future symbol checks use the copies under `dll_compare`.

### libssh2 upstream build analysis

- Replace the PHP SDK binary package with the official `libssh2/libssh2` repository pinned to `libssh2-1.11.1`, matching the package version previously selected by `prepare`.
- Clean-absence and no-change preparation both pass. `src/Makefile.inc` defines 26 static-library C sources. The broad `src/*.c` pattern finds those plus exactly seven backend/platform fragments, so one `remove_files` list reproduces the manifest.
- `crypto.c` textually includes the selected backend implementation. Define `LIBSSH2_OPENSSL` and do not compile `openssl.c` separately. The other crypto backend C files, `agent_win.c`, and `blowfish.c` are likewise not independent manifest inputs.
- Do not define `HAVE_CONFIG_H`: `libssh2_setup.h` contains the authoritative hand-written MSVC configuration. The static public headers require no consumer define because they apply import/export decoration only for shared-library modes.
- Upstream disables zlib compression by default, and the reference `dll_compare/libssh2.dll` imports OpenSSL but no zlib DLL. Keep zlib disabled to match that interface. Propagate the Windows static-link libraries `ws2_32`, `crypt32`, and `bcrypt`.
- Compile all 26 C sources independently with no callback and no unity rule. Validate the archive against all 137 exports from `dll_compare/libssh2.dll`, plus x64 and `/MD` directives.

### nghttp2 upstream build analysis

- Use the already pinned official `nghttp2/nghttp2` repository at `v1.69.0`.
- Upstream `lib/CMakeLists.txt` and `lib/Makefile.am` agree on all 26 direct C children of `lib`; the older standalone MSVC makefile omits five newer sources, so use the current CMake/Automake manifest. The broad `lib/*.c` pattern matches it exactly.
- The library has no external link dependency. Its Windows configuration needs `ssize_t=int`, `HAVE_WINDOWS_H`, and `HAVE_GETTICKCOUNT64`; define `BUILDING_NGHTTP2` privately. Propagate `NGHTTP2_STATICLIB` because consumers must suppress `dllimport` in the public header.
- Generate `lib/includes/nghttp2/nghttp2ver.h` from its committed `.in` template in the single target callback, substituting version `1.69.0` and hexadecimal version `0x014500`. No other generated input or callback is required.
- Compile all 26 sources independently without unity. Compare the archive with the 181 exports from `dll_compare/nghttp2.dll`, and verify x64 `/MD`, no `/EXPORT:` directives, and no `__imp_nghttp2*` thunks.

### nghttp2 code-generation inventory

| Owner | Tool | Input | Output | Handling | Status |
| --- | --- | --- | --- | --- | --- |
| `nghttp2` | Xmake Lua I/O | `lib/includes/nghttp2/nghttp2ver.h.in` | `lib/includes/nghttp2/nghttp2ver.h` | Replace `@PACKAGE_VERSION@` with `1.69.0` and `@PACKAGE_VERSION_NUM@` with `0x014500` in the target's only `on_prepare` callback | Build validated |

### libcurl upstream build analysis

- Use the official `curl/curl` GitHub repository pinned to tag `curl-8_21_0`, matching the previous PHP SDK package version 8.21.0. Fetch sources into `in/deps/libcurl` and do not retain the redundant prebuilt SDK archive when libcurl is compiled by its own Xmake target.
- `lib/Makefile.inc` selects 192 C sources: every C file under `lib` except shared-library-only `dllmain.c`. The direct and recursive broad source patterns plus that one removal reproduce the upstream manifest exactly.
- PHP's Windows curl configuration requires OpenSSL, zlib, libssh2, nghttp2, WinIDN/`normaliz`, Winsock, and Windows LDAP; Brotli and zstd are optional but available from validated targets. Complete libssh2 and nghttp2 first so the initial libcurl target is feature-complete rather than a temporary reduced build.
- The hand-written `lib/config-win32.h` supplies Windows types and probes, threaded DNS, Windows LDAP and crypto, and Unix-socket support. Define `BUILDING_LIBCURL` privately and propagate only `CURL_STATICLIB`, which public headers require to suppress DLL decoration for static consumers.
- Enable `USE_OPENSSL`, `HAVE_LIBZ`, `HAVE_BROTLI`, `HAVE_ZSTD`, `USE_LIBSSH2`, `USE_NGHTTP2`, `USE_WIN32_IDN`, and `USE_IPV6`. Keep `CURL_CA_NATIVE` disabled, matching its upstream default; WinIDN supplies the PHP-required `normaliz` edge independently of native CA handling.
- Depend on the enabled `openssl`, `zlib`, `brotli`, `zstd`, `libssh2`, and `nghttp2` targets so the complete libcurl closure participates in its build test. Inherit their public headers and static-interface definitions; retain only libcurl's private directory and OpenSSL's non-public include directory explicitly. Propagate the Windows closure selected by upstream and PHP: `advapi32`, `bcrypt`, `crypt32`, `iphlpapi`, `normaliz`, `winmm`, `wldap32`, and `ws2_32`.
- No library input requires generation: `easyoptions.c` and its data are committed upstream. Compile all 192 sources independently without a callback or unity rule, then validate the public symbol set against `lib/libcurl.def` because `dll_compare` has no libcurl DLL.

### libsodium upstream build analysis

- Replace the PHP SDK binary package with the official `jedisct1/libsodium` repository pinned to tag `1.0.22`, which resolves to the same release version.
- Clean-absence and unchanged-repeat preparation both pass and retain the correct official-source hx marker.
- The upstream VS2026 project lists all 141 C files under `src/libsodium` and no other C input; the recursive Xmake glob reproduces this manifest exactly. The autotools manifest agrees on the full non-minimal feature set and the architecture-specific C implementations.
- The MSVC AMD64 assembly option defaults to off. Keep it off and compile the reference, SSE2, SSSE3, SSE4.1, AVX2, AVX512F, AES-NI, and platform C files that the official project includes; their guards and runtime CPU dispatch select usable implementations.
- The official MSVC pre-build step copies committed `builds/msvc/version.h` to `src/libsodium/include/sodium/version.h`. Reproduce that idempotent copy in the target's only callback; there is no other generation.
- Propagate `SODIUM_STATIC` so public headers suppress `dllimport`. Keep `NATIVE_LITTLE_ENDIAN`, `NDEBUG`, `UNICODE`, `WIN32`, `WIN64`, `_CRT_SECURE_NO_WARNINGS`, `_LIB`, `_UNICODE`, and `inline=__inline` private, matching the MSVC property sheets. Retain the toolset's `/UndefIntOverflow-` behavior.
- Upstream's standalone static ReleaseLIB configuration selects `/MT`, but this project deliberately overrides it with the global `/MD` policy required for PHP DLL compatibility. The only system dependency is `advapi32`, used for Windows random generation.
- Compile every source independently without unity. Validate against the exports of `dll_compare/libsodium.dll`, plus archive architecture, `/MD`, static decoration, and absence of embedded export directives.

### libsodium code-generation inventory

| Owner | Tool | Input | Output | Handling | Status |
| --- | --- | --- | --- | --- | --- |
| `libsodium` | Xmake file copy | `builds/msvc/version.h` | `src/libsodium/include/sodium/version.h` | Idempotent copy in the target's only `on_prepare` callback, matching the official MSVC pre-build event | Build validated |

### libuv upstream build analysis

- Use the already prepared official `libuv/libuv` repository pinned to `v1.52.1`. This exceeds the True Async extension's stated minimum of 1.45.0.
- Upstream CMake selects 12 direct C children of `src` plus all 25 C sources in `src/win` on Windows. The two broad Xmake patterns reproduce exactly those 37 sources while excluding all 50 Unix sources, tests, and benchmarks.
- The Windows implementation defines `WIN32_LEAN_AND_MEAN`, `_WIN32_WINNT=0x0A00`, and `_CRT_DECLARE_NONSTDC_NAMES=0` privately. Retain upstream's undeclared-function error flag `/we4013`.
- The public header applies DLL decoration only when `BUILDING_UV_SHARED` or `USING_UV_SHARED` is defined. Define neither for this static target; consumers require no propagated definition.
- Propagate the exact CMake Windows library closure in its declared order: `psapi`, `user32`, `advapi32`, `iphlpapi`, `userenv`, `ws2_32`, `dbghelp`, `ole32`, and `shell32`. PHP True Async also explicitly expects `Dbghelp` and `Userenv`.
- There is no library code generation or assembly. Compile every source independently without a callback or unity; validate the archive architecture, `/MD`, static decoration, and representative APIs from `uv.h` because `dll_compare` has no libuv DLL.
- MSVC 14.50 emits C4090 at `uv-common.c:960` and `win/util.c:644`: the public `uv_cpu_info_t.model` field is intentionally `const char *`, while libuv owns and frees its allocation through `uv__free(void *)`. This is source-level upstream const qualification, not an Xmake configuration or unity issue; retain and document the warnings rather than patching the pinned source or adding a blanket suppression.

### nghttp3 upstream build analysis

- Use the official `ngtcp2/nghttp3` repository at commit `dbfc24286138cb0b6490160e7ca87fe1ce6722a0`, which is release tag `v1.18.0`. Its `lib/sfparse` input is a Git submodule, which plain GitHub source archives leave empty; use hx's native `--recursive` flag so `xmake prepare` materializes the exact gitlink commit recorded by the release. Hx's recursive Git path currently treats symbolic refs as branch names, so the immutable release commit is required instead of the equivalent tag name.
- Upstream `lib/CMakeLists.txt` and `lib/Makefile.am` agree on 31 direct `lib/nghttp3_*.c` sources plus `lib/sfparse/sfparse.c`. Compile those 32 inputs independently without unity.
- Define `BUILDING_NGHTTP3` privately and propagate `NGHTTP3_STATICLIB`, which suppresses DLL decoration in the public header. The library has no external link dependency.
- The generated CMake configuration only supplies Unix feature probes and a fallback `ssize_t` typedef. The selected Windows implementation does not use `ssize_t`, and its endian conversion takes the explicit `_byteswap_*` path, so the target does not need `HAVE_CONFIG_H` or a generated `config.h`.
- Generate `lib/includes/nghttp3/version.h` from its committed `.in` template in the target's only callback, substituting version `1.18.0` and hexadecimal version `0x011200`. No other generated input or callback is required.

## PHP Code-generation Inventory

All paths below are relative to `in/php-src` unless prefixed with `out/`. Entries marked "planned" reproduce the known PHP generation commands but are not yet wired into the `php` target's `on_prepare` callback.

| Owner | Tool | Input | Primary output | Full command / special handling | Status |
| --- | --- | --- | --- | --- | --- |
| `php` | Bison | `Zend/zend_ini_parser.y` | `Zend/zend_ini_parser.c` | `bison -Wall --no-lines --output=Zend/zend_ini_parser.c -v -d Zend/zend_ini_parser.y`; also emits the parser header/report | Planned |
| `php` | Bison | `Zend/zend_language_parser.y` | `Zend/zend_language_parser.c` | `bison -Wall --no-lines --output=Zend/zend_language_parser.c -v -d Zend/zend_language_parser.y`; also emits the parser header/report | Planned |
| `php` | Bison | `sapi/phpdbg/phpdbg_parser.y` | `sapi/phpdbg/phpdbg_parser.c` | `bison -Wall --no-lines --output=sapi/phpdbg/phpdbg_parser.c -v -d sapi/phpdbg/phpdbg_parser.y`; also emits the parser header/report | Planned |
| `php` | Bison | `ext/json/json_parser.y` | `ext/json/json_parser.tab.c` | `bison -Wall --no-lines --defines ext/json/json_parser.y -o ext/json/json_parser.tab.c`; also emits the parser header | Planned |
| `php` | RE2C | `Zend/zend_ini_scanner.l` | `Zend/zend_ini_scanner.c`, `Zend/zend_ini_scanner_defs.h` | `re2c --no-generation-date --case-inverted -cbdFt Zend/zend_ini_scanner_defs.h -oZend/zend_ini_scanner.c Zend/zend_ini_scanner.l` | Planned |
| `php` | RE2C | `Zend/zend_language_scanner.l` | `Zend/zend_language_scanner.c`, `Zend/zend_language_scanner_defs.h` | `re2c --no-generation-date --case-inverted -cbdFt Zend/zend_language_scanner_defs.h -oZend/zend_language_scanner.c Zend/zend_language_scanner.l` | Planned |
| `php` | RE2C | `sapi/phpdbg/phpdbg_lexer.l` | `sapi/phpdbg/phpdbg_lexer.c` | `re2c --no-generation-date -cbdFo sapi/phpdbg/phpdbg_lexer.c sapi/phpdbg/phpdbg_lexer.l` | Planned |
| `php` | RE2C | `ext/json/json_scanner.re` | `ext/json/json_scanner.c`, `ext/json/php_json_scanner_defs.h` | `re2c --no-generation-date -t ext/json/php_json_scanner_defs.h -bci -o ext/json/json_scanner.c ext/json/json_scanner.re` | Planned |
| `php` | RE2C | `ext/standard/var_unserializer.re` | `ext/standard/var_unserializer.c` | `re2c --no-generation-date -b -o ext/standard/var_unserializer.c ext/standard/var_unserializer.re` | Planned |
| `php` | RE2C | `ext/standard/url_scanner_ex.re` | `ext/standard/url_scanner_ex.c` | `re2c --no-generation-date -b -o ext/standard/url_scanner_ex.c ext/standard/url_scanner_ex.re` | Planned |
| `php` | RE2C | `ext/phar/phar_path_check.re` | `ext/phar/phar_path_check.c` | `re2c --no-generation-date -b -o ext/phar/phar_path_check.c ext/phar/phar_path_check.re` | Planned |
| `php` | Windows `mc` | `win32/build/wsyslog.mc` | Headers under `win32/`; resources and binary message data under `out/` | `mc -h win32 -r out -x out win32/build/wsyslog.mc` | Planned |
| `php` | `minilua` target and DynASM | `ext/opcache/jit/ir/ir_x86.dasc` | `ext/opcache/jit/ir/ir_emit_x86.h` | `out/minilua.exe ext/opcache/jit/ir/dynasm/dynasm.lua -L -D WIN=1 -o ext/opcache/jit/ir/ir_emit_x86.h ext/opcache/jit/ir/ir_x86.dasc`; requires a programmatic build of `minilua` | Planned |
| `php` | `gen_ir_fold_hash` target | `ext/opcache/jit/ir/ir_fold.h` | `ext/opcache/jit/ir/ir_fold_hash.h` | `out/gen_ir_fold_hash.exe < ext/opcache/jit/ir/ir_fold.h > ext/opcache/jit/ir/ir_fold_hash.h`; use Xmake process redirection after a programmatic helper build | Planned |

The PHP target also assembles `Zend/asm/*_xmm_x86_64_ms_masm.asm` with MSVC-compatible assembly flags. Broader PHP and extension source inclusion, static linking, and the direct per-source baseline build remain to be implemented.
