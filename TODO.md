# Build Roadmap

Last updated: 2026-08-12

## Current State

- [x] Initialize the Git repository and ignore downloaded sources, tools, caches, and outputs.
- [x] Add an idempotent-oriented `prepare` task for sources, binary dependencies, Perl, MSVC, and the Windows SDK.
- [x] Complete one successful `xmake prepare` run with all currently pinned inputs.
- [ ] Repeat `xmake prepare` to validate idempotence after the build-target work advances.
- [x] Add the `cb` rule skeleton for target-owned code generation.
- [x] Define the `minilua` and `gen_ir_fold_hash` helper targets.
- [x] Record the known PHP code-generation inventory in `AGENTS.md`.
- [x] Disable non-priority targets by default so focused builds only exercise the target under integration.
- [x] Build and archive `out/zlib.lib` successfully with MSVC x64.
- [x] Build and archive the complete single-target `out/brotli.lib` successfully with MSVC x64.
- [ ] Validate the current Xmake configuration and helper targets.
- [x] Remove empty and placeholder callbacks; only targets with real codegen/configuration work may attach a `cb` callback.
- [ ] Replace the object-only `php` prototype and add its real `cb` callback when PHP codegen is implemented.

## Completed Target: zlib

`zlib` is the first validated dependency target:

- [x] Inspect upstream `CMakeLists.txt` and `win32/Makefile.msc` for exact sources, Windows defines, output naming, configuration, and optional assembly.
- [x] Add one static-library target with the broadest safe source pattern.
- [x] Confirm that shipped Windows configuration needs no zlib codegen and therefore no `cb` callback.
- [x] Use one maximal explicit unity group for compatible core sources; isolate only `zutil.c`, `gz*.c`, and `inf*.c`, whose unguarded internal headers and macros require separate translation units.
- [x] Build and record the validation result before moving to the next dependency.

## Completed Target: Brotli

Integrate Brotli after analyzing its upstream build structure:

- [x] Inspect upstream CMake/Bazel build files for component libraries, exact sources, generated inputs, defines, include paths, and dependencies.
- [x] Map upstream common, decoder, and encoder components into one `brotli` target; do not create preventive sublibrary targets.
- [x] Add broad patterns for all three component directories; no callback is needed because Brotli has no build-time codegen.
- [x] Put the complete dependency in one unity translation unit for the first full build.
- [x] Keep one `brotli` target and split compilation into the minimum three units required by the observed private-symbol conflict graph.
- [x] Build and record the validation result before moving to zstd.

## Next Target

Integrate zstd as one dependency target:

- [ ] Inspect upstream CMake/Makefiles for exact library sources, exclusions, Windows defines, generated inputs, assembly/intrinsics, and feature toggles.
- [ ] Keep all upstream components in one `zstd` target unless a concrete target-level constraint proves otherwise.
- [ ] Add the broadest source patterns and no `cb` callback unless real codegen/configuration work exists.
- [ ] Attempt one unity translation unit first; partition only on demonstrated conflicts.
- [ ] Build and record the validation result before moving to bzip2.

## Dependency Targets

Every library must receive its own static target. Integrate and validate them one at a time in dependency order.

- [ ] Foundation compression: zlib, Brotli, zstd, bzip2, liblzma.
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
- [ ] Define the intended static, multithreaded build flags and runtime linkage.
- [ ] Add the widest safe unity-build groups and document necessary exclusions.
- [ ] Connect all dependency targets in correct link order.
- [ ] Produce the final PHP executable/library artifacts.
- [ ] Run a basic CLI smoke test and record the resulting PHP version and enabled modules.

## Validation Log

- 2026-08-12 — `xmake` at commit `a64db92`: built the complete single-target `out/brotli.lib` successfully with MSVC x64 in 0.921 seconds. The minimal three-unit partition compiled without warnings or errors.
- 2026-08-12 — `xmake` at commit `3e9fc34`: the complete single-target Brotli build reached compilation but one unity unit exposed private encoder symbol collisions (`Hash`, `IsMatch`, `ShouldCompress`, `SortHuffmanTree`, and `BrotliReverseBits`). The dependency remains one archive; sources were partitioned into the minimum three unity-compatible units for the next test.
- 2026-08-12 — `xmake` at commit `c33180e`: built the initial common-only Brotli target in one unity translation unit in 0.39 seconds. Per project policy, common/decoder/encoder are now being combined into one dependency target before full validation.
- 2026-08-12 — `xmake` at commit `8e0d4f8`: built `out/zlib.lib` successfully with MSVC x64 in 0.656 seconds. The explicit core unity group and isolated internal implementation sources compiled without warnings or errors.
- 2026-08-12 — `xmake` at commit `f48875c`: the separately compiled inflate sources succeeded, but the next arbitrary four-file batch combined `deflate.c` and multiple `gz*.c` files and failed on `GZIP`/`gz_state` redefinitions. Arbitrary batching was removed in favor of one explicit maximal compatible group.
- 2026-08-12 — `xmake` at commit `af8b0a4`: correctly selected only `zlib`, then failed in `unity_3.c`. `gzwrite.c` brings in a `COPY` macro that collides with the `inflate.h` enum; the three inflate implementation sources were excluded from unity batches for the next test.
- 2026-08-12 — `xmake prepare` at commit `0d2bf4c`: completed successfully after correcting the `ngtcp2` and `nghttp3` release refs. A repeat run is still required to prove idempotence.
- 2026-08-12 — `xmake prepare` at commit `fec296f`: stopped after the initial dependency downloads because the configured `ngtcp2` ref `v1.69.0` does not exist. Official release tags are `ngtcp2` `v1.25.0` and `nghttp3` `v1.18.0`; the pins were corrected for the next test.
- 2026-08-12 — `xmake` at commit `bc16350`: MSVC x64 detection succeeded and the `php` callback ran. The build stopped while compiling `Zend/zend.c` because `Zend/zend_config.h` has not been generated yet. The helper targets remain unvalidated by an isolated target build.
