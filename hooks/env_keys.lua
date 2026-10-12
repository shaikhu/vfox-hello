--- Configure the environment variables for an installed version.
--- @param ctx table Context information
--- @field ctx.path string Installation directory of this version
--- @return table Environment variables to set
function PLUGIN:EnvKeys(ctx)
    return {
        {
            key = "PATH",
            value = ctx.path .. "/bin",
        },
    }
end
