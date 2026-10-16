# Two version numbers: the plugin and the tool

Notes on the single most confusing thing about vfox plugins, written against this
repository so every claim can be checked by running something.

## The short version

A vfox plugin is a small program that knows **how to find and install** some
software. The plugin has a version. The software has versions. They are
different things that both happen to have version numbers.

|  | The plugin | The tool |
|---|---|---|
| What it is | ~6 Lua files | the actual software |
| Declared in | `PLUGIN.version` in `metadata.lua` | whatever `available.lua` returns |
| Versioned by | the plugin author | the software's authors |
| Published as | a GitHub release of the plugin repo | wherever the software ships |

## The analogy: SDKMAN

```
SDKMAN itself     ->  5.18.2
What it installs  ->  java 21.0.1, maven 3.9.6, groovy 4.0.18
```

Nobody thinks `maven 3.9.6` is a version of SDKMAN. A vfox plugin is the same
idea, scoped to one tool.

## Real example: vfox-nodejs

```
Plugin version:  0.5.0
Tool versions:   24.9.0, 22.11.0, 20.18.0, ... every Node.js release
```

`vfox install nodejs@22.11.0` installs **Node.js 22.11.0**. The plugin doing the
installing is at **0.5.0**. One plugin, hundreds of installable Node versions.

The changelog for plugin v0.5.0 contains this entry:

> Fix trailing slash in VFOX_NODEJS_MIRROR causing double slashes in URL paths

That is a bug in **the Lua code**. Node.js did not change. The authors fixed
their code and shipped plugin 0.5.0; every Node version stayed installable
before and after.

## This repository

```
Plugin version:  0.2.0                  metadata.lua
Tool versions:   1.0.0, 1.1.0, 2.0.0    lib/util.lua
```

So this is correct behaviour, not a bug:

```console
$ vfox install hello@0.2.0
version not found for provided version 0.2.0
```

`0.2.0` is the *plugin's* version. There is no *tool* called hello at 0.2.0.

Caveat specific to this demo: the tool versions here are fiction.
`post_install.lua` writes the `hello` script itself and interpolates whatever
version was asked for; nothing is downloaded. In vfox-nodejs, `available.lua`
does an `http.get` against the Node.js dist index, so its versions are real.

## Why `hello@1.0.0` works when GitHub only shows `v0.2.0`

Because the GitHub release and the tool version live in different places.

```
GitHub release v0.2.0
      |
      |  contains -> vfox-hello-0.2.0.zip   (only Lua files, no software)
      |
      v
lib/util.lua declares: 1.0.0, 1.1.0, 2.0.0
      |
      v
vfox search hello  ->  2.0.0 (latest), 1.1.0 (LTS), 1.0.0
      |
      v
vfox install hello@1.0.0   OK
```

**GitHub hosts the plugin. The plugin declares the tool versions.** GitHub has no
idea what versions of `hello` exist; only the Lua inside the zip knows.

Two separate questions, two separate answers:

- *What plugin versions exist?* -> ask GitHub -> `v0.2.0`
- *What tool versions can I install?* -> ask the plugin -> `1.0.0, 1.1.0, 2.0.0`

Same split for vfox-nodejs: GitHub lists `v0.5.0, v0.4.1, v0.4.0...` while
`vfox search nodejs` lists hundreds of Node releases. The two lists are
unrelated.

## Check it yourself

```shell
# 1. what GitHub hosts: releases of the PLUGIN
gh release list --repo shaikhu/vfox-hello

# 2. what is inside that release: only Lua
curl -sL -o /tmp/p.zip \
  https://github.com/shaikhu/vfox-hello/releases/download/v0.2.0/vfox-hello-0.2.0.zip
unzip -l /tmp/p.zip

# 3. the plugin's own version, from inside the zip
unzip -p /tmp/p.zip metadata.lua | grep PLUGIN.version

# 4. the TOOL versions the same zip declares
unzip -p /tmp/p.zip lib/util.lua | grep 'version ='

# 5. what vfox therefore offers
vfox search hello

# 6. the plugin version is not a tool version
vfox install hello@0.2.0     # fails, correctly
```

## Why this matters for JReleaser

When JReleaser generates a vfox plugin for a project, the mapping is:

```
Tool version    = YOUR project's version   (jreleaser 1.25.0)  -> {{projectVersion}}
Plugin version  = the generated Lua's version                   -> its own property
```

Two mistakes are easy to make, and both are expensive.

### Mistake 1: `PLUGIN.version = "{{projectVersion}}"`

Every release of your software would publish a "new plugin version", even though
the generated Lua is byte-identical. The public registry re-reads plugin
manifests hourly, so this churns it for nothing and tells users "plugin updated"
when nothing changed.

Correct: a dedicated `vfox.pluginVersion` config property, bumped only when the
template itself changes.

### Mistake 2: hardcoding the version in `available.lua`

```lua
version = "{{projectVersion}}"   -- plugin can then only ever install that one version
```

You would have to republish the plugin on every release, forever. Instead the
generated `available.lua` should query the project's releases at install time,
the way vfox-nodejs queries the Node.js index.

This is why JReleaser's existing **asdf** packager does a placeholder
substitution. From `AsdfPackagerProcessor.java`:

```java
String str = props.get(KEY_DISTRIBUTION_URL);
str = str.replace(context.getModel().getProject().getEffectiveVersion(), "$version");
props.set(KEY_ASDF_DISTRIBUTION_URL, str);
```

It takes the concrete download URL, which contains `1.25.0`, and swaps the
version back out for a `$version` placeholder so the **generated script**
substitutes whatever the user asks for at install time. A vfox packager needs
the same trick with `ctx.version` in place of `$version`.

### The payoff

Get both right and the generated plugin is **version-independent**: generated
once, installs every past and future release.

```
JReleaser generates plugin -> commits to your plugin repo -> barely changes per release
vfox install yourtool@1.26.0 -> works, with no new plugin release
```

A consequence worth remembering: because the plugin barely changes, regenerating
it on every release usually produces a **no-op diff** on the plugin repo. The
asdf packager already behaves this way, and the publish path is wrapped in
`catch (Exception) -> warn`, so it cannot fail a release.

## One-line summary

> The plugin version says *how old the installer is*.
> The tool version says *what you are installing*.
> GitHub releases version the installer, never the tool.
