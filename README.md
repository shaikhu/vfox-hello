# vfox-hello

A minimal [vfox](https://vfox.dev) plugin. It installs a single `hello` command that prints a greeting.

## Layout

```
metadata.lua              plugin name, version, homepage, license, description
hooks/available.lua       which versions exist          (required)
hooks/pre_install.lua     what to install               (required)
hooks/env_keys.lua        what goes on PATH             (required)
hooks/post_install.lua    writes bin/hello              (optional)
```

## Versions

`available.lua` returns `PLUGIN.version`, so the release tag, the plugin version
and the installable tool version are always the same number. Only the current
version is installable.

That is specific to this plugin: it has no upstream, and `post_install.lua`
generates the payload, so the plugin *is* the tool. Real plugins keep the two
independent — `vfox-nodejs` at 0.5.0 serves every Node.js release, because its
`available.lua` queries the upstream index. Do not copy the coupling.

## Try it

vfox only accepts a `.zip` or a single `.lua`, not a directory, so package it
first:

```shell
zip -r /tmp/vfox-hello.zip metadata.lua hooks LICENSE
vfox add --source /tmp/vfox-hello.zip
vfox search hello
vfox install hello@0.1.0
vfox use hello@0.1.0
hello
```

Expected output:

```
Hello, World! (hello 0.1.0)
```

## Publishing

Releases are produced by the shared workflow in
[.github/workflows/publish.yaml](.github/workflows/publish.yaml).

```shell
gh workflow run publish.yaml --repo shaikhu/vfox-hello --ref main -f version=0.1.0
```

That bumps `PLUGIN.version`, commits it, tags `vX.Y.Z`, packages the plugin zip and
publishes a release alongside a `manifest.json`. A second, permanent `manifest` tag
holds the current `manifest.json`, whose `downloadUrl` points at the versioned zip —
that manifest URL is the stable address other tooling consumes.

Installing straight from a published release:

```shell
vfox add --source https://github.com/shaikhu/vfox-hello/releases/download/v0.1.0/vfox-hello-0.1.0.zip
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
  "test": { "version": "0.1.0", "check": "hello", "resultRegx": "Hello, World!" }
}
```
