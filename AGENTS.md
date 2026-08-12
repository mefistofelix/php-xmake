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
- Keep `xmake.lua` primarily declarative: it should consist of Xmake configuration, target declarations, and only the target-specific `cb` callbacks that perform real configuration generation or code generation.
- Do not add arbitrary Lua helper functions, tables, aliases, or variables. Introduce Lua state only when an Xmake API requires it and no direct declarative expression is practical; keep such state local to the owning task or target callback.
- A target that needs imperative configuration or code generation must use one target-specific `cb` function as its single imperative entry point. Do not split target preparation across extra Lua functions. A target with no such work must not define or attach an empty callback.
- Give every library dependency its own static-library target.
- Treat preprocessor definitions as part of the dependency's ABI and symbol-surface configuration. Before adding them, inspect the upstream public-header import/export macros and static target. Enable only the standard upstream public interface required by PHP; do not expose shared-library export modes, alternate namespaces, experimental/deprecated APIs, or private interfaces accidentally.
- Propagate with `{public = true}` only definitions that consumers of the static archive must see in public headers, such as `LZMA_API_STATIC`. Keep feature-selection, platform, threading, internal namespace, and implementation-detection definitions private to the owning target. When definitions can affect external linkage, inspect the resulting archive or final DLL symbol surface as part of validation.
- Do not mirror an upstream build's internal component libraries as separate Xmake targets by default. Keep one dependency in one target and include all of its components there. Create sublibrary targets only when a single target is proven impractical by duplicate external symbols, incompatible compile settings, unavoidable build ordering/code-generation edges, or another concrete technical constraint. Unity-group splits do not require target splits.
- PHP extensions are part of the main PHP target; do not create a separate target for each extension.
- Add source files with the broadest safe patterns, ideally at dependency or PHP-tree scope.
- When a directory contains mostly target sources plus a small, clearly identifiable set of programs, tests, or generators, prefer a broad `add_files` followed by Xmake's declarative `remove_files` patterns. Keep an explicit positive source list when exclusions would be longer, fragile, or liable to admit unrelated files.
- Prefer a clean two-layer source declaration when only a subset needs file-specific settings: first call `add_files` once with the broadest pattern and no file config, then repeat only the narrower subset with `unity_ignored`, `unity_group`, callback, or other file config. Xmake deduplicates the matched source paths and applies the narrow config. Do not use exclusion-heavy globs merely to re-add those files. Avoid overlapping declarations when the broad declaration itself already has file config, because competing configs would make override behavior unclear.
- Prefer one unity translation unit containing all of a target's sources. Do not choose arbitrary batch sizes. Split into the fewest and widest explicit unity groups only when observed symbol, macro, header, or compiler conflicts prove that a single translation unit is impossible; isolate only the incompatible files.
- Build the project incrementally, one target at a time, starting with dependencies and ending with the complete PHP target.
- Keep only the current priority target active during focused build/debug cycles. Use `set_enabled(false)` to remove unrelated or unfinished targets completely. Use `set_default(false)` when a target must remain available for an explicit build or as a dependency but should not join the default build. Re-enable a target when it becomes the priority or a dependency of the priority target.

## Code Generation

- Run every required code-generation step from a callback supplied by the `cb` rule.
- For each target that actually needs configuration generation or code generation, use exactly one target-specific callback. Attach it as file configuration to the single most appropriate source entry for that target; that callback owns all generated sources, headers, and configuration files for the target.
- Do not create a separate callback for each generated file.
- If a callback needs an external executable such as Perl, Bison, RE2C, or the Windows message compiler, make that executable available during `xmake prepare`.
- If a callback needs an executable built by this project, such as `minilua` or `gen_ir_fold_hash`, build/invoke its Xmake target programmatically from the callback using Xmake built-ins.
- Generate C configuration headers and their defines/parameters in the owning target callback. Use Xmake detection APIs for platform properties instead of hard-coding them.
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
- Keep generated files, downloaded sources, tool binaries, caches, and build output ignored.
- Treat warnings and accidental undeclared inputs as build issues to investigate rather than silently accepting them.

## Current Target Inventory

| Target | Build state | Kind | Source inputs | Output | Purpose | Status |
| --- | --- | --- | --- | --- | --- | --- |
| `zlib` | Disabled | Static library | `in/deps/zlib/*.c` | `out/zlib.lib` | First compression dependency | Build validated with `/MD` on MSVC x64 |
| `brotli` | Disabled | Static library | `in/deps/brotli/c/common/*.c`, `in/deps/brotli/c/dec/*.c`, `in/deps/brotli/c/enc/*.c` | `out/brotli.lib` | Complete Brotli common, decoder, and encoder implementation | One target; three compilation units; build validated with `/MD` on MSVC x64 |
| `zstd` | Disabled | Static library | `in/deps/zstd/lib/{common,compress,decompress,dictBuilder,legacy}/*.c` | `out/zstd.lib` | Multithreaded zstd library with level-5 legacy decoding | One main unity group; FastCover and legacy sources isolated; build validated with explicit `/MD` on MSVC x64 |
| `bzip2` | Disabled | Static library | `in/deps/bzip2/*.c` minus upstream programs/tests via `remove_files` | `out/bzip2.lib` | bzip2 compression library for the PHP bz2 extension | Exactly seven library sources in one unity translation unit; declarative selection validated with `/MD` on MSVC x64 |
| `liblzma` | Enabled (current priority) | Static library | Upstream-default library sources under `in/deps/xz/src/{common,liblzma}` | `out/liblzma.lib` | XZ/LZMA compression for PHP consumers including zip, GD, and fileinfo | One target; five-unit minimum unity partition under validation |
| `minilua` | Disabled | Binary | `in/php-src/ext/opcache/jit/ir/dynasm/minilua.c` | `out/minilua.exe` | Runs DynASM for the PHP JIT IR emitter | Defined; build validation pending |
| `gen_ir_fold_hash` | Disabled | Binary | `in/php-src/ext/opcache/jit/ir/gen_ir_fold_hash.c` | `out/gen_ir_fold_hash.exe` | Generates the JIT IR fold hash header | Defined; build validation pending |
| `php` | Disabled | Object prototype | `in/php-src/Zend/zend.c`, `in/php-src/Zend/asm/*_xmm_x86_64_ms_masm.asm` | `out/` | Becomes the static PHP build after dependency, configuration, codegen, and source integration | Prototype only; real codegen callback pending |

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
- No build-time code generation is required, so the target has no `cb` callback.
- Keep 29 current sources in the default unity group. Compile `dictBuilder/fastcover.c` separately because it and `cover.c` both include the unguarded internal `cover.h`, which redefines shared structures when merged. Compile each of the seven legacy decoder sources separately: source inspection shows that historical implementations intentionally reuse dozens of private FSE, HUF, and ZSTD function names, making a shared unity translation unit invalid even though they coexist safely as separate objects in one archive.
- Upstream CMake calls the MSVC static archive `zstd_static.lib` only to avoid a shared import-library name collision. This static-only project uses the simpler target-derived name `zstd.lib`.

### bzip2 upstream build analysis

- Upstream version: bzip2 1.0.8, the current stable release. Sourceware is the authoritative upstream and publishes the official release tarball. The available GitHub repository is a mirror, so fetch the Sourceware tarball and strip its single top-level directory with `hx`. Do not retain the redundant prebuilt PHP SDK archive.
- The root `Makefile` and `makefile.msc` agree that the library contains exactly `blocksort.c`, `huffman.c`, `crctable.c`, `randtable.c`, `compress.c`, `decompress.c`, and `bzlib.c`. The root contains only those library sources plus six command-line/test programs, so use one broad `*.c` declaration and remove the five concise patterns `bzip2*.c`, `dlltest.c`, `mk251.c`, `spewG.c`, and `unzcrash.c` with Xmake's native `remove_files` API.
- The upstream MSVC build uses `WIN32`, `_FILE_OFFSET_BITS=64`, `/MD`, and `/Ox`. The project-wide runtime supplies `/MD`. The Xmake-native `set_optimize("fastest")` emits MSVC `/O2`, its portable maximize-speed preset; do not describe it as an exact `/Ox` mapping. No assembly or build-time code generation is required, so the target has no `cb` callback.
- All seven library sources compile successfully in one unity translation unit; no split or isolated source is needed.
- Upstream MSVC calls the archive `libbz2.lib`, while the PHP SDK package calls its static variant `libbz2_a.lib`. Since the final PHP target will depend directly on the Xmake target rather than search by filename, this project keeps the simpler target-derived `bzip2.lib`.

### liblzma upstream build analysis

- Upstream project: XZ Utils from the official `tukaani-project/xz` GitHub repository. Pin tag `v5.8.3`, which matches the previously downloaded PHP SDK package version, and fetch it as source into `in/deps/xz`; do not retain the redundant prebuilt `liblzma` archive.
- The root upstream `CMakeLists.txt` is the authoritative liblzma source declaration. With default options it includes the common API/container implementation, both multithreaded stream coders, LZ/LZMA1/LZMA2, delta, all eight simple BCJ filters, MicroLZMA encoder/decoder, lzip decoder, CRC32, CRC64, internal SHA-256, and Windows CPU-count/physical-memory helpers. Generator/table-generator sources, small CRC variants, command-line tools, and non-MSVC assembly are excluded.
- On Windows x64, upstream selects `MYTHREAD_VISTA`, all five match finders, both encoders and decoders for every supported filter, the three integrity checks, fast unaligned access, MSVC intrinsics with runtime-detected CLMUL CRC, and `HAVE_VISIBILITY=0`. The public static-library interface requires `LZMA_API_STATIC`. Native Windows threading needs no additional link library.
- `LZMA_API_STATIC` is the only propagated definition: it prevents public headers from applying `dllimport` to standard liblzma APIs when a consumer links the static archive. Do not define `DLL_EXPORT`. All `HAVE_*`, match-finder/filter, threading, visibility, and `TUKLIB_SYMBOL_PREFIX=lzma_` definitions are private implementation configuration and must not leak to consumers.
- The CMake path does not generate a configuration header for liblzma. It supplies feature macros directly and uses committed `tuklib_config.h` and public API/version headers, so no code generation and no `cb` callback are required.
- The source directories that contain only default library inputs use broad `*.c` declarations. The check directory is explicit because it also contains mutually exclusive small variants and generator programs; the LZMA directory excludes its table generator. The initial one-unit build proved that many state-machine implementation files reuse translation-unit-scoped `SEQ_*` enumerators, private coder typedefs, and static helper names. Keep one target, derive the minimum compatible unity partition from the observed private-symbol conflict graph, and avoid arbitrary batch sizes.
- Source-level symbol analysis found 39 conflict edges. `alone_decoder.c`, `alone_encoder.c`, `auto_decoder.c`, `block_decoder.c`, and `block_encoder.c` all define `SEQ_CODE`, forming a five-file clique and proving that at least five translation units are required. A five-color partition reaches that lower bound. The first build of that partition eliminated the source-level collisions but revealed that `lz_decoder.h` and `lz_encoder.h` both define the internal `lzma_lz_options` type. Keep `lzma_encoder.c`, which includes the encoder header through `lzma_encoder_private.h`, in the already encoder-compatible fourth exception group. The resulting groups contain 59, 11, 3, 3, and 3 sources; no sixth unit is needed.
- Upstream 5.8.3 now names the MSVC static archive `lzma.lib`, while the PHP SDK package and PHP build probes use `liblzma_a.lib` or `liblzma.lib`. The final PHP target will depend directly on this Xmake target, so the project keeps the logical target-derived `liblzma.lib`.

## PHP Code-generation Inventory

All paths below are relative to `in/php-src` unless prefixed with `out/`. Entries marked "planned" reproduce the known PHP generation commands but are not yet wired into the `php` target callback.

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

The PHP target also assembles `Zend/asm/*_xmm_x86_64_ms_masm.asm` with MSVC-compatible assembly flags. Broader PHP and extension source inclusion, static linking, and unity-build grouping remain to be implemented.
