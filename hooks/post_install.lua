--- Write the `hello` command into the freshly created installation directory.
--- PreInstall downloads nothing, so this hook supplies the whole payload.
--- @param ctx table Context information
--- @field ctx.rootPath string Installation root directory
function PLUGIN:PostInstall(ctx)
    local sdkInfo = ctx.sdkInfo[self.name]
    local bin = sdkInfo.path .. "/bin"
    local greeting = "Hello, World! (" .. self.name .. " " .. sdkInfo.version .. ")"

    if RUNTIME.osType == "windows" then
        os.execute('mkdir "' .. bin .. '"')
        local script = assert(io.open(bin .. "/hello.cmd", "w"))
        script:write("@echo off\r\n")
        script:write("echo " .. greeting .. "\r\n")
        script:close()
    else
        os.execute('mkdir -p "' .. bin .. '"')
        local script = assert(io.open(bin .. "/hello", "w"))
        script:write("#!/bin/sh\n")
        script:write("echo '" .. greeting .. "'\n")
        script:close()
        os.execute('chmod 755 "' .. bin .. '/hello"')
    end
end
