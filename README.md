# vfox-hello

A minimal [vfox](https://vfox.dev) plugin. It installs a single `hello` command that prints a greeting.

## Layout

```
metadata.lua              plugin name, version, homepage, license, description
hooks/available.lua       which tool versions exist     (required)
hooks/pre_install.lua     what to install               (required)
hooks/env_keys.lua        what goes on PATH             (required)
hooks/post_install.lua    writes bin/hello              (optional)
lib/util.lua              the version list and sorting  (auto-loaded)
```

Only `Available`, `PreInstall` and `EnvKeys` are required. Unused optional hooks
must be deleted rather than left as stubs. Anything in `lib/` is importable with
`require`, so `hooks/available.lua` does `require("util")`.

## Versions

A vfox plugin has two unrelated version numbers:

| | Where | What it versions |
|---|---|---|
| Plugin version | `PLUGIN.version` in `metadata.lua`, released as tag `vX.Y.Z` | the Lua code |
| Tool version | whatever `available.lua` returns | the software being installed |

They are independent. This plugin is at `0.2.0` and offers the tool at `1.0.0`,
`1.1.0` and `2.0.0`; `vfox install hello@0.2.0` is correctly rejected, because
`0.2.0` is not a version of the *tool*.

The same holds upstream: `vfox-nodejs` at plugin version 0.5.0 serves every
Node.js release, because its `available.lua` queries the Node.js dist index over
HTTP. A real plugin never hardcodes versions — it reports what upstream says.
The list in `lib/util.lua` is static only because this demo has no upstream.

## Try it

vfox only accepts a `.zip` or a single `.lua`, not a directory, so package it
first:

```shell
zip -r /tmp/vfox-hello.zip metadata.lua hooks lib LICENSE
vfox add --source /tmp/vfox-hello.zip
vfox search hello
vfox install hello@1.1.0
vfox install hello@latest
vfox use hello@1.1.0
hello
```

Expected output:

```
Hello, World! (hello 1.1.0)
```

Versions install side by side, which is the point of a version manager:
`vfox use hello@2.0.0` then `hello` prints `Hello, World! (hello 2.0.0)`.

## Publishing

Releases are produced by the shared workflow in
[.github/workflows/publish.yaml](.github/workflows/publish.yaml).

```shell
gh workflow run publish.yaml --repo shaikhu/vfox-hello --ref main -f version=0.2.0
```

That bumps `PLUGIN.version`, commits it, tags `vX.Y.Z`, packages the plugin zip and
publishes a release alongside a `manifest.json`. A second, permanent `manifest` tag
holds the current `manifest.json`, whose `downloadUrl` points at the versioned zip —
that manifest URL is the stable address other tooling consumes.

Installing straight from a published release:

```shell
vfox add --source https://github.com/shaikhu/vfox-hello/releases/download/v0.2.0/vfox-hello-0.2.0.zip
```

## Registry submission

Listing in the public registry, which enables the shorter `vfox add hello`, is a
separate one-time pull request to
[version-fox/vfox-plugins](https://github.com/version-fox/vfox-plugins) adding a
`sources/hello.json` pointer:

```json
{
  "name": "hello",
  "manifestUrl": "https://github.com/shaikhu/vfox-hello/releases/download/manifest/manifest.json",
  "test": { "version": "2.0.0", "check": "hello", "resultRegx": "Hello, World!" }
}
```
