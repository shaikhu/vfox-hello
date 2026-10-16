--- Returns pre-installation information for the requested version.
---
--- No `url` is returned, so vfox creates the installation directory and
--- downloads nothing; PostInstall then provides the entire payload. A plugin
--- that installs real software returns `url` here, plus a checksum that vfox
--- verifies for you.
---
--- @param ctx table
--- @field ctx.version string User-input version
--- @return table Version information
function PLUGIN:PreInstall(ctx)
    local version = ctx.version
    local available = self:Available({})

    if version == "latest" then
        version = available[1].version
    end

    for _, candidate in ipairs(available) do
        if candidate.version == version then
            return {
                version = version,
            }
        end
    end

    error("version not found for provided version " .. (ctx.version or "null"))
end
