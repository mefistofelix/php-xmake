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
- [x] Validate that the Xmake source declaration matches the configured 1,100-C plus 39-assembly upstream closure exactly.
- [x] Resolve only observed unity-build conflicts and retain the fewest widest groups.
- [x] Validate the standard public OpenSSL interface and inspect the resulting archive symbol/directive surface.
- [x] Build and record the validation result before moving to libcurl/libssh2/libsodium.

## Next Target: libcurl

- [x] Verify the official `curl/curl` tag `curl-8_21_0`, matching the previous PHP SDK dependency version.
- [x] Replace the prebuilt SDK archive with the pinned official source and validate `xmake prepare` from a clean absence and on a no-change repeat.
- [ ] Inspect upstream CMake/Makefile metadata and PHP's curl configuration for exact library sources, exclusions, generated inputs, public/private defines, protocols, TLS backend, compression dependencies, and Windows system libraries.
- [ ] Add one static libcurl target using direct Xmake compilation and the fewest widest unity groups justified by observed conflicts.
- [ ] Build and validate `/MD`, the static public interface, archive architecture, and representative curl symbols before moving to libssh2.

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
- [ ] Consolidate all PHP generation into the single `php` target `on_prepare` callback.

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
