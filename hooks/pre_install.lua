--- Return the version to install.
--- No `url` is returned, so vfox creates the installation directory and
--- downloads nothing. PostInstall then provides the entire payload.
--- @param ctx table
--- @field ctx.version string User-input version
--- @return table Version information
function PLUGIN:PreInstall(ctx)
    local requested = ctx.version
    local available = self:Available({})

    if requested == "latest" then
        return { version = available[1].version }
    end

    for _, candidate in ipairs(available) do
        if candidate.version == requested then
            return { version = requested }
        end
    end

    error("version " .. tostring(requested) .. " is not available")
end
