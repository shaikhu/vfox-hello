--- Return all available versions provided by this plugin.
--- A real plugin would query a remote API here; this one is deliberately static.
--- @param ctx table Empty table used as context, for future extension
--- @return table Descriptions of available versions
function PLUGIN:Available(ctx)
    return {
        {
            version = "1.0.0",
            note = "latest",
        },
    }
end
