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
| `zlib` | Disabled after test | FAIL | Preprocessor/type contamination across zlib components: repeated unguarded `gzguts.h`, `GZIP` macro collision, and `COPY`/other generic macros breaking `inflate.h`. |
| `brotli` | Disabled after test | FAIL | Multiple file-local collisions, mostly inside `c/enc/`; simple `common` / `dec` / `enc` directory partition is insufficient. |
| `zstd` | Disabled after test | FAIL | `dictBuilder` has an unguarded shared `cover.h`; legacy decoders embed historical FSE/HUF/ZSTD implementations that collide with current code and with each other. |
| `liblzma` | Disabled after test | FAIL | Widespread file-local enum/type/helper reuse inside `liblzma/common/`, including encoder/decoder pairs; even a directory-level `common` Unity unit is not viable. |
| `libssh2` | Enabled | PASS | 26 C sources compile as one `unity_1.c` / one object. |
| `nghttp2` | Disabled after test | FAIL | Duplicate file-local `VALID_AUTHORITY_CHARS` tables in `nghttp2_helper.c` and `nghttp2_http.c`. |
| `nghttp3` | Disabled after test | FAIL | Duplicate file-local `static int is_ws(uint8_t)` between the main library and bundled `sfparse`. Normal non-Unity build remains valid. |
| `ngtcp2` | Enabled | PASS | 48 C sources across the core and crypto directories compile as one `unity_1.c` / one object. |
| `libcurl` | Enabled | PASS | 192 C sources across libcurl's core and protocol subdirectories compile as one `unity_1.c` / one object. |
| `libuv` | Disabled after test | FAIL | Duplicate file-local Windows backend buffers: `uv_zero_` in pipe/tcp/udp and `uv_null_buf_` in pipe/tty. |
| `libsodium` | Disabled after test | FAIL | Alternative AEGIS-128L AES-NI and software backends reuse `aes_block_t`, AES macros, and shared static helper bodies inside the same algorithm directory. |
| `oniguruma` | Disabled after test | FAIL | Per-encoding implementation files deliberately reuse private helper/table names; generated gperf/unicode sources also reuse `hash` and generic macros. |
| `sqlite3` | N/A | SINGLE TU | The target is already the single upstream amalgamation source `sqlite3.c`; Unity would be a no-op. |
| `libpng` | Disabled after test | FAIL | Upstream `pngpriv.h` explicitly errors on duplicate inclusion; all 15 main library sources and both Intel C sources include it once per normal translation unit. |
| `libjpeg` | Disabled after test | FAIL | Baseline/lossless/progressive Huffman implementations reuse private state/helper names; `jchuff.c` also leaks the `emit_byte` macro into `jcmarker.c`. NASM remains correctly separate. |

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

## `zlib`

### Result

FAIL under full Unity. The target was tested by adding only `add_rules("c.unity_build")` to its existing `in/deps/zlib/*.c` source declaration.

Xmake generated a single `out/.gens/zlib/windows/unity_build/unity_1.c` containing all 15 selected C sources in this order:

```text
adler32.c
compress.c
crc32.c
deflate.c
gzclose.c
gzlib.c
gzread.c
gzwrite.c
infback.c
inffast.c
inflate.c
inftrees.c
trees.c
uncompr.c
zutil.c
```

The failure is not one isolated duplicate function. Several implementation components intentionally rely on being separate translation units and leak preprocessor/type state when concatenated.

### Collision 1: `GZIP`

`deflate.h` defines `GZIP` as a feature-presence macro when gzip support is enabled:

```text
in/deps/zlib/deflate.h:23
```

```c
#ifndef NO_GZIP
#  define GZIP
#endif
```

Later, `gzguts.h` uses the same identifier as a numeric state constant:

```text
in/deps/zlib/gzguts.h:167
```

```c
#define GZIP 2
```

In normal compilation these macros live in different translation units. In the generated Unity file `deflate.c` is included before the `gz*.c` files, so the macro from the deflate implementation is still active when `gzguts.h` is parsed. MSVC first reports `C4005: 'GZIP': macro redefinition`.

### Collision 2: unguarded `gzguts.h` and `gz_state`

`gzguts.h` intentionally has no whole-file include guard. At least these selected target sources include it independently:

```text
in/deps/zlib/gzclose.c:6
in/deps/zlib/gzlib.c:6
in/deps/zlib/gzread.c:6
in/deps/zlib/gzwrite.c:6
in/deps/zlib/zutil.c:10   (when not Z_SOLO)
```

The header defines an anonymous structure typedef ending at:

```text
in/deps/zlib/gzguts.h:203
```

```c
} gz_state;
```

That is valid when every source is compiled separately: each translation unit sees one independent definition. Full Unity includes `gzguts.h` repeatedly in the same translation unit, producing repeated incompatible typedef definitions and MSVC `C2371: 'gz_state': redefinition; different basic types`.

This means that even a proposed Unity partition containing all four `gz*.c` files together is not currently viable without changing the upstream header/source model. Splitting only by the obvious `gz*` filename family would therefore not be sufficient.

### Collision 3: generic gzip macros contaminate inflate implementation

`gzguts.h` also defines generic state macros:

```text
LOOK
COPY
GZIP
```

After the `gz*.c` includes, the same Unity translation unit reaches `inflate.h`, whose `inflate_mode` enum contains identifiers such as `COPY`, `TABLE`, `LEN`, `DONE`, `BAD`, and others. At least `COPY` has already become a macro, so preprocessing corrupts the enum declaration. The first compiler errors appear around:

```text
in/deps/zlib/inflate.h:36
in/deps/zlib/inflate.h:84
```

and then cascade through `infback.c` because `inflate_state` and its mode identifiers are no longer declared correctly.

### Natural partition hypotheses

zlib keeps nearly all implementation files in the same directory, so directory-based partitioning is not informative. The source architecture instead suggests logical component boundaries:

```text
Core / wrappers
    adler32.c
    compress.c
    crc32.c
    uncompr.c
    zutil.c   (but note that zutil.c also includes gzguts.h when not Z_SOLO)

Deflate side
    deflate.c
    trees.c

Inflate side
    infback.c
    inffast.c
    inflate.c
    inftrees.c

Gz file API
    gzclose.c
    gzlib.c
    gzread.c
    gzwrite.c
```

These are only architectural hypotheses, not validated Unity groups.

Important caveat: the `gz` component is itself not Unity-safe in the current upstream source because its files repeatedly include unguarded `gzguts.h`. Therefore a clean grouped solution may require either a deliberate upstream/source change to make that internal header Unity-safe, or leaving those sources as separate translation units. Merely assigning four directory/file groups in Xmake would not solve the underlying repeated typedef.

Likewise, the interaction between `zutil.c` and `gzguts.h` means the apparent logical boundaries need actual compilation tests before any grouped design is accepted.

### Current decision

Do not modify zlib sources or add `unity_group` / `unity_ignored` exceptions during the full-Unity survey. Leave `zlib` non-Unity after the failed test and record the component boundaries above for later investigation.

---

## `brotli`

### Result

FAIL under full Unity. The target was tested by adding only `add_rules("c.unity_build")` to its existing source declaration covering:

```text
in/deps/brotli/c/common/*.c
in/deps/brotli/c/dec/*.c
in/deps/brotli/c/enc/*.c
```

Xmake generated one `unity_1.c` for the complete C source batch. Compilation fails on multiple file-local helpers that deliberately reuse names in separate translation units.

### Main collision cluster: `compress_fragment.c` vs `compress_fragment_two_pass.c`

Both files live in the same natural component directory:

```text
in/deps/brotli/c/enc/compress_fragment.c
in/deps/brotli/c/enc/compress_fragment_two_pass.c
```

The first errors include these duplicate `static` helpers:

```text
Hash
    compress_fragment.c:32
    compress_fragment_two_pass.c:31

HashBytesAtOffset
    compress_fragment.c:37
    compress_fragment_two_pass.c:38

IsMatch
    compress_fragment.c:47
    compress_fragment_two_pass.c:47

BuildAndStoreCommandPrefixCode
    compress_fragment.c:117
    compress_fragment_two_pass.c:58

EmitInsertLen
    compress_fragment.c:170
    compress_fragment_two_pass.c:107

EmitCopyLen
    compress_fragment.c:219
    compress_fragment_two_pass.c:137

EmitCopyLenLastDistance
    compress_fragment.c:251
    compress_fragment_two_pass.c:160

EmitDistance
    compress_fragment.c:294
    compress_fragment_two_pass.c:199

BrotliStoreMetaBlockHeader
    compress_fragment.c:321
    compress_fragment_two_pass.c:211

RewindBitPosition
    compress_fragment.c:357
    compress_fragment_two_pass.c:543

EmitUncompressedMetaBlock
    compress_fragment.c:398
    compress_fragment_two_pass.c:551
```

The signatures are not always identical. For example:

```text
compress_fragment.c:32
    static BROTLI_INLINE uint32_t Hash(const uint8_t* p, size_t shift)

compress_fragment_two_pass.c:31
    static BROTLI_INLINE uint32_t Hash(const uint8_t* p, size_t shift, size_t length)
```

In separate translation units that is legal. In a single Unity translation unit the second definition collides with the first, and later calls bind to the wrong declaration and generate the cascade of argument-count/type errors.

`IsMatch` is also reused by another encoder file with a different signature:

```text
in/deps/brotli/c/enc/static_dict.c:36
```

so isolating only `compress_fragment_two_pass.c` would remove some errors but not prove that the rest of `enc/` is one safe Unity unit.

### Additional encoder-local collisions

`ShouldCompress` is independently defined in:

```text
in/deps/brotli/c/enc/compress_fragment_two_pass.c:526
in/deps/brotli/c/enc/encode.c:443
```

`SortHuffmanTree` is independently defined in:

```text
in/deps/brotli/c/enc/brotli_bit_stream.c:399
in/deps/brotli/c/enc/entropy_encode.c:45
```

These are further evidence that `c/enc/` as a whole is not full-Unity-safe.

### Cross-component collision: `BrotliReverseBits`

There is also a collision across the obvious decoder/encoder directory boundary:

```text
in/deps/brotli/c/dec/huffman.c:68
    static BROTLI_INLINE brotli_reg_t BrotliReverseBits(brotli_reg_t num)

in/deps/brotli/c/enc/entropy_encode.c:454
    static uint16_t BrotliReverseBits(size_t num_bits, uint16_t bits)
```

This specific collision would disappear if decoder and encoder sources were separate Unity units, but that split does not solve the numerous collisions already internal to `enc/`.

### Natural partition hypotheses

The source tree suggests the first-level component split:

```text
Unity candidate A: c/common/*.c
Unity candidate B: c/dec/*.c
Unity candidate C: c/enc/*.c
```

However, the full-Unity test proves candidate C is not viable as a single unit because `compress_fragment.c`, `compress_fragment_two_pass.c`, `encode.c`, `brotli_bit_stream.c`, `entropy_encode.c`, and `static_dict.c` contain overlapping file-local names.

A finer encoder partition could be hypothesized around algorithm implementations, for example keeping the two fragment encoders apart and separating entropy/bit-stream helpers where duplicate names are known. That would need a dedicated grouped-Unity experiment and should be based on real implementation boundaries rather than arbitrary file exceptions.

The earlier project experiments that used `unity_group` / `unity_ignored` are intentionally not reinstated here: this survey records why the complete target fails before deciding whether those historical partitions were actually minimal and principled.

### Current decision

Leave `brotli` non-Unity after this test. Do not rename upstream helpers or add Unity-specific file exceptions during the survey.

---

## `zstd`

### Result

FAIL under full Unity. The test added only `add_rules("c.unity_build")` to the existing target containing sources from:

```text
in/deps/zstd/lib/common/*.c
in/deps/zstd/lib/compress/*.c
in/deps/zstd/lib/decompress/*.c
in/deps/zstd/lib/dictBuilder/*.c
in/deps/zstd/lib/legacy/*.c
```

The failure contains two structurally different classes of collision.

### `dictBuilder`: repeated unguarded `cover.h`

Both dictionary-builder implementations include the same internal header:

```text
in/deps/zstd/lib/dictBuilder/cover.c:48
in/deps/zstd/lib/dictBuilder/fastcover.c:29
```

```c
#include "cover.h"
```

`cover.h` has no whole-file include guard and defines implementation types directly, including:

```text
in/deps/zstd/lib/dictBuilder/cover.h:27  COVER_best_s
in/deps/zstd/lib/dictBuilder/cover.h:44  COVER_segment_t
in/deps/zstd/lib/dictBuilder/cover.h:52  COVER_epoch_info_t
in/deps/zstd/lib/dictBuilder/cover.h:57  COVER_dictSelection
```

Normal compilation sees the header once in each separate translation unit. Full Unity includes `cover.c` and `fastcover.c` in one translation unit, so the header is parsed twice and MSVC reports structure/typedef redefinitions immediately.

Therefore `dictBuilder/*.c` is not, by itself, a valid single Unity group in the current upstream source.

### `legacy`: embedded historical implementations

The target includes seven legacy decoder sources:

```text
in/deps/zstd/lib/legacy/zstd_v01.c
in/deps/zstd/lib/legacy/zstd_v02.c
in/deps/zstd/lib/legacy/zstd_v03.c
in/deps/zstd/lib/legacy/zstd_v04.c
in/deps/zstd/lib/legacy/zstd_v05.c
in/deps/zstd/lib/legacy/zstd_v06.c
in/deps/zstd/lib/legacy/zstd_v07.c
```

These are not thin adapters. They contain historical copies of FSE, HUF, bitstream and ZSTD implementation details. When merged with the current implementation, the Unity translation unit reports collisions such as:

```text
FSE_CState_t
FSE_DState_t
FSE_decode_t
FSE_DTableHeader
FSE_readNCount
FSE_initDState
FSE_decodeSymbol
FSE_decodeSymbolFast
FSE_endOfDState
FSE_decompress_usingDTable_generic
HUF_CElt
nodeElt_s
ZSTD_copy4
ZSTD_copy8
ZSTD_wildcopy
seq_t
seqState_t
ZSTD_decodeSequence
ZSTD_execSequence
ZSTD_decompressSequences
ZSTD_decompressBlock
```

There are also many macro collisions (`FSE_*`, `HUF_*`, `ZSTD_VERSION_*`, `MINMATCH`, `MAX`, and others).

The legacy files collide not only with the modern `common` / `compress` / `decompress` implementation but also with each other. For example `zstd_v01.c` and `zstd_v02.c` both define historical FSE helpers such as `FSE_tableStep`, `FSE_buildDTable`, `FSE_abs`, and decompression functions.

This means a single directory-based group:

```text
Unity legacy = legacy/*.c
```

is itself invalid. Each historical decoder is effectively an implementation snapshot with its own private namespace only because it normally lives in a separate translation unit.

### Natural partition hypotheses

The top-level source tree suggests these real component boundaries:

```text
common/
compress/
decompress/
dictBuilder/
legacy/
```

but the full-Unity failure proves that simply making five Unity units is not sufficient:

- `dictBuilder/` already fails internally because `cover.c` and `fastcover.c` repeatedly include unguarded `cover.h`;
- `legacy/` fails internally because the versioned decoder files intentionally contain overlapping historical implementations.

A plausible future grouped strategy would first keep each legacy `zstd_v0*.c` separate from every other translation unit, then independently test whether `common`, `compress`, and `decompress` can each be unified or whether they also require finer component boundaries. `cover.c` and `fastcover.c` would likewise need to remain separate unless the upstream internal header model is deliberately made Unity-safe.

That is only an architectural hypothesis and is not applied during this survey.

### Current decision

Leave `zstd` non-Unity after the failed full-target test. Do not patch historical source names, add include guards to upstream internals, or recreate old `unity_ignored` exceptions merely to obtain a passing build.

---

## `liblzma`

### Result

FAIL under full Unity. The test added only `add_rules("c.unity_build")` to the existing target. Xmake generated one `unity_1.c` covering the selected C sources from `src/common` and the `liblzma/{common,check,delta,lz,lzma,rangecoder,simple}` components.

The first failures are already entirely inside `in/deps/xz/src/liblzma/common/`, so a simple one-Unity-per-directory strategy is insufficient.

### Reused file-local state names in encoder/decoder pairs

Several source pairs deliberately use the same private enum constants and coder type names because they normally compile as separate translation units.

`alone_decoder.c` and `alone_encoder.c` collide on:

```text
SEQ_CODE
    in/deps/xz/src/liblzma/common/alone_decoder.c:25
    in/deps/xz/src/liblzma/common/alone_encoder.c:24

lzma_alone_coder
    in/deps/xz/src/liblzma/common/alone_decoder.c:48
    in/deps/xz/src/liblzma/common/alone_encoder.c:29
```

The second type has a different private layout in encoder and decoder code, so once the names collide, later field accesses produce the expected cascade of invalid-member and wrong-call errors.

The same pattern appears in the block implementation:

```text
SEQ_CODE
    block_decoder.c:19
    block_encoder.c:27

SEQ_PADDING
    block_decoder.c:20
    block_encoder.c:28

SEQ_CHECK
    block_decoder.c:21
    block_encoder.c:29

lzma_block_coder
    block_decoder.c:53
    block_encoder.c:43
```

and in the MicroLZMA implementation:

```text
lzma_microlzma_coder
    microlzma_decoder.c:44
    microlzma_encoder.c:21
```

### Shared private helper name: `coder_find`

The filter implementations independently define a file-local helper named `coder_find`:

```text
in/deps/xz/src/liblzma/common/filter_decoder.c:157
in/deps/xz/src/liblzma/common/filter_encoder.c:200
```

Full Unity puts both bodies in one translation unit and MSVC reports a duplicate function body.

### Index implementation collisions

`index_decoder.c`, `index_encoder.c`, and `index_hash.c` reuse several generic state-enum identifiers, including:

```text
SEQ_INDICATOR
SEQ_COUNT
SEQ_UNPADDED
SEQ_UNCOMPRESSED
SEQ_PADDING_INIT
SEQ_PADDING
SEQ_CRC32
```

The encoder and decoder also define different private structures with the same name:

```text
lzma_index_coder
    index_decoder.c:52
    index_encoder.c:39
```

This makes a single `common/` Unity source impossible even if the earlier `alone` and `block` collisions were removed.

### Stream implementation collisions

`stream_decoder.c`, `stream_decoder_mt.c`, and `stream_encoder.c` independently use generic state identifiers such as:

```text
SEQ_STREAM_HEADER
SEQ_BLOCK_HEADER
SEQ_BLOCK_INIT
SEQ_STREAM_FOOTER
SEQ_STREAM_PADDING
```

There are also direct helper/type collisions:

```text
stream_decoder_reset
    stream_decoder.c:86
    stream_decoder_mt.c:935

lzma_stream_coder
    stream_decoder.c:82
    stream_encoder.c:57
```

Additional examples from the same full-Unity run include `SEQ_CODER_INIT` in `lzip_decoder.c` versus `alone_decoder.c`, and `HEADERS_BOUND` in `stream_buffer_encoder.c` versus `block_buffer_encoder.c`.

### Natural partition hypotheses

The physical source tree already separates broad subsystems (`common`, `check`, `delta`, `lz`, `lzma`, `rangecoder`, `simple`), but `common/` itself contains many paired encoder/decoder state machines that intentionally reuse private names. Therefore a directory-only grouping cannot be the final strategy.

A principled grouped-Unity experiment could instead follow implementation boundaries, keeping at least these families apart:

```text
alone decoder / alone encoder
auto decoder
block decoder / block encoder
filter decoder / filter encoder
index decoder / index encoder / index hash
microlzma decoder / microlzma encoder
stream decoder / stream decoder MT / stream encoder
```

The remaining `check`, `delta`, `lz`, `lzma`, `rangecoder`, and `simple` components would then need their own independent Unity tests rather than being assumed compatible.

Previous project experiments had already hinted that liblzma needed multiple Unity units. The current survey does not restore those historical groups: it records the concrete reasons first so any later partition can be justified from actual source boundaries rather than accumulated exceptions.

### Current decision

Leave `liblzma` non-Unity after this test. Do not rename private enums/types, patch upstream source, or add Unity-specific file exclusions during the survey.

---

## `nghttp2`

### Result

FAIL under full Unity. The target has 26 C sources under `in/deps/nghttp2/lib/*.c`; the test added only `add_rules("c.unity_build")`, producing one `unity_1.c`.

The first fatal error is a duplicate file-local lookup table:

```text
in/deps/nghttp2/lib/nghttp2_helper.c:685
    static char VALID_AUTHORITY_CHARS[] = { ... }

in/deps/nghttp2/lib/nghttp2_http.c:351
    static char VALID_AUTHORITY_CHARS[] = { ... }
```

The two tables are intentionally independent and are not identical in purpose: the HTTP-specific table notes that `@` is not allowed, while the general helper table backs `nghttp2_check_authority()`. Separate translation units give both objects internal linkage; full Unity places both definitions in one file scope and MSVC reports `C2374: redefinition; multiple initialization`.

The corresponding users are also local to their components:

```text
nghttp2_helper.c:752  nghttp2_check_authority()
nghttp2_http.c:418    static check_authority()
```

### Natural partition hypothesis

All target sources physically live in the same `lib/` directory, so there is no useful directory boundary. A semantic split that isolates `nghttp2_http.c` from the core/helper unit would certainly remove this known table collision:

```text
Unity candidate A: core library sources except nghttp2_http.c
Unity candidate B: nghttp2_http.c
```

That is only a first hypothesis. The remaining 25-source core group has not been tested independently, so additional private-name collisions may still exist. No per-file Unity exception is applied during this survey.

### Current decision

Leave `nghttp2` non-Unity after the test. Preserve the normal source list unchanged and revisit semantic grouping only after the full-target survey is complete.

---

## `libcurl`

### Result

PASS under full Unity. The existing target source batch spans libcurl's core implementation and protocol/platform subdirectories. Adding only `add_rules("c.unity_build")` produced one `out/.gens/libcurl/windows/unity_build/unity_1.c` containing **192** C source includes, compiled it as one object, and archived `libcurl.lib` successfully.

No `batchsize`, Unity group, ignored file, source rename, or source-list change was required. The full dependency closure rebuilt during the forced test, but the libcurl target itself was one Unity translation unit.

### Partitioning

No partition is currently needed. Keep full-target Unity enabled unless a later project-wide validation exposes an incremental, memory, or semantic issue not visible in this compile test.

---

## `libuv`

### Result

FAIL under full Unity. The test merged the existing `src/*.c` and `src/win/*.c` source batch into one `unity_1.c` and failed inside the Windows backend.

### Duplicate `uv_zero_`

Three independent Windows I/O implementations define the same private zero-size buffer:

```text
in/deps/libuv/src/win/pipe.c:39
    static char uv_zero_[] = "";

in/deps/libuv/src/win/tcp.c:38
    static char uv_zero_[] = "";

in/deps/libuv/src/win/udp.c:33
    static char uv_zero_[] = "";
```

Each object has internal linkage and is legal in its normal translation unit. Full Unity gives all three definitions one file scope, producing MSVC `C2374: 'uv_zero_': redefinition; multiple initialization`.

### Duplicate `uv_null_buf_`

The pipe and console implementations also independently define:

```text
in/deps/libuv/src/win/pipe.c:42
    static const uv_buf_t uv_null_buf_ = { 0, NULL };

in/deps/libuv/src/win/tty.c:76
    static const uv_buf_t uv_null_buf_ = { 0, NULL };
```

These collide for the same reason.

The compiler also reports `CTL_CODE`, `FILE_READ_ACCESS`, and `FILE_WRITE_ACCESS` macro redefinition warnings between libuv's `src/win/winapi.h` and the Windows SDK `winioctl.h`; these warnings are not the fatal blocker observed in this test, but they are another indication that include/preprocessor state changes when all Windows sources share a translation unit.

### Natural partition hypotheses

A first physical split:

```text
src/*.c
src/win/*.c
```

would not be sufficient because both fatal collision classes are already entirely inside `src/win/`.

The known collision graph suggests that these Windows backends cannot all share one Unity unit:

```text
pipe.c <-> tcp.c <-> udp.c    through uv_zero_
pipe.c <-> tty.c              through uv_null_buf_
```

A principled grouped experiment could therefore isolate the transport/terminal implementation files (`pipe.c`, `tcp.c`, `udp.c`, `tty.c`) from one another, while independently testing whether the remaining generic Windows backend sources can form a larger Unity unit. That is only a hypothesis; the remaining Windows sources have not yet been tested as an isolated group and may contain additional private-name collisions.

### Current decision

Leave `libuv` non-Unity after this test. Do not rename upstream private buffers or add per-file Unity exceptions during the survey.

---

## `libsodium`

### Result

FAIL under full Unity. The target recursively includes all 141 C sources under `src/libsodium`; adding only `add_rules("c.unity_build")` makes alternative implementation backends that are normally separate translation units share one file scope.

The first fatal collision is already inside the AEGIS-128L algorithm directory:

```text
in/deps/libsodium/src/libsodium/crypto_aead/aegis128l/aegis128l_aesni.c
in/deps/libsodium/src/libsodium/crypto_aead/aegis128l/aegis128l_soft.c
```

### Alternative backend type and macro collisions

The AES-NI source defines:

```text
aegis128l_aesni.c:32
    typedef __m128i aes_block_t;

aegis128l_aesni.c:33-38
    AES_BLOCK_XOR
    AES_BLOCK_AND
    AES_BLOCK_LOAD
    AES_BLOCK_LOAD_64x2
    AES_BLOCK_STORE
    AES_ENC
```

The software fallback defines the same private abstraction names with a different underlying type and different operations:

```text
aegis128l_soft.c:25
    typedef SoftAesBlock aes_block_t;

aegis128l_soft.c:26-31
    AES_BLOCK_XOR
    AES_BLOCK_AND
    AES_BLOCK_LOAD
    AES_BLOCK_LOAD_64x2
    AES_BLOCK_STORE
    AES_ENC
```

In normal compilation each backend gets its own private `aes_block_t` abstraction. Full Unity first reports `C2371: 'aes_block_t': redefinition; different basic types`, followed by the expected macro redefinition warnings and type-mismatch cascade.

### Shared implementation-header bodies

Both backend sources also define the same backend-local update helper and then include the same implementation header:

```text
aegis128l_aesni.c:41
    static inline void aegis128l_update(...)

aegis128l_soft.c:34
    static inline void aegis128l_update(...)

both include:
    aegis128l_common.h
```

`aegis128l_common.h` contains static implementation bodies parameterized by the backend's `aes_block_t` and AES macros, including functions such as:

```text
aegis128l_init
aegis128l_mac
aegis128l_absorb
aegis128l_absorb2
aegis128l_enc
```

Including that implementation header once per backend is intentional. Full Unity includes it twice in one translation unit under two incompatible backend macro/type environments, causing duplicate function bodies in addition to the type collision.

### Natural partition hypotheses

The source tree has strong algorithm/component directories, but this result proves that a simple "one Unity per algorithm directory" policy is not universally valid: a single algorithm directory may contain mutually exclusive or runtime-selected optimized backends.

For AEGIS-128L, the natural boundary is at least:

```text
AES-NI backend: aegis128l_aesni.c
software backend: aegis128l_soft.c
```

The public/dispatch source for the algorithm could potentially form another unit with compatible code, but that requires a dedicated grouped test. The same implementation pattern may occur in other libsodium algorithms with portable, SSE/AVX, AES-NI, or architecture-specific implementations, so a future grouped design should follow backend implementation boundaries rather than blindly grouping by directory.

### Current decision

Leave `libsodium` non-Unity after this test. Do not rename the backend abstraction, rewrite implementation headers, or exclude optimized backends merely to make a full-target Unity compile pass.

---

## `oniguruma`

### Result

FAIL under full Unity. All selected Oniguruma C sources physically live under `in/deps/libonig/src/`, but many are independent encoding implementations that deliberately reuse the same private names because they normally compile as separate translation units.

Representative direct collisions from the full-Unity compile include:

```text
is_valid_mbc_string
    big5.c:75
    euc_jp.c:60

CaseFoldMap
    cp1251.c:131
    iso8859_1.c:73
    iso8859_2.c:128
    iso8859_3.c:137
    iso8859_4.c:137
    iso8859_5.c:130
    iso8859_7.c:130
    iso8859_9.c:137
    iso8859_10.c:137
    iso8859_13.c:137
    iso8859_14.c:137
    iso8859_15.c:137
    iso8859_16.c:137
    koi8_r.c:130

mbc_case_fold
    euc_jp.c:155
    iso8859_1.c:224

is_code_ctype
    euc_jp.c:244
    iso8859_1.c:246

mbc_enc_len / code_to_mbclen / mbc_to_code / code_to_mbc /
left_adjust_char_head / is_allowed_reverse_match
    independently implemented by euc_jp.c and sjis.c

CR_Hiragana / CR_Katakana / PropertyList
    euc_jp.c and sjis.c, with some names also present in unicode_property_data.c

init
    ascii.c:33
    utf16_be.c:34

EncLen_UTF16
    utf16_be.c:79
    utf16_le.c:77
```

This is not accidental duplication: each encoding module provides similarly shaped private operations behind its exported encoding descriptor.

### Generated/gperf collisions

The generated property/fold sources also assume separate translation units. For example the EUC-JP and Shift-JIS gperf outputs both define a private `hash()` function, while `unicode_property_data.c`, `unicode_fold1_key.c`, `unicode_fold2_key.c`, `unicode_fold3_key.c`, and `unicode_unfold_key.c` reuse generic generated macros such as:

```text
TOTAL_KEYWORDS
MIN_WORD_LENGTH
MAX_WORD_LENGTH
MIN_HASH_VALUE
MAX_HASH_VALUE
```

Once merged, macro leakage also makes later generated calls bind to the wrong `hash` signature and produces cascading type/argument errors.

### Natural partition hypotheses

A directory split is useless because core code, encoding backends, and generated tables are all in `src/`. The source architecture suggests instead:

```text
Unity candidate: compatible regex/core engine sources
Separate TU or independently tested unit: each encoding backend (ascii, big5, euc_jp, sjis,
    iso8859_*, utf16_*, utf32_*, cp1251, koi8_r, etc.)
Separate generated units: property/fold/gperf-generated sources unless proven compatible
```

The repeated private API shape across encodings means combining many encoding files is fundamentally likely to collide; a useful grouped strategy would need to identify a compatible core subset rather than force the encoding implementations together.

### Current decision

Leave `oniguruma` non-Unity after this test. Do not rename upstream encoding helpers or generated symbols during the survey.

---

## `sqlite3`

### Result

N/A: the target already consists of exactly one C translation unit:

```text
in/deps/sqlite3/sqlite3.c
```

SQLite's amalgamation has already performed the source-merging role that Unity Build would otherwise provide. Xmake's Unity rule does not create a Unity file for a source batch containing only one source, so adding `c.unity_build` would not change compilation.

### Current decision

Keep the target unchanged and count it separately as **SINGLE TU**, not as a Unity PASS or FAIL.

---

## `libpng`

### Result

FAIL under full Unity by explicit upstream design. Adding only `add_rules("c.unity_build")` causes the generated Unity source to include more than one libpng implementation file, and the second implementation immediately triggers a deliberate `#error` in `pngpriv.h`.

The header states:

```text
in/deps/libpng/pngpriv.h:23-30
```

```c
/* pngpriv.h must be included first in each translation unit inside libpng. */
#ifndef PNGPRIV_H
#  define PNGPRIV_H
#else
#  error Duplicate inclusion of pngpriv.h; please check the libpng source files
#endif
```

This is stronger than an accidental duplicate-symbol problem: upstream explicitly requires `pngpriv.h` to be included once at the start of each libpng translation unit and treats a second inclusion in the same translation unit as a source error.

All 15 selected top-level library C sources include `pngpriv.h` directly:

```text
png.c
pngerror.c
pngget.c
pngmem.c
pngpread.c
pngread.c
pngrio.c
pngrtran.c
pngrutil.c
pngset.c
pngtrans.c
pngwio.c
pngwrite.c
pngwtran.c
pngwutil.c
```

and both selected Intel implementation sources include the same header through `../pngpriv.h`:

```text
intel/filter_sse2_intrinsics.c
intel/intel_init.c
```

Therefore the current 17-source target cannot combine any two of these ordinary implementation files into one Unity translation unit without changing the upstream private-header contract.

### Natural partition hypotheses

There is no useful multi-file Unity partition under the current source contract: because every selected C source includes `pngpriv.h`, every Unity unit containing two or more selected sources will hit the same deliberate duplicate-inclusion error.

A hypothetical source patch could redesign `pngpriv.h` for Unity use, but that would be an upstream-source semantic change and is outside this survey. Merely grouping by read/write/core/Intel directories cannot solve the explicit header check.

### Current decision

Leave `libpng` non-Unity. This target is best classified as **explicitly non-Unity-safe upstream**, rather than a candidate for Xmake-side grouping.

---

## `libjpeg`

### Result

FAIL for the complete C source batch. The target also contains x86-64 NASM sources; `c.unity_build` correctly leaves those assembly files as separate compilation units and merges only C. The generated `out/.gens/libjpeg/windows/unity_build/unity_1.c` contained 102 source includes from the target's C batch.

The first fatal collisions occur in libjpeg-turbo's independent Huffman entropy implementations.

### Baseline vs lossless Huffman encoder state

`jchuff.c` and `jclhuff.c` independently define private state types with the same names but different layouts:

```text
savable_state
    in/deps/libjpeg-turbo/src/jchuff.c:85
    in/deps/libjpeg-turbo/src/jclhuff.c:48

working_state
    in/deps/libjpeg-turbo/src/jchuff.c:124
    in/deps/libjpeg-turbo/src/jclhuff.c:109
```

Both names are intentionally file-local implementation details. Full Unity makes the second typedef a conflicting redefinition and subsequent code starts accessing fields from the wrong private structure.

The same two files also reuse private function names, including:

```text
dump_buffer
    jchuff.c:334
    jclhuff.c:223

flush_bits
    jchuff.c:481
    jclhuff.c:285

emit_restart
    jchuff.c:668
    jclhuff.c:300

finish_pass_huff
    jchuff.c:770
    jclhuff.c:422

finish_pass_gather
    jchuff.c:1116
    jclhuff.c:534
```

The decoder side follows the same architecture. For example `jdhuff.c` and `jdphuff.c` both define different private `savable_state` records (`jdhuff.c:43`, `jdphuff.c:44`). The compile reached the error limit before every decoder-side collision could be enumerated, so those families must be tested independently rather than assumed compatible.

### `emit_byte` preprocessor leakage into marker code

`jchuff.c` defines a function-like macro:

```text
in/deps/libjpeg-turbo/src/jchuff.c:325
#define emit_byte(state, val, action) ...
```

and `jclhuff.c` independently defines a similarly named macro at line 214.

Later in the Unity translation unit, `jcmarker.c` declares a real private function:

```text
in/deps/libjpeg-turbo/src/jcmarker.c:115
LOCAL(void)
emit_byte(j_compress_ptr cinfo, int val)
```

Because the earlier macro is still active, the preprocessor interprets this function declaration and its two-argument calls as invocations of the three-argument entropy macro. MSVC reports `C4003` and then a large cascade involving the entropy `working_state` fields instead of `jpeg_destination_mgr`.

This demonstrates that the failure is not merely duplicate C identifiers: source-local macro state is also intentionally scoped by normal translation-unit boundaries.

### Natural partition hypotheses

All core C sources are mostly in the same `src/` directory, so directory grouping is not useful. The implementation architecture suggests semantic families instead:

```text
compressor baseline Huffman      jchuff.c
compressor lossless Huffman      jclhuff.c
compressor progressive Huffman   jcphuff.c
compressor arithmetic            jcarith.c
compressor marker/output         jcmarker.c and related compressor core

decoder baseline Huffman         jdhuff.c
decoder lossless Huffman         jdlhuff.c
decoder progressive Huffman      jdphuff.c
decoder arithmetic               jdarith.c

shared/core and color/transform files: independently testable remainder
SIMD NASM: already separate by source kind
```

A later grouped-Unity experiment could test compatible remainder sets while keeping the entropy implementations and marker code across macro boundaries separate. This is only a source-architecture hypothesis; no grouping or ignored-file settings are added during the survey.

### Current decision

Leave `libjpeg` non-Unity after this test. Keep the NASM configuration unchanged and do not rename upstream private state/functions or add macro cleanup solely for Unity.

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
