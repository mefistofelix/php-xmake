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
- Exclude `ext/dba` from this PHP distribution. Its Windows configuration is opt-in (`ARG_WITH("dba", ..., "no")`), and its external LMDB, QDBM, and Berkeley DB backends are therefore not project dependencies. Do not add `liblmdb`, QDBM, or Berkeley DB solely to match the optional DBA handler set shipped by official PHP Windows binaries.
- Exclude `pdo_firebird` from this PHP distribution. Firebird/fbclient is not a project dependency; do not download, build, or integrate it.
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

- During exploratory configure/build/debug cycles, do not create a commit for every individual test. Iterate freely, keep `TODO.md` synchronized with meaningful findings, and commit only when a useful partial or complete result has been reached.
- Before moving to another dependency or materially different approach, commit the validated partial/complete result so the repository retains a stable checkpoint.
- Use matching reference DLLs from `dll_compare` to validate static archive symbol coverage when available. Compare exported DLL names with archive-defined symbols and also inspect architecture, CRT directives, import thunks, and embedded `/EXPORT:` directives as applicable.
- Keep generated files, downloaded sources, tool binaries, caches, and build output ignored.
- Warnings may be recorded but do not block the current baseline target integration; do not add configuration or delay progress solely to silence them. Accidental undeclared inputs remain build issues to investigate.

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
| `nghttp3` | Disabled | Static library | 31 direct library C sources plus `lib/sfparse/sfparse.c` | `out/nghttp3.lib` | HTTP/3 framing and QPACK required by ngtcp2/PHP | Build and complete 91-API header-surface validation passed with C11 and `/MD` on MSVC x64 |
| `ngtcp2` | Disabled | Static library | All 46 direct C children of `in/deps/ngtcp2/lib` | `out/ngtcp2.lib` | QUIC transport required by PHP HTTP/3 | Build and complete 168-API header-surface validation passed with C11 and `/MD` on MSVC x64 |
| `ngtcp2_crypto_ossl` | Disabled | Static library | `crypto/ossl/ossl.c` and `crypto/shared.c` | `out/ngtcp2_crypto_ossl.lib` | OpenSSL 3.5 QUIC glue required by PHP HTTP/3 | Build and complete 54-API header-surface validation passed with C11 and `/MD` on MSVC x64 |
| `icu` | Disabled | Static library | All 201 common and 254 i18n C++ sources plus generated `icudt77l_dat.obj` | `out/icu.lib` | Unicode common, internationalization, and packaged data for PHP intl | Build, C/data symbol surface, CRT, architecture, and C++ runtime smoke validation passed |
| `libiconv` | Disabled | Static library | `lib/iconv.c`, `libcharset/lib/localcharset.c`, and `lib/compat.c` | `out/libiconv.lib` | Character-set conversion for PHP iconv and dependent libraries | Build, complete 9-symbol surface, CRT, architecture, and upstream runtime validation passed |
| `libintl` | Disabled | Static library | Exact PHP SDK manifest: 25 core plus 78 Gnulib C sources and generated native Windows COFF resource | `out/libintl.lib` | GNU message catalogs and locale handling for PHP and dependent libraries | Build, 79/79 SDK DLL export coverage, x64 `/MD`, COFF resource, and upstream catalog runtime validation passed |
| `libxml2` | Disabled | Static library | 43 native Windows library sources selected from `in/deps/libxml2/*.c` | `out/libxml2.lib` | XML, HTML, XPath, schema, catalog, and network parsing for PHP and dependent libraries | Build, SDK symbol surface, CRT, architecture, static linkage, and upstream parser smoke validation passed |
| `libxslt` | Disabled | Static library | `in/deps/libxslt/libxslt/*.c`, `in/deps/libxslt/libexslt/*.c` | `out/libxslt.lib` | XSLT and EXSLT transformation support for PHP | Build, complete SDK/DLL symbol surface, CRT, architecture, static linkage, and upstream XSLT/EXSLT runtime validation passed |
| `oniguruma` | Disabled | Static library | 50 native Windows sources selected from `in/deps/libonig/src/*.c` | `out/oniguruma.lib` | Multibyte regular expressions for PHP mbstring | Build, complete SDK/DLL symbol surface, CRT, architecture, static linkage, and 1,529-case upstream UTF-8 validation passed |
| `sqlite3` | Disabled | Static library | Official SQLite 3.53.2 amalgamation `in/deps/sqlite3/sqlite3.c` | `out/sqlite3.lib` | SQLite core with FTS3/FTS4/FTS5 and column metadata for PHP sqlite3/PDO SQLite | Build, 295/295 SDK DLL API coverage, x64 `/MD`, static linkage, FTS3/4/5, and column-metadata runtime validation passed |
| `libpq` | Disabled | Static library | PostgreSQL 16.14 libpq plus the required frontend `src/common` and `src/port` support closure | `out/libpq.lib` | PostgreSQL client library for PHP pgsql/PDO_PGSQL | Build, 187/187 reference DLL API coverage, x64 `/MD`, and static-interface validation passed |
| `libsasl` | Disabled | Static library | Cyrus SASL 2.1.28 Windows core sources only | `out/libsasl.lib` | SASL client support required by OpenLDAP/PHP LDAP | Build, 72/72 SDK DLL export coverage, x64 `/MD`, static decoration, and runtime version validation passed |
| `openldap` | Disabled | Static library | OpenLDAP 2.6.13 client `libldap` + `liblber` with embedded rxspencer 3.9.0 | `out/openldap.lib` | LDAP client library for PHP ext/ldap | Build, 695/695 SDK Windows LDAP/LBER API coverage, x64 `/MD`, static decoration, and LBER runtime validation passed |
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
- Upstream `lib/CMakeLists.txt` and `lib/Makefile.am` agree on 31 direct `lib/nghttp3_*.c` sources plus `lib/sfparse/sfparse.c`. The root CMake configuration requires C11, and internal min/max macros use C11 `_Generic`; select `c11` at target scope so MSVC receives `/std:c11`. Compile the 32 inputs independently without unity.
- Define `BUILDING_NGHTTP3` privately and propagate `NGHTTP3_STATICLIB`, which suppresses DLL decoration in the public header. The library has no external link dependency.
- The generated CMake configuration only supplies Unix feature probes and a fallback `ssize_t` typedef. The selected Windows implementation does not use `ssize_t`, and its endian conversion takes the explicit `_byteswap_*` path, so the target does not need `HAVE_CONFIG_H` or a generated `config.h`.
- Generate `lib/includes/nghttp3/version.h` from its committed `.in` template in the target's only callback, substituting version `1.18.0` and hexadecimal version `0x011200`. No other generated input or callback is required.

### nghttp3 code-generation inventory

| Owner | Tool | Input | Output | Handling | Status |
| --- | --- | --- | --- | --- | --- |
| `nghttp3` | Xmake Lua I/O | `lib/includes/nghttp3/version.h.in` | `lib/includes/nghttp3/version.h` | Replace `@PACKAGE_VERSION@` with `1.18.0` and `@PACKAGE_VERSION_NUM@` with `0x011200` in the target's only `on_prepare` callback | Build validated |

### ngtcp2 upstream build analysis

- Use the already prepared official `ngtcp2/ngtcp2` repository pinned to `v1.25.0`. Its git submodules belong only to tests and non-library third-party code, so the two selected libraries require no recursive source fetch.
- Upstream CMake and Automake agree that the core library contains all 46 direct C children of `lib`. They also define the OpenSSL 3.5 QUIC adapter as a distinct two-source library containing `crypto/ossl/ossl.c` and `crypto/shared.c` and linking the core plus OpenSSL SSL/crypto.
- Preserve the two upstream archives because PHP's Windows configuration explicitly checks and links both `ngtcp2.lib` and `ngtcp2_crypto_ossl.lib`. This concrete consumer ABI/output requirement is the exception to the usual one-target-per-dependency preference.
- Both libraries require C11. Define `BUILDING_NGTCP2` privately and propagate `NGTCP2_STATICLIB` so all public core and crypto declarations suppress DLL decoration. The Windows paths infer `WIN32` from `_WIN32`; the selected sources do not use the configuration header's `ssize_t` fallback or Unix probes, so neither target needs `HAVE_CONFIG_H` or a generated `config.h`.
- The OpenSSL adapter publishes `crypto/includes`, depends on the core and the validated OpenSSL target, and carries the Windows system-library closure used by configured OpenSSL plus PHP's required `bcrypt` edge. Compile every source independently without unity.
- Generate `lib/includes/ngtcp2/version.h` from its committed `.in` template in the core target's only callback, substituting version `1.25.0` and hexadecimal version `0x011900`. No other library input requires generation.

### ngtcp2 code-generation inventory

| Owner | Tool | Input | Output | Handling | Status |
| --- | --- | --- | --- | --- | --- |
| `ngtcp2` | Xmake Lua I/O | `lib/includes/ngtcp2/version.h.in` | `lib/includes/ngtcp2/version.h` | Replace `@PACKAGE_VERSION@` with `1.25.0` and `@PACKAGE_VERSION_NUM@` with `0x011900` in the target's only `on_prepare` callback | Build validated |

### ICU upstream build analysis

- Replace the PHP SDK binary package with the official `unicode-org/icu` repository pinned to tag `release-77-1`, matching the selected ICU 77.1 package version. Fetch the complete release source into `in/deps/ICU`.
- The repository intentionally omits the packaged `icudt77l.dat`. ICU's own guidance for custom build systems recommends using the prebuilt data file rather than rebuilding all data tools, so fetch `icudt77l.dat` from the official `icu4c-77_1-data-bin-l.zip` release asset.
- The official Win64 archive does not contain a reusable data object. Its 1,686-byte `icudt.lib` is only the import library for `icudt77.dll` and defines `__imp_icudt77_dat`, while neither that archive nor the data archive contains `icudt77l_dat.obj`. A generator remains necessary to embed the data in a truly static archive.
- Use the release's official Win64 `genccode.exe` strictly as a build-time generator, retaining it and its four required ICU runtime DLLs under `in/tools/icu`. Invoke it from the ICU target callback with object output, skipped DLL export, and entry point `icudt77` to turn the little-endian package into a 16-byte-aligned COFF object. Do not pass `--cpu-arch`: the upstream MSVC path intentionally writes a machine-neutral data-only object that `link.exe` accepts for any target architecture; that option exists for ClangCL. Xmake's built-in object merge rule accepts the generated `.obj` directly into the static archive.
- The official `common.vcxproj` selects all 201 direct C++ children of `source/common`, and `i18n.vcxproj` selects all 254 direct C++ children of `source/i18n`. The two broad non-recursive patterns reproduce those manifests exactly and exclude tools, tests, samples, and extra libraries. Compile all 455 sources independently without unity.
- Keep common, i18n, and packaged data in one `icu` archive because they are components of one dependency and no source needs incompatible duplicate compilation. PHP's original configure script probes three upstream filenames, but the final Xmake PHP target links target dependencies directly and does not require that component split.
- Match the upstream Windows release configuration with C++17, disabled C++ exceptions, `/utf-8`, `/MD`, `WIN32`, `WIN64`, `WINVER=0x0601`, `_WIN32_WINNT=0x0601`, `_CRT_SECURE_NO_DEPRECATE`, `_HAS_EXCEPTIONS=0`, `NDEBUG`, and `U_ATTRIBUTE_DEPRECATED=`. Apply `U_COMMON_IMPLEMENTATION` and `U_PLATFORM_USES_ONLY_WIN32_API=1` only to common sources and `U_I18N_IMPLEMENTATION` only to i18n sources.
- Propagate `U_STATIC_IMPLEMENTATION`, which removes DLL import decoration from every public ICU component API for static consumers. Keep all implementation and Windows configuration definitions private. Publish the common and i18n include roots and the common library's `advapi32` system dependency.
- Validate the combined archive against the union of `icuuc77.dll`, `icuin77.dll`, and the data entry from `icudt77.dll` under `dll_compare`; also inspect member architecture, `/MD`, import thunks, and embedded export directives.

### ICU code-generation inventory

| Owner | Tool | Input | Output | Handling | Status |
| --- | --- | --- | --- | --- | --- |
| `icu` | Official ICU 77.1 Win64 `genccode.exe` | `source/data/in/icudt77l.dat` | `source/data/in/icudt77l_dat.obj` | Generate a machine-neutral, 16-byte-aligned COFF data object with entry point `icudt77` and no DLL export directive in the target's only `on_prepare` callback; merge it directly into `icu.lib` | Build validated |

### libiconv upstream build analysis

- Replace the PHP SDK binary package with the authoritative GNU libiconv 1.19 release tarball from `ftp.gnu.org`, matching the selected package version. Strip its single top-level directory into `in/deps/libiconv`; do not substitute an unofficial GitHub mirror merely to use a Git transport.
- Upstream `lib/Makefile.in` defines the libiconv library from `lib/iconv.c`, `libcharset/lib/localcharset.c`, and `lib/compat.c`. Its Windows resource is packaging metadata, and `woe32dll/iconv-exports.c` is shared-library-only. `libcharset/lib/relocatable-stub.c` belongs to the separate libcharset archive and is not part of libiconv's combined manifest. The previous PHP SDK `libiconv_a.lib` independently confirms the same three-object static layout.
- Generate `include/iconv.h` from `iconv.h.build.in` with no visibility attribute, DLL-variable decoration, or const input pointer, with MSVC's existing `EILSEQ`, usable `mbstate_t`, and standalone `wchar.h`. Generate `libcharset/include/localcharset.h` with visibility disabled. Neither static consumers nor the library require a propagated definition: without `DLL_EXPORT`, the upstream headers leave all declarations undecorated.
- Generate a minimal `lib/config.h` for the selected sources: default extra encodings disabled, no Unix `langinfo` API, working MSVC `mbrtowc`, `mbsinit`, and `wcrtomb`, an empty `ICONV_CONST`, and little-endian byte order. Define `BUILDING_LIBICONV` and `BUILDING_LIBCHARSET` privately as upstream does. The generated gperf tables trigger MSVC C4311 for deliberate null-base member-offset casts, and `qsort(void *)` triggers C4090 while reordering an array of pointers to const strings; these warnings do not change the selected source or configuration and are accepted under the baseline warning policy.
- Compile the three sources independently without unity. The Windows implementation uses only CRT and Kernel32 APIs, so no explicit system-library edge is required. Validate all nine exports of the reference PHP SDK `libiconv.dll`, the three x64 `/MD` archive members, static decoration, and representative conversions.

### libiconv code-generation inventory

| Owner | Tool | Input | Output | Handling | Status |
| --- | --- | --- | --- | --- | --- |
| `libiconv` | Xmake Lua I/O | `include/iconv.h.build.in`, `libcharset/include/localcharset.h.build.in`, MSVC/platform configuration | `include/iconv.h`, `libcharset/include/localcharset.h`, `lib/config.h` | Substitute the upstream header templates and write the selected configuration macros in the target's only `on_prepare` callback | Build validated |

### libintl source identity

- GNU Gettext 1.0 is the authoritative release corresponding to the current PHP SDK `libintl-1.0` package. Fetch the official `gettext-1.0.tar.gz` release from `ftp.gnu.org` and strip its single top-level directory into `in/deps/libintl`.
- The package SBOM identifies `winlibs/gettext` tag `libintl-1.0`, commit `cd6fcaeffc493305f9c0081310efa0e063060da6`, as its build input and GNU Savannah tag `v1.0` as upstream. A complete file-level comparison shows that the fork tag and official release tarball contain identical source trees; only the hx provenance marker differs. Use the official release rather than the packaging fork.
- The PHP package was produced by the public `winlibs/winlib-builder` Cygwin workflow. It configured `gettext-runtime` for x64 MSVC with both static and shared libraries, `/MD /O2`, `_WIN32_WINNT=0x0601`, and then built and installed only the `intl` subdirectory. Treat the official `gettext-runtime/intl/Makefile.am`, generated configuration, and that Windows workflow as the source/build authorities for the direct Xmake conversion.

### libintl upstream build analysis

- `gettext-runtime/intl/Makefile.am` defines 25 core C sources. The release already contains generated `plural.c` and `plural.h`, so no Bison or other source generator is required. `intl-exports.c` is shared-library support and `os2compat.c` is OS/2-only.
- The PHP SDK reference `libintl_a.lib` contains exactly 25 core objects, 78 Gnulib support objects, and one Windows resource object. Its actual static compile command uses `/MD /O2` and `_WIN32_WINNT=0x0601` without `DLL_EXPORT` or `PIC`; shared-library probe commands in the same PDB are not part of the static archive configuration. The official SDK package at `libintl-1.0-vs18-x64.zip` is a validation reference only and must never become a build dependency.
- Match the SDK Gnulib manifest rather than compiling every implementation in `gnulib-lib`: use the broad direct-root pattern plus the complete `glthread`, `unicase`, `unictype`, and `uniwidth` component patterns, then remove the 22 direct-root alternatives absent from the reference archive. In particular, the reference includes `getcwd-lgpl`, `getlocalename_l-unsafe`, `tsearch`, and all four native `windows-*` lock implementations, while it excludes `frexp`, `frexpl`, the unused `isw*` replacements, and the other mutually exclusive substitutes.
- Generate `config.h`, static `libgnuintl.h`/`libintl.h`, the required `alloca.h`, `float.h`, `search.h`, `string.h`, `unistd.h`, `locale.h`, `stdckdint.h`, `sched.h`, `pthread.h`, `wchar.h`, and `uchar.h` Gnulib wrappers, and the small libunistring-compatible generated headers in the target's single callback. On MSVC, generate wrappers around the actual UCRT headers selected from the configured SDK path/version. Treat unspecified Gnulib template placeholders as zero and spell out only the nonzero/syntactic substitutions; this is equivalent to the previously expanded configure result and removes a large amount of redundant substitution code. `locale.h` provides Gnulib's POSIX `locale_t` model over native `_locale_t`; `wchar.h` redirects the native inline `mbsinit` and the selected `mbrtowc` replacement before the Gnulib implementation is compiled; `uchar.h` redirects the native `mbrtoc32`, whose Windows sanity check fails upstream. The `stringeq` module is header-defined on this target: generate Gnulib's `string.h` around the configured UCRT header with `GNULIB_STRINGEQ=1` and `HAVE_DECL_STREQ=0`, so `streq` remains inline and does not become an unresolved or exported archive symbol. The reference-selected `pthread-once.c` does not imply a pthread runtime dependency: on native Windows, generate Gnulib's `sched.h` compatibility header and `pthread.h` shim with only the once module enabled so `pthread_once_t` is backed by `windows-once.h`; select the replacement spelling `rpl_pthread_once`, matching the SDK symbol surface. Generate `float.h` around the selected UCRT header so Gnulib supplies the three signaling-NaN objects exported by the SDK. Hide the replacement tree-search implementation under `_libintl_tsearch`, `_libintl_tfind`, `_libintl_tdelete`, and `_libintl_twalk` as required by `configure.ac`, rather than leaking generic `t*` names from the static archive. Map `rpl_mbsinit` and `rpl_mbrtowc` to libintl's private `_libintl_*` names exactly as `configure.ac` does. The current MSVC C mode obtains `bool` from `<stdbool.h>` rather than as a native C keyword, so leave `HAVE_C_BOOL` undefined while setting `HAVE_STDBOOL_H=1`; removing `HAVE_STDBOOL_H` was explicitly tested and fails immediately in Gnulib's `config.h`. Do not run Autoconf, sed, or a Unix shell, and keep generated static headers free of DLL decoration.
- Define the upstream Windows library mode directly, use the validated `libiconv` target, and link `advapi32`, which is the only extra Windows library selected by the upstream `intl` build. The direct MSVC configuration does not need explicit `HAVE_LONG_LONG_INT`, `HAVE_UNSIGNED_LONG_LONG_INT`, `HAVE_MBSTATE_T`, `HAVE_C_STATIC_ASSERT`, `HAVE_MBSINIT`, `HAVE_WCHAR_H`, `PACKAGE`, `PACKAGE_NAME`, `PACKAGE_VERSION`, or `VERSION` substitutions; all ten were removed and the full build/runtime/symbol validation still passes. Do not invoke Cygwin, `configure`, Make, NMake, MSBuild, a solution, or a project file.
- The complete exact-manifest source build now succeeds with Xmake driving MSVC directly: all 25 core and 78 Gnulib C sources compile with `/MD /O2`, including the native Windows threading and locale replacements, and `out/libintl.lib` is archived successfully without MinGW, Cygwin, Autoconf, sed, or other Unix build tooling.
- Archive validation covers all 79 exports from the SDK `libintl.dll`; all 103 compiled C members are x64 and request `MSVCRT`, with no `LIBCMT` or embedded `/EXPORT:` directives. The five remaining non-export static-reference name deltas (`_snprintf`, `_snwprintf`, `_vsnprintf`, `_vsnwprintf_l`, and `frexpl`) are UCRT/header fallback definitions emitted inside the SDK's `vasnprintf`/`vasnwprintf` objects, not missing libintl API symbols.
- Match the SDK's final Windows resource member without `windres`: in the target callback, substitute version string `1.0` and numeric version `1,0,0,0` into committed `libintl.rc`, compile it to a native `.res` with the configured Windows SDK `rc.exe`, then convert that resource to a real x64 COFF object with the configured MSVC `cvtres.exe`. Add the generated `out/libintl.res.obj` directly to the static archive. Xmake's direct `.rc` rule is not sufficient for this static-library case because `rc.exe` emits resource-file format even when the output is named `.obj`; the SDK reference instead contains a true x64 COFF resource object. The Microsoft conversion produces `.rsrc$01` plus `.rsrc$02` with a combined `0x5e0` bytes, matching the SDK resource payload size, while remaining a valid x64 COFF input.
- Upstream `gettext-runtime/install-tests/test-api.c` linked directly against the Xmake-built `libintl` and `libiconv` archives and consumed the committed `en_US/LC_MESSAGES/itest.mo` catalog. It exited 0 without the test's explicit skip message, proving actual catalog lookup and UTF-8 translation. The executable imports only Advapi32, Kernel32, VCRuntime, and UCRT API-set DLLs; it has no `libintl.dll`, `libiconv.dll`, MinGW, Cygwin, or other third-party runtime DLL dependency.
- The validated target was subsequently reduced from 130 to 93 lines. The two near-identical wrapper-header helpers were unified, repeated configuration/header declarations were compacted, and four exact-match wildcard exclusions (`frexp*.c`, `isw*.c`, `signbit*.c`, `wmem*.c`) replace equivalent enumerations. All 19 generated configuration/public wrapper headers remain byte-for-byte identical, the final archive still covers 79/79 SDK DLL exports with 104 members (103 C `/MD` members plus the resource), and the upstream catalog runtime test still exits 0 with the same system-only PE dependency set.

### libintl code-generation inventory

| Owner | Tool | Input | Output | Handling | Status |
| --- | --- | --- | --- | --- | --- |
| `libintl` | Xmake Lua I/O | `config.h.in`, `libgnuintl.in.h`, Gnulib `*.in.h` configuration templates | `config.h`, static `libgnuintl.h`/`libintl.h`, and required Gnulib compatibility headers | Fixed native-Windows/MSVC substitutions in the target's only `on_prepare` callback; no Autoconf, sed, shell, or generated C implementation source | Build and runtime validated |
| `libintl` | Windows SDK `rc.exe` + MSVC `cvtres.exe` | committed `libintl.rc` | `out/libintl.res.obj` | Substitute Gettext 1.0 version fields, compile to `.res`, convert to x64 read-only COFF, then merge the generated object directly into `libintl.lib` | Build and COFF-format validation passed |

### libxml2 upstream build analysis

- The PHP SDK 2.11.9-7 SBOM identifies GNOME libxml2 2.11.9 as upstream and the exact package source as `winlibs/libxml2` tag `libxml2-2.11.9-7`, commit `f06d784607050c08a9b28b1fce2faa4236c052cf`. Use that pinned PHP-maintained source rather than the vanilla GNOME tarball: it retains the 2.11.9 ABI while backporting the security fixes declared by the SDK, including CVE-2026-0989 and its `xmlRelaxParserSetIncLImit` API.
- Upstream `win32/Makefile.msvc` and the preserved PHP SDK `libxml2_a.lib` agree on exactly 43 root C sources. Select them with one broad `*.c` declaration and remove the 17 root programs, tests, optional Trio implementations, and disabled compression wrapper through `run*.c`, `test*.c`, `trio*.c`, `xmlcatalog.c`, `xmllint.c`, and `xzlib.c`. The native Makefile adds `xzlib.c` only for the optional compression configuration; the reference package enables neither zlib nor LZMA.
- Match the reference feature surface: native Windows threads using the Windows TLS API; XML tree/output/push/reader/pattern/writer/SAX1/FTP/HTTP/validation/HTML/legacy/C14N/catalog/XPath/XPointer/XInclude/debug/Unicode/regexp/automata/schema/Schematron/module support; and libiconv conversion. Keep compiler TLS, XPointer locations, ICU, ISO-8859 fallback, memory debugging, zlib, LZMA, thread-local allocation hooks, and Trio disabled.
- The Windows configuration step performs no implementation-source generation. It copies committed `include/win32config.h` to `config.h` and substitutes the committed public `include/libxml/xmlversion.h.in`; reproduce those two actions in the target's only `on_prepare` callback. Do not execute `configure.js`, CMake, NMake, MSBuild, a solution, or a project file.
- Compile every source independently without unity using `/MD /O2`. Define the static public interface with propagated `LIBXML_STATIC`; keep `LIBXML_STATIC_FOR_DLL`, `_REENTRANT`, `_WINDOWS`, `_MBCS`, `NOLIBTOOL`, and the implementation warning-compatibility macros private. Do not define `HAVE_COMPILER_TLS`: the PHP DLL calls the `xmlDllMain` supplied by libxml2's Windows TLS implementation, and PHP's native configuration explicitly selects `LIBXML_STATIC_FOR_DLL`. This matches the SDK's special static archive intended for inclusion in a DLL.
- Depend on the direct `libiconv` target and propagate the native Windows networking link edge. The reference archive contains 43 x64 `/MD` objects, standard undecorated libxml APIs, and direct `libiconv*` references; use its DLL export surface and a parser smoke test for final validation.

### libxml2 code-generation inventory

| Owner | Tool | Input | Output | Handling | Status |
| --- | --- | --- | --- | --- | --- |
| `libxml2` | Xmake Lua I/O | `include/win32config.h`, `include/libxml/xmlversion.h.in`, pinned Windows feature selection | `config.h`, `include/libxml/xmlversion.h` | Copy the committed Windows configuration and substitute version/feature placeholders in the target's only `on_prepare` callback | Build and runtime validation passed |

### libxslt upstream build analysis

- The PHP SDK 1.1.43-2 SBOM identifies GNOME libxslt 1.1.43 as upstream and the exact package source as `winlibs/libxslt` tag `libxslt-1.1.43-2`, commit `9f399f8d223ddddeaeacd15285a2e993ec326c0f`. Prepare that pinned PHP-maintained source so the direct build retains the 1.1.43 ABI and the SDK's CVE-2025-10911, CVE-2025-11731, and CVE-2025-7424 backports.
- Upstream `win32/Makefile.msvc`, Automake, CMake, and the preserved SDK archives agree on exactly 19 `libxslt/*.c` and 10 `libexslt/*.c` sources. Both directories contain only library C inputs, so select them with two broad declarations and no exclusions. Do not compile `xsltproc`, tests, examples, Python bindings, or documentation tools.
- The preserved SDK package splits those sources into `libxslt_a.lib` and `libexslt_a.lib`, but this project combines both native components in one `libxslt` target. Their defined-symbol sets overlap only on five link-once compiler constants and contain no duplicate API or implementation symbol, so separate targets would add structure without solving a technical constraint.
- Match the SDK public configuration: libxslt 1.1.43, libexslt 0.8.24, XSLT diagnostics, external debugger hooks, profiler, and `.dll` extension modules enabled; Trio and EXSLT crypto disabled. Crypto remains compiled as its upstream disabled stub, so the target needs neither CryptoAPI nor libgcrypt. Module loading uses the Windows loader API and propagates `kernel32`.
- Generate `libxslt/xsltconfig.h` and `libexslt/exsltconfig.h` directly from their committed templates in the target's only callback. The selected Windows sources include committed `libxslt/win32config.h` directly, so no `config.h`, implementation code generation, or configure execution is required. Do not invoke `configure.js`, CMake, NMake, MSBuild, a solution, or a project file.
- Compile all 29 sources independently without unity using `/MD /O2`. Propagate `LIBXSLT_STATIC` and `LIBEXSLT_STATIC`, which are required by the public headers to suppress `dllimport`; `LIBXML_STATIC` arrives from the direct libxml2 dependency. Keep `_WINDOWS`, `_MBCS`, `_REENTRANT`, `NDEBUG`, and the native implementation warning-compatibility definitions private.
- The SDK references contain 19 plus 10 x64 objects, all selecting `MSVCRT` and none selecting `LIBCMT` or emitting export directives. Their union defines 334 unique symbols. The SDK DLLs export 252 libxslt and 17 libexslt APIs; the copies in `dll_compare` are a strict subset, differing only by the SDK source's additional `xsltReleaseRVTList`, so final validation must cover both and use the exact SDK 1.1.43-2 package as the authoritative surface.

### libxslt code-generation inventory

| Owner | Tool | Input | Output | Handling | Status |
| --- | --- | --- | --- | --- | --- |
| `libxslt` | Xmake Lua I/O | `libxslt/xsltconfig.h.in`, `libexslt/exsltconfig.h.in`, pinned SDK feature selection | `libxslt/xsltconfig.h`, `libexslt/exsltconfig.h` | Substitute version and feature placeholders in the target's only `on_prepare` callback | Build and runtime validation passed |

### Oniguruma upstream build analysis

- Use the official `kkos/oniguruma` GitHub repository pinned to tag `v6.9.10`, matching the PHP SDK package. The package SBOM names that tag as upstream and declares no Winlibs security backport or downstream fix, so prefer the authoritative upstream source over the packaging fork.
- Upstream `CMakeLists.txt`, `src/Makefile.windows`, and the preserved SDK `onig_a.lib` agree on 48 core and encoding C sources plus `regposix.c` and `regposerr.c`. Select those 50 inputs with one broad `src/*.c` declaration and remove `koi8.c`, the `mktable.c` generator, and the five committed `unicode_*_data.c` fragments that `unicode.c` includes directly. No generated implementation source, assembly, or external library is required.
- Enable both `USE_POSIX_API` and `USE_BINARY_COMPATIBLE_POSIX_API`, matching the native Windows Makefile and SDK archive rather than CMake's platform-neutral defaults. Copy the committed `src/config.h.win64` to `src/config.h` in the target's only callback and define `HAVE_CONFIG_H`; the header already records the correct MSVC x64 type sizes and platform facilities, so do not run CMake, configure, NMake, MSBuild, a solution, or a project file.
- Propagate `ONIG_STATIC`, the standard upstream static-consumer interface that makes `ONIG_EXTERN` plain `extern` in both public headers. PHP's native `/DONIG_EXTERN=extern` serves the same import-suppression purpose, so the eventual PHP target receives the cleaner upstream definition through its dependency. Keep the POSIX and configuration definitions private; `PHP_ONIG_BAD_KOI8_ENTRY=1` belongs only to PHP mbstring because the selected library intentionally exposes `KOI8-R` but not the obsolete `KOI8` entry.
- Compile the 50 sources independently without unity and use the project-wide `/MD`. The preserved SDK archive confirms the exact member list and exposes all 211 APIs of both the SDK and `dll_compare` DLLs, but it selects `LIBCMT` and embeds `/EXPORT` directives. Treat it only as the ABI reference: the direct archive must instead select `MSVCRT`, contain no `LIBCMT`, export directive, or `__imp_onig*` thunk, and cover the same 211 APIs.

### Oniguruma code-generation inventory

| Owner | Tool | Input | Output | Handling | Status |
| --- | --- | --- | --- | --- | --- |
| `oniguruma` | Xmake file copy | `src/config.h.win64` | `src/config.h` | Copy the committed x64 MSVC configuration in the target's only `on_prepare` callback | Build and runtime validation passed |

### SQLite upstream build analysis

- Use SQLite 3.53.2, matching the current PHP SDK package. The SDK SBOM identifies upstream `sqlite/sqlite` tag `version-3.53.2`; for this dependency, use SQLite's official pre-generated `sqlite-amalgamation-3530200.zip` rather than cloning the canonical source tree or generating the amalgamation locally.
- The official amalgamation already contains the SQLite core plus optional FTS3/FTS4 and FTS5 implementation behind compile-time switches. Compile the single distribution input `sqlite3.c`; publish the adjacent `sqlite3.h` and `sqlite3ext.h`. No Tcl, Lemon, configure script, Makefile, CMake, NMake, MSBuild, or target callback is required.
- Match the PHP SDK feature surface required by PHP: define `SQLITE_ENABLE_COLUMN_METADATA`, `SQLITE_ENABLE_FTS3`, `SQLITE_ENABLE_FTS4`, and `SQLITE_ENABLE_FTS5`. The preserved SDK executable reports all four through `PRAGMA compile_options`; FTS3 and FTS4 share implementation support, while FTS5 is separately enabled.
- Keep SQLite's normal serialized/thread-safe Windows defaults and system allocator defaults; do not redundantly spell default compile options merely because they appear in `PRAGMA compile_options`. The project-wide `/MD` runtime overrides only the CRT linkage policy and does not change SQLite's thread-safety mode.
- The preserved PHP SDK static reference is itself a one-member `libsqlite3_a.lib` containing only `sqlite3.obj`, confirming that the one-source amalgamation layout matches the intended Windows package shape. The direct archive covers all 295 SDK DLL APIs, its sole object is x64 and requests `MSVCRT` with no `LIBCMT`, SQLite import thunk, or embedded `/EXPORT:` directive, and a static consumer successfully creates and queries FTS3, FTS4, and FTS5 virtual tables while `sqlite3_column_table_name()` verifies column metadata. The test executable imports only Kernel32, VCRuntime, and UCRT API-set DLLs.

### PostgreSQL / libpq upstream build analysis

- Build directly from the authoritative PostgreSQL source, `postgres/postgres` tag `REL_16_14`. The PHP SDK 16.14 SBOM points through `winlibs/postgresql` tag `libpq-16.14`, but the libpq, `src/common`, `src/port`, and `src/include` trees were verified byte-for-byte identical to PostgreSQL `REL_16_14`, so no Winlibs source patch is required. Keep the former SDK package only under `out/libpq-sdk-reference` for comparison.
- The upstream libpq manifest contains 13 unconditional C files, Windows `pthread-win32.c` and `win32.c`, and with the SDK feature selection `fe-secure-common.c` plus `fe-secure-openssl.c`: 17 libpq C translation units total. GSS sources are disabled. The preserved SDK `libpq_a.lib` confirms the same 17 libpq objects plus a resource member.
- Static libpq also needs part of PostgreSQL's frontend `pgcommon`/`pgport` support. Preserve the project rule of one target per external dependency by folding the actual static link closure directly into `libpq`: 13 `src/common` sources and 24 `src/port` sources, for 54 archive members total together with the 17 libpq sources. Do not compile the complete server-oriented common/port manifests or create separate Xmake subtargets.
- Match the SDK Windows configuration: thread safety, LDAP and OpenSSL enabled; GSS, NLS and zlib disabled. Keep `openssl` as a normal Xmake target dependency. The final Windows system-library closure is `ws2_32`, `secur32`, `wldap32`, `shell32`, and `advapi32`; compile PostgreSQL sources as `FRONTEND` with the upstream MSVC Windows compatibility defines.
- Generate only the frontend configuration inputs actually required by this closure: render `pg_config.h` and `pg_config_ext.h` from their committed templates, copy `src/include/port/win32.h` as `pg_config_os.h`, and write `pg_config_paths.h` in the target's single `on_prepare` callback. No Perl generator, `kwlist_d.h`, backend/catalog generation, Visual Studio build, or Meson build is required.
- Do not add the Windows version resource to the direct static target. PostgreSQL's authoritative Meson declaration adds it only to the shared library; the resource member in the SDK's packaging-specific `libpq_a.lib` is metadata rather than a required static interface input.
- The final `out/libpq.lib` built successfully from official PostgreSQL `REL_16_14`. It contains all 187/187 reference DLL exports with zero missing names and 400 public linker-member symbols total. Archive-level inspection reports 54 x64 members, 54 `MSVCRT` directives, zero `LIBCMT`, zero embedded `/EXPORT:` directives, and zero libpq-family import thunks. Extra internal/support symbols in the static archive are expected and are not a validation failure.
- The validated target was subsequently reduced from 129 to 53 lines without changing its source closure or configuration. The compact callback emits `pg_config.h`, `pg_config_ext.h`, `pg_config_os.h`, and `pg_config_paths.h` byte-for-byte identically to the prior validated target; the rebuilt archive remains 187/187 with the same 400-symbol surface and 54-member x64 `/MD` layout.

### OpenLDAP / Cyrus SASL upstream build analysis

- PHP `ext/ldap` is opt-in and requires the OpenLDAP client headers, OpenSSL, the LDAP/LBER static interfaces, and Cyrus SASL. Build only the client stack; do not build slapd or server backends.
- Use authoritative OpenLDAP 2.6.13 and Cyrus SASL 2.1.28 sources. The PHP SDK OpenLDAP packaging fork leaves the `libldap` and `liblber` implementation sources unchanged; reproduce only its three relevant MSVC portability fixes: undefine Winsock-conflicting errno names before remapping, avoid redefining `timespec` on modern MSVC, and map `strcasecmp`/`strncasecmp` to MSVC spellings.
- OpenLDAP's selected client closure depends on Cyrus SASL, OpenSSL, and rxspencer, not LMDB or SQLite. LMDB remains excluded because it belongs to server/sasldb paths.
- Build Cyrus SASL as its Windows core only: the 13 `lib/*.c` inputs declared by upstream `win32/sasl2.vcxproj` plus `common/plugin_common.c` from `lib/NTMakefile`. Define `NO_STATIC_PLUGINS`; do not compile `sasldb` or any database backend. Its Windows core needs `ws2_32` plus `advapi32` for the Registry and `GetUserNameW`.
- The upstream Windows public `prop.h` assumes DLL linkage whenever `WIN32` is defined, and `saslutil.c` hard-codes `dllexport` on its getopt globals. For this real static archive, generate a static-consumer header copy guarded by `LIBSASL_STATIC` and an otherwise identical `saslutil.c` with those four variable decorations removed. Propagate `LIBSASL_STATIC`; do not modify or depend on the SDK headers.
- Use authoritative `garyhouston/rxspencer` 3.9.0 as embedded regex support. Its CMake library contains exactly `regcomp.c`, `regerror.c`, `regexec.c`, and `regfree.c`, matching the four rxspencer members in the SDK LBER archive. Fold them into the single `openldap` target.
- Combine the upstream `libldap` object manifest, Windows `liblber` manifest, and rxspencer support in one `openldap` archive. The PHP SDK's `oldap32_a.lib`/`olber32_a.lib` split is packaging structure, not a reason for multiple Xmake targets.
- Generate `portable.h`, `lber_types.h`, `ldap_features.h`, `ldap_config.h`, and the small library `version.c` input in the target's single `on_prepare` callback. Match the SDK client configuration: x64 64-bit BER tag/length types, NT threads, Winsock2/IPv6, OpenSSL TLS, Cyrus SASL, thread safety, and OpenLDAP 2.6.13.
- Final `out/libsasl.lib` covers all 72/72 exports of the preserved SDK `libsasl.dll`, has 14 x64 members selecting `MSVCRT`, zero `LIBCMT`, zero embedded `/EXPORT:` directives, and zero SASL/prop import thunks. A direct static consumer queried `sasl_version_info()` and verified 2.1.28 with exit code 0; its PE imports contain only Windows/VCRuntime/UCRT libraries.
- Final `out/openldap.lib` covers all 695/695 public LDAP/LBER names present in the SDK Windows `oldap32_a.lib` + `olber32_a.lib` references. The authoritative OpenLDAP map-file union contains 704 APIs; the remaining nine are absent from the SDK Windows reference itself. The direct archive has 92 x64 members selecting `MSVCRT`, zero `LIBCMT`, zero embedded `/EXPORT:` directives, and zero LDAP/LBER/SASL-family import thunks. Its extra internal symbols are expected for a combined static archive.
- A direct LBER consumer allocated a DER element, encoded `{is}`, and exited 0 using `openldap.lib` plus only `ws2_32`; its PE imports contain no OpenLDAP, SASL, or OpenSSL DLL. A full libldap call intentionally pulls the archive's TLS/SASL closure and is therefore not used to reopen the already validated OpenSSL target. The two retained `tls2.c` C4133 diagnostics are the pinned Windows fallback passing Winsock's `long tv_sec` to `time(time_t *)`; they are investigated source/configuration warnings, not missing LDAP APIs.

### OpenLDAP / Cyrus SASL code-generation inventory

| Owner | Tool | Input | Output | Handling | Status |
| --- | --- | --- | --- | --- | --- |
| `libsasl` | Xmake Lua I/O | upstream public headers, `win32/include/md5global.h`, `lib/saslutil.c` | `out/libsasl/include/**`, `out/libsasl/saslutil.c` | Copy the public header layout, make `prop.h` honor `LIBSASL_STATIC`, and remove DLL decoration from the four getopt globals in the target's only `on_prepare` callback | Build, symbol, and runtime validated |
| `openldap` | Xmake Lua I/O | `portable.hin`, `lber_types.hin`, `ldap_features.hin`, `ldap_config.hin`, `ac/socket.h`, `ac/time.h`, `build/version.h` | configured headers under `out/openldap/include`, `out/openldap/version.c` | Render the verified Windows client configuration, apply the three required MSVC portability adaptations, and emit the library version source in the target's only `on_prepare` callback | Build, symbol, and runtime validated |

### libpq code-generation inventory

| Owner | Tool | Input | Output | Handling | Status |
| --- | --- | --- | --- | --- | --- |
| `libpq` | Xmake Lua I/O | `src/include/pg_config.h.in`, `pg_config_ext.h.in`, `src/include/port/win32.h` | `out/libpq/include/pg_config.h`, `pg_config_ext.h`, `pg_config_os.h`, `out/libpq/port/pg_config_paths.h` | Render/copy only the verified Windows frontend configuration in the target's single `on_prepare` callback; no external generator is needed | Build validated |

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
