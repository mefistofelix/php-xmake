# Proposal: make `platform.windows.idl` lazy and stop forcing source expansion during `config`

## Summary

The built-in Windows IDL rule currently calls `target:sourcebatches()` from its `on_config` path only to determine whether the target contains an `.idl` source before adding the IDL autogen include directory.

That call has an unexpectedly large side effect: `target:sourcebatches()` materializes `target:sourcefiles()`, which expands every `add_files()` pattern in the target and caches the result. Because Xmake configures every enabled target before the build action traverses the requested target and its dependency graph, this forces source glob expansion for targets that may never be built and, more importantly, freezes missing generated-source globs before target-selective prepare/codegen has a chance to create them.

The proposed fix is to make the IDL configuration fully lazy:

1. remove the IDL `on_config` callback;
2. move the IDL autogen include-directory setup into the existing `before_build_files` callback;
3. keep `target:add("includedirs", autogendir, {public = true})` there;
4. remove the `target:sourcebatches()` test from `idl.configure()`, because `before_build_files` is already called with the actual IDL `sourcebatch` and therefore proves that IDL inputs exist.

This keeps the existing IDL generation/build machinery and its public include path, but only touches the target after Xmake has selected the build graph and after Xmake already knows that this target has an IDL source batch.

The problem and proposed fix were reproduced on Windows x64 with:

```text
xmake v3.1.0+HEAD.96ad28edb
```

Line numbers below refer to that revision and may move slightly on `master`.

---

## Relevant Xmake source

The behavior involves these files:

- `xmake/rules/platform/windows/idl/xmake.lua`
- `xmake/rules/platform/windows/idl/idl.lua`
- `xmake/modules/private/utils/target.lua`
- `xmake/modules/private/action/build/target.lua`
- `xmake/actions/build/main.lua`
- `xmake/core/project/target.lua`

Upstream locations:

- https://github.com/xmake-io/xmake/blob/master/xmake/rules/platform/windows/idl/xmake.lua
- https://github.com/xmake-io/xmake/blob/master/xmake/rules/platform/windows/idl/idl.lua
- https://github.com/xmake-io/xmake/blob/master/xmake/modules/private/utils/target.lua
- https://github.com/xmake-io/xmake/blob/master/xmake/modules/private/action/build/target.lua
- https://github.com/xmake-io/xmake/blob/master/xmake/actions/build/main.lua
- https://github.com/xmake-io/xmake/blob/master/xmake/core/project/target.lua

---

## Current implementation

### `xmake/rules/platform/windows/idl/xmake.lua`

At lines 20-30 in the tested revision:

```lua
rule("platform.windows.idl")
    set_extensions(".idl")
    on_config("windows", "mingw", function (target)
        import("idl").configure(target)
    end)
    before_build_files(function (target, jobgraph, sourcebatch, opt)
        import("idl").generate_idl(target, jobgraph, sourcebatch, opt)
    end, {jobgraph = true, batch = true})
    on_build_files(function (target, jobgraph, sourcebatch, opt)
        import("idl").build_idlfiles(target, jobgraph, sourcebatch, opt)
    end, {jobgraph = true, batch = true, distcc = true})
```

### `xmake/rules/platform/windows/idl/idl.lua`

At lines 100-107:

```lua
function configure(target)
    local sourcebatch = target:sourcebatches()["platform.windows.idl"]
    if sourcebatch then
        local autogendir = path.join(target:autogendir(), "platform/windows/idl")
        os.mkdir(autogendir)
        target:add("includedirs", autogendir, {public = true})
    end
end
```

The only information taken from `sourcebatches()` here is whether this rule has a source batch. The function does not inspect the IDL filenames, output files, per-file configuration, or build state.

The actual IDL source batch is already available later as an argument to `before_build_files` and `on_build_files`.

---

## Why the current call is problematic

`target:sourcebatches()` is not a cheap rule-presence query. It requires the source list.

The effective call chain is:

```text
platform.windows.idl:on_config
    -> idl.configure(target)
        -> target:sourcebatches()
            -> target:sourcefiles()
                -> expand add_files() patterns
                -> os.files(...)
                -> cache the matched source paths
```

I instrumented `target:sourcefiles()` and confirmed that the first source-list materialization in the reproduction came from this exact IDL configuration path.

The relevant stack was:

```text
target:sourcefiles()
target:sourcebatches()
rules/platform/windows/idl/idl.lua: configure()
rules/platform/windows/idl/xmake.lua: on_config
modules/private/utils/target.lua: config_target()
modules/private/utils/target.lua: config_targets()
config action
```

---

## Why this occurs before build-graph pruning

### Global target configuration

In `xmake/modules/private/utils/target.lua`, lines 214-220 of the tested revision:

```lua
function config_targets(opt)
    opt = opt or {}
    for _, target in ipairs(table.wrap(project.ordertargets())) do
        if target:is_enabled() then
            config_target(target, opt)
        end
    end
end
```

`config_target()` then runs every rule's `before_config`, `on_config`, and `after_config` callbacks.

Therefore `platform.windows.idl:on_config` is invoked for every enabled target that owns the Windows platform rule, whether or not that target belongs to the build requested on the command line.

### Build action order

In `xmake/actions/build/main.lua`, lines 157-184 of the tested revision:

```lua
function main(opt)
    ...
    project.lock()

    local targetnames, group_pattern = action_utils.get_targets_and_group()
    task.run("config", {}, {disable_dump = true})

    ...
    build_targets(targetnames, {group_pattern = group_pattern})
```

So the build action knows the requested root target names, but the global `config` task is completed before `build_targets()` constructs the actual build graph.

### Actual dependency pruning happens later

In `xmake/modules/private/action/build/target.lua`, lines 349-373:

```lua
function add_targetjobs_and_deps(jobgraph, target, targetrefs, opt)
    local targetname = target:fullname()
    if not targetrefs[targetname] then
        targetrefs[targetname] = target
        add_targetjobs(jobgraph, target, opt)
        for _, depname in ipairs(target:get("deps")) do
            local dep = project.target(depname, {namespace = target:namespace()})
            add_targetjobs_and_deps(jobgraph, dep, targetrefs, opt)
            _add_targetjobs_plain_orders(jobgraph, target, dep, opt)
        end
        ...
    end
end

function get_targetjobs(targets_root, opt)
    local jobgraph = async_jobgraph.new(opt.job_kind)
    local targetrefs = {}
    for _, target in ipairs(targets_root) do
        add_targetjobs_and_deps(jobgraph, target, targetrefs, opt)
    end
    return jobgraph
end
```

This is the point where Xmake does the expected pruning: it starts from the requested root targets and recursively adds only their dependencies.

The current IDL `on_config` source query bypasses that laziness by materializing source lists before this traversal happens.

---

# Reproduction: current behavior breaks prepare-time generated source globs

The following self-contained test has three enabled targets:

```text
bar -> dep
foo        (unrelated)
```

`bar`, `dep`, and `foo` all declare a generated-source glob. A target-level prepare rule generates the source only for targets participating in the selected build graph.

## `xmake.lua`

```lua
set_toolchains("msvc")
set_runtimes("MD")

rule("generate.selected")
    on_prepare(function (target)
        local dir = path.join("generated_repro", target:name())
        print("GENERATE " .. target:name())
        os.mkdir(dir)
        io.writefile(
            path.join(dir, target:name() .. ".c"),
            "int generated_" .. target:name() .. "(void) { return 1; }\n")
    end, {jobgraph = true})
rule_end()

target("dep")
    set_kind("static")
    add_rules("generate.selected")
    add_files("dep.c")
    add_files("generated_repro/dep/*.c")

target("bar")
    set_kind("static")
    add_deps("dep")
    add_rules("generate.selected")
    add_files("bar.c")
    add_files("generated_repro/bar/*.c")

target("foo")
    set_kind("static")
    add_rules("generate.selected")
    add_files("foo.c")
    add_files("generated_repro/foo/*.c")
```

With initially absent `generated_repro/`, run:

```text
xmake build -v bar
```

## Observed output with the current built-in IDL rule

The prepare callback is correctly pruned to the requested graph:

```text
GENERATE bar
GENERATE dep
```

There is no:

```text
GENERATE foo
```

That part is exactly the desired lazy behavior.

However, only the ordinary sources are compiled:

```text
<bar> compiling.release bar.c
<dep> compiling.release dep.c
```

The generated `bar.c` and `dep.c` exist on disk after prepare, but are not compiled in this invocation.

At the end Xmake reports:

```text
warning: ... cannot match add_files("generated_repro\dep\*.c") in target(dep)
warning: ... cannot match add_files("generated_repro\bar\*.c") in target(bar)
warning: ... cannot match add_files("generated_repro\foo\*.c") in target(foo)
```

The third warning is particularly revealing: `foo` is not part of `bar`'s dependency graph and its prepare callback did not run, but its generated-source glob was nevertheless inspected during configuration.

The sequence is therefore effectively:

```text
config all enabled targets
    -> platform.windows.idl:on_config
        -> target:sourcebatches()
            -> expand generated_repro/dep/*.c  (missing)
            -> expand generated_repro/bar/*.c  (missing)
            -> expand generated_repro/foo/*.c  (missing)
            -> cache empty matches

build requested root bar
    -> traverse bar -> dep
    -> prepare bar
        -> create generated_repro/bar/bar.c
    -> prepare dep
        -> create generated_repro/dep/dep.c
    -> build using source matches already materialized during config
```

This is surprising because the build graph itself already performs the correct pruning, but the source lists have been forced earlier by a platform rule unrelated to these generated C files.

---

# Behavior after removing only the premature IDL source query

For the same no-IDL reproduction, I shadowed `platform.windows.idl` with an otherwise empty rule containing only its `.idl` extension, which removes the configuration-time `target:sourcebatches()` call without changing the test's codegen logic:

```lua
rule("platform.windows.idl")
    set_extensions(".idl")
rule_end()
```

Again starting with `generated_repro/` absent:

```text
xmake build -v bar
```

The selected prepare callbacks remain:

```text
GENERATE bar
GENERATE dep
```

and `foo` still does not run.

But now the same invocation compiles the generated sources:

```text
<bar> compiling.release generated_repro\bar\bar.c
<dep> compiling.release generated_repro\dep\dep.c
```

and both archives include the generated objects.

There are no missing-glob warnings for the unrelated `foo` target because its source list is never needed by this build.

This demonstrates that the rest of the build graph already has the intended lazy/pruned behavior. The premature IDL `on_config` source query is what causes the source lists to be materialized globally.

---

# Proposed lazy implementation

The existing IDL file rule already has exactly the information needed to avoid the query: `before_build_files` receives the IDL `sourcebatch`.

If this callback is being executed for `platform.windows.idl`, the existence test currently performed by:

```lua
target:sourcebatches()["platform.windows.idl"]
```

has already been satisfied by Xmake itself.

The include path can therefore be configured at that point, immediately before scheduling MIDL generation.

## Change 1: `xmake/rules/platform/windows/idl/xmake.lua`

### Current lines 20-30

```lua
rule("platform.windows.idl")
    set_extensions(".idl")
    on_config("windows", "mingw", function (target)
        import("idl").configure(target)
    end)
    before_build_files(function (target, jobgraph, sourcebatch, opt)
        import("idl").generate_idl(target, jobgraph, sourcebatch, opt)
    end, {jobgraph = true, batch = true})
    on_build_files(function (target, jobgraph, sourcebatch, opt)
        import("idl").build_idlfiles(target, jobgraph, sourcebatch, opt)
    end, {jobgraph = true, batch = true, distcc = true})
```

### Proposed replacement

```lua
rule("platform.windows.idl")
    set_extensions(".idl")
    before_build_files(function (target, jobgraph, sourcebatch, opt)
        local idl = import("idl")
        idl.configure(target)
        idl.generate_idl(target, jobgraph, sourcebatch, opt)
    end, {jobgraph = true, batch = true})
    on_build_files(function (target, jobgraph, sourcebatch, opt)
        import("idl").build_idlfiles(target, jobgraph, sourcebatch, opt)
    end, {jobgraph = true, batch = true, distcc = true})
```

The important changes are:

- delete the current `on_config("windows", "mingw", ...)` block at lines 22-24;
- invoke `idl.configure(target)` at the start of the already existing `before_build_files` callback at lines 25-27;
- keep IDL generation immediately after configuration in the same callback.

No new lifecycle hook is required.

## Change 2: `xmake/rules/platform/windows/idl/idl.lua`

### Current lines 100-107

```lua
function configure(target)
    local sourcebatch = target:sourcebatches()["platform.windows.idl"]
    if sourcebatch then
        local autogendir = path.join(target:autogendir(), "platform/windows/idl")
        os.mkdir(autogendir)
        target:add("includedirs", autogendir, {public = true})
    end
end
```

### Proposed replacement

```lua
function configure(target)
    local autogendir = path.join(target:autogendir(), "platform/windows/idl")
    os.mkdir(autogendir)
    target:add("includedirs", autogendir, {public = true})
end
```

There is no longer a reason for `configure()` to query the source graph. Its caller is the `platform.windows.idl` `before_build_files` callback and already has a non-empty IDL source batch.

---

# Complete proposed diff

```diff
--- a/xmake/rules/platform/windows/idl/xmake.lua
+++ b/xmake/rules/platform/windows/idl/xmake.lua
@@
 rule("platform.windows.idl")
     set_extensions(".idl")
-    on_config("windows", "mingw", function (target)
-        import("idl").configure(target)
-    end)
     before_build_files(function (target, jobgraph, sourcebatch, opt)
-        import("idl").generate_idl(target, jobgraph, sourcebatch, opt)
+        local idl = import("idl")
+        idl.configure(target)
+        idl.generate_idl(target, jobgraph, sourcebatch, opt)
     end, {jobgraph = true, batch = true})
     on_build_files(function (target, jobgraph, sourcebatch, opt)
         import("idl").build_idlfiles(target, jobgraph, sourcebatch, opt)
     end, {jobgraph = true, batch = true, distcc = true})
```

```diff
--- a/xmake/rules/platform/windows/idl/idl.lua
+++ b/xmake/rules/platform/windows/idl/idl.lua
@@
 function configure(target)
-    local sourcebatch = target:sourcebatches()["platform.windows.idl"]
-    if sourcebatch then
-        local autogendir = path.join(target:autogendir(), "platform/windows/idl")
-        os.mkdir(autogendir)
-        target:add("includedirs", autogendir, {public = true})
-    end
+    local autogendir = path.join(target:autogendir(), "platform/windows/idl")
+    os.mkdir(autogendir)
+    target:add("includedirs", autogendir, {public = true})
 end
```

---

# Why the lazy version should preserve IDL behavior

The proposed patch changes when the include-directory setup is performed, but not what the IDL rule generates or how it builds those generated files.

The existing flow is:

```text
config target
    -> inspect full source graph
    -> if IDL batch exists:
        -> create autogen directory
        -> add autogen directory as public include

later, for selected target:
    -> before_build_files(IDL sourcebatch)
        -> schedule MIDL generation
    -> on_build_files(IDL sourcebatch)
        -> build generated C files
```

The proposed flow is:

```text
select requested target + dependency graph
    -> discover actual source batches for selected targets
    -> before_build_files(IDL sourcebatch)
        -> create autogen directory
        -> add autogen directory as public include
        -> schedule MIDL generation
    -> on_build_files(IDL sourcebatch)
        -> build generated C files
```

The condition is equivalent:

```text
current:
    if target:sourcebatches()["platform.windows.idl"] then ...

proposed:
    before_build_files for platform.windows.idl was called
    therefore the IDL sourcebatch already exists
```

The proposed version simply lets the file-rule dispatch itself provide the existence test instead of asking the entire target source graph during global configuration.

---

# Public include propagation was tested with the lazy timing

The main compatibility concern with moving `target:add("includedirs", ..., {public = true})` later is whether a dependent target still sees that public include directory.

I tested the same lifecycle with a small custom file rule that behaves like the proposed IDL rule:

1. a dependency target owns a custom source extension;
2. its `before_build_files(..., {jobgraph = true})` callback adds an autogen include directory with `{public = true}`;
3. the same callback adds a generation job that creates a header in that directory;
4. an executable depends on the library and includes that generated header.

The relevant rule was:

```lua
rule("lazy.idlmock")
    set_extensions(".idlmock")
    before_build_files(function (target, jobgraph, sourcebatch, opt)
        local autogendir = path.join(target:autogendir(), "idlmock")
        target:add("includedirs", autogendir, {public = true})

        for _, sourcefile in ipairs(sourcebatch.sourcefiles) do
            jobgraph:add(target:fullname() .. "/generate/" .. sourcefile, function ()
                os.mkdir(autogendir)
                io.writefile(
                    path.join(autogendir, "generated_api.h"),
                    "#define GENERATED_VALUE 42\n")
            end)
        end
    end, {jobgraph = true, batch = true})
rule_end()
```

The dependent application's compile command contained the dependency's dynamically added public include path:

```text
cl.exe ... -I..\out\.gens\dep\windows\x64\release\idlmock ... main.c
```

The application included the generated header:

```c
#include "generated_api.h"

int main(void) {
    return GENERATED_VALUE == 42 ? 0 : 1;
}
```

The first build succeeded from an initially absent generated header.

This validates two important properties of the proposed timing:

- the include directory added from `before_build_files(..., {jobgraph = true})` is visible to a dependent target through `{public = true}`;
- the generation job is ordered early enough for the dependent compile job to consume the generated header.

An actual MIDL regression test should still be added upstream, but this removes the main lifecycle concern about moving the public include setup out of `on_config`.

---

# Suggested upstream regression tests

## Test 1: generated-source glob must remain lazy until selected-target prepare

This is the regression test for the bug itself.

Use the three-target reproduction shown above:

```text
bar -> dep
foo        unrelated
```

Start with all generated directories absent and run:

```text
xmake build bar
```

### Expected behavior after the patch

- prepare/codegen runs for `bar` and `dep`;
- prepare/codegen does not run for `foo`;
- `generated_repro/bar/bar.c` is compiled in the same invocation;
- `generated_repro/dep/dep.c` is compiled in the same invocation;
- Xmake does not inspect or warn about `generated_repro/foo/*.c`, because `foo` is outside the selected build graph.

This test protects the important invariant that an unrelated platform rule must not force global source matching before the target graph is pruned.

## Test 2: normal IDL generation

Create a Windows target with a real `.idl` input and verify that:

- MIDL runs;
- the generated header is emitted under `target:autogendir()/platform/windows/idl`;
- `_i.c`, `_c.c`, `_s.c`, and `_p.c` when requested are handled exactly as before;
- the target itself can include the generated IDL header;
- the final target builds successfully.

This confirms that moving configuration into `before_build_files` does not change normal IDL generation.

## Test 3: IDL public include propagation to a dependent target

Create:

```text
idl_library -> consumer
```

where:

- `idl_library` has an `.idl` input;
- `consumer` depends on `idl_library`;
- a consumer C/C++ source includes the generated IDL header directly.

Build only `consumer` from a clean state.

Expected:

- `idl_library`'s IDL `before_build_files` callback adds the autogen directory with `{public = true}`;
- MIDL generates the header;
- the consumer compile command contains the autogen include directory;
- the consumer compiles successfully.

This is the direct real-IDL equivalent of the lifecycle test already performed with the mock file rule.

## Test 4: unrelated enabled target must remain untouched

Add another enabled target containing an absent generated-source glob but no dependency edge from the selected root.

Building the root target must not evaluate that unrelated target's source glob as a side effect of IDL configuration.

This explicitly catches the current behavior where the unrelated `foo` target produces a missing-glob warning during `xmake build bar`.

---

# Why this is preferable to cache invalidation or rematching

A project can work around the current behavior by generating files and then clearing Xmake's source-match cache / invalidating target file state so that declarative `add_files()` globs are evaluated again.

That works, but it requires project code to know about source-list caching internals and duplicates work that should not have happened before target selection in the first place.

The lazy IDL change keeps the normal build model intact:

```text
configure metadata
    -> select root targets
    -> recursively select dependencies
    -> run selected-target preparation/codegen
    -> resolve the selected targets' source batches
    -> build
```

No private cache API, source rematch, dynamic `target:add("files", ...)`, or manual reconstruction of the target dependency graph is needed.

---

# Scope of the change

This proposal is intentionally narrow.

It does **not** require changes to:

- `target:sourcefiles()`;
- `target:sourcebatches()`;
- the source glob cache;
- the config action;
- root-target selection;
- dependency traversal;
- MIDL command generation;
- generated IDL C-file compilation;
- general rule dispatch.

Only the Windows IDL rule's configuration timing changes.

The build engine already performs target pruning correctly. The proposal removes a premature source-graph query from a rule that does not need that graph during `on_config`.

---

# Short version for maintainers

`platform.windows.idl:on_config` currently calls `target:sourcebatches()` only to answer “does this target have IDL files?”. Because config runs for all enabled targets, this forces every target's `add_files()` globs to be expanded before the build graph is pruned. Missing generated-source globs are therefore cached before selected-target prepare code can generate them, and even unrelated targets have their source patterns scanned.

The IDL rule already receives its real `sourcebatch` in `before_build_files`. Moving `idl.configure(target)` into that callback makes the existence test implicit, preserves the public autogen include directory and MIDL flow, and restores lazy source matching after target/dependency selection.

The required code change is limited to:

1. remove `platform.windows.idl`'s `on_config` block in `rules/platform/windows/idl/xmake.lua`;
2. call `idl.configure(target)` at the beginning of the existing `before_build_files` callback;
3. remove the `target:sourcebatches()` conditional from `idl.configure()` in `rules/platform/windows/idl/idl.lua`.

A generated-source reproduction confirms that removing the premature query allows generated sources to be discovered and compiled in the same invocation while leaving unrelated targets untouched. A separate jobgraph lifecycle test confirms that a `{public = true}` include directory added from `before_build_files(..., {jobgraph = true})` is inherited by a dependent target and can expose a generated header successfully.
