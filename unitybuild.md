# Unity Build Validation

This file records the Unity Build experiments for the dependency targets in `xmake.lua`.

The purpose is diagnostic, not to force every dependency to support Unity Build. Each target is tested incrementally with the smallest possible Xmake change:

```lua
add_rules("c.unity_build")
```

With no `batchsize`, `unity_group`, or `unity_ignored` options, Xmake's default `c.unity_build` combines the complete `c.build` source batch into one unity translation unit. This is the mode being tested here.

Do not alter a target's real source list, rename upstream symbols, add Unity exclusions, or split the target merely to make a test pass. When full Unity fails, record the concrete collision first. Possible Unity partitions may be documented as hypotheses, but they are not considered fixes until separately tested and justified.

## Status

| Target | Full Unity | Result | Notes |
| --- | --- | --- | --- |
| `wineditline` | Enabled | PASS | 3 C sources compile as one `unity_1.c` / one object. |
| `bzip2` | Enabled | PASS | 7 library C sources compile as one `unity_1.c` / one object after the target's normal `remove_files()` exclusions. |
| `nghttp3` | Disabled after test | FAIL | Duplicate file-local `static int is_ws(uint8_t)` between the main library and bundled `sfparse`. Normal non-Unity build remains valid. |

---

## `wineditline`

### Result

PASS.

Target declaration:

```text
xmake.lua:1423
```

Unity is enabled with only:

```lua
add_rules("c.unity_build")
```

Sources:

```text
in/deps/wineditline/src/editline.c
in/deps/wineditline/src/fn_complete.c
in/deps/wineditline/src/history.c
```

Xmake generates one unity source containing all three files and compiles one object. No source-level collision has been observed.

### Partitioning

None required or proposed. The complete target works as one Unity translation unit.

---

## `bzip2`

### Result

PASS.

Target declaration:

```text
xmake.lua:64
```

Unity is enabled with only:

```lua
add_rules("c.unity_build")
```

The target keeps its normal source declaration and its normal non-Unity exclusions:

```lua
add_files("in/deps/bzip2/*.c")
remove_files(...)
```

The resulting Unity translation unit contains all seven actual library sources:

```text
in/deps/bzip2/blocksort.c
in/deps/bzip2/bzlib.c
in/deps/bzip2/compress.c
in/deps/bzip2/crctable.c
in/deps/bzip2/decompress.c
in/deps/bzip2/huffman.c
in/deps/bzip2/randtable.c
```

Xmake generates one `unity_1.c`, compiles one object, and archives `bzip2.lib` successfully.

### Partitioning

None required or proposed. The complete target works as one Unity translation unit.

---

## `nghttp3`

### Result

FAIL under full Unity. The `c.unity_build` line was removed again after diagnosis so the target remains buildable normally.

The normal non-Unity target was rebuilt after the experiment and succeeds.

The target source declaration is structurally simple:

```lua
add_files(
    "in/deps/nghttp3/lib/*.c",
    "in/deps/nghttp3/lib/sfparse/sfparse.c"
)
```

This yields 32 C sources in the target:

- 31 sources directly under `in/deps/nghttp3/lib/`;
- 1 source under `in/deps/nghttp3/lib/sfparse/`: `sfparse.c`.

Full Unity places all 32 in the same generated translation unit. In the failed generated file:

```text
out/.gens/nghttp3/windows/unity_build/unity_1.c:10
    #include ".../in/deps/nghttp3/lib/nghttp3_http.c"

out/.gens/nghttp3/windows/unity_build/unity_1.c:32
    #include ".../in/deps/nghttp3/lib/sfparse/sfparse.c"
```

### Collision: `is_ws`

Both source files define the same file-local function:

```text
in/deps/nghttp3/lib/nghttp3_http.c:124
```

```c
static int is_ws(uint8_t c) {
  switch (c) {
  case ' ':
  case '\t':
    return 1;
  default:
    return 0;
  }
}
```

and:

```text
in/deps/nghttp3/lib/sfparse/sfparse.c:100
```

```c
static int is_ws(uint8_t c) {
  switch (c) {
  case ' ':
  case '\t':
    return 1;
  default:
    return 0;
  }
}
```

In the normal build these definitions are legal because each `static` function has internal linkage in a different translation unit.

Full Unity changes the compilation model to approximately:

```c
#include "nghttp3_http.c"
...
#include "sfparse/sfparse.c"
```

Both definitions therefore appear in the same translation unit and the compiler reports a redefinition (`MSVC C2084`). This is a source-level full-Unity incompatibility, not a failure of Xmake's grouping logic.

### Natural partition hypothesis

The source-tree boundary suggests a very simple possible two-part Unity layout:

```text
Unity A
    in/deps/nghttp3/lib/*.c
    31 main nghttp3 sources

Unity B
    in/deps/nghttp3/lib/sfparse/*.c
    target currently uses only sfparse/sfparse.c
```

This partition would isolate the two known `is_ws` definitions, so it would remove this specific collision without arbitrary per-file exceptions.

It is only a hypothesis at this stage:

- it has not been enabled in `xmake.lua`;
- it has not been validated as a complete Unity solution;
- the 31 main `lib/*.c` files may contain additional file-local collisions that only appear once this first error is removed;
- because the target currently uses only one C file from `sfparse/`, the second partition would effectively remain a standalone translation unit rather than gaining Unity compilation benefits.

If grouped Unity is considered later, this directory boundary is preferable to ad-hoc `unity_ignored` entries because it corresponds to a real bundled component boundary: the main `nghttp3` implementation versus the separately maintained `sfparse` implementation.

### Other possible approaches, not applied

1. Patch upstream/local source names, for example rename one `is_ws`. This would make full Unity possible for this particular collision but modifies dependency source solely for Unity and is therefore not currently acceptable.
2. Use `unity_ignored` for `sfparse.c` or `nghttp3_http.c`. This would avoid the collision but is an ad-hoc exception and is intentionally not used in the current validation phase.
3. Use explicit Unity groups. The directory-based split above is the only currently plausible grouping worth investigating because it reflects an actual component boundary. It must still be validated rather than assumed correct.
4. Leave `nghttp3` non-Unity. This is currently the working configuration.

---

## Procedure for the next targets

For each target:

1. Confirm the existing non-Unity target is already valid.
2. Add only:

   ```lua
   add_rules("c.unity_build")
   ```

3. Force a rebuild of that target.
4. Verify that Xmake generated one Unity source for the complete C source batch.
5. If it passes, record the source count and result here.
6. If it fails, stop at the first concrete error and record:
   - symbol/macro/type involved;
   - every conflicting source file and line;
   - source directories/components involved;
   - why separate translation units were valid before Unity;
   - whether a natural directory/component partition is visible;
   - whether that partition is merely plausible or has actually been tested.
7. Do not add Unity-specific workarounds to `xmake.lua` until the conflict has been understood and a deliberate strategy has been chosen.
