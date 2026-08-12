# Build Roadmap

Last updated: 2026-08-12

## Current State

- [x] Initialize the Git repository and ignore downloaded sources, tools, caches, and outputs.
- [x] Add an idempotent-oriented `prepare` task for sources, binary dependencies, Perl, MSVC, and the Windows SDK.
- [x] Add the `cb` rule skeleton for target-owned code generation.
- [x] Define the `minilua` and `gen_ir_fold_hash` helper targets.
- [x] Record the known PHP code-generation inventory in `AGENTS.md`.
- [ ] Validate the current Xmake configuration and helper targets.
- [ ] Normalize every target to the intended declarative form with one target-specific `cb` callback and no unrelated Lua helpers or state.
- [ ] Replace the placeholder callback and object-only `php` prototype.

## Next Target

Integrate `zlib` as the first dependency target:

- [ ] Inspect its Windows source/configuration requirements and source exclusions.
- [ ] Add one static-library target with the broadest safe source pattern.
- [ ] Attach any configuration generation to one target-owned `cb` callback.
- [ ] Enable a safe unity-build batch and resolve symbol collisions explicitly.
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

No Xmake test has been run from the documented repository state yet. Commit the current changes before the first test, as required by `AGENTS.md`.
