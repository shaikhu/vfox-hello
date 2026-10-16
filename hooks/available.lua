--- Return all available versions provided by this plugin.
---
--- A real plugin queries an upstream index here and returns whatever versions
--- that reports, independently of PLUGIN.version — see vfox-nodejs, whose
--- plugin version is unrelated to the Node.js versions it serves.
---
--- This plugin has no upstream: PostInstall generates the payload, so the
--- plugin *is* the tool. The installable version is therefore taken straight
--- from PLUGIN.version rather than repeated as a literal, which keeps the
--- release, the plugin and the tool version from drifting apart.
---
--- @param ctx table Empty table used as context, for future extension
--- @return table Descriptions of available versions
function PLUGIN:Available(ctx)
    return {
        {
            version = PLUGIN.version,
            note = "latest",
        },
    }
end
