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
- [ ] Validate the current Xmake configuration and helper targets.
- [x] Normalize every current target to the intended declarative form with one target-specific `cb` callback and no unrelated Lua helpers or state.
- [ ] Replace the placeholder callback and object-only `php` prototype.

## Next Target

Integrate `zlib` as the first dependency target:

- [x] Inspect its Windows source/configuration requirements and source exclusions.
- [x] Add one static-library target with the broadest safe source pattern.
- [x] Attach its target-owned `cb` callback to `zutil.c`; no zlib code generation is currently required.
- [x] Keep four-file C unity batches while isolating `infback.c`, `inffast.c`, and `inflate.c`, which are not unity-safe because of internal-header and macro collisions.
- [ ] Build and record the validation result before moving to the next dependency.

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

- 2026-08-12 — `xmake` at commit `af8b0a4`: correctly selected only `zlib`, then failed in `unity_3.c`. `gzwrite.c` brings in a `COPY` macro that collides with the `inflate.h` enum; the three inflate implementation sources were excluded from unity batches for the next test.
- 2026-08-12 — `xmake prepare` at commit `0d2bf4c`: completed successfully after correcting the `ngtcp2` and `nghttp3` release refs. A repeat run is still required to prove idempotence.
- 2026-08-12 — `xmake prepare` at commit `fec296f`: stopped after the initial dependency downloads because the configured `ngtcp2` ref `v1.69.0` does not exist. Official release tags are `ngtcp2` `v1.25.0` and `nghttp3` `v1.18.0`; the pins were corrected for the next test.
- 2026-08-12 — `xmake` at commit `bc16350`: MSVC x64 detection succeeded and the `php` callback ran. The build stopped while compiling `Zend/zend.c` because `Zend/zend_config.h` has not been generated yet. The helper targets remain unvalidated by an isolated target build.
