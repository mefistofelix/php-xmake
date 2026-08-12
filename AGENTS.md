# Project Guidance

## Goal

Build PHP on Windows with a minimal `xmake.lua`. The finished build must be static and use parallel compilation.

Keep this file and `TODO.md` clear, organized, written in English, and synchronized with the implementation.

## Supported Environment

- Support Windows only for now; do not add cross-platform branches prematurely.
- Prefer relative paths throughout the build.
- Prefer Xmake built-in placeholders and platform/toolchain queries for architecture-dependent values such as `x64`, Windows paths, type sizes, and compiler properties.
- The supported workflow is:

  ```text
  xmake prepare
  xmake
  ```

- `xmake prepare` is run manually before the main build and must be idempotent. It downloads and extracts source trees, prebuilt dependencies, and required external tools.

## Target Model

- Before converting a dependency, inspect its original non-Xmake build system (`CMakeLists.txt`, configure scripts, Makefiles, Visual Studio projects, or equivalent). Treat it as the primary source for the exact source list and exclusions, generated files, platform defines, include paths, output names, runtime flags, optional assembly, and dependency edges. Record the relevant findings in this file before the first build attempt so Xmake conversion is guided by upstream intent instead of trial and error.
- Keep `xmake.lua` primarily declarative: it should consist of Xmake configuration, target declarations, and one target-specific `cb` callback function per target.
- Do not add arbitrary Lua helper functions, tables, aliases, or variables. Introduce Lua state only when an Xmake API requires it and no direct declarative expression is practical; keep such state local to the owning task or target callback.
- A target's `cb` function is its single imperative entry point for configuration and code generation. Do not split target preparation across extra Lua functions.
- Give every library dependency its own static-library target.
- PHP extensions are part of the main PHP target; do not create a separate target for each extension.
- Add source files with the broadest safe patterns, ideally at dependency or PHP-tree scope.
- Prefer one unity translation unit containing all of a target's sources. Do not choose arbitrary batch sizes. Split into the fewest and widest explicit unity groups only when observed symbol, macro, header, or compiler conflicts prove that a single translation unit is impossible; isolate only the incompatible files.
- Build the project incrementally, one target at a time, starting with dependencies and ending with the complete PHP target.
- Keep only the current priority target active during focused build/debug cycles. Use `set_enabled(false)` to remove unrelated or unfinished targets completely. Use `set_default(false)` when a target must remain available for an explicit build or as a dependency but should not join the default build. Re-enable a target when it becomes the priority or a dependency of the priority target.

## Code Generation

- Run every required code-generation step from a callback supplied by the `cb` rule.
- Use exactly one target-specific callback per target. Attach it as file configuration to the single most appropriate source entry for that target; that callback owns all generated sources, headers, and configuration files for the target.
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
| `zlib` | Enabled (current priority) | Static library | `in/deps/zlib/*.c` | `out/zlib.lib` | First compression dependency | One maximal core unity group; incompatible internal sources isolated; rebuild pending |
| `minilua` | Disabled | Binary | `in/php-src/ext/opcache/jit/ir/dynasm/minilua.c` | `out/minilua.exe` | Runs DynASM for the PHP JIT IR emitter | Defined; build validation pending |
| `gen_ir_fold_hash` | Disabled | Binary | `in/php-src/ext/opcache/jit/ir/gen_ir_fold_hash.c` | `out/gen_ir_fold_hash.exe` | Generates the JIT IR fold hash header | Defined; build validation pending |
| `php` | Disabled | Object prototype | `in/php-src/Zend/zend.c`, `in/php-src/Zend/asm/*_xmm_x86_64_ms_masm.asm` | `out/` | Becomes the static PHP build after dependency, configuration, codegen, and source integration | Prototype only; callback is a placeholder |

The `prepare` task fetches dependencies. Each library must receive its own Xmake static-library target as it is integrated; downloaded or prebuilt archives are not yet build targets.

The zlib target uses one explicit unity group for `adler32.c`, `compress.c`, `crc32.c`, `deflate.c`, `trees.c`, and `uncompr.c`. It compiles `zutil.c`, all `gz*.c` files, and all `inf*.c` files separately. `gzguts.h`, `inflate.h`, and `inftrees.h` are internal headers without conventional guards; repeated inclusion redefines types, and `gzguts.h` also exposes `COPY` and `GZIP` macros that collide with the deflate/inflate implementation. These observed conflicts make those sources unsafe in a shared translation unit.

### zlib upstream build analysis

- Upstream version: zlib 1.3.2.
- `CMakeLists.txt` and `win32/Makefile.msc` agree on the same 15 root C sources; the Xmake wildcard covers exactly that set.
- The upstream static CMake target defines `ZLIB_BUILD`, `NO_FSEEKO` when the probe fails on MSVC, `_CRT_SECURE_NO_DEPRECATE`, and `_CRT_NONSTDC_NO_DEPRECATE`. It does not enable Unix large-file or hidden-visibility defines on Windows.
- The shipped root `zconf.h` already contains the Windows configuration used by the MSVC Makefile, so the zlib callback has no generation work.
- The MSVC Makefile names the static result `zlib.lib`. CMake uses `zs.lib`; this project keeps `zlib.lib` to match the native MSVC convention and the target name.
- The MSVC Makefile declares optional x86/x64 assembly rules but leaves `OBJA` empty. Upstream CMake also leaves contrib acceleration disabled by default, so the initial target intentionally compiles no assembly.

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
