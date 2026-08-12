# Build Roadmap

Last updated: 2026-08-12

## Current State

- [x] Initialize the Git repository and ignore downloaded sources, tools, caches, and outputs.
- [x] Add an idempotent-oriented `prepare` task for sources, binary dependencies, Perl, MSVC, and the Windows SDK.
- [x] Complete one successful `xmake prepare` run with all currently pinned inputs.
- [x] Repeat `xmake prepare` with every current input present and validate idempotence.
- [x] Add the `cb` rule skeleton for target-owned code generation.
- [x] Define the `minilua` and `gen_ir_fold_hash` helper targets.
- [x] Record the known PHP code-generation inventory in `AGENTS.md`.
- [x] Disable non-priority targets by default so focused builds only exercise the target under integration.
- [x] Build and archive `out/zlib.lib` successfully with MSVC x64.
- [x] Build and archive the complete single-target `out/brotli.lib` successfully with MSVC x64.
- [ ] Validate the current Xmake configuration and helper targets.
- [x] Remove empty and placeholder callbacks; only targets with real codegen/configuration work may attach a `cb` callback.
- [x] Follow upstream Windows PHP and select the dynamic multithreaded MSVC CRT globally with `set_runtimes("MD")` for loadable-extension compatibility.
- [x] Verify a forced zstd build uses `/MD` in every MSVC compile command.
- [ ] Replace the object-only `php` prototype and add its real `cb` callback when PHP codegen is implemented.

## Completed Target: zlib

`zlib` is the first validated dependency target:

- [x] Inspect upstream `CMakeLists.txt` and `win32/Makefile.msc` for exact sources, Windows defines, output naming, configuration, and optional assembly.
- [x] Add one static-library target with the broadest safe source pattern.
- [x] Confirm that shipped Windows configuration needs no zlib codegen and therefore no `cb` callback.
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
- [x] Add broad source patterns and no `cb` callback because the upstream library has no build-time codegen.
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

## Next Target: OpenSSL

- [x] Replace the moving official `openssl-3.5` branch with the pinned official `openssl-3.5.7` LTS release tag.
- [x] Remove `in/deps/openssl` and validate the pinned source fetch from a clean absence.
- [x] Repeat `xmake prepare` with every input present to validate idempotence.
- [x] Inspect upstream Configure/build metadata and Windows notes for the exact crypto/SSL source set, generated files, assembly, public/private defines, providers, and system libraries.
- [x] Implement OpenSSL code generation with `perl Configure` and the required Perl generators only; do not invoke `nmake` from the target callback.
- [x] Declare all selected C and generated assembly sources directly in Xmake and let Xmake perform compilation, NASM assembly, and archiving.
- [x] Add one static OpenSSL dependency target; the configured closure contains no source compiled with incompatible duplicate settings.
- [x] Validate that the Xmake source declaration matches the configured 1,100-C plus 39-assembly upstream closure exactly.
- [ ] Resolve only observed unity-build conflicts and retain the fewest widest groups.
- [ ] Validate the standard public OpenSSL interface and inspect the resulting archive symbol/directive surface.
- [ ] Build and record the validation result before moving to libcurl/libssh2/libsodium.

## Dependency Targets

Every library must receive its own static target. Integrate and validate them one at a time in dependency order.

- [x] Foundation compression: zlib, Brotli, zstd, bzip2, liblzma.
- [ ] Cryptography and transport: OpenSSL, libcurl, libssh2, libsodium.
- [ ] HTTP/async: libuv, nghttp2, nghttp3, ngtcp2.
- [ ] Data/text: ICU, libiconv, libintl, libxml2, libxslt, Oniguruma, SQLite, LMDB, QDBM.
- [ ] Database/directory clients: PostgreSQL, Firebird, OpenLDAP.
- [ ] Image/font stack: FreeType, libjpeg-turbo, libpng, libtiff, libwebp, libavif, libheif, libjxl, libultrahdr, libxpm.
- [ ] Remaining libraries: Apache support files, GLib, Argon2, Enchant, libffi, SASL, Tidy, libzip, MPIR, Net-SNMP, WinEditLine.
- [ ] Document exact target names, source patterns, dependencies, defines, unity groups, and validation status as each target lands.

## PHP Code Generation

- [ ] Make Bison and RE2C available through `xmake prepare`.
- [ ] Generate the Zend, PHPDBG, and JSON parsers with Bison.
- [ ] Generate all inventoried scanners with RE2C.
- [ ] Generate Windows message resources with `mc`.
- [ ] Build and invoke `minilua` programmatically for DynASM output.
- [ ] Build and invoke `gen_ir_fold_hash` programmatically with redirected input/output.
- [ ] Generate PHP Windows configuration headers/defines using Xmake detection APIs.
- [ ] Consolidate all PHP generation into the single `php` target callback.

## PHP Target and Final Link

- [ ] Add broad Zend, main, TSRM, SAPI, extension, and selected external source patterns.
- [ ] Keep PHP extensions inside the PHP target rather than creating extension targets.
- [x] Select the upstream-compatible dynamically linked multithreaded MSVC CRT globally with `set_runtimes("MD")`.
- [ ] Decide and configure PHP ZTS versus NTS independently of the MSVC CRT selection.
- [ ] Add the widest safe unity-build groups and document necessary exclusions.
- [ ] Connect all dependency targets in correct link order.
- [ ] Produce the final PHP executable/library artifacts.
- [ ] Run a basic CLI smoke test and record the resulting PHP version and enabled modules.

## Validation Log

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
