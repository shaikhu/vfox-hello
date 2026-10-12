# vfox-plugin (hello)

A minimal [vfox](https://vfox.dev) plugin. It installs a single `hello` command that prints a greeting.

## Layout

```
metadata.lua              plugin name, version, homepage, license, description
hooks/available.lua       which versions exist          (required)
hooks/pre_install.lua     what to install               (required)
hooks/env_keys.lua        what goes on PATH             (required)
hooks/post_install.lua    writes bin/hello              (optional)
```

## Try it

```shell
vfox add --source /path/to/this/repo
vfox available hello
vfox install hello@1.0.0
vfox use hello@1.0.0
hello
```

Expected output:

```
Hello, World! (hello 1.0.0)
```

## Publishing

Releases are produced by the shared workflow in
[.github/workflows/publish.yaml](.github/workflows/publish.yaml).

```shell
gh workflow run publish.yaml --repo shaikhu/vfox-plugin --ref main -f version=1.0.0
```

That bumps `PLUGIN.version`, commits it, tags `vX.Y.Z`, packages the plugin zip and
publishes a release alongside a `manifest.json`. A second, permanent `manifest` tag
holds the current `manifest.json`, whose `downloadUrl` points at the versioned zip —
that manifest URL is the stable address other tooling consumes.

Installing straight from a published release:

```shell
vfox add --source https://github.com/shaikhu/vfox-plugin/releases/download/v1.0.0/vfox-plugin-1.0.0.zip
```

## Registry submission

Listing in the public registry, which enables the shorter `vfox add hello`, is a
separate one-time pull request to
[version-fox/vfox-plugins](https://github.com/version-fox/vfox-plugins) adding a
`sources/hello.json` pointer:

```json
{
  "name": "hello",
  "manifestUrl": "https://github.com/shaikhu/vfox-plugin/releases/download/manifest/manifest.json",
  "test": { "version": "1.0.0", "check": "hello", "resultRegx": "Hello, World!" }
}
```
