# Proposal: truly lazy, cross-platform toolchain initialization

## Goal

Make toolchains descriptive until they are actually used.

The intended invariant is:

```text
declare / associate toolchain
        |
        | no prepare, no detection, no on_load
        v
first real consumer
(target / rule / option / other tool user)
        |
        v
on_toolchain_prepare(toolchain)
        |
        v
check / detect
        |
        v
on_load
        |
        v
actual tool/config use
```

The implementation must be fully cross-platform. There should be no logic such as:

```lua
if target:is_plat("windows") then ...
if target:has_tool("cc", "cl") then ...
if toolchain:name() == "nasm" then ...
```

inside the core patch.

Platform/tool names may appear in regression tests only. They must not affect the implementation.

The prototype below was tested with:

```text
xmake v3.1.0+HEAD.96ad28edb
```

on Windows x64, but every code change is platform-independent.

---

# Current problems

There are three independent eager paths.

## 1. `config` checks toolchains globally

The build action already knows the requested targets:

```lua
local targetnames, group_pattern = action_utils.get_targets_and_group()
```

but invokes `config` without passing them:

```lua
task.run("config", {}, {disable_dump = true})
```

The config action then performs two global checks:

```lua
instance_plat:check()
```

and:

```lua
target_utils.check_target_toolchains()
```

and finally configures every enabled target.

Therefore an unrelated target can initialize or fail on a toolchain even when that target is not part of the requested build.

### Reproduction

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
```

Current behavior for:

```text
xmake build bar
```

can fail because `never`, which belongs only to `foo`, is checked during global configuration.

The requirement should instead be:

> only toolchains reachable from real consumers in the selected build graph need to exist.

---

## 2. `toolchain.toolconfig()` loads every candidate

`toolchain.toolconfig()` iterates all candidate toolchains and currently does:

```lua
local values = toolchain_inst:get(name)
```

`get()` performs lazy `on_load` when the value is not already static.

Therefore asking the active compiler for flags can initialize unrelated candidate toolchains simply because they are present in the platform/target candidate list.

This is not a real use of those candidates.

The correct behavior is:

```text
unloaded candidate -> read static descriptor values only
loaded candidate   -> dynamic values are already present and remain readable
```

No toolchain-specific filtering is required.

---

## 3. API validation can evaluate dynamic valid-value callbacks unnecessarily

The generic API checker currently evaluates:

```lua
opt.values(instance)
```

before checking whether the API is even set on the instance.

Some dynamic valid-value functions legitimately inspect a toolchain. If the corresponding API is absent, evaluating that function is unnecessary and can accidentally become a toolchain consumer.

The generic fix is simply:

```lua
local values = instance:get(apiname)
if not values then return end
```

before evaluating a dynamic `opt.values` callback.

This is not specific to toolchains, platforms, `symbols`, MSVC, or phony targets. It is a generic checker optimization.

---

# Minimal design

The patch keeps the changes concentrated around existing abstraction boundaries.

## A. Reuse Xmake's existing build jobgraph for config

Xmake already contains a commented `_config_targets()` implementation based on:

```lua
private.action.build.target
get_root_targets(...)
run_targetjobs(..., {job_kind = "config"})
```

and already has a TODO referencing the config-jobgraph work.

Instead of implementing a second dependency-closure algorithm, the build action passes its already-resolved root request into `config`, and `_config_targets()` reuses the native build target graph.

For a normal standalone:

```text
xmake config
```

the old behavior is preserved: all enabled targets are configured.

For:

```text
xmake build bar
```

only `bar` and its dependency closure receive config jobs.

This is important because a selected rule or option is allowed to be a real toolchain consumer. An unrelated target's rules should not execute merely because the target exists in the project.

---

## B. Make `_load()` the single lazy initialization boundary

`toolchain:_load()` becomes responsible for:

```text
prepare -> check -> load
```

and remains idempotent.

Actual `tool()` and dynamic `get()` already naturally flow through `_load()`.

This removes the old assumption:

```lua
-- check can only be called during config
```

and replaces it with a simpler invariant:

> check happens when the toolchain is first actually needed.

---

## C. Add one global pre-detection callback

Project API:

```lua
on_toolchain_prepare(function (toolchain)
    -- install/download/setup the toolchain if needed
    -- mutate toolchain config/path/toolset before detection
end)
```

It runs:

- once per toolchain instance in the current process;
- before `on_check`;
- before the persisted `__checked` result is consumed;
- for built-in and project-defined toolchains alike;
- for the `none` toolchain too, if `none` is ever actually used.

There are no per-toolchain callback branches in core.

---

## D. `toolconfig` must not activate candidates

Both generic toolchain config lookup and target-specific `target.on_*flags` lookup use:

```lua
get(..., {load = false})
```

This is enough.

If a toolchain was already really used, its `on_load` values are already stored in its info object and are returned normally.

If it has never been used, only static descriptor values are visible and no initialization occurs.

No `_is_loaded()` condition is required.

---

## E. Phony targets use an inert `none` standalone fallback

A phony target should not inherit a platform compiler merely because target toolchain resolution always wants one standalone toolchain.

Add a built-in empty toolchain:

```lua
toolchain("none")
    set_kind("standalone")
```

and append it to phony target toolchains.

Result:

```text
phony                    -> none
phony + explicit nasm    -> nasm + none
normal target            -> unchanged platform fallback
```

`none` is not a lifecycle exception. It uses exactly the same prepare/check/load path as every other toolchain.

If it is never used, no hook runs.

If somebody really asks it for a tool, the global hook runs once and the lookup naturally returns no tool.

---

# Unified diff of the tested minimal prototype

```diff
diff --git a/xmake/actions/build/main.lua b/xmake/actions/build/main.lua
--- a/xmake/actions/build/main.lua
+++ b/xmake/actions/build/main.lua
@@ -197,7 +197,7 @@ function main(opt)
 
     -- config it first
     local targetnames, group_pattern = action_utils.get_targets_and_group()
-    task.run("config", {}, {disable_dump = true})
+    task.run("config", {}, {disable_dump = true, build = true, targets = targetnames, group_pattern = group_pattern})
 
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
@@ -308,8 +306,6 @@ function main(opt)
     assert(plat == config.plat())
     assert(arch == config.arch())
 
-    -- load platform instance
-    local instance_plat = platform.load(plat, arch)
-
     -- merge the checked configuration
@@ -330,8 +326,6 @@ function main(opt)
-        -- check platform
-        instance_plat:check()
-
         -- check project options
@@ -370,13 +364,9 @@ function main(opt)
         -- otherwise has_package() will be invalid.
         _check_targets()
 
-        -- check target toolchains
-        if recheck then
-            target_utils.check_target_toolchains()
-        end
-
         -- load targets
-        project.load_targets({recheck = recheck})
+        project.load_targets({recheck = recheck, build = opt.build, targets = opt.targets, group_pattern = opt.group_pattern})
 
         -- update the config files

diff --git a/xmake/core/sandbox/modules/import/core/project/project.lua b/xmake/core/sandbox/modules/import/core/project/project.lua
--- a/xmake/core/sandbox/modules/import/core/project/project.lua
+++ b/xmake/core/sandbox/modules/import/core/project/project.lua
@@ -129,8 +129,14 @@ end
 
 -- config targets
 function sandbox_core_project._config_targets(opt)
-    import("private.utils.target", {alias = "target_utils"})
-    target_utils.config_targets(opt)
+    if opt and opt.build then
+        import("private.action.build.target", {alias = "target_buildutils"})
+        local targets_root = target_buildutils.get_root_targets(opt.targets, {group_pattern = opt.group_pattern})
+        target_buildutils.run_targetjobs(targets_root, {job_kind = "config", target_fence = true, jobs = 1, job_opt = opt})
+    else
+        import("private.utils.target", {alias = "target_utils"})
+        target_utils.config_targets(opt)
+    end
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
@@ -196,8 +200,7 @@ function _instance:get(name, opt)
     end
 
     -- lazy loading toolchain
-    if opt.load ~= false then
-        self:_load()
+    if opt.load ~= false and self:_load() then
         return self:info():get(name)
     end
 end
@@ -272,12 +275,7 @@ function _instance:tool(toolkind)
-    if not self:_is_checked() then
-        utils.warning("we cannot get tool(%s) in toolchain(%s) with %s/%s, because it has been not checked yet!", toolkind, self:name(), self:plat(), self:arch())
-    end
-    -- ensure to do load for initializing toolset first
-    -- @note we cannot call self:check() here, because it can only be called on config
-    self:_load()
+    if not self:_load() then return end
     local toolpaths = self:get("toolset." .. toolkind)
@@ -352,6 +350,14 @@ function _instance:check()
+    if not self._PREPARED then
+        local cb = toolchain._ON_PREPARE
+        if cb then
+            local ok, errors = sandbox.call(cb, self)
+            if not ok then os.raise(errors) end
+        end
+        self._PREPARED = true
+    end
     local checked = self:config("__checked")
@@ -441,9 +447,7 @@ function _instance:_load()
-    if not self:_is_checked() then
-        utils.warning("we cannot load toolchain(%s), because it has been not checked yet!", self:name(), self:plat(), self:arch())
-    end
+    if not self:check() then return false end
     local info = self:info()
@@ -457,6 +461,7 @@ function _instance:_load()
         end
         info:set("__loaded", true)
     end
+    return true
 end
@@ -966,10 +971,7 @@ function toolchain.toolconfig(toolchains, name, opt)
     local toolconfig = cache:get2(cachekey, name)
     if toolconfig == nil then
         for _, toolchain_inst in ipairs(toolchains) do
-            if not toolchain_inst:_is_checked() then
-                utils.warning("we cannot get toolconfig(%s) in toolchain(%s) with %s/%s, because it has been not checked yet!", name, toolchain_inst:name(), toolchain_inst:plat(), toolchain_inst:arch())
-            end
-            local values = toolchain_inst:get(name)
+            local values = toolchain_inst:get(name, {load = false})
             if values then

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
@@ -685,6 +689,7 @@ function project.apis()
         ,   {"add_plugindirs",          project._api_add_plugindirs    }
         ,   {"add_platformdirs",        project._api_add_platformdirs  }
         ,   {"add_toolchaindirs",       project._api_add_toolchaindirs }
+        ,   {"on_toolchain_prepare",    project._api_on_toolchain_prepare}
         }

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
@@ -2827,7 +2830,7 @@ function _instance:toolconfig(name)
                                                           after_get = function(toolchain_inst)
         -- get flags from target.on_xxflags()
-        local script = toolchain_inst:get("target.on_" .. name)
+        local script = toolchain_inst:get("target.on_" .. name, {load = false})
         if type(script) == "function" then

diff --git a/xmake/modules/private/check/checkers/api/api_checker.lua b/xmake/modules/private/check/checkers/api/api_checker.lua
--- a/xmake/modules/private/check/checkers/api/api_checker.lua
+++ b/xmake/modules/private/check/checkers/api/api_checker.lua
@@ -137,6 +137,8 @@ end
 
 -- check instance
 function _check_instance(instance, apiname, valueset, level, opt)
+    local values = instance:get(apiname)
+    if not values then return end
     local instance_valueset = valueset
     if type(opt.values) == "function" then
@@ -144,7 +146,6 @@ function _check_instance(instance, apiname, valueset, level, opt)
             instance_valueset = hashset.from(instance_values)
         end
     end
-    local values = instance:get(apiname)
 
     -- check the keyvalues api

diff --git a/xmake/toolchains/none/xmake.lua b/xmake/toolchains/none/xmake.lua
new file mode 100644
--- /dev/null
+++ b/xmake/toolchains/none/xmake.lua
@@ -0,0 +1,2 @@
+toolchain("none")
+    set_kind("standalone")
```

---

# Why the patch is cross-platform

No implementation branch depends on:

- host OS;
- target platform;
- compiler name;
- assembler name;
- linker name;
- a specific built-in toolchain.

The behavior is expressed only in terms of generic Xmake concepts:

```text
selected target graph
toolchain descriptor
toolchain check/load lifecycle
static versus loaded configuration
phony target kind
generic API validation
```

The same lazy lifecycle applies to GCC, Clang, MSVC, NASM, CUDA, Rust, Swift, Go, custom toolchains, cross toolchains, and any future toolchain without adding names to the core logic.

---

# Regression tests performed

The examples below use concrete tools only to make behavior observable. They are not conditions in the patch.

## 1. Selected config graph only

Test graph:

```text
bar -> dep
foo       unrelated, custom toolchain always fails check
```

Observed with the minimal prototype:

```text
CONFIG dep
CONFIG bar
[100%]: build ok
```

Not observed:

```text
CONFIG foo
CHECK NEVER
```

This specifically validates the new `run_targetjobs(..., job_kind = "config")` path.

## 2. Explicit but unused toolchain remains inert

A phony target declared a built-in assembler toolchain with a deliberately invalid bindir:

```lua
set_toolchains("nasm", {bindir = "Z:/definitely-not-there"})
```

but never requested a tool.

Observed:

```text
BUILD noop_nasm
[100%]: build ok
```

There was no prepare callback, no detection, and no error.

## 3. `none` follows the same lifecycle

A plain phony target that does not request a tool initializes nothing.

When another phony target actually calls:

```lua
target:tool("cc")
```

observed:

```text
PREPARE none
NONE USE nil nil
NONE USE2 nil nil
```

The callback runs once. `none` is not special-cased in `check()` or `_load()`.

## 4. Built-in toolchain can be prepared before first use

The global callback configured the path of a built-in assembler before its first use.

Observed:

```text
PREPARE nasm
SETUP nasm=.../nasm.exe
USE1 nasm .../nasm.exe
ASFLAGS -f win64
USE2 nasm .../nasm.exe
```

The important points are:

- prepare runs before the first actual use;
- the callback can mutate the toolchain object;
- repeated use does not repeat initialization;
- dynamically loaded tool configuration remains available (`ASFLAGS` in this test).

## 5. Explicit callback ordering

A custom toolchain used a real assembler executable and printed each lifecycle phase.

Observed:

```text
PREPARE probe
CHECK probe prepared=yes
LOAD probe
USE1 nasm .../nasm.exe
USE2 nasm .../nasm.exe
```

This verifies exactly:

```text
prepare -> check -> load -> use
```

and verifies one-shot initialization.

---

# Why `load = false` is enough for config aggregation

The minimal patch intentionally does not use conditions such as:

```lua
load = toolchain_inst:_is_loaded() and true or false
```

That is unnecessary.

`toolchain:get()` first reads the current info object:

```lua
local value = self:info():get(name)
if value ~= nil then
    return value
end
```

Therefore:

```lua
get(name, {load = false})
```

has exactly the wanted behavior:

- static descriptor value: returned;
- value added by an earlier real `on_load`: returned;
- missing value on an unused candidate: returns nil without initializing it.

This gives lazy candidate aggregation with one generic flag and no lifecycle branching.

---

# Scope

The proposal deliberately does not attempt to redesign every config/check subsystem.

It changes only what is necessary for the invariant:

> toolchain initialization occurs because something in the selected build actually uses the toolchain.

Standalone `xmake config` retains the existing all-target configuration behavior. The build path uses the already existing root/dependency jobgraph.

The generic API checker optimization is included because it prevents dynamic valid-value callbacks from running for APIs that are not set at all; this is independently useful and avoids turning passive validation into accidental toolchain use.

---

# Suggested upstream tests

1. Unrelated target with an unavailable custom toolchain does not affect `xmake build <other-target>`.
2. Config jobs execute for the requested roots and dependencies only.
3. Default/group target selection still matches the existing build root selection.
4. Declaring a toolchain does not call its prepare/check/load hooks.
5. First `tool()` call produces `prepare -> check -> load` exactly once.
6. A dynamic `get()` that genuinely needs `on_load` follows the same lifecycle.
7. `toolconfig()` does not initialize unused candidate toolchains.
8. A previously loaded toolchain still contributes its dynamic config values.
9. A phony target with no real tool use initializes no platform compiler.
10. `none`, when explicitly used, receives the same global prepare callback and naturally resolves no tools.
11. API validation does not invoke a dynamic valid-values callback when the API value is absent.
12. Run the same tests on at least two host/platform families to ensure no hidden platform dependency was introduced.

---

# Conclusion

The reduced patch has one simple model:

```text
build selects target graph
        |
        v
only selected config jobs execute
        |
        v
toolchain descriptors remain passive
        |
        v
first real use
        |
        v
global prepare -> check -> load
```

No Windows/MSVC/NASM/GCC/etc. condition is needed in the implementation.

The patch reuses Xmake's existing target jobgraph instead of implementing another dependency traversal and keeps candidate toolchains passive by using the existing `get(..., {load = false})` mechanism during configuration aggregation.
