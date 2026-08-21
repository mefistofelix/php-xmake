# php-xmake

Windows-only work in progress for building TrueAsync PHP with a compact `xmake.lua`, static third-party libraries, and the dynamic multithreaded MSVC runtime (`/MD`). The current ZTS checkpoint builds all three Windows executables with the mandatory modules, Opcache/JIT, and builtin `ctype`, `calendar`, `tokenizer`, `filter`, `session`, `bcmath`, `PDO`, `exif`, `bz2`, `gettext`, and `iconv`. Optional extensions are added in small validated batches.

The required patched Xmake bundle is included as `xmake.exe` in the repository root. Its source, tests, and detailed patch documentation are maintained in [mefistofelix/xmake-patched](https://github.com/mefistofelix/xmake-patched).

The patches provide:

- lazy Windows IDL and generated-source discovery;
- lazy toolchain setup and selected-target configuration pruning;
- incremental `add_files` source materialization and dependency-aware `build_callback` jobs;
- faster no-change dependency checks.

Build the default dependency stack from PowerShell:

```powershell
.\xmake.exe
```

Build the minimal ZTS CLI and its shared PHP core with:

```powershell
.\xmake.exe build php-cli
.\out\php.exe -n -v
```

Build the console-less Windows CLI with:

```powershell
.\xmake.exe build php-win
```

Build the CGI/FastCGI executable with:

```powershell
.\xmake.exe build php-cgi
```

See [AGENTS.md](AGENTS.md) for build policy and target details, [TODO.md](TODO.md) for current progress, and [unitybuild.md](unitybuild.md) for Unity Build validation results.
