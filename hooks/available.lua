local util = require("util")

--- Return all available versions provided by this plugin.
---
--- A real plugin queries an upstream index here and returns whatever it
--- reports, independently of PLUGIN.version -- vfox-nodejs at plugin version
--- 0.5.0 serves every Node.js release. This plugin has no upstream, so the
--- list lives in lib/util.lua, but it is still the TOOL's versions and has
--- nothing to do with the plugin's own version.
---
--- @param ctx table Empty table used as context, for future extension
--- @return table Descriptions of available versions
function PLUGIN:Available(ctx)
    local result = {}
    for _, v in ipairs(util.versions) do
        table.insert(result, {
            version = v.version,
            note = v.note,
        })
    end
    table.sort(result, util.compare_versions)
    return result
end
