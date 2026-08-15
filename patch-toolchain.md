# Proposal: make toolchain initialization and detection truly lazy

## Summary

Xmake already has several pieces of a lazy toolchain model, but today the configuration path eagerly checks platform and target toolchains before the build action has selected the targets that will actually be built.

This has two undesirable effects:

1. toolchains belonging only to unrelated targets can be detected, initialized, or even cause the requested build to fail;
2. platform toolchain candidates can be detected before any target, rule, option, or other consumer actually asks to use them.

This proposal makes toolchain initialization follow a simple rule:

> A toolchain may be described and associated with targets without being initialized. It is prepared, checked/detected, and loaded only when some real consumer actually needs it.

A real consumer can be a target, a rule, an option, or any other Xmake code path that actually requests a tool or a dynamically loaded toolchain property.

The proposal also adds one project-wide callback that runs exactly once for each toolchain instance immediately before its first check/detection. This allows a project to install or prepare a toolchain on demand and to mutate the toolchain object before Xmake detects or uses it.

The prototype and all tests below were run on Windows x64 with:

```text
xmake v3.1.0+HEAD.96ad28edb
```

The changes are intentionally small and centralized. They do not require rewriting individual compiler/linker rules or adding special cases for every toolchain.

---

# Desired semantics

The intended lifecycle is:

```text
toolchain descriptor exists
        |
        | no detection, no setup, no on_load
        v
some real consumer first needs it
        |
        v
global on_toolchain_prepare(toolchain)
        |
        v
toolchain:check() / on_check
        |
        v
toolchain:on_load
        |
        v
actual tool/config use
```

More precisely:

- Merely declaring a toolchain must not initialize it.
- Merely associating a toolchain with a target must not initialize it.
- An unrelated target must not cause its toolchain to be initialized when another target is built.
- If a target does not explicitly specify a toolchain, Xmake should keep the existing platform-toolchain fallback, but the platform candidates should only be checked when a real consumer asks for a tool from them.
- A rule is a real consumer. If a rule attached to a selected target calls `target:has_tool()` or `target:tool()`, initializing the relevant toolchain at that point is expected.
- An option is also a real consumer. If an option genuinely needs a compiler/toolchain to perform its check, that use can initialize the toolchain.
- Dynamic toolchain values populated by `on_load` must remain available after that toolchain is actually selected and loaded.
- Reading static descriptor metadata from an unused candidate must not initialize it.

The project-wide callback should have this semantic:

```lua
on_toolchain_prepare(function (toolchain)
    -- Runs once for this toolchain instance, immediately before check/detect.
    -- The project may install the toolchain, configure paths, or mutate it.
end)
```

The callback must run before `on_check`, not after it.

It should also run before checking a cached `__checked` value. The environment may have changed between Xmake processes, and the callback may be responsible for preparing the toolchain on the current machine before its first use in the current process.

---

# Current eager behavior

There are two explicit eager sweeps in the configuration action.

## 1. Platform-wide check

In `xmake/actions/config/main.lua`, the config action currently loads the platform and, on recheck, calls:

```lua
local instance_plat = platform.load(plat, arch)
...
instance_plat:check()
```

For example, the Windows platform declares multiple candidate toolchains:

```lua
set_toolchains(
    "msvc", "clang", "yasm", "nasm", "cuda", "rust", "swift",
    "go", "gfortran", "zig", "fpc", "nim", "dotnet")
```

`platform:check()` walks candidate toolchains and calls `toolchain:check()`.

This means the platform can begin detecting toolchains before any selected target has asked to use them.

## 2. Global target-toolchain check

Later in the same config action:

```lua
if recheck then
    target_utils.check_target_toolchains()
end
```

`check_target_toolchains()` walks project targets and checks their toolchains globally.

This happens before the normal build action has pruned the project to the requested root targets and their dependency closure.

---

# Reproduction of the current problem

The following is intentionally minimal.

`foo` has a toolchain that always fails detection. `bar` is unrelated to `foo`.

```lua
toolchain("never")
    set_kind("standalone")
    on_check(function ()
        print("CHECK NEVER")
        return false
    end)

target("bar")
    set_kind("phony")
    on_build(function ()
        print("BUILD bar")
    end)

target("foo")
    set_kind("phony")
    set_toolchains("never")
    on_build(function (target)
        target:tool("cc")
    end)
```

Run:

```text
xmake build bar
```

Observed with the unmodified tested Xmake:

```text
checking for Microsoft C/C++ Compiler (x64) ... ok
CHECK NEVER
error: toolchain("never"): not found!
```

`BUILD bar` is never reached.

The requested build of `bar` fails only because an unrelated enabled target named `foo` declares an unavailable toolchain.

This is not only a performance issue. The eager check changes the semantic requirement from:

> toolchains used by this build must be valid

into:

> toolchains attached to every enabled target in the project must be valid

before the requested build can start.

---

# Xmake already has the correct build-graph pruning machinery

The build action already knows the requested target names before it invokes `config`:

```lua
local targetnames, group_pattern = action_utils.get_targets_and_group()
task.run("config", {}, {disable_dump = true})
```

Later, the normal build machinery uses `private.action.build.target.get_root_targets()` and the target dependency graph to select the real roots and dependencies.

`get_root_targets()` already handles:

- explicit target names;
- default targets;
- `--all`;
- group selection;
- enabled/default state;
- rebuild semantics used by the build layer.

Targets already provide `orderdeps()`, so the configuration stage does not need to implement its own dependency traversal semantics.

There is also already a relevant TODO in:

```text
xmake/core/sandbox/modules/import/core/project/project.lua
```

around the `_config_targets()` implementation:

```lua
-- TODO we need to optimize jobgraph
-- https://github.com/xmake-io/xmake/issues/6775
```

The commented implementation immediately below it already references `private.action.build.target` and `get_root_targets()`.

So the proposed direction reuses machinery already present in Xmake rather than introducing a parallel target-selection model.

---

# Minimal proposed changes

The prototype that produced the test results in this document changes the following small set of central points.

## 1. Pass build target selection into `config`

File:

```text
xmake/actions/build/main.lua
```

Current:

```lua
local targetnames, group_pattern = action_utils.get_targets_and_group()
task.run("config", {}, {disable_dump = true})
```

Proposed:

```lua
local targetnames, group_pattern = action_utils.get_targets_and_group()
task.run("config", {}, {
    disable_dump = true,
    build = true,
    targets = targetnames,
    group_pattern = group_pattern
})
```

The tested prototype used the same change on one line; it is expanded here only for readability.

This does not ask the config action to reconstruct command-line selection. The build action already has the resolved request and simply passes it through.

---

## 2. Remove the two eager toolchain sweeps from `config`

File:

```text
xmake/actions/config/main.lua
```

Remove the platform instance used only for the eager check:

```lua
local instance_plat = platform.load(plat, arch)
```

and remove:

```lua
instance_plat:check()
```

Also remove:

```lua
if recheck then
    target_utils.check_target_toolchains()
end
```

The imports that become unused can then be removed:

```lua
import("core.platform.platform")
import("private.utils.target", {alias = "target_utils"})
```

Pass the selection to target loading:

Current:

```lua
project.load_targets({recheck = recheck})
```

Proposed:

```lua
project.load_targets({
    recheck = recheck,
    build = opt.build,
    targets = opt.targets,
    group_pattern = opt.group_pattern
})
```

Standalone `xmake config` does not set `opt.build`, so it keeps the current behavior of configuring all project targets. The selected-target optimization applies when `config` is entered as part of a build.

---

## 3. Configure only selected roots + dependencies during a build

File:

```text
xmake/modules/private/utils/target.lua
```

Current:

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

Tested prototype:

```lua
function config_targets(opt)
    opt = opt or {}
    local selected
    if opt.build then
        local target_buildutils = import("private.action.build.target")
        selected = {}
        for _, root in ipairs(target_buildutils.get_root_targets(
                opt.targets, {group_pattern = opt.group_pattern})) do
            selected[root:fullname()] = true
            for _, dep in ipairs(root:orderdeps()) do
                selected[dep:fullname()] = true
            end
        end
    end
    for _, target in ipairs(table.wrap(project.ordertargets())) do
        if target:is_enabled() and
            (not selected or selected[target:fullname()]) then
            config_target(target, opt)
        end
    end
end
```

This is deliberately small.

It does **not** manually reproduce Xmake dependency semantics. It asks Xmake's existing build helper for the root targets and uses Xmake's existing ordered dependency closure.

A selected target's `on_config` rules still run normally. Therefore a rule that genuinely calls `target:has_tool()` remains a legitimate first toolchain consumer.

The important difference is that rules belonging only to an unrelated target are not executed during the requested build's config pass.

---

# Lazy toolchain lifecycle

The existing `toolchain.lua` already distinguishes descriptor information from lazy `on_load` values. The smallest lifecycle change is to make `_load()` the central "ensure checked + loaded" point.

File:

```text
xmake/core/tool/toolchain.lua
```

## 4. Add one global prepare callback

Add a setter in the toolchain module:

```lua
function toolchain.on_prepare_set(script)
    toolchain._ON_PREPARE = script
end
```

Then at the beginning of `toolchain:check()`:

```lua
function _instance:check()
    if not self._PREPARED then
        local on_prepare = toolchain._ON_PREPARE
        if on_prepare then
            local ok, errors = sandbox.call(on_prepare, self)
            if not ok then
                os.raise(errors)
            end
        end
        self._PREPARED = true
    end

    local checked = self:config("__checked")
    ...
end
```

Important properties:

- called exactly once per toolchain instance in the current process;
- receives the real toolchain object;
- runs before `on_check`;
- runs before Xmake consults the persisted `__checked` result;
- can call `toolchain:config_set(...)`, `toolchain:set(...)`, etc.;
- applies equally to built-in and project-defined toolchains;
- no toolchain-specific lifecycle special cases are required.

Example user API:

```lua
on_toolchain_prepare(function (toolchain)
    if toolchain:name() == "nasm" then
        -- install/download/setup NASM here if necessary
        toolchain:set("toolset", "as", "C:/tools/nasm/nasm.exe")
    end
end)
```

---

## 5. Let `_load()` perform the first lazy check

Current:

```lua
function _instance:_load()
    if not self:_is_checked() then
        utils.warning(
            "we cannot load toolchain(%s), because it has been not checked yet!",
            self:name(), self:plat(), self:arch())
    end
    ...
end
```

Proposed:

```lua
function _instance:_load()
    if not self:check() then
        return false
    end
    ...
    return true
end
```

The old design contains a comment in `toolchain:tool()` saying:

```lua
-- @note we cannot call self:check() here, because it can only be called on config
```

This proposal removes that restriction. `check()` becomes idempotent lazy initialization and can be reached from the first actual tool use.

---

## 6. Make actual `tool()` access rely on lazy `_load()`

Current:

```lua
function _instance:tool(toolkind)
    if not self:_is_checked() then
        utils.warning(...)
    end
    self:_load()
    ...
end
```

Proposed:

```lua
function _instance:tool(toolkind)
    if not self:_load() then
        return
    end
    ...
end
```

This is the natural first-use path for a compiler, assembler, linker, etc.

If the toolchain was never used, none of this runs.

---

## 7. Propagate `_load()` failure through dynamic `get()`

Current:

```lua
if opt.load ~= false then
    self:_load()
    return self:info():get(name)
end
```

Proposed:

```lua
if opt.load ~= false and self:_load() then
    return self:info():get(name)
end
```

Static values remain available before loading because `get()` already checks `self:info():get(name)` first.

Dynamic values requiring `on_load` trigger the lazy lifecycle when requested as a real dynamic use.

---

# Do not initialize unrelated candidate toolchains while collecting flags

Removing the explicit config sweeps is not sufficient by itself.

`toolchain.toolconfig()` currently iterates every candidate toolchain and calls:

```lua
local values = toolchain_inst:get(name)
```

Because `get()` lazily calls `_load()` when a value is not already static, a C compile using MSVC can initialize NASM, Dotnet, or other platform candidates merely while asking for values such as:

```text
cl.cflags
cflags
includedirs
arflags
```

This is not a real use of those candidate toolchains.

## 8. Read unloaded candidates statically; use dynamic values only after real load

Current:

```lua
for _, toolchain_inst in ipairs(toolchains) do
    if not toolchain_inst:_is_checked() then
        utils.warning(...)
    end
    local values = toolchain_inst:get(name)
    ...
end
```

Proposed:

```lua
for _, toolchain_inst in ipairs(toolchains) do
    local values = toolchain_inst:get(name, {
        load = toolchain_inst:_is_loaded() and true or false
    })
    ...
end
```

The explicit boolean conversion is intentional.

This is wrong:

```lua
{load = toolchain_inst:_is_loaded()}
```

because `_is_loaded()` returns `nil` for an unloaded toolchain. In Lua a field assigned `nil` is absent, so `get()` sees `opt.load == nil` and falls back to its default loading behavior.

This form is required:

```lua
{load = toolchain_inst:_is_loaded() and true or false}
```

The same rule should be used by the target-specific `toolconfig()` callback lookup.

File:

```text
xmake/core/project/target.lua
```

Current:

```lua
local script = toolchain_inst:get("target.on_" .. name)
```

Proposed:

```lua
local script = toolchain_inst:get(
    "target.on_" .. name,
    {load = toolchain_inst:_is_loaded() and true or false})
```

This preserves static descriptor contributions from candidate toolchains without executing their `on_load` code.

Once a toolchain is actually selected by `tool()` and loaded, its dynamically generated flags are visible normally.

A dedicated test below confirms this with NASM's `nasm.asflags`.

---

# Phony targets should use an inert `none` toolchain

A phony target has no compiler/linker requirement by default. Falling back to the platform's standalone toolchain gives it an unnecessary implicit dependency on a compiler toolchain.

The proposed model is:

```text
phony, no explicit toolchain   -> none
phony + nasm                   -> nasm + none
normal target                  -> unchanged platform fallback
```

`none` is not a lifecycle exception. It is simply an empty standalone toolchain.

## 9. Add a built-in `none` toolchain

New file:

```text
xmake/toolchains/none/xmake.lua
```

Contents:

```lua
toolchain("none")
    set_kind("standalone")
```

That is all.

There is deliberately no `on_check` and no `on_load`.

If `none` is never really used, it is never prepared or checked.

If a consumer really asks it for a tool, it follows exactly the same lifecycle as every other toolchain:

```text
on_toolchain_prepare(none)
check() -> true because there is no on_check
a load with no on_load
tool lookup -> nil
```

No special-case in `toolchain:check()` is necessary or desirable.

## 10. Append `none` to phony target toolchains

In `target:toolchains()` immediately after reading the explicit target toolchains:

```lua
local target_toolchains = self:get("toolchains")
if self:is_phony() then
    target_toolchains = table.join(
        table.wrap(target_toolchains), {"none"})
end
```

The existing target-toolchain logic already prefers a standalone toolchain when deciding whether a platform fallback is required.

Since `none` is standalone, a phony target no longer receives MSVC/GCC/etc. merely to satisfy the standalone fallback rule.

If the phony explicitly names `nasm`, both descriptors are associated, but neither one is initialized until a consumer asks for it.

---

# Avoid artificial post-build tool use on phony targets

During testing, a phony target correctly executed without using a toolchain, but the normal post-build API checker subsequently called `target:has_tool()` from the symbols checker.

That artificially turned a metadata validation pass into a toolchain consumer.

File:

```text
xmake/modules/private/check/checkers/api/target/symbols.lua
```

Current:

```lua
if target:is_plat("windows") and
   (target:has_tool("cc", "cl") or target:has_tool("cxx", "cl")) then
```

Proposed:

```lua
if not target:is_phony() and target:is_plat("windows") and
    (target:has_tool("cc", "cl") or target:has_tool("cxx", "cl")) then
```

A phony target cannot meaningfully use the MSVC `symbols = edit/embed` modes that this check is discovering, so asking it for a C/C++ compiler is unnecessary.

The separate syntax checker also uses `has_tool()`, but it first filters targets by C/C++ build rules and is invoked by an explicit syntax-check action, so it is a legitimate consumer for applicable targets.

---

# Expose the global callback in the project DSL

File:

```text
xmake/core/project/project.lua
```

Minimal prototype API:

```lua
function project._api_on_toolchain_prepare(interp, script)
    toolchain.on_prepare_set(script)
end
```

and register:

```lua
{"on_toolchain_prepare", project._api_on_toolchain_prepare}
```

The exact public API name can of course be adjusted to Xmake naming conventions. The important semantic is that it is project-wide and receives each toolchain instance immediately before its first check/detection.

---

# Test matrix

All patched results below were observed with the prototype described above.

## Test A: unrelated target must not initialize its toolchain

Graph:

```text
bar -> dep
foo       (unrelated, set_toolchains("never"), on_check returns false)
```

Both `bar` and `dep` print from `on_config`. `foo` also has an `on_config` print so it is obvious if config touches it.

Command:

```text
xmake build bar
```

Patched output:

```text
PREPARE msvc
checking for Microsoft C/C++ Compiler (x64) ... ok
CONFIG dep
CONFIG bar
... compile dep/bar ...
build ok
```

Not present:

```text
CONFIG foo
PREPARE never
CHECK NEVER
```

This demonstrates both properties:

- config uses the selected root/dependency closure;
- a selected C/C++ rule is allowed to initialize MSVC because the rule really asks which compiler is active.

## Test B: default build must preserve normal target selection

Same graph, with:

```lua
target("foo")
    set_default(false)
```

Command:

```text
xmake build
```

Observed:

```text
PREPARE msvc
checking for Microsoft C/C++ Compiler (x64) ... ok
CONFIG dep
CONFIG bar
... build ok ...
```

Again there is no `CONFIG foo`, `PREPARE never`, or `CHECK NEVER`.

So the selection uses Xmake's existing default-root logic rather than assuming that every enabled target is a root.

---

# Phony tests

## Test C: pure phony must initialize no toolchain

```lua
target("noop")
    set_kind("phony")
    on_build(function ()
        print("BUILD noop")
    end)
```

Observed:

```text
BUILD noop
[100%]: build ok
```

No prepare hook and no compiler detection occurs.

## Test D: declaring an unavailable NASM must still be inert if unused

```lua
target("noop_nasm")
    set_kind("phony")
    set_toolchains("nasm", {bindir = "Z:/definitely-not-there"})
    on_build(function ()
        print("BUILD noop_nasm")
    end)
```

The `bindir` is intentionally nonexistent so the test does not depend on NASM being installed on the machine.

Observed:

```text
BUILD noop_nasm
[100%]: build ok
```

Not present:

```text
PREPARE nasm
checking for NASM ...
error: ...
```

This demonstrates the distinction between **association** and **use**.

## Test E: real use of `none` uses the same global hook

A phony target with no explicit toolchain calls:

```lua
local program, name = target:tool("cc")
local program2, name2 = target:tool("cc")
```

Observed:

```text
PREPARE none
NONE USE nil nil
NONE USE2 nil nil
[100%]: build ok
```

The callback runs once. There is no compiler detect and no special `none` branch in the lifecycle.

## Test F: real use of built-in NASM

The project hook installs/configures the assembler before Xmake attempts to use it:

```lua
on_toolchain_prepare(function (tc)
    print("PREPARE " .. tc:name())
    if tc:name() == "nasm" then
        local program = "C:/tools/nasm/nasm.exe"
        print("SETUP nasm=" .. program)
        tc:set("toolset", "as", program)
    end
end)
```

A phony target explicitly declares NASM and calls `target:tool("as")` twice.

Observed:

```text
PREPARE nasm
SETUP nasm=.../nasm.exe
USE1 nasm .../nasm.exe
USE2 nasm .../nasm.exe
[100%]: build ok
```

There is no `PREPARE none` and no `PREPARE msvc`.

The callback fires once for the actual NASM instance and mutates it before its first tool lookup.

---

# Callback ordering test

A custom toolchain was used to make the order explicit:

```lua
on_toolchain_prepare(function (tc)
    print("PREPARE " .. tc:name())
    if tc:name() == "probe" then
        tc:config_set("prepared", "yes")
        tc:set("toolset", "cc", "cl@C:/Windows/System32/cmd.exe")
    end
end)

toolchain("probe")
    set_kind("standalone")
    on_check(function (tc)
        print("CHECK " .. tc:name() ..
              " prepared=" .. tostring(tc:config("prepared")))
        return tc:config("prepared") == "yes"
    end)
    on_load(function (tc)
        print("LOAD " .. tc:name())
    end)
```

The target requests the tool twice.

Observed:

```text
PREPARE probe
CHECK probe prepared=yes
LOAD probe
USE1 cl c:/windows/system32/cmd.exe
USE2 cl c:/windows/system32/cmd.exe
[100%]: build ok
```

This verifies:

```text
prepare -> check -> load -> use
```

and verifies that prepare/check/load do not repeat on the second tool request.

---

# Dynamic toolconfig non-regression test

NASM's built-in `on_load` dynamically adds platform-specific flags. On Windows x86_64 it contributes:

```text
-f win64
```

After the first real `target:tool("as")`, the test queried:

```lua
target:toolconfig("nasm.asflags")
```

Observed:

```text
PREPARE nasm
SETUP nasm=.../nasm.exe
USE1 nasm .../nasm.exe
ASFLAGS -f win64
USE2 nasm .../nasm.exe
```

Therefore the static-only behavior for **unloaded candidate toolchains** does not suppress dynamic configuration from a toolchain that was actually selected and loaded.

During instrumentation of a normal MSVC C build, the same change allowed Xmake to read static NASM descriptor metadata with `load=false` while producing no `CHECK nasm` and no NASM prepare callback.

That is the intended behavior:

```text
candidate metadata read   != toolchain initialization
actual selected tool use  == toolchain initialization
```

---

# Unified diff of the tested prototype

The following is the patch-form version of the prototype used for the tests in this document. Paths are normalized to the Xmake repository layout so this section can be reviewed or applied like a conventional unified diff.

```diff
diff --git a/xmake/actions/build/main.lua b/xmake/actions/build/main.lua
--- a/xmake/actions/build/main.lua
+++ b/xmake/actions/build/main.lua
@@ -197,7 +197,12 @@ function main(opt)
 
     -- config it first
     local targetnames, group_pattern = action_utils.get_targets_and_group()
-    task.run("config", {}, {disable_dump = true})
+    task.run("config", {}, {
+        disable_dump = true,
+        build = true,
+        targets = targetnames,
+        group_pattern = group_pattern
+    })
 
     -- check target names
     if targetnames then

diff --git a/xmake/actions/config/main.lua b/xmake/actions/config/main.lua
--- a/xmake/actions/config/main.lua
+++ b/xmake/actions/config/main.lua
@@ -25,7 +25,6 @@ import("core.base.hashset")
 import("core.tool.toolchain")
 import("core.project.config")
 import("core.project.project")
-import("core.platform.platform")
 import("private.detect.find_platform")
 import("core.cache.localcache")
 import("core.cache.detectcache")
@@ -35,7 +34,6 @@ import("configfiles", {alias = "generate_configfiles"})
 import("private.action.require.register", {alias = "register_packages"})
 import("private.action.require.install", {alias = "install_packages"})
 import("private.service.remote_build.action", {alias = "remote_build_action"})
-import("private.utils.target", {alias = "target_utils"})
 
 -- filter option
 function _option_filter(name)
@@ -308,9 +306,6 @@ force to build in current directory via run `xmake -P .`]], os.projectdir())
     assert(plat == config.plat())
     assert(arch == config.arch())
 
-    -- load platform instance
-    local instance_plat = platform.load(plat, arch)
-
     -- merge the checked configuration
     local recheck = _need_check(options_changed or not configcache_loaded or autogen)
@@ -330,9 +325,6 @@ force to build in current directory via run `xmake -P .`]], os.projectdir())
             localcache.save()
         end
 
-        -- check platform
-        instance_plat:check()
-
         -- check project options
         if not trybuild then
@@ -370,13 +362,12 @@ force to build in current directory via run `xmake -P .`]], os.projectdir())
         -- otherwise has_package() will be invalid.
         _check_targets()
 
-        -- check target toolchains
-        if recheck then
-            target_utils.check_target_toolchains()
-        end
-
         -- load targets
-        project.load_targets({recheck = recheck})
+        project.load_targets({
+            recheck = recheck,
+            build = opt.build,
+            targets = opt.targets,
+            group_pattern = opt.group_pattern
+        })
 
         -- update the config files
         generate_configfiles({force = recheck})

diff --git a/xmake/modules/private/utils/target.lua b/xmake/modules/private/utils/target.lua
--- a/xmake/modules/private/utils/target.lua
+++ b/xmake/modules/private/utils/target.lua
@@ -226,10 +226,24 @@ end
 --
 function config_targets(opt)
     opt = opt or {}
+    local selected
+    if opt.build then
+        local target_buildutils = import("private.action.build.target")
+        selected = {}
+        for _, root in ipairs(target_buildutils.get_root_targets(
+                opt.targets, {group_pattern = opt.group_pattern})) do
+            selected[root:fullname()] = true
+            for _, dep in ipairs(root:orderdeps()) do
+                selected[dep:fullname()] = true
+            end
+        end
+    end
     for _, target in ipairs(table.wrap(project.ordertargets())) do
-        if target:is_enabled() then
+        if target:is_enabled() and
+            (not selected or selected[target:fullname()]) then
             config_target(target, opt)
         end
     end
 end

diff --git a/xmake/core/tool/toolchain.lua b/xmake/core/tool/toolchain.lua
--- a/xmake/core/tool/toolchain.lua
+++ b/xmake/core/tool/toolchain.lua
@@ -40,6 +40,10 @@ local language       = require("language/language")
 local sandbox        = require("sandbox/sandbox")
 local sandbox_module = require("sandbox/modules/import/core/sandbox/module")
 
+function toolchain.on_prepare_set(script)
+    toolchain._ON_PREPARE = script
+end
+
 -- new an instance
 function _instance.new(name, info, opt)
     opt = opt or {}
@@ -196,9 +200,8 @@ function _instance:get(name, opt)
     end
 
     -- lazy loading toolchain
-    if opt.load ~= false then
-        self:_load()
+    if opt.load ~= false and self:_load() then
         return self:info():get(name)
     end
 end
@@ -272,13 +275,10 @@ end
 -- @return          the program path, the tool name
 --
 function _instance:tool(toolkind)
-    if not self:_is_checked() then
-        utils.warning("we cannot get tool(%s) in toolchain(%s) with %s/%s, because it has been not checked yet!", toolkind, self:name(), self:plat(), self:arch())
+    if not self:_load() then
+        return
     end
-    -- ensure to do load for initializing toolset first
-    -- @note we cannot call self:check() here, because it can only be called on config
-    self:_load()
     local toolpaths = self:get("toolset." .. toolkind)
     if toolpaths then
         for _, toolpath in ipairs(table.wrap(toolpaths)) do
@@ -352,6 +352,14 @@ end
 -- @return      true if the toolchain is available
 --
 function _instance:check()
+    if not self._PREPARED then
+        local on_prepare = toolchain._ON_PREPARE
+        if on_prepare then
+            local ok, errors = sandbox.call(on_prepare, self)
+            if not ok then
+                os.raise(errors)
+            end
+        end
+        self._PREPARED = true
+    end
     local checked = self:config("__checked")
     if checked == nil then
         local on_check = self:_on_check()
@@ -441,9 +449,10 @@ end
 
 -- do load, @note we need to load it repeatly for each architectures
 function _instance:_load()
-    if not self:_is_checked() then
-        utils.warning("we cannot load toolchain(%s), because it has been not checked yet!", self:name(), self:plat(), self:arch())
+    if not self:check() then
+        return false
     end
     local info = self:info()
     if not info:get("__loaded") and not info:get("__loading") then
@@ -457,6 +466,7 @@ function _instance:_load()
         end
         info:set("__loaded", true)
     end
+    return true
 end
 
 -- is loaded?
@@ -966,10 +976,10 @@ function toolchain.toolconfig(toolchains, name, opt)
     local toolconfig = cache:get2(cachekey, name)
     if toolconfig == nil then
         for _, toolchain_inst in ipairs(toolchains) do
-            if not toolchain_inst:_is_checked() then
-                utils.warning("we cannot get toolconfig(%s) in toolchain(%s) with %s/%s, because it has been not checked yet!", name, toolchain_inst:name(), toolchain_inst:plat(), toolchain_inst:arch())
-            end
-            local values = toolchain_inst:get(name)
+            local values = toolchain_inst:get(name, {
+                load = toolchain_inst:_is_loaded() and true or false
+            })
             if values then
                 toolconfig = toolconfig or {}
                 table.join2(toolconfig, values)

diff --git a/xmake/core/project/project.lua b/xmake/core/project/project.lua
--- a/xmake/core/project/project.lua
+++ b/xmake/core/project/project.lua
@@ -227,6 +227,10 @@ function project._api_add_toolchaindirs(interp, ...)
     end
 end
 
+function project._api_on_toolchain_prepare(interp, script)
+    toolchain.on_prepare_set(script)
+end
+
 -- load the project file
 function project._load(force, disable_filter)
@@ -685,6 +689,7 @@ function project.apis()
         ,   {"add_plugindirs",          project._api_add_plugindirs    }
         ,   {"add_platformdirs",        project._api_add_platformdirs  }
         ,   {"add_toolchaindirs",       project._api_add_toolchaindirs }
+        ,   {"on_toolchain_prepare",    project._api_on_toolchain_prepare}
         }
     }
 end

diff --git a/xmake/core/project/target.lua b/xmake/core/project/target.lua
--- a/xmake/core/project/target.lua
+++ b/xmake/core/project/target.lua
@@ -2730,6 +2730,9 @@ function _instance:toolchains()
         -- load target toolchains first
         local has_standalone = false
         local target_toolchains = self:get("toolchains")
+        if self:is_phony() then
+            target_toolchains = table.join(table.wrap(target_toolchains), {"none"})
+        end
         if target_toolchains then
             toolchains = {}
             for _, name in ipairs(table.wrap(target_toolchains)) do
@@ -2827,7 +2830,10 @@ function _instance:toolconfig(name)
     return toolchain.toolconfig(self:toolchains(), name, {cachekey = "target_" .. self:fullname(), plat = self:plat(), arch = self:arch(),
                                                           after_get = function(toolchain_inst)
         -- get flags from target.on_xxflags()
-        local script = toolchain_inst:get("target.on_" .. name)
+        local script = toolchain_inst:get(
+            "target.on_" .. name,
+            {load = toolchain_inst:_is_loaded() and true or false}
+        )
         if type(script) == "function" then
             local ok, result_or_errors = utils.trycall(script, nil, self)
             if ok then

diff --git a/xmake/modules/private/check/checkers/api/target/symbols.lua b/xmake/modules/private/check/checkers/api/target/symbols.lua
--- a/xmake/modules/private/check/checkers/api/target/symbols.lua
+++ b/xmake/modules/private/check/checkers/api/target/symbols.lua
@@ -25,7 +25,8 @@ function main(opt)
     opt = opt or {}
     api_checker.check_targets("symbols", table.join(opt, {values = function (target)
         local values = {"none", "debug", "hidden", "hidden_cxx"}
-        if target:is_plat("windows") and (target:has_tool("cc", "cl") or target:has_tool("cxx", "cl")) then
+        if not target:is_phony() and target:is_plat("windows") and
+            (target:has_tool("cc", "cl") or target:has_tool("cxx", "cl")) then
             table.insert(values, "edit")
             table.insert(values, "embed")
         end

diff --git a/xmake/toolchains/none/xmake.lua b/xmake/toolchains/none/xmake.lua
new file mode 100644
--- /dev/null
+++ b/xmake/toolchains/none/xmake.lua
@@ -0,0 +1,2 @@
+toolchain("none")
+    set_kind("standalone")
```

The exact public callback name is still open for maintainer preference, but the lifecycle and code paths above are the ones exercised by the tests in this document.

---

# Compatibility notes

## Standalone `xmake config`

The prototype only prunes config targets when the config task was called by the build action with `opt.build = true`.

A direct:

```text
xmake config
```

still configures all enabled targets as it does today.

It no longer needs the unconditional platform/toolchain sweeps; individual options and target rules can trigger lazy initialization if they actually require a toolchain.

## Existing target platform fallback

Normal build targets retain the existing `target:toolchains()` fallback to platform candidates.

The semantic change is not which platform toolchains are candidates. The change is **when candidates become checked/loaded**.

## Partial explicit toolchains

For normal targets, existing behavior remains: a partial toolchain such as NASM can coexist with the platform standalone compiler toolchain.

For phony targets only, the standalone fallback becomes the inert `none` toolchain, so a phony target does not gain an implicit compiler dependency.

## Rules that call `target:has_tool()`

A rule attached to a selected target is a legitimate consumer. If it asks `target:has_tool()`, it can initialize the necessary toolchain.

The important optimization is that rules belonging to targets outside the selected build graph do not run as part of that build's config pass.

## Cached detection

The global `on_toolchain_prepare` hook runs before the `__checked` cache lookup and once per instance/process.

This is useful for environments where the hook is responsible for making a previously detected toolchain available again or adjusting its parameters before current-process use.

---

# Files touched by the tested prototype

The functional prototype is small and concentrated in these files:

```text
xmake/actions/build/main.lua
xmake/actions/config/main.lua
xmake/modules/private/utils/target.lua
xmake/core/tool/toolchain.lua
xmake/core/project/project.lua
xmake/core/project/target.lua
xmake/modules/private/check/checkers/api/target/symbols.lua
xmake/toolchains/none/xmake.lua                      (new)
```

The largest conceptual changes are still only:

1. pass selected roots into config;
2. stop globally pre-checking toolchains;
3. make `_load()` perform lazy `check()`;
4. run one global callback immediately before the first check;
5. do not dynamically load unrelated candidates just to collect toolconfig values;
6. give phony targets an inert standalone fallback.

No individual compiler, assembler, linker, or platform toolchain implementation needs to learn a new lifecycle.

---

# Why this model is useful

For small projects, eager detection is mostly wasted work.

For large projects with many optional targets and heterogeneous toolchains, it has stronger consequences:

- a target that is not part of the requested build can require software that should not be necessary for the build;
- unavailable optional toolchains can make unrelated builds fail;
- expensive detection runs before it is known whether the toolchain will be used;
- projects cannot reliably bootstrap a missing toolchain immediately before Xmake detects it;
- declaring optional toolchains becomes less composable because declaration implicitly creates an environment requirement.

A true lazy lifecycle makes declaration cheap and use explicit:

```text
declare many possible targets/toolchains
                 |
                 v
select requested target graph
                 |
                 v
only real consumers initialize what they need
```

The new global callback additionally enables self-preparing builds without requiring every target or toolchain consumer to duplicate setup logic.

---

# Suggested regression tests for upstream

At minimum, an upstream test should cover these cases:

1. **Unrelated unavailable toolchain**
   - `foo` uses an always-failing custom toolchain;
   - `bar` is unrelated;
   - `xmake build bar` succeeds and never calls `foo`'s `on_check`.

2. **Selected dependency closure**
   - `bar -> dep`, unrelated `foo`;
   - config callbacks run for `bar` and `dep`, not `foo`.

3. **Default target selection**
   - non-default `foo` is excluded from bare `xmake build` config and toolchain detection.

4. **Prepare callback ordering**
   - callback mutates a config value;
   - `on_check` asserts that value is already present;
   - observed order is prepare -> check -> load -> use.

5. **Prepare callback is one-shot**
   - request the same tool twice;
   - prepare/check/load each run once.

6. **Built-in toolchain callback**
   - use an existing built-in toolchain such as NASM;
   - callback overrides its tool path before first use.

7. **Unused explicit phony toolchain**
   - phony declares NASM with a deliberately invalid/nonexistent bindir;
   - build succeeds without prepare/check/detect because no tool is requested.

8. **Phony `none` fallback**
   - plain phony build produces no toolchain callback;
   - explicit first `target:tool(...)` produces `on_toolchain_prepare(none)` once and returns no tool.

9. **Unrelated candidate toolconfig**
   - compile C with MSVC while NASM is a platform candidate;
   - reading compiler flags must not call NASM `on_check` or `on_load`.

10. **Loaded dynamic toolconfig**
    - actually select NASM;
    - verify its dynamically added `nasm.asflags` remains available after `on_load`.

---

# Conclusion

The main issue is not that Xmake lacks lazy primitives. It already has lazy descriptor loading, `on_check`, `on_load`, target-root selection, dependency traversal, and cached tool resolution.

The eager behavior comes from a few central paths that force those primitives too early:

```text
config -> platform:check()
config -> check_target_toolchains()
config -> configure every enabled target
and
collect toolconfig -> dynamically load every candidate
```

Removing those eager entry points and making `_load()` responsible for an idempotent first `check()` produces a much simpler invariant:

> A toolchain is initialized because something actually used it, not because it happened to be declared somewhere in the project.

The tested prototype demonstrates that this can be implemented with a small centralized patch while preserving normal platform fallback, target rules, dynamic `on_load` configuration, and existing target/dependency selection semantics.
