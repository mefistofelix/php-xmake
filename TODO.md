# Build Roadmap

Last updated: 2026-08-13

## Current State

- [x] Initialize the Git repository and ignore downloaded sources, tools, caches, and outputs.
- [x] Add an idempotent-oriented `prepare` task for sources, binary dependencies, Perl, MSVC, and the Windows SDK.
- [x] Complete one successful `xmake prepare` run with all currently pinned inputs.
- [x] Repeat `xmake prepare` with every current input present and validate idempotence.
- [x] Use native target `on_prepare` callbacks for target-owned code generation.
- [x] Define the `minilua` and `gen_ir_fold_hash` helper targets.
- [x] Record the known PHP code-generation inventory in `AGENTS.md`.
- [x] Disable non-priority targets by default so focused builds only exercise the target under integration.
- [x] Build and archive `out/zlib.lib` successfully with MSVC x64.
- [x] Build and archive the complete single-target `out/brotli.lib` successfully with MSVC x64.
- [ ] Validate the current Xmake configuration and helper targets.
- [x] Remove empty and placeholder callbacks; only targets with real codegen/configuration work may define `on_prepare`.
- [x] Follow upstream Windows PHP and select the dynamic multithreaded MSVC CRT globally with `set_runtimes("MD")` for loadable-extension compatibility.
- [x] Verify a forced zstd build uses `/MD` in every MSVC compile command.
- [ ] Replace the object-only `php` prototype and add its real `on_prepare` callback when PHP codegen is implemented.
- [x] Replace the custom file-configuration `cb` adapter with native target `on_prepare` callbacks. The callback imports the dependency module in its own body and calls `os.vrunv` directly; no Xmake API is injected through callback arguments.
- [x] Use one uniform Perl include/module prefix for every OpenSSL `.in` template in `openssl_test`; all 50 C/header templates accept the superset, so template-content inspection and specialized argument construction are unnecessary.
- [x] Use `**/*x86_64*.pl|crypto/perlasm/**` in `openssl_test`; the declarative exclusion prevents the stdin-driven `x86_64-xlate.pl` helper from hanging an interactive build while retaining the standalone generator matches.
- [x] Consolidate repeated OpenSSL-root and Perl-program expressions in `openssl_test:on_prepare` into two local values; the simplified callback preserves the validated template and perlasm preparation behavior.
- [x] Run the independent `mkbuildinf.pl` invocation directly after `Configure`, before the template loop; it depends only on its arguments and optional `SOURCE_DATE_EPOCH`.
- [x] Replace the OpenSSL template output-extension `if` with the union of the complete `**/*.c.in` and `**/*.h.in` input globs; they select the same 50 templates directly.
- [x] Use the single `**/*.[ch].in` Xmake glob for the true single-character `c`/`h` alternative; it resolves to and regenerates the same 50 template outputs.
- [x] Validate the upstream application generation sequence in `openssl_test`: Configure with apps enabled, generate `apps/progs.c` with `apps/progs.pl -C apps\openssl`, then generate `apps/progs.h` with `-H`. `apps/include/apps.h` is already a committed input and needs no generator.
- [x] Validate `async.runjobs` for the independent OpenSSL template and perlasm generators, with concurrency limited by the build action's `-j` value.
- [x] Complete a clean parallel build of the broad `openssl_test` source-glob experiment with preparation temporarily bypassed, using declarative exclusions for disabled, platform-incompatible, test/example, and textually included implementation sources.
- [x] Promote the compact `openssl_test` declaration to the official `openssl` target and remove the obsolete 109-group unity declaration.
- [x] Preserve the validated compact target unchanged apart from renaming it to `openssl`; do not reanalyze it against the removed verbose implementation.
- [x] Defer new unity-build work until all dependencies and the complete PHP target have validated baseline builds.

## Completed Target: zlib

`zlib` is the first validated dependency target:

- [x] Inspect upstream `CMakeLists.txt` and `win32/Makefile.msc` for exact sources, Windows defines, output naming, configuration, and optional assembly.
- [x] Add one static-library target with the broadest safe source pattern.
- [x] Confirm that shipped Windows configuration needs no zlib codegen and therefore no `on_prepare` callback.
- [x] Use the default maximal unity group for compatible core sources; reapply file config only to `zutil.c`, `gz*.c`, and `inf*.c` to isolate their unguarded internal headers and macro conflicts.
- [x] Build and record the validation result before moving to the next dependency.

## Completed Target: Brotli

Integrate Brotli after analyzing its upstream build structure:

- [x] Inspect upstream CMake/Bazel build files for component libraries, exact sources, generated inputs, defines, include paths, and dependencies.
- [x] Map upstream common, decoder, and encoder components into one `brotli` target; do not create preventive sublibrary targets.
- [x] Add broad patterns for all three component directories; no callback is needed because Brotli has no build-time codegen.
- [x] Put the complete dependency in one unity translation unit for the first full build.
- [x] Keep one `brotli` target and split compilation into the minimum three units required by the observed private-symbol conflict graph.
- [x] Build and record the validation result before moving to zstd.

## Completed Target: zstd

Integrate zstd as one dependency target:

- [x] Inspect upstream CMake, Makefiles, and Visual Studio project for exact library sources, exclusions, Windows defines, generated inputs, assembly/intrinsics, and feature toggles.
- [x] Keep common, compression, decompression, dictionary-builder, and legacy modules in one `zstd` target.
- [x] Add broad source patterns and no `on_prepare` callback because the upstream library has no build-time codegen.
- [x] Keep 29 current sources in one unity group; isolate FastCover because `cover.h` is unguarded, and isolate the seven legacy sources whose inspected private symbols collide across historical versions.
- [x] Build the complete target once and validate its source/unity layout.
- [x] Rebuild with the final `/MD` selection, verify the compiler command, and record the validation result before moving to bzip2.

## Completed Target: bzip2

- [x] Inspect upstream `Makefile`, `makefile.msc`, the official release source, and PHP's `ext/bz2/config.w32` for exact library inputs, Windows flags, output names, tests, and link expectations.
- [x] Remove the redundant prebuilt PHP SDK archive download and use `hx` with the official Sourceware bzip2 1.0.8 release tarball; do not prefer an unofficial GitHub mirror over upstream.
- [x] Add one static target with the exact seven upstream library sources, no callback, and one initial maximal unity group.
- [x] Run `xmake prepare` and verify that the official Sourceware release is materialized directly into `in/deps/bzip2`.
- [x] Repeat `xmake prepare` with every input present to validate the official fetch's idempotence.
- [x] Build all seven sources in one unity translation unit and record the validation result before moving to liblzma.
- [x] Revalidate that broad `add_files("*.c")` plus declarative `remove_files` selects the same seven library sources and still builds one unity unit.

## Completed Target: liblzma

- [x] Confirm that the authoritative `tukaani-project/xz` GitHub repository provides tag `v5.8.3`, matching the version selected by the PHP SDK dependency inventory.
- [x] Replace the prebuilt PHP SDK `liblzma` archive download with the pinned official XZ source repository.
- [x] Run `xmake prepare` and verify that official XZ 5.8.3 sources are materialized in `in/deps/xz`.
- [x] Repeat `xmake prepare` with the XZ input present to validate idempotence.
- [x] Remove the current `in/deps/xz` tree and obsolete prebuilt `in/deps/liblzma` tree, then validate the official XZ fetch again from a clean absence.
- [x] Inspect upstream CMake and Windows configuration for the exact liblzma sources, generated headers, feature defines, threading backend, and link requirements.
- [x] Add one `liblzma` static target with all upstream-default features and one initial maximal unity group.
- [x] Verify that only the standard liblzma public interface is exposed: propagate only `LZMA_API_STATIC`, keep implementation defines private, and inspect the resulting symbol surface.
- [x] Derive a five-unit minimum unity partition from the observed liblzma private-symbol conflict graph; do not use arbitrary batch sizes.
- [x] Build and record the validation result before moving to the next dependency group.

## Completed Target: OpenSSL

- [x] Replace the moving official `openssl-3.5` branch with the pinned official `openssl-3.5.7` LTS release tag.
- [x] Remove `in/deps/openssl` and validate the pinned source fetch from a clean absence.
- [x] Repeat `xmake prepare` with every input present to validate idempotence.
- [x] Inspect upstream Configure/build metadata and Windows notes for the exact crypto/SSL source set, generated files, assembly, public/private defines, providers, and system libraries.
- [x] Implement OpenSSL code generation with `perl Configure` and the required Perl generators only; do not invoke `nmake` from the target's `on_prepare` callback.
- [x] Declare all selected C and generated assembly sources directly in Xmake and let Xmake perform compilation, NASM assembly, and archiving.
- [x] Add one static OpenSSL dependency target; the configured closure contains no source compiled with incompatible duplicate settings.
- [x] Replace the verbose source manifest and 109 unity groups with the validated broad C-selection and declarative-removal patterns from `openssl_test`.
- [x] Compile OpenSSL sources independently; do not enable unity while baseline target integration is in progress.
- [x] Retain the prior clean build and 6,475-symbol validation as the validation of the unchanged promoted target; use `dll_compare` for future reference checks.

## Next Targets: libssh2 and nghttp2 prerequisites

- [x] Verify the official `libssh2/libssh2` tag `libssh2-1.11.1`, matching the previously downloaded PHP SDK package version.
- [x] Replace the prebuilt libssh2 package with the pinned official source and validate `xmake prepare` from a clean absence and on a no-change repeat.
- [x] Inspect libssh2's upstream manifest, hand-written MSVC configuration, OpenSSL backend selection, default-disabled zlib support, public API decoration, and Windows libraries.
- [x] Add and validate one 26-source static libssh2 target using direct per-source compilation without unity.
- [x] Inspect nghttp2 CMake/Automake/MSVC metadata and confirm that the current library manifest is exactly the 26 direct C children of `lib`.
- [x] Add and validate one direct per-source nghttp2 target without unity, including its generated version header.

## Completed Target: libcurl

- [x] Verify the official `curl/curl` tag `curl-8_21_0`, matching the previous PHP SDK dependency version.
- [x] Replace the prebuilt SDK archive with the pinned official source and validate `xmake prepare` from a clean absence and on a no-change repeat.
- [x] Confirm that broad direct/recursive `lib/*.c` patterns minus `dllmain.c` reproduce all 192 sources in upstream `lib/Makefile.inc`.
- [x] Complete the feature defines, include paths, dependency edges, and Windows system-library analysis; enable the complete OpenSSL/compression/SSH/HTTP2 dependency closure for the focused build test.
- [x] Add one static libcurl target using direct per-source Xmake compilation without unity.
- [x] Build and validate `/MD`, the static public interface, archive architecture, and every symbol in upstream `libcurl.def` before moving to the next dependency.

## Completed Target: libsodium

- [x] Verify the exact official `jedisct1/libsodium` tag `1.0.22`, matching the previous PHP SDK dependency version.
- [x] Replace the prebuilt SDK archive with the pinned official source and validate `xmake prepare` from a clean absence and on a no-change repeat.
- [x] Inspect the upstream Visual Studio and autotools manifests for sources, generated files, architecture implementations, defines, includes, and Windows libraries.
- [x] Add one direct per-source static target without unity.
- [x] Build and validate all 141 x64 `/MD` members, the static public interface, and the complete `dll_compare/libsodium.dll` export surface.

## Completed Target: libuv

- [x] Confirm the prepared official `libuv/libuv` tag `v1.52.1` exceeds True Async's minimum supported version.
- [x] Inspect upstream CMake and confirm the Windows library contains exactly 12 common plus 25 Windows C sources.
- [x] Record the private Windows defines, public-header decoration behavior, and nine system-library edges.
- [x] Add one direct per-source static target without unity or a callback.
- [x] Build and validate all 37 x64 `/MD` members and every one of the 318 APIs declared by `uv.h`.

## Completed Target: nghttp3

- [x] Inspect the upstream CMake and Automake source manifests, Windows configuration, public static definition, and version-header generation.
- [x] Fetch the release's exact `sfparse` gitlink with hx `--recursive` and validate clean and repeated preparation.
- [x] Add one 32-source static target with direct per-source compilation and no unity.
- [x] Build and validate architecture, `/MD`, static decoration, and the complete public header API surface.

## Completed Target: ngtcp2

- [x] Inspect the upstream core and OpenSSL-adapter CMake/Automake manifests, C11 requirement, Windows configuration, static interface, generation, and dependency edges.
- [x] Keep the core and OpenSSL adapter as two targets because upstream and PHP require the distinct `ngtcp2.lib` and `ngtcp2_crypto_ossl.lib` outputs.
- [x] Add direct per-source targets for all 46 core sources and the two adapter sources without unity.
- [x] Build the complete core/OpenSSL closure and validate both archives, their public header API surfaces, architecture, `/MD`, and static decoration.

## Completed Target: ICU

- [x] Verify the official `unicode-org/icu` release tag `release-77-1`, matching the previous PHP SDK dependency version.
- [x] Replace the prebuilt SDK package with the pinned official source and validate clean and repeated preparation.
- [x] Fetch the official little-endian data archive and minimal Win64 `genccode` runtime, then validate the expanded preparation from clean absence and on a repeat.
- [x] Inspect the upstream Windows build for exact common, i18n, data, generation, definitions, and dependency edges before declaring the target.
- [x] Add a direct per-source static target without unity, then build and validate it.

## Completed Target: libiconv

- [x] Verify GNU's official libiconv 1.19 release tarball, matching the previous PHP SDK dependency version.
- [x] Replace the prebuilt SDK package with the official release source and validate preparation from clean absence and on an unchanged repeat.
- [x] Inspect the upstream build for exact library sources, generated configuration, Windows definitions, public static interface, and dependencies.
- [x] Add a direct per-source static target without unity, then build and validate it.

## Current Target: libintl

- [x] Identify the authoritative source and version corresponding to the current PHP SDK package.
- [x] Replace the prebuilt package with pinned upstream source and validate clean and repeated preparation.
- [x] Inspect the upstream Windows build for its exact source manifest, generated configuration, static interface, and libiconv dependency.
- [x] Recover the official PHP SDK `libintl_a.lib` reference and derive its exact 25-core + 78-Gnulib + 1-resource object manifest.
- [x] Replace the broad compiler-driven Gnulib experiment with the exact SDK source selection.
- [x] Complete the native MSVC Gnulib wrapper configuration and direct per-source static build without MinGW, Cygwin, Autoconf, Make, sed, or other Unix build tools.
- [x] Validate the 103 C archive members as x64 `/MD`, with no static CRT or embedded export directives, and cover all 79 SDK DLL exports.
- [ ] Add and validate the SDK-matching Windows version resource member with the native Windows resource compiler.
- [ ] Validate runtime catalog lookup and executable DLL dependencies.

## Completed Target: libxml2

- [x] Identify the SDK's exact pinned `winlibs/libxml2` 2.11.9-7 source and its GNOME 2.11.9 base.
- [x] Replace the vanilla upstream tree with the SDK's security-backported source and validate clean and repeated preparation.
- [x] Inspect the upstream native build declarations for the exact source manifest, generated configuration, definitions, and dependency edges.
- [x] Add a direct per-source static target without unity, then build and validate it.

## Completed Target: libxslt

- [x] Identify the SDK's exact pinned `winlibs/libxslt` 1.1.43-2 source and its GNOME 1.1.43 base.
- [x] Replace the prebuilt package with pinned source and validate clean and repeated preparation.
- [x] Inspect the upstream native build declarations for exact sources, configuration, static interface, and dependency edges.
- [x] Add a direct per-source static target without unity, then build and validate it against libxml2.

## Completed Target: Oniguruma

- [x] Identify the official `kkos/oniguruma` v6.9.10 source matching the current PHP SDK package.
- [x] Replace the prebuilt package with pinned source and validate clean and repeated preparation.
- [x] Inspect the upstream native build declarations for exact sources, configuration, static interface, and dependencies.
- [x] Add a direct per-source static target without unity, then build and validate it.

## Next Target: SQLite

- [ ] Identify the authoritative source and exact version corresponding to the current PHP SDK package.
- [ ] Replace the prebuilt package with pinned source and validate clean and repeated preparation.
- [ ] Inspect the upstream native build declarations for exact sources, configuration, static interface, and dependencies.
- [ ] Add a direct per-source static target without unity, then build and validate it.

## Dependency Targets

Every library must receive its own static target. Integrate and validate them one at a time in dependency order.

- [x] Foundation compression: zlib, Brotli, zstd, bzip2, liblzma.
- [x] Cryptography and transport: OpenSSL, libcurl, libssh2, libsodium.
- [x] HTTP/async: libuv, nghttp2, nghttp3, ngtcp2.
- [ ] Data/text: ICU, libiconv, libintl, libxml2, libxslt, Oniguruma, SQLite, LMDB, QDBM.
- [ ] Database/directory clients: PostgreSQL, Firebird, OpenLDAP.
- [ ] Image/font stack: FreeType, libjpeg-turbo, libpng, libtiff, libwebp, libavif, libheif, libjxl, libultrahdr, libxpm.
- [ ] Remaining libraries: Apache support files, GLib, Argon2, Enchant, libffi, SASL, Tidy, libzip, MPIR, Net-SNMP, WinEditLine.
- [ ] Document exact target names, source patterns, dependencies, defines, and validation status as each target lands.

## PHP Code Generation

- [ ] Make Bison and RE2C available through `xmake prepare`.
- [ ] Generate the Zend, PHPDBG, and JSON parsers with Bison.
- [ ] Generate all inventoried scanners with RE2C.
- [ ] Generate Windows message resources with `mc`.
- [ ] Build and invoke `minilua` programmatically for DynASM output.
- [ ] Build and invoke `gen_ir_fold_hash` programmatically with redirected input/output.
- [ ] Generate PHP Windows configuration headers/defines using Xmake detection APIs.
- [ ] Consolidate all PHP generation into the single `php` target `on_prepare` callback.

## PHP Target and Final Link

- [ ] Add broad Zend, main, TSRM, SAPI, extension, and selected external source patterns.
- [ ] Keep PHP extensions inside the PHP target rather than creating extension targets.
- [x] Select the upstream-compatible dynamically linked multithreaded MSVC CRT globally with `set_runtimes("MD")`.
- [ ] Decide and configure PHP ZTS versus NTS independently of the MSVC CRT selection.
- [ ] Complete a direct per-source PHP baseline build; revisit unity only after every target works.
- [ ] Connect all dependency targets in correct link order.
- [ ] Produce the final PHP executable/library artifacts.
- [ ] Run a basic CLI smoke test and record the resulting PHP version and enabled modules.

## Validation Log

- 2026-08-14 — corrected `libintl` symbol validation after commit `20507ee`: the rebuilt archive covers all 79/79 names exported by the SDK DLL. All 103 C members report x64 machine type and `MSVCRT`, with zero `LIBCMT` and zero embedded `/EXPORT:` directives. The only meaningful static-reference names absent after filtering compiler/debug/resource artifacts are `_snprintf`, `_snwprintf`, `_vsnprintf`, `_vsnwprintf_l`, and `frexpl`; inspection of the SDK `vasnprintf.obj` confirms these are header/UCRT fallback functions emitted inside that object rather than libintl API. The only manifest member still absent is `libintl.res.obj`; add committed `libintl.rc` through Xmake's native Windows resource compilation with version `1.0` before runtime validation.

- 2026-08-14 — replacement-surface `libintl` rebuild at commit `1346f39`: the generated UCRT-backed `float.h`, `rpl_pthread_once` selection, and hidden `_libintl_tsearch` family mappings compiled successfully with the same direct `/MD /O2` MSVC build; `out/libintl.lib` was recreated in 3.125 seconds. Re-run the SDK export/static-symbol comparison before integrating the remaining Windows resource object.

- 2026-08-14 — initial `libintl` archive/symbol inspection after commit `c53c5b2`: `out/libintl.lib` contains the exact 103 C members corresponding to the SDK's 25 core plus 78 Gnulib objects; all 103 request `MSVCRT`, none requests `LIBCMT`, and no member emits `/EXPORT:`. Against the 79 names exported by the SDK DLL, 75 are already present. The four missing names are Gnulib configuration differences: `gl_FLT_SNAN`, `gl_DBL_SNAN`, `gl_LDBL_SNAN`, and `rpl_pthread_once`. The static-reference comparison also exposed generic `tsearch`/`tfind`/`tdelete`/`twalk` names where upstream `configure.ac` hides them with the `_libintl_` prefix. Generate the missing `float.h` wrapper, select the pthread-once replacement spelling, and restore the hidden tree-search mappings before final symbol validation. The SDK's extra `libintl.res.obj` remains a separate resource-integration step.

- 2026-08-14 — complete direct `libintl` build at commit `d08a889`: Xmake compiled the exact 25 core plus 78 Gnulib C sources selected by the official PHP SDK reference using only the configured MSVC/Windows SDK toolchain with `/MD /O2`, rebuilt the direct `libiconv` dependency, and archived `out/libintl.lib` successfully in 3.515 seconds. The complete native Gnulib wrapper set now supplies MSVC's missing POSIX/C23 interfaces without MinGW, Cygwin, Autoconf, Make, sed, or other Unix build tools. Existing source-level warnings remain non-blocking under project policy; archive, symbol-surface, resource, and runtime validation remain.

- 2026-08-14 — fifth exact-manifest `libintl` build at commit `4cdd370`: Gnulib's generated checked-arithmetic header compiled `stdio-consolesafe.c` and the pass advanced through `unistd.c`, `wctype-h.c`, `wcwidth.c`, `wgetcwd-lgpl.c`, and the first native Windows synchronization objects to 64%. The next fatal error was only the missing generated `alloca.h` in `vasnprintf.c`; on MSVC the committed Gnulib template maps `alloca` directly to UCRT `_alloca`, so generate that header with no external dependency.

- 2026-08-14 — fourth exact-manifest `libintl` build at commit `4931805`: the generated `sched.h`/once-only `pthread.h` shim compiled reference-selected `pthread-once.c` successfully with no pthread library or non-Windows runtime. Compilation advanced to 57% and stopped in `stdio-consolesafe.c` only because MSVC lacks C23 `<stdckdint.h>`; Gnulib ships a header-only replacement based on `intprops-internal.h`, so generate that wrapper directly and continue.

- 2026-08-14 — third exact-manifest `libintl` build at commit `1b90f01`: the generated `wchar.h` correctly redirected the MSVC inline `mbsinit`, so `mbsinit.c` compiled, and the generated `uchar.h` removed the prior `mbrtoc32` DLL-linkage warning. Compilation advanced to 55% and stopped only because reference-selected `pthread-once.c` includes Gnulib's generated `pthread.h`; native Windows does not need a pthread library because that wrapper defines `pthread_once_t` over `windows-once.h` under `USE_WINDOWS_THREADS`. Generate the once-only pthread shim and continue.

- 2026-08-14 — second exact-manifest `libintl` build at commit `52f76ef`: fixing MSVC `bool` handling let the complete 25-source core and the selected Gnulib set compile through 50%, including the newly generated native `locale.h`, `getcwd-lgpl.c`, and `getlocalename_l-unsafe.c`. The next fatal error was `mbsinit.c` colliding with UCRT's inline `mbsinit`; Gnulib's own `mbsinit.m4` explicitly selects `REPLACE_MBSINIT=1` on `windows*`, so this source must remain and be renamed through the generated `wchar.h` wrapper. `mbrtoc32.c` also emitted an inconsistent-DLL-linkage warning against UCRT, matching the need for its upstream-selected `uchar.h` replacement wrapper. The now-active setlocale-null wrapper also supplies `SETLOCALE_NULL_ALL_MAX`, making the previous source-local define redundant.

- 2026-08-14 — first exact-manifest `libintl` build at commit `aec0a80`: Xmake invoked only the configured MSVC toolchain with `/MD /O2`; the generated `locale.h` successfully included the selected UCRT header and supplied the previously missing POSIX `locale_t` model. Compilation then stopped immediately because `config.h` incorrectly defined `HAVE_C_BOOL`, causing Gnulib to skip `<stdbool.h>` even though MSVC C obtains `bool` from that header. Leave `HAVE_C_BOOL` undefined and retry.

- 2026-08-14 — Oniguruma runtime validation at commit `9bc8c94`: the complete upstream UTF-8 suite ran against the direct static archive and reported 1,529 successes, zero failures, zero errors, and Oniguruma 6.9.10, exiting 0 in 30 ms. The executable imports only Kernel32, VCRuntime, and UCRT libraries, confirming static Oniguruma linkage with the dynamic MSVC CRT. Remove the temporary test target and disable the completed library.

- 2026-08-14 — Oniguruma upstream-test build at commit `4f94492`: the temporary non-default Xmake target compiled `test/test_utf8.c` with the upstream-required UTF-8 source mode and linked it directly against `oniguruma.lib` in 0.344 seconds. Execute the full suite and inspect its runtime dependencies before removing the temporary target.

- 2026-08-14 — Oniguruma archive inspection after commit `45a4373`: `out/oniguruma.lib` contains the same 50 x64 members as the SDK reference, and every member selects `MSVCRT`; none selects `LIBCMT`, emits an export directive, or defines an `__imp_onig*` thunk. The direct archive covers all 211 APIs exported by both the preserved SDK DLL and `dll_compare/onig.dll`. Its 30 name differences from the SDK archive are paired MSVC-decorated internal string literals, not public or external interfaces. Runtime validation remains.

- 2026-08-14 — initial direct Oniguruma build at commit `26f3570`: Xmake copied the committed Win64 configuration, compiled all 50 native-manifest sources independently with `/MD /O2`, and created `out/oniguruma.lib` successfully in 1.828 seconds without target warnings. Archive interface and runtime validation remain.

- 2026-08-14 — Oniguruma native-build analysis after commit `4c5c195`: upstream CMake and `src/Makefile.windows` select 48 core/encoding sources plus the two POSIX sources. The preserved SDK archive independently confirms those exact 50 x64 members, while the seven other root C files are one generator, one unselected legacy KOI8 encoding, and five committed Unicode fragments included by `unicode.c`. The Windows path copies `config.h.win64`, defines both POSIX modes, requires no external library or generated implementation source, and exposes 211 APIs in both the SDK and `dll_compare` DLLs. The SDK archive's `LIBCMT` and embedded export directives are packaging properties to correct: the direct target will use `/MD`, propagate `ONIG_STATIC`, and emit neither exports nor import thunks.

- 2026-08-14 — unchanged Oniguruma preparation after commit `6e432af`: `xmake prepare` completed in 0.8 seconds with the exact official v6.9.10 source already present, validating idempotence.

- 2026-08-14 — clean Oniguruma preparation at commit `98b6789`: after preserving the SDK package under `%TEMP%`, validating `in/deps/libonig` as the exact direct child of `in/deps`, and moving it to the Recycle Bin, `xmake prepare` recreated the official source from `github://kkos/oniguruma?ref=v6.9.10` in 1.5 seconds. The hx provenance records that exact ref and the public header declares version 6.9.10. An unchanged repeat remains.

- 2026-08-14 — `libxslt` runtime validation at commit `e445886`: a temporary non-default Xmake target compiled and linked upstream `xsltproc.c` against the combined direct archive and its static libxml2/libiconv chain. The `general/array` XSLT and `exslt/strings/tokenize.1` EXSLT cases both exited 0 without stderr and matched their committed expected outputs exactly. The executable imports only Windows, VCRuntime, and UCRT DLLs, confirming static third-party linkage with the dynamic MSVC CRT. Remove the temporary target and disable the completed dependency chain.

- 2026-08-14 — initial direct `libxslt` build and archive inspection at commit `dc924a2`: Xmake generated both public configuration headers, compiled all 19 libxslt and 10 libexslt sources independently with `/MD /O2`, and created the combined archive successfully in 4.25 seconds. All 29 members are x64 and request `MSVCRT`; none requests `LIBCMT` or emits an export directive. The archive contains all 334 unique symbols from the two SDK static references plus only `_Avx2WmemEnabledWeakValue`, and `xslDebugStatus` is correctly represented as a four-byte COFF common definition. This covers all 269 SDK DLL APIs and all 268 APIs in `dll_compare`. The generated headers match the SDK files line for line, and all 574 libxml references are direct with no `__imp_xml` thunk, matching the all-static dependency goal. Runtime transformation validation remains.

- 2026-08-14 — `libxslt` native-build analysis after commit `6789973`: upstream Windows, Automake, and CMake manifests match the SDK's 19-object libxslt plus 10-object libexslt static archives. Both source directories are pure library inputs. The SDK configuration enables XSLT diagnostics, debugger hooks, profiler, and modules while disabling Trio and crypto; it needs only two generated public configuration headers, the committed Windows configuration, libxml2, and `kernel32`. The component symbol sets have no API/implementation collision, so combine them in one per-source target. The two SDK DLLs export 252 and 17 APIs; the `dll_compare` copies are a strict subset missing only the SDK backport's `xsltReleaseRVTList`.

- 2026-08-14 — unchanged `libxslt` preparation after commit `60bf81d`: `xmake prepare` completed in 0.8 seconds with the exact 1.1.43-2 source already present, validating idempotence.

- 2026-08-14 — clean `libxslt` preparation at commit `d19b65a`: after preserving the complete SDK package under `%TEMP%`, validating `in/deps/libxslt` as the exact direct child of `in/deps`, and moving it to the Recycle Bin, `xmake prepare` recreated the source from `github://winlibs/libxslt?ref=libxslt-1.1.43-2` in 2.2 seconds. The hx provenance records that exact ref and the source declares libxslt 1.1.43 plus libexslt 0.8.24. An unchanged repeat remains.

- 2026-08-14 — `libxml2` runtime validation at commit `1510d26`: a temporary non-default Xmake target compiled and linked upstream `doc/examples/parse3.c` against the direct `libxml2` and `libiconv` archives. The example verified the ABI, parsed an in-memory XML document, cleaned up, and exited 0. Its import table contains only Windows, VCRuntime, and UCRT DLLs, with no libxml2 or libiconv DLL dependency, confirming static third-party linkage with the dynamic MSVC CRT. Remove the temporary target and disable the completed library.

- 2026-08-14 — patched `libxml2` build and archive inspection after commit `c201401`: Xmake compiled the same 43 independent sources with `/MD /O2` and archived them successfully in 3.5 seconds. All 43 members are x64 and request `MSVCRT`; none requests `LIBCMT`, emits `/EXPORT:`, or contains libxml/libiconv import thunks. The archive contains every one of the SDK reference `libxml2_a_dll.lib`'s 1,770 defined symbols, including `xmlDllMain` and `xmlRelaxParserSetIncLImit`; its only additional symbol is the current MSVC compiler artifact `_Avx2WmemEnabledWeakValue`. It also covers all 1,622 reference DLL exports except the DLL entry point `DllMain`, and the generated public `xmlversion.h` matches the SDK header line for line. Runtime parser validation remains.

- 2026-08-14 — unchanged patched `libxml2` preparation after commit `8921be0`: `xmake prepare` completed in 0.8 seconds with the exact 2.11.9-7 source already present, validating idempotence.

- 2026-08-14 — clean patched `libxml2` preparation at commit `3f7cd25`: after validating `in/deps/libxml2` as the exact direct child of `in/deps`, the vanilla GNOME tree was moved to the Recycle Bin and `xmake prepare` recreated it from `github://winlibs/libxml2?ref=libxml2-2.11.9-7` in 2.9 seconds. The hx provenance records that exact ref, the CVE-2026-0989 function is present in the public header, implementation, and regression test, and the existing declarative filter still selects exactly 43 library sources. An unchanged repeat remains.

- 2026-08-14 — initial `libxml2` archive inspection after commit `7436b4a`: all 43 objects are x64 and select `MSVCRT`; no object selects `LIBCMT`, emits `/EXPORT:`, or contains libxml/libiconv import thunks. The vanilla GNOME 2.11.9 tree nevertheless differs from the current PHP SDK 2.11.9-7 package by the security-backported `xmlRelaxParserSetIncLImit` symbol. The SDK SBOM identifies its exact source as `winlibs/libxml2` tag `libxml2-2.11.9-7` at commit `f06d784607050c08a9b28b1fce2faa4236c052cf`; switch preparation to that source. The SDK's `libxml2_a_dll.lib` also contains `xmlDllMain`, and PHP calls it from `win32/dllmain.c`, so use the native Windows TLS path and remove the incompatible `HAVE_COMPILER_TLS` define before final validation.

- 2026-08-14 — initial direct `libxml2` build at commit `3f6dbc7`: Xmake copied/substituted the two committed configuration headers, compiled exactly the 43 native Windows library sources independently with `/MD /O2`, rebuilt the `libiconv` dependency, and archived `out/libxml2.lib` successfully in 3.5 seconds. Only the already accepted generated-table warnings from `libiconv` appeared; archive, symbol-surface, and parser runtime validation remain.

- 2026-08-14 — unchanged libxml2 preparation after commit `82bab6f`: `xmake prepare` completed in 0.8 seconds with the official 2.11.9 source already present, validating idempotence.

- 2026-08-14 — clean libxml2 preparation at commit `4e444e4`: after preserving the PHP SDK package under `%TEMP%`, validating `in/deps/libxml2` as the exact direct child of `in/deps`, and moving it to the Recycle Bin, `xmake prepare` recreated the official GNOME 2.11.9 release source in 2.4 seconds. The source's release macros and hx provenance match 2.11.9; an unchanged repeat remains.

- 2026-08-14 — broad `libintl` build at commit `bbeabc6`: the generated `unistd.h` wrapper compiled `rpl_getcwd` successfully and advanced the pass to 32%. The selected `getlocalename_l-unsafe.c` then required Gnulib's generated `locale.h` and Windows `locale_t` model. Per current priority, disable and defer this incomplete target rather than expanding its wrapper configuration now.

- 2026-08-14 — broad `libintl` build at commit `47e56f6`: the replacement exclusion passed and compilation advanced into the selected Gnulib runtime. `getcwd-lgpl.c`, which is present in the native static manifest, then stopped at its required generated `unistd.h`; generate that wrapper directly from `unistd.in.h` with the Windows replacement declaration, without invoking `configure`.

- 2026-08-14 — expanded Gnulib build at commit `e3369b2`: defining the native Windows 16-bit `wchar_t` model resolved the C32 checks and compilation advanced to 31%. The broad source experiment then proved that `frexp.c` and `frexpl.c` are replacement implementations rather than Windows target inputs: MSVC already defines `frexpl`, so compiling the Gnulib replacement produces C2084. Exclude this paired substitute and continue the broad compiler-driven pass.

- 2026-08-14 — expanded Gnulib build at commit `0f36ebd`: the direct-root source pattern was active and compilation reached the C32 character helpers. Their static assertion failed because the omitted generated `uchar.h` normally identifies native Windows' 16-bit `wchar_t`; supply Gnulib's `_GL_SMALL_WCHAR_T=1` platform fact privately instead of shadowing MSVC's standard header.

- 2026-08-14 — `libintl` build at commit `98be709`: Xmake completed successfully in 1.8 seconds, but archive inspection found only 42 C objects because `gnulib-lib/**/*.c` matches nested directories and not the 83 direct-root Gnulib files. This is not yet a valid completed target. Add the adjacent `gnulib-lib/*.c` declaration and remove the ineffective command-line `alignof` mapping, which the upstream source intentionally replaces locally and which only added a redefinition warning.

- 2026-08-14 — fifth direct `libintl` build at commit `1055bb4`: the generated Unicode and search headers worked, eliminating the tree-search implicit declarations and advancing compilation to 48%. `setlocale.c` then required `SETLOCALE_NULL_ALL_MAX`, normally exposed by Gnulib's generated locale wrapper; apply the upstream value only to that source. Map C `alignof` to MSVC's intrinsic and declare `wgetcwd` in the internal generated header to eliminate the remaining pointer-sized implicit declarations before retrying.

- 2026-08-14 — fourth direct `libintl` build at commit `d5a7f98`: relative `LOCALEDIR` and `LIBDIR` values allowed all 25 core sources to compile and advanced the broad build to 46%. The first Gnulib failure was the expected generated `unicase.h`; generate only the non-system Unicode headers plus the tree-search wrapper in the callback, leaving MSVC's CRT headers unshadowed.

- 2026-08-14 — third direct `libintl` build at commit `0ac0440`: after the two platform exclusions, the core compiled through 22% and stopped only because the direct target had not supplied upstream's install-time `LOCALEDIR` macro. Define relative `LOCALEDIR` and `LIBDIR` values in Xmake; the same translation unit's implicit tree-search diagnostics identify the generated `search.h` compatibility declaration as the next likely configuration requirement.

- 2026-08-14 — second direct `libintl` build at commit `c544fe4`: the corrected configuration compiled the initial core sources through 12%, then `intl-exports.c` failed because its DLL-only declaration machinery is not active for a static build. Remove that shared-library source and the independently identified OS/2-only `os2compat.c`; retain the broad root and recursive Gnulib patterns for the next pass.

- 2026-08-14 — initial direct `libintl` build at commit `925ef5a`: Xmake invoked MSVC directly on the broad per-source C declarations with `/MD /O2`; compilation stopped in the first core batch because the Windows configuration lacked `FLEXIBLE_ARRAY_MEMBER=1`. The callback's substitutions for `PACKAGE` and `HAVE_STDINT_H` also matched longer macro names and produced harmless redefinition warnings; make those substitutions exact and add the required flexible-array setting before retrying.

- 2026-08-13 — unchanged libintl preparation after commit `5c571ee`: `.\xmake.exe prepare` completed in 0.8 seconds with the official GNU Gettext 1.0 tree already present, validating the new source fetch's idempotence.

- 2026-08-13 — clean libintl preparation at commit `ee36d3b`: after preserving the PHP SDK static archive/header under `%TEMP%`, verifying `in/deps/libintl` as the exact direct child of `in/deps`, and moving the binary package to the Recycle Bin, `.\xmake.exe prepare` recreated the tree from GNU's official Gettext 1.0 tarball in 6.5 seconds. The source reports version 1.0 and retains the expected `gettext-runtime/intl` build metadata; an unchanged repeat remains.

- 2026-08-13 — final `libiconv` validation at commit `fc8e535`: all three upstream sources built independently with `/MD /O2` in 0.7 seconds; the accepted generated-table C4311 and nested-qualifier C4090 diagnostics did not block the baseline. The archive contains exactly three x64 members, all requesting `MSVCRT`, with zero `LIBCMT`, `/EXPORT:`, iconv import thunks, or unresolved header-template tokens. All nine reference DLL exports are defined, and upstream `tests/test-to-wchar.c` linked against `libiconv.lib` and passed its incomplete UTF-8 conversion check.

- 2026-08-13 — `.\xmake.exe -vD -j8 libiconv` plus archive/reference checks at commit `8d9bfea`: all three upstream sources compiled with `/MD /O2` and archived in 0.7 seconds. The three members are x64 and request `MSVCRT`, with zero `LIBCMT`, `/EXPORT:`, import thunks, or unresolved template tokens; all nine exports from the reference PHP SDK `libiconv.dll` are present. Per the revised baseline policy, remove warning-only suppressions and retain the simpler functional configuration for the final build.

- 2026-08-13 — `.\xmake.exe -vD -j8 libiconv` at commit `4c686c0` built and archived all three sources with `/MD /O2` in 0.7 seconds. One C4090 remained at `iconv.c:499`, where the standard `qsort(void *)` API reorders an array of pointers to const strings; suppress this understood nested-qualifier warning only on `iconv.c` before the final rebuild.

- 2026-08-13 — `.\xmake.exe -vD -j8 libiconv` at commit `3c5848e` stopped while compiling `iconv.c`: the minimal generated config omitted upstream's empty `ICONV_CONST`, making the function definition invalid. MSVC also reports C4311 for the generated gperf tables' deliberate pointer-to-offset casts through `long`; add the missing empty macro and suppress that warning only for `iconv.c` before retrying.

- 2026-08-13 — unchanged libiconv preparation after commit `9d93681`: `xmake prepare` completed in 0.8 seconds with the official GNU 1.19 source already present, validating the new fetch's idempotence.

- 2026-08-13 — clean libiconv preparation at commit `cb595ee`: after verifying the old binary-package directory as the exact `in/deps/libiconv` direct child and moving it to the Recycle Bin, `xmake prepare` recreated the directory from GNU's official libiconv 1.19 tarball in 2.4 seconds. The complete release source and matching hx provenance marker are present; an unchanged repeat remains.

- 2026-08-13 — `.\xmake.exe -vD -j8 icu` plus archive/reference checks and the official C++ transliteration sample at commit `c7e4a01`: all 455 C++ sources rebuilt independently without warnings using `/MD /O2 /std:c++17 /EHs-c-`, and `genccode` inserted the packaged data as one intentional machine-neutral object. The 70,195,496-byte archive has 456 members: 455 x64 objects requesting `MSVCRT` and one machine-neutral data object, with zero `LIBCMT`, `/EXPORT:`, or ICU import thunks. All 1,635 C/data exports from the reference common, i18n, and data DLLs are present; the official C++ sample linked statically, exercised calendar, date formatting, normalization, and transliteration against the embedded data, and exited successfully.

- 2026-08-13 — `.\xmake.exe -vD -j8 icu` at commit `8032603` built all 455 C++ sources and the generated data object without warnings in 32.3 seconds. The 456-member archive contains one intentional machine-neutral data object and 455 x64 objects; every compiled object requests `MSVCRT`, with zero `LIBCMT`, `/EXPORT:`, or ICU import thunks. It contains all 1,635 C/data exports from the reference `icuuc77.dll`, `icuin77.dll`, and `icudt77.dll`; the official C++ transliteration sample also linked statically and ran successfully against the archive and embedded data. The verbose command exposed Xmake's default `/EHsc`, so disable C++ exceptions with the native target setting before the final rebuild, matching ICU's no-exception library configuration.

- 2026-08-13 — `.\xmake.exe -vD -j8 icu` at commit `4a17fff` stopped in the target callback before compilation: Xmake expanded `$(projectdir)` in the `os.vrunv` program path but passed placeholders in the argument table literally, so `genccode` could not open its input. Keep the executable placeholder and use direct project-relative data paths in the argument list before retrying.

- 2026-08-13 — unchanged expanded ICU preparation after commit `17b02f2`: `xmake prepare` completed in 0.7 seconds with source, data archive, and minimal generator runtime already present, validating the complete ICU preparation's idempotence.

- 2026-08-13 — expanded clean ICU preparation at commit `15227d9`: after revalidating and moving the exact `in/deps/ICU` direct child to the Recycle Bin, `xmake prepare` recreated the official source, extracted the 31,895,376-byte `icudt77l.dat`, and retained only `genccode.exe` plus its four required ICU runtime DLLs from the official Win64 release under `in/tools/icu`. The complete preparation finished in 9.9 seconds; an unchanged repeat remains.

- 2026-08-13 — unchanged ICU source preparation after commit `6bc5e02`: `xmake prepare` completed in 0.7 seconds with official tag `release-77-1` already present, validating source-fetch idempotence. The forthcoming official data archive and build-time `genccode` inputs require their own clean preparation validation.

- 2026-08-13 — clean ICU preparation at commit `c11de6e`: after validating and moving the exact prebuilt `in/deps/ICU` direct child to the Recycle Bin, `xmake prepare` recreated it from official tag `release-77-1` in 11.4 seconds. The complete ICU4C source and committed data inputs are present; an unchanged repeat remains.

- 2026-08-13 — `.\xmake.exe -vD -j8 ngtcp2_crypto_ossl` plus public-header API comparisons at commit `ceb9e69`: all 46 core and two OpenSSL-adapter sources compiled independently with `/MD /O2 /std:c11`, producing both PHP-required archives without warnings in 3.2 seconds. Every member is x64 and requests `MSVCRT`, with zero `LIBCMT`, `/EXPORT:`, ngtcp2 import thunks, or OpenSSL import thunks. `ngtcp2.lib` contains all 168 core APIs; `ngtcp2_crypto_ossl.lib` contains all 54 generic/ossl crypto APIs. The generated version header contains `1.25.0` and `0x011900`.

- 2026-08-13 — `.\xmake.exe -vD -j8 nghttp3` plus public-header API comparison at commit `d52a7f1`: all 32 sources compiled independently with `/MD /O2 /std:c11`, and `out/nghttp3.lib` archived without warnings in 1.0 second. All 32 members are x64 and request `MSVCRT`, with zero `LIBCMT` or `/EXPORT:` directives; all 91 public header APIs are present and none uses an import thunk. The generated version header contains `1.18.0` and `0x011200`.

- 2026-08-13 — `.\xmake.exe -vD -j8 nghttp3` at commit `736a6eb` stopped in `nghttp3_ksl.h` because the initial target omitted upstream's required C11 language level and MSVC parsed the `_Generic` min/max macro as legacy C. Add target-scoped `c11` so Xmake emits `/std:c11`, then retry.

- 2026-08-13 — unchanged recursive `nghttp3` preparation after commit `4e5789f`: `xmake prepare` completed in 0.7 seconds with the release commit and all recursively materialized gitlinks already present, validating idempotence.

- 2026-08-13 — clean recursive `nghttp3` preparation at commit `212a0ae`: hx materialized release commit `dbfc24286138cb0b6490160e7ca87fe1ce6722a0` and its exact `sfparse` and test submodule gitlinks in one command. The source tree now contains all 31 direct library C files plus `lib/sfparse/sfparse.c`; preparation completed in 2.6 seconds and an unchanged repeat remains.

- 2026-08-13 — clean recursive `nghttp3` preparation at commit `f5d4832` stopped before writing the destination: hx's recursive Git implementation interpreted tag name `v1.18.0` as `refs/heads/v1.18.0`. Pin the tag's immutable commit `dbfc24286138cb0b6490160e7ca87fe1ce6722a0` while retaining `--recursive`, then retry from absence.

- 2026-08-13 — clean `nghttp3` preparation at commit `4170b01`: the separate pinned `sfparse` fetch populated the release's formerly empty gitlink successfully, but inspection of hx's own help showed that `--recursive` provides this behavior natively. Replace the redundant second command and repeat the clean preparation before accepting it.

- 2026-08-13 — `.\xmake.exe -vD -j8 libuv` plus `uv.h` API comparison at commit `aa908fe`: all 37 sources compiled independently with `/MD /O2`, and `out/libuv.lib` archived in 1.7 seconds. All 37 members are x64 and request `MSVCRT`, with zero `LIBCMT` or `/EXPORT:` directives; all 318 public header APIs are present and none uses an import thunk. MSVC 14.50 reports two investigated upstream C4090 warnings where libuv frees its owned `const char *` CPU-model field.

- 2026-08-13 — `.\xmake.exe -vD -j8 libsodium` plus `dll_compare/libsodium.dll` comparison at commit `b80cb81`: the committed MSVC version header was copied exactly, all 141 sources compiled independently with `/MD /O2`, and `out/libsodium.lib` archived without warnings in 3.5 seconds. All 141 members are x64 and request `MSVCRT`, with zero `LIBCMT` or `/EXPORT:` directives. The archive contains all 756 reference exports and no public-API import thunks.

- 2026-08-13 — `.\xmake.exe prepare` at commit `acabee7`: the unchanged repeat completed successfully in 0.8 seconds with the official libsodium source already present, validating preparation idempotence.

- 2026-08-13 — `.\xmake.exe prepare` at commit `2d281bb`: after verifying that `in/deps/libsodium` was the intended direct child and moving the previous PHP SDK binary package to the Recycle Bin, preparation recreated the official `1.0.22` source tree in 1.8 seconds with the correct hx marker. An unchanged repeat remains.

- 2026-08-13 — `.\xmake.exe -vD -j8 libcurl` plus static-archive inspection at commit `9df6001`: the enabled OpenSSL/compression/SSH/HTTP2 closure and all 192 libcurl sources built successfully in 34.7 seconds. Every libcurl object is x64 and requests `MSVCRT`, with zero `LIBCMT` or `/EXPORT:` directives. The archive contains all 100 APIs from upstream `libcurl.def`, no `__imp_curl*`, `__imp_nghttp2*`, or `__imp_libssh2*` thunks, and real references to OpenSSL, zlib, Brotli, zstd, nghttp2, and libssh2. The dependency build emitted the already documented upstream OpenSSL C4133 warning at `obj_dat.c:238`.

- 2026-08-13 — `.\xmake.exe -vD -j8 nghttp2` plus `dll_compare/nghttp2.dll` comparison at commit `317c34f`: the generated header contains version `1.69.0`/`0x014500`; all 26 sources compiled independently with `/MD /O2`, and `out/nghttp2.lib` archived in 1.2 seconds. The archive contains all 181 reference exports, 26 x64 members, 26 `MSVCRT` and zero `LIBCMT` directives, no `/EXPORT:` directives, and no `__imp_nghttp2*` thunks.

- 2026-08-13 — `.\xmake.exe -vD -j8 nghttp2` at commit `e23a5cc`: preparation stopped before compilation because the final Lua `gsub` returned both the transformed text and replacement count, so `io.writefile` received the count as its options argument. Parenthesize the chained expression to collapse it to one value before retesting.

- 2026-08-13 — `.\xmake.exe -vD -j8 libssh2` plus `dll_compare/libssh2.dll` comparison at commit `1750338`: all 26 sources compiled independently with `/MD /O2`, and `out/libssh2.lib` archived successfully in 1.5 seconds. The archive contains all 137 reference exports, 26 x64 members, 26 `MSVCRT` and zero `LIBCMT` directives, no `/EXPORT:` directives, and no `__imp_libssh2*` thunks.

- 2026-08-13 — `.\xmake.exe prepare` at commit `e5d38b4`: the no-change repeat completed successfully in 0.8 seconds with the official libssh2 source tree already present, validating preparation idempotence.

- 2026-08-13 — `.\xmake.exe prepare` at commit `f07525a`: after verifying that `in/deps/libssh2` was the intended direct child and moving the former prebuilt package to the Recycle Bin, preparation recreated it from official tag `libssh2-1.11.1` in 1.7 seconds. The new source tree and hx marker are correct; a no-change repeat remains.

- 2026-08-13 — clean `.\xmake.exe clean openssl_test` plus `.\xmake.exe -j8 openssl_test` and root-DLL symbol comparison at commit `4f25734`: the complete target rebuilt and archived successfully in 24.781 seconds. The single combined `openssl_test.lib` contains all 6,475 names exported by the OpenSSL 3.5.7 x64 `libcrypto` and `libssl` DLLs, with zero missing names and zero embedded `/EXPORT:` directives.

- 2026-08-13 — `.\xmake.exe -j8 openssl_test` plus root-DLL symbol comparison at commit `54e439d`: Xmake compiled the restored configured `ecp_nist.c` and `ecp_nistz256.c`, re-archived successfully, and the combined `openssl_test.lib` now contains all 6,475 names exported by the OpenSSL 3.5.7 x64 `libcrypto` and `libssl` DLLs. Removing `ms/applink.c` also leaves the archive with zero embedded `/EXPORT:` directives. A clean rebuild remains for final validation.

- 2026-08-13 — symbol comparison at commit `4a88c59`: the root OpenSSL 3.5.7 x64 DLLs export 5,872 `libcrypto` names and 603 `libssl` names. The combined `openssl_test.lib` contains 6,474 of those 6,475 exports; only `EC_GFp_nist_method` is absent because `ecp_nist*.c` also removes the configured `ecp_nist.c`. The archive additionally carries `/EXPORT:OPENSSL_Applink` from non-library source `ms/applink.c`. Narrow the EC exclusion to disabled `ecp_nistp*.c` plus included table fragment `ecp_nistz256_table.c`, and remove `ms/applink.c` before rebuilding.

- 2026-08-13 — clean `.\xmake.exe clean openssl_test` plus `.\xmake.exe -j8 openssl_test` at commit `6eadcf1`: Xmake rebuilt the complete simplified C and x64 assembly selection from zero, compiled both explicitly retained engines, and archived `openssl_test.lib` successfully in 24.39 seconds. The broad source-glob experiment is build-complete; its existing upstream-style MSVC warnings remain non-fatal.

- 2026-08-13 — `.\xmake.exe -j8 openssl_test` at commit `169f7d9`: the single `test/**.c` exclusion removed the complete disabled test tree. The incremental compilation resumed at 94%, compiled the two explicitly retained engines, archived `openssl_test.lib`, and completed successfully. A clean parallel rebuild remains to verify the complete simplified declaration without cached objects.

- 2026-08-13 — `.\xmake.exe -j8 openssl_test` at commit `cc19cdc`: the exact `ktls_meth.c` exclusion passed and compilation advanced from 74% into the test tree, failing at `test/bn_internal_test.c` because its test-only generated `bn_prime.h` is absent. The configuration uses `no-tests`; Xmake's `test/**.c` glob selects all 288 test C sources, exactly matching the union of 251 direct and 37 nested files.

- 2026-08-13 — `.\xmake.exe -j8 openssl_test` at commit `4682cde`: the VC-WIN64A seeding selection compiled only `rand_cpu_x86.c`, `rand_tsc.c`, `rand_unix.c`, and `rand_win.c`, passing the previous platform-source failure. Compilation reached 72% and failed at `ssl/record/methods/ktls_meth.c`; upstream `build.info` selects that source only when KTLS is enabled, while the generated configuration records both `no-ktls` and `OPENSSL_NO_KTLS`.

- 2026-08-13 — `.\xmake.exe -j8 openssl_test` at commit `4e847c2`: excluding the macro-parameterized Blake2 implementation fragment preserved and compiled both concrete Blake2 MAC wrappers. Compilation reached the platform seeding directory and failed at VMS-only `rand_vms.c`; VC-WIN64A selects `rand_cpu_x86.c`, `rand_tsc.c`, `rand_unix.c`, and `rand_win.c`, while omitting ARM64 `rand_cpu_arm64.c` and the two `rand_v*.c` VMS/VxWorks variants.

- 2026-08-13 — `.\xmake.exe -j8 openssl_test` at commit `d2258a9`: the complete non-FIPS exclusion passed, while the shared default-provider implementations `cipher_aes_xts_fips.c` and `pbkdf2_fips.c` compiled as expected. Compilation reached `providers/implementations/macs/blake2_mac_impl.c`; this is a macro-parameterized implementation fragment textually included by both `blake2b_mac.c` and `blake2s_mac.c`, and upstream never compiles it independently.

- 2026-08-13 — `.\xmake.exe -j8 openssl_test` at commit `5944614`: the corrected direct-child `fuzz/*.c` pattern removed all 33 fuzz sources. Compilation advanced into providers and failed at the FIPS-only `providers/common/securitycheck_fips.c`; the configured `no-fips` closure also omits all five direct C sources in `providers/fips` and `providers/implementations/rands/fips_crng_test.c`, while retaining the default-provider sources whose filenames contain `fips`.

- 2026-08-13 — `.\xmake.exe -j8 openssl_test` at commit `353a546`: the attempted `fuzz/**/*.c` exclusion matched no files because Xmake's `**/` requires at least one nested directory in this position, while all 33 fuzz sources are direct children of `fuzz`. Direct Xmake glob probes returned zero matches for `fuzz/**/*.c` and 33 for `fuzz/*.c`; use the direct-child pattern.

- 2026-08-13 — `.\xmake.exe -j8 openssl_test` at commit `b47a95f`: the broad glob's `|engines/*.c` exclusion removed every unselected engine C source, while the explicit CAPI and PadLock sources remained selected. Compilation advanced directly to `fuzz/driver.c`; all 33 C files in `fuzz` are standalone fuzz or corpus-test program inputs, and none belongs to the library closure under `no-tests`, `no-fuzz-afl`, and `no-fuzz-libfuzzer`.

- 2026-08-13 — `.\xmake.exe -j8 openssl_test` at commit `3be0820`: the AF_ALG exclusion removed both Linux engine sources, then compilation failed on the Unix `/dev/crypto` engine. The configured static-engine closure contains only `e_capi.c` and `e_padlock.c` plus PadLock x64 assembly; exclude all direct `engines/*.c` files inside the broad glob and add back those two selected C sources instead of accumulating per-engine exclusions.

- 2026-08-13 — `.\xmake.exe -j8 openssl_test` at commit `37aa64a`: excluding all seven documentation C snippets removed the `sys/poll.h` failure. Compilation next stopped at the Linux AF_ALG engine source `engines/e_afalg.c`; VC-WIN64A enables only the CAPI and PadLock engines, while `no-afalgeng` omits both `e_afalg.c` and its generated `e_afalg_err.c` companion.

- 2026-08-13 — `.\xmake.exe -j8 openssl_test` at commit `b53263b`: excluding all demo C sources removed the Unix-only HTTP/3 failure. Compilation immediately reached the seven C examples under `doc/designs/ddd` and failed on `ddd-06-mem-uv.c` requiring `sys/poll.h`; none of these documentation snippets occurs in the upstream compile graph, and the configuration also uses `no-docs`.

- 2026-08-13 — `.\xmake.exe -j8 openssl_test` at commit `9ffb5ab`: the ACVP glob removed both disabled ACVP C sources, allowing compilation to traverse the remaining `crypto` tree and reach 52%. The next failure came from Unix-only `demos/http3/ossl-nghttp3-demo-server.c`; all 69 C files below `demos` are example programs, and the configured `no-demos` option omits the complete directory.

- 2026-08-13 — `.\xmake.exe -j8 openssl_test` at commit `888b9f4`: excluding the five disabled low-level RC5 sources and two legacy-provider RC5 sources preserved upstream-selected `crypto/evp/e_rc5.c`, which compiled successfully under `OPENSSL_NO_RC5`. Compilation advanced to `crypto/rsa/rsa_acvp_test_params.c`; this unguarded FIPS ACVP helper is omitted by `no-acvp-tests`, and the verified `**/*acvp*.c` glob matches it plus only the independently disabled `test/acvp_test.c`.

- 2026-08-13 — `.\xmake.exe -j8 openssl_test` at commit `ad7bfa9`: the `crypto/poly1305/poly1305_*.c` exclusion removed exactly the three unselected alternative implementations while retaining and compiling upstream-selected `poly1305.c`. Compilation advanced to the disabled RC5 implementation at `crypto/rc5/rc5cfb64.c`; the configured `OPENSSL_NO_RC5` skips all five low-level `crypto/rc5` sources and both legacy-provider `cipher_rc5` sources while retaining the guarded `crypto/evp/e_rc5.c` adapter.

- 2026-08-13 — `.\xmake.exe -j8 openssl_test` at commit `9efaf6f`: excluding the six `LPdir_*.c` backend fragments let the broad source experiment advance from 34% to 39%. Compilation stopped at `crypto/poly1305/poly1305_base2_44.c`, a standalone assembly-development template requiring a 128-bit integer type unavailable in MSVC. Upstream VC-WIN64A selects only `poly1305.c` plus generated `poly1305-x86_64.asm`; the `crypto/poly1305/poly1305_*.c` glob matches exactly the three unselected alternative C implementations.

- 2026-08-13 — `.\xmake.exe -j8 openssl_test` at commit `832c52b`: excluding `crypto/*cap.c` removed all six non-x64 CPU-capability implementations while preserving the x64 CPUID C/assembly pair. Compilation stopped at `crypto/LPdir_win.c`; upstream compiles only `o_dir.c`, which selects `LPdir_win32.c` and transitively includes `LPdir_win.c`. All six `LPdir_*.c` files are backend fragments rather than independent translation units and must remain out of the broad source glob.
- 2026-08-13 — `.\xmake.exe -j8 openssl_test` at commit `4f3bcd1`: the verified `**/*md2*.c` glob removed all four default-disabled MD2 sources and compilation advanced through the remaining EVP implementations. It stopped at `crypto/loongarchcap.c`, a LoongArch/Linux CPU-capability implementation requiring `sys/auxv.h`. VC-WIN64A selects none of the six root `crypto/*cap.c` files; x64 capability detection instead uses `crypto/cpuid.c` and generated `crypto/x86_64cpuid.asm`.
- 2026-08-13 — `.\xmake.exe -j8 openssl_test` at commit `a5821aa`: the deliberately broad `ecp_nist*.c` exclusion bypassed all generic, NISTP, NISTZ256, and table C files. Compilation stopped next at `crypto/evp/legacy_md2.c`; VC-WIN64A defines `OPENSSL_NO_MD2`, and upstream omits the complete four-source MD2 closure. The verified `**/*md2*.c` pattern matches exactly `legacy_md2.c`, both `crypto/md2` implementation files, and `md2_prov.c`.
- 2026-08-13 — `.\xmake.exe -j8 openssl_test` at commit `6626e5b`: the precise `ecp_nistp*.c` exclusion removed the complete disabled GCC-128 group while retaining and compiling `ecp_nist.c` and `ecp_nistz256.c`. Compilation advanced to 30% and failed on `ecp_nistz256_table.c`, which is not an independent C translation unit: the x64 perlasm generator reads it as table data and emits the global `ecp_nistz256_precomputed` symbol in `ecp_nistz256-x86_64.asm`. The broad source-selection experiment will temporarily widen the exclusion to `ecp_nist*.c` as requested.
- 2026-08-13 — `.\xmake.exe -j8 openssl_test` at commit `d73ab4f`: the qualified `async.runjobs` calls loaded through the small eager `async` namespace and completed both generator groups. The corrected Windows `apps\openssl` key produced a 14,342-byte `progs.c` and a 5,200-byte `progs.h` containing all 54 command-main and 54 option-table declarations; Xmake compiled `apps/progs.c` and advanced past every application source. The next independent broad-glob failure is the architecture-inapplicable `crypto/bn/bn_s390x.c`, which requires unavailable `crypto/s390x_arch.h` on the x64 configuration.
- 2026-08-13 — `.\xmake.exe -vD -j8 openssl_test` at commit `42fa1f6`: both `async.runjobs` groups completed under the requested eight-job limit, producing all 50 template outputs and all 30 perlasm outputs before compilation. Configure also enabled apps and both `progs.pl` invocations exited successfully, but the forward-slash `apps/openssl` argument did not match configdata's Windows `apps\openssl` key: `progs.h` contained no command declarations. Preserve the exact backslash argument from the upstream build log before revalidating application generation. The deliberately broad compilation subsequently exited unsuccessfully and remains outside this generator-parallelism result.
- 2026-08-13 — `.\xmake.exe -j1 openssl_test` at commit `1d23c6f`: excluding `crypto/perlasm/**` removed the interactive stdin hang. Preparation completed and Xmake advanced to C compilation, where the deliberately broad source glob now fails normally at `apps/asn1parse.c` because `progs.h` is unavailable. The next experiment must narrow or exclude application sources; perlasm generation is no longer blocking progress.
- 2026-08-13 — `.\xmake.exe -vD -j1 openssl_test` at commit `49ed4a4`: Xmake's `**/*.[ch].in` character-class glob selected all 50 C/header templates and regenerated all 50 outputs with zero missing. `[ch]` is the correct single-character alternative; `[c|h]` would also admit a literal `|`. The complete target retained its independent post-preparation failure.
- 2026-08-13 — `.\xmake.exe -vD -j1 openssl_test` at commit `758bb4f`: the complete `**/*.c.in` and `**/*.h.in` glob union selected 10 C templates and 40 header templates, regenerated all 50 outputs, and left zero missing outputs. The former output-extension `if` is unnecessary; the complete target retained its separate post-preparation failure.
- 2026-08-13 — `.\xmake.exe -vD -j1 openssl_test` at commit `0f08bd0`: `mkbuildinf.pl` ran successfully immediately after `Configure` and before the first `dofile.pl` template invocation. The remaining preparation behavior was unchanged, confirming that build-info generation has no dependency on the generated-template loop.
- 2026-08-13 — `.\xmake.exe -vD -j1 openssl_test` at commit `a2362dd`: consolidating the repeated OpenSSL root and Perl executable expressions into `root` and `perl` preserved Configure, all 50 uniform template generations, build-info generation, and the unrestricted perlasm loop. The complete broad target retained its existing post-preparation failure; no new failure was introduced by the callback simplification.
- 2026-08-13 — `.\xmake.exe -vD -j1 openssl_test` at commit `0d6edea`: the unrestricted `**/*x86_64*.pl` loop appeared to complete in the non-interactive test environment because standard input was already at EOF. Later interactive validation showed that `crypto/perlasm/x86_64-xlate.pl` reads standard input until EOF and therefore hangs when it inherits a terminal. Its 64-byte output was only an empty-input NASM preamble, not a generated OpenSSL source; exclude `crypto/perlasm/**` declaratively.
- 2026-08-13 — `.\xmake.exe -vD -j1 openssl_test` at commit `6e93bad`: all 50 `.in` templates that produce C or header outputs completed with the uniform `-I. -Iutil/perl -Iproviders/common/der -Mconfigdata -MOpenSSL::paramnames -Moids_to_c` prefix; every expected output exists and was regenerated during the run. The complete experimental target still exited later in its intentionally broad perlasm/source experiment, so only the uniform template invocation is validated by this run.
- 2026-08-13 — `.\xmake.exe -vD -j1 openssl` at commit `8aa0c2a`: the migrated native `on_prepare` callback directly imported `core.project.depend`, called `os.vrunv` without injected arguments, completed the authoritative Configure/template/DER/perlasm generation, rebuilt the target, and archived `out/openssl.lib` successfully in 61.2 seconds. Restore the validated `openssl` target to disabled and return `openssl_test` to active pattern experimentation.
- 2026-08-13 — `.\xmake.exe -vD -j1 openssl` at commit `a7268d1`: Xmake stopped before target preparation because the validated `openssl` target was still disabled and therefore unavailable even by explicit name. Temporarily make `openssl` the sole active priority target before testing its native `on_prepare` migration.
- 2026-08-13 — `.\xmake.exe -vD -j1 openssl_test` at commit `c000c49`: the native target `on_prepare` callback directly exposed `os.vrunv` and successfully ran `perl Configure`, the broad `.in` template pass, `mkbuildinf.pl`, and the pattern-selected perlasm scripts without injected callback arguments. The complete experimental target still exited unsuccessfully after the generator pass; its broad generator/source patterns remain intentionally unvalidated and are separate from the callback-environment result.
- 2026-08-13 — isolated Xmake 3.1 environment probe: native target/rule hooks reported both `os.vrunv` and `import` as functions, while a function stored in custom `add_files` file configuration reported both names as `nil`. This confirms that the old adapter needed injection only because it stored a nested configuration-time closure; replacing it with native `on_prepare` removes that workaround.
- 2026-08-12 — `.\xmake.exe prepare` at commit `040a065`: completed the no-change repeat successfully in 0.671 seconds, retaining the pinned official libcurl source and validating preparation idempotence.
- 2026-08-12 — `.\xmake.exe prepare` at commit `6b62c7b`: after moving the previous prebuilt SDK directory out of `in/deps`, completed the clean official libcurl source preparation in 3.6 seconds. The recreated tree contains the complete upstream build metadata, and its hx marker records `github://curl/curl?ref=curl-8_21_0`. A no-change repeat is still required.
- 2026-08-12 — final clean `.\xmake.exe clean openssl` plus `.\xmake.exe -vD -j1 openssl` at commit `3cd23c7`: direct compilation, NASM assembly, and archive creation passed with no errors. The warning set is exactly C4133/C4244/C4267/C4319/C4334, matching the captured official `nmake` build; unity-only C4005/C4090/C4129/C4996/C5332 are absent. Fresh archive inspection reports 148 x64 members, 109 `MSVCRT` and zero `LIBCMT` directives, no exports or OpenSSL-family import thunks, and all representative crypto, TLS, default/legacy provider, and assembly symbols.
- 2026-08-12 — clean `.\xmake.exe clean openssl` plus `.\xmake.exe -vD -j1 openssl` at commit `8dc8e23`: build and archive succeeded with zero C4005, C4090, and C4996. The remaining warning-code delta against the official log is 25 C4129 plus two C5332 diagnostics; both indicate that Xmake's configured Windows path string literals contain single backslashes interpreted as C escape introducers. Encode literal doubled backslashes in `OPENSSLDIR`, `ENGINESDIR`, and `MODULESDIR` before final validation.
- 2026-08-12 — clean `.\xmake.exe clean openssl` plus `.\xmake.exe -vD -j1 openssl` at commit `3245381`: the target still builds and archives, and unity-only C4996 is gone, but Xmake's value-less `add_defines("OPENSSL_SUPPRESS_DEPRECATED")` emits a command-line definition with implicit value `1`. That differs from upstream's empty source-local definitions and causes 80 C4005 diagnostics, so this form is rejected; express the macro with an explicitly empty replacement before the next full test.
- 2026-08-12 — clean `.\xmake.exe clean openssl` plus `.\xmake.exe -vD -j1 openssl` at commit `6864988`: the 109-unit CT recoloring rebuilt and archived successfully with zero C4005 and zero C4090. It exposed C4996 diagnostics absent from the official build because unity header caching can precede the source-local `OPENSSL_SUPPRESS_DEPRECATED` definitions used throughout upstream OpenSSL. Apply that attribute-only suppression privately and uniformly to the target, then repeat the clean warning comparison.
- 2026-08-12 — clean `.\xmake.exe clean openssl` plus `.\xmake.exe -vD -j1 openssl` at commit `e870f8c`: all 39 NASM inputs and all 109 C unity/direct units rebuilt successfully and Xmake archived `out/openssl.lib`. No C4090 diagnostic remains. The C4133 sites match the official upstream `nmake` log, while the only Xmake-only diagnostics are C4005 macro redefinitions in CT colors 53–58 and 60; clean those seven unity boundaries before completing OpenSSL.
- 2026-08-12 — read-only archive validation after commit `c93e394`: `out/openssl.lib` contains 148 members, exactly 109 C unity/direct objects plus 39 NASM objects, and all 148 report x64 COFF headers. The 109 C members request `MSVCRT`; none requests `LIBCMT`. No `/EXPORT:` directive or OpenSSL-family `__imp_` thunk is present. Representative crypto, TLS, default/legacy provider, and assembly symbols are present. The official `openssl_build.txt` contains 77 C4133 warnings at the same atomic/refcount sites and no C4005/C4090 warning; run one clean serial Xmake build to review every remaining Xmake-only C4005 occurrence.
- 2026-08-12 — `.\xmake.exe -vD -j1 openssl` at commit `f2e7a21`: successful build and archive of `openssl.lib`. Terminal colors 107 and 108 removed the RSA/AES/DES failures and macro warnings, color 71 passed, and serial traversal completed every remaining unity group through 106. The build still reports MSVC C4133 warnings in upstream atomic/refcount sites; compare them with `openssl_build.txt`, then inspect archive CRT directives, exports/import thunks, representative crypto/TLS/provider symbols, and object count before declaring the target fully validated. The previously observed equivalent CT/common C4005 boundary warnings require a clean-build review because their objects were cached in this incremental success.
- 2026-08-12 — `.\xmake.exe -vD -j1 openssl` at commit `99ed6d0`: colors 11–70 compiled, reaching 74%. Color 71 failed because `rsa_sign.c` leaves ASN.1 tag macros defined before `extensions_clnt.c` includes X.509. Move `rsa_sign.c` and the compatible AES-local trio into terminal color 107, and move the DES unity set into terminal color 108 to remove its analogous `c2l`/`l2c` warning; the selected partition becomes 109 units. CT/common macro warnings in colors 53–60 are semantically equivalent boundary redefinitions and remain queued for final warning review.
- 2026-08-12 — `.\xmake.exe -vD -j1 openssl` at commit `c201327`: the default unit and colors 1, 10, and 100–106 compiled successfully. Color 11 then combined direct core user `gcm128.c` with provider cipher anchor `cipher_aes.c`, which includes the same unguarded `crypto/modes.h` through guarded `prov/ciphercommon.h`. Move the six core mode sources from provider-cipher colors 11–16 to non-cipher colors 44, 45, and 47–50 before continuing the serial traversal.
- 2026-08-12 — `.\xmake.exe -vD -j1 openssl` at commit `397b6ff`: state-machine, generated-DER, AES-local, and provider-cipher partitions passed. The default unit then exposed three indirect `providercommon.h` expansion units: one guarded digest-common unit and two textually included Blake2 MAC implementations. Blake2b and Blake2s must also remain separate but can share their corresponding MAC units, raising the exact lower bound to 107 units. The compile also exposed three colliding Windows key decoders, two ML `codecs` tables, two active x64 `NON_EMPTY_TRANSLATION_UNIT` seed sources, and `e_capi.c` versus `crypto/init.c`; use new colors 104–106 only for the unavoidable provider-common units and reuse 53–59 for the rest.
- 2026-08-12 — `.\xmake.exe -vD -j1 openssl` at commit `c31b9cc`: all record-method units passed and the default compile reached the final SSL/provider region. It exposed ten `statem_local.h` users, three generated DER `MD_CASE` macros, guarded AES macros contaminating later modes headers, and the complete unguarded AES-CBC-HMAC, AES-GCM-SIV, AES-XTS, ChaCha, TDES, DES, and SM4 implementation-header sets plus four persistent hardware-selection macro implementations. Reuse colors 39–46 and 70–99 to separate the observed sets before the next serial test.
- 2026-08-12 — `.\xmake.exe -vD -j1 openssl` at commit `64c320f`: all newly separated safe-math, X.509, and QUIC constraints passed before `dtls_meth.c`. Its `recmethod_local.h` still collided because earlier default source `quic_tls.c` intentionally defines its own incompatible `ossl_record_layer_st`; move `dtls_meth.c` to color 47 so all seven selected record methods are outside default.
- 2026-08-12 — `.\xmake.exe -vD -j1 openssl` at commit `141d37d`: the X.509 and policy header partitions passed. The default unit then reached SSL and exposed four typed safe-math cliques, residual X.509 `delete_ext`, small QUIC list/helper cliques, and seven selected users of unguarded `recmethod_local.h`; reuse sparse colors 48–69 for the independent crypto/QUIC constraints and colors 98–103 for six record methods while retaining compatible anchors in default.
- 2026-08-12 — `.\xmake.exe -vD -j1 openssl` at commit `734e38b`: the default unity unit passed the CT, STORE, and TS partitions, then exposed 24 selected users of unguarded `x509_local.h` and seven users of unguarded `pcy_local.h`, with `v3_cpols.c` in both sets. Keep one compatible anchor from each clique in default and reuse colors 1–23 for all other users before the next serial test.
- 2026-08-12 — `.\xmake.exe -vD -j1 openssl` at commit `0287807`: the complete 104-way `providercommon.h` partition passed the previous default-unit failures. The next default compile exposed five selected `store_local.h` users and nine selected `ts_local.h` users; its lone remaining CT source also redefined the `n2s`, `s2n`, and `l2n3` macros inherited from `internal/common.h`. Reuse colors 94–101 for the independent STORE and TS cliques and move `ct_b64.c` to color 60 before the next serial test.
- 2026-08-12 — `.\xmake.exe -vD -j1 openssl` at commit `9a77c17`: serial compilation attributed all first-wave failures to the default unity unit. The decisive constraint is 104 selected users of unguarded `providercommon.h`, establishing a new exact 104-unit lower bound. The same unit exposed smaller CMP/COMP/CT, engine-static, build-info, RC4, BIGNUM stack, RSA/SHA/SipHash macro, and SLH-DSA header conflicts; map the 104-user clique bijectively to default plus groups 1–103 and pack every smaller set into those colors before the next test.
- 2026-08-12 — `.\xmake.exe -vD openssl` at commit `02db927`: the authoritative `/W3 /wd4090` flags were present with `/MD /O2`, the DES group contained exactly the 19 configured sources without reintroducing excluded `ncbc_enc.c`, and the PKCS12 failure passed. The default unit next exposed four `provider_local.h` users, three `OSSL_PROVIDER` stack expansions, private `skip_dot` and `base` collisions, and duplicate `BIGNUM_const` stack expansions in `param_build_set.c` and `rsa_backend.c`; all can reuse colors 41–45. Parallel output also reported lhash/property header redefinitions even though each generated group contains only one direct user, so the next validation must run serially to attribute the first remaining edge accurately.
- 2026-08-12 — `.\xmake.exe -vD openssl` at commit `508346f`: OCSP and the five digest template implementations passed their previous conflicts. The default unit next exposed two `lhash_local.h` users, nine `p12_local.h` users, five selected `property_local.h` users, and a DES `ROTATE` macro collision with `md32_common.h`. C4090 warnings in `params_dup.c` also revealed that the target was missing upstream `VC-common`'s `/W3 /wd4090` flags; add the authoritative flags and reuse existing colors for all observed cliques.
- 2026-08-12 — `.\xmake.exe -vD openssl` at commit `a989f0d`: separating `o_names.c` removed both the `obj_local.h` and `init` conflicts. The default unit next exposed eight `ocsp_local.h` users and cross-algorithm `HASH_*` macro redefinitions among MD4, MD5, RIPEMD, SHA-1, and SM3. The `obj_dat.c:238` C4133 warning is also present in the captured upstream `nmake` log at the same line and is not unity-induced.
- 2026-08-12 — `.\xmake.exe -vD openssl` at commit `960295d`: the ML-DSA, ML-KEM, and modes partition passed the previously observed failures. The default unit next repeated unguarded `obj_local.h` between its two exact users, `obj_dat.c` and `o_names.c`; the latter also collided on its static `init` object with `evp/m_null.c`, so moving `o_names.c` to an existing color resolves both edges.
- 2026-08-12 — `.\xmake.exe -vD openssl` at commit `9d33479`: the 49-way EVP/error partition removed the previous header redefinitions while preserving `/MD /O2`. Xmake emitted wrappers only for groups with multiple sources and correctly compiled one-source groups directly. The remaining default unit exposed eight ML-DSA users of unguarded internal headers, a distinct ML-KEM `reduce_once`, and 17 selected direct users of unguarded `crypto/modes.h`; all fit within the existing 49-color lower bound.
- 2026-08-12 — `.\xmake.exe -vD openssl` at commit `432800b`: the DH, DSA, and encoder partitions passed their previous default-unit conflicts while all compile commands retained `/MD /O2`. Compilation then exposed five selected users of unguarded `err_local.h` and 49 selected users of unguarded `evp_local.h`; the latter raises the minimum partition to 49 groups, with `decoder_pkey.c` retaining its existing encoder-compatible group 2.
- 2026-08-12 — `.\xmake.exe -vD openssl` at commit `4d8ad3c`: the 27-group EC/DSO partition removed all previously observed conflicts and every command retained `/MD /O2`. The default unit next exposed cliques of 11 selected `dh_local.h` users, 12 `dsa_local.h` users, and six `encoder_local.h` users; all fit within the existing 27 groups.
- 2026-08-12 — `.\xmake.exe -vD openssl` at commit `acf2a15`: the callback-bearing `.in` entry worked as the target's first `add_files`, and all 26 BIO groups passed their previous ordering failure. The default unit then exposed 27 selected `ec_local.h` users, six `dso_local.h` users, plus private `hash_init_with_dom` and `dummy` collisions. Raise the proven partition lower bound to 27 and distribute these users through the existing groups.
- 2026-08-12 — `.\xmake.exe -vD openssl` at commit `8c06005`: the 17-way ASN.1/async lower-bound partition compiled its exception groups with `/MD /O2`. The remaining default unit then hit `bio_local.h`'s deliberate ordering error because another source had already included `internal/cryptlib.h`; all 26 BIO users share this unguarded header. Make one BIO source lead the default group and distribute the other 25 across distinct groups before the next test.
- 2026-08-12 — `.\xmake.exe -vD openssl` at commit `760d027`: Xmake invoked bundled NASM with the exact `-f win64` format and reached the initial 1,100-source C unity unit. Compilation then proved two unguarded internal-header cliques: 17 direct users of `asn1_local.h` and five users of `async_local.h` redefine their types and generated stack helpers. Partition those users into the 17-unit lower bound before continuing.
- 2026-08-12 — `.\xmake.exe -vD openssl` at commit `e7a224a`: all required Perl configuration and code generation completed, and Xmake directly invoked the bundled NASM for the declared assembly files. The custom assembler tool path did not infer an object format, so NASM defaulted to 16-bit mode and rejected x64 instructions. Add upstream's explicit `-f win64` before the next test.
- 2026-08-12 — `.\xmake.exe -vD openssl` at commit `0da7c35`: the callback successfully invoked `perl Configure`, which stopped at its own NASM availability check because Xmake's absolute assembler tool path is not inherited through `PATH`. Add Strawberry Perl's bundled `in/perl/c/bin` directory only to the Configure process environment; Xmake remains responsible for assembly.
- 2026-08-12 — `.\xmake.exe -vD openssl` at commit `65f2dd8`: dependency tracking reached the OpenSSL callback, but the stored file-configuration closure exposes filesystem helpers rather than `os.vrunv`. Pass the rule's verbose process runner into the target callback before attempting code generation again.
- 2026-08-12 — `.\xmake.exe -vD openssl` at commit `c5e978c`: MSVC configuration succeeded, then the generic file callback adapter failed before OpenSSL code generation because a stored file-configuration function does not inherit Xmake's global `import`. Pass the dependency module from the `cb` rule into the target callback for the next test.

- 2026-08-12 — `.\xmake.exe prepare` at commit `6bca1b1`: completed the no-change repeat successfully in 1.3 seconds, validating idempotence of the pinned official OpenSSL 3.5.7 input.
- 2026-08-12 — `.\xmake.exe prepare` at commit `efb786e`: after moving the previous `openssl-3.5` branch tree out of `in/deps`, completed a clean preparation in 8.1 seconds. The recreated official source reports release `3.5.7` with no prerelease tag and its hx marker records pinned ref `openssl-3.5.7`.
- 2026-08-12 — `.\xmake.exe -r -v` at commit `9955073`: built `out/liblzma.lib` successfully in 1.172 seconds from the upstream-default 79 sources in exactly five minimum unity units of 55, 10, 4, 3, and 7 sources, all with `/MD /O2`. COFF inspection found zero `/EXPORT:` directives, zero `__imp_lzma*` members, five `MSVCRT` directives, no `LIBCMT`, and the expected standard API symbols.
- 2026-08-12 — `.\xmake.exe -r -v` at commit `a335cb4`: all five units again compiled with `/MD /O2`; the default and fourth encoder-compatible groups passed, exposing the same internal header-type conflict inside group 1 between encoder users `lz_encoder.c`/`lzma2_encoder.c` and `lzma_decoder.c`. The latter has no private-name conflict with group 2 and can move there. `lzma2_decoder.c` cannot join that wider setting because it overlaps group 2 on `SEQ_PROPERTIES` and `SEQ_COPY`.
- 2026-08-12 — `.\xmake.exe -r -v` at commit `d717c1b`: generated and compiled the same five unity units with `/MD /O2`, but the default unit still combined `lz_decoder.h` and `lz_encoder.h`. Inspection of the generated unit found the remaining encoder-header users: direct user `lz/lz_encoder_mf.c` and indirect users `lzma_encoder_optimum_fast.c` and `lzma_encoder_optimum_normal.c` through `lzma_encoder_private.h`. They must join `lzma_encoder.c` in the existing encoder-compatible fourth group.
- 2026-08-12 — `xmake -r -v` at commit `8035fb6`: PowerShell could not resolve the bare `xmake` command, so the build did not start and produced no compiler result. The repository-local ignored `xmake.exe` is present; subsequent validation must invoke it explicitly as `.\xmake.exe`.
- 2026-08-12 — `xmake -r -v` at commit `ddac5e5`: the five derived unity groups eliminated the previously observed source-level private-symbol conflicts. Compilation then exposed one header-level conflict in the 60-source default group: `lz_decoder.h` and `lz_encoder.h` both define incompatible internal `lzma_lz_options` types. `lzma_encoder.c` can move into the existing encoder-compatible fourth exception group, preserving the proven five-unit minimum.
- 2026-08-12 — `xmake -r -v` at commit `695834b`: the complete liblzma source set reached MSVC in one unity translation unit with `/MD` and `/O2`, then failed on reused translation-unit-private names. Observed collisions include `SEQ_*` enumerators and distinct `lzma_alone_coder`, `lzma_block_coder`, `lzma_microlzma_coder`, and `lzma_stream_coder` types/functions across encoder, decoder, and multithreaded implementations. A symbol-conflict partition is required inside the same target.
- 2026-08-12 — `xmake -r -v` at commit `f5ea765`: rebuilt `out/bzip2.lib` successfully in 1.312 seconds after the source-selection cleanup. The generated unity file contained exactly the seven upstream library sources; broad `add_files("*.c")` plus five `remove_files` patterns excluded all six programs/tests correctly.
- 2026-08-12 — `xmake prepare` at commit `e5d4ecd`: after moving both `in/deps/xz` and the obsolete prebuilt `in/deps/liblzma` out of `in/deps`, completed a clean preparation in 2.1 seconds. The official GitHub XZ tree was recreated with the pinned `v5.8.3` marker, while the removed PHP SDK binary directory was not recreated.
- 2026-08-12 — `xmake prepare` at commit `e87ad12`: completed a no-change repeat successfully in 1.3 seconds, validating idempotence of the pinned official XZ source input.
- 2026-08-12 — `xmake prepare` at commit `7bad85f`: completed successfully in 2.0 seconds and materialized the official `tukaani-project/xz` tag `v5.8.3` in `in/deps/xz`. A no-change repeat is still required for the new input.
- 2026-08-12 — `xmake prepare` at commit `e4e0df8`: completed successfully in 1.4 seconds with the final authoritative-source policy. The official Sourceware bzip2 input was retained idempotently; the PHP SDK binary package is no longer part of `prepare`.
- 2026-08-12 — `xmake -r -v` at commit `dccf414`: built `out/bzip2.lib` successfully in 1.391 seconds. All seven upstream library sources compiled in one unity translation unit with `/MD`; Xmake's `set_optimize("fastest")` emitted `/O2` on MSVC.
- 2026-08-12 — `xmake prepare` at commit `5f134f4`: completed a no-change repeat successfully in 1.3 seconds. The pinned GitHub bzip2 source and every other current input were retained, validating idempotence.
- 2026-08-12 — `xmake prepare` at commit `60a2840`: completed successfully in 2.0 seconds and materialized `github://libarchive/bzip2?ref=bzip2-1.0.8` in `in/deps/bzip2`. A no-change repeat is still required to validate the new GitHub marker.
- 2026-08-12 — `xmake prepare` at commit `0af7160`: completed a no-change repeat successfully in 1.3 seconds. All existing inputs, including bzip2, were retained without redundant work, validating task idempotence for the current inventory.
- 2026-08-12 — `xmake prepare` at commit `a4ed100`: completed successfully in 3.1 seconds and extracted the official bzip2 1.0.8 tarball directly into `in/deps/bzip2`. A no-change repeat is still required to validate the new fetch's idempotence.
- 2026-08-12 — `xmake -r -v` at commit `9f8c33a`: rebuilt `out/zstd.lib` successfully in 0.891 seconds after restoring the upstream-compatible dynamic CRT. Every verbose MSVC compile command used `-MD` (equivalent to `/MD`), and none used `/MT`.
- 2026-08-12 — `xmake -r -v` at commit `43d46e7`: rebuilt `out/zstd.lib` successfully in 0.906 seconds. Every verbose MSVC compile command used `-MT` (equivalent to `/MT`), and none used `/MD`; the global static CRT selection is effective.
- 2026-08-12 — `xmake -r -v` at commit `b270cd4`: built `out/zstd.lib` successfully in 0.922 seconds, validating the one-target source list and the minimal unity exclusions. The verbose MSVC commands exposed Xmake's default `/MD` runtime, so the target must be rebuilt after selecting `set_runtimes("MT")` globally.

- 2026-08-12 — `xmake -r` at commit `a05d138`: confirmed that broad `add_files` plus narrower repeated file config deduplicates correctly; all seven legacy files compiled separately. The main zstd unity unit then failed because `cover.c` and `fastcover.c` both include the unguarded `cover.h`. FastCover was isolated for the next test.
- 2026-08-12 — `xmake -r` at commit `17a93d0`: forced a complete `brotli` rebuild after removing empty callbacks; `out/brotli.lib` built without warnings or errors in 0.906 seconds.
- 2026-08-12 — `xmake` at commit `a64db92`: built the complete single-target `out/brotli.lib` successfully with MSVC x64 in 0.921 seconds. The minimal three-unit partition compiled without warnings or errors.
- 2026-08-12 — `xmake` at commit `3e9fc34`: the complete single-target Brotli build reached compilation but one unity unit exposed private encoder symbol collisions (`Hash`, `IsMatch`, `ShouldCompress`, `SortHuffmanTree`, and `BrotliReverseBits`). The dependency remains one archive; sources were partitioned into the minimum three unity-compatible units for the next test.
- 2026-08-12 — `xmake` at commit `c33180e`: built the initial common-only Brotli target in one unity translation unit in 0.39 seconds. Per project policy, common/decoder/encoder are now being combined into one dependency target before full validation.
- 2026-08-12 — `xmake` at commit `8e0d4f8`: built `out/zlib.lib` successfully with MSVC x64 in 0.656 seconds. The explicit core unity group and isolated internal implementation sources compiled without warnings or errors.
- 2026-08-12 — `xmake` at commit `f48875c`: the separately compiled inflate sources succeeded, but the next arbitrary four-file batch combined `deflate.c` and multiple `gz*.c` files and failed on `GZIP`/`gz_state` redefinitions. Arbitrary batching was removed in favor of one explicit maximal compatible group.
- 2026-08-12 — `xmake` at commit `af8b0a4`: correctly selected only `zlib`, then failed in `unity_3.c`. `gzwrite.c` brings in a `COPY` macro that collides with the `inflate.h` enum; the three inflate implementation sources were excluded from unity batches for the next test.
- 2026-08-12 — `xmake prepare` at commit `0d2bf4c`: completed successfully after correcting the `ngtcp2` and `nghttp3` release refs. A repeat run is still required to prove idempotence.
- 2026-08-12 — `xmake prepare` at commit `fec296f`: stopped after the initial dependency downloads because the configured `ngtcp2` ref `v1.69.0` does not exist. Official release tags are `ngtcp2` `v1.25.0` and `nghttp3` `v1.18.0`; the pins were corrected for the next test.
- 2026-08-12 — `xmake` at commit `bc16350`: MSVC x64 detection succeeded and the `php` callback ran. The build stopped while compiling `Zend/zend.c` because `Zend/zend_config.h` has not been generated yet. The helper targets remain unvalidated by an isolated target build.
