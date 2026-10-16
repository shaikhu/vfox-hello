local util = {}

--- Versions of the `hello` tool that this plugin can install.
---
--- A real plugin does not hold a list like this: it fetches the versions from
--- an upstream index at runtime. See vfox-nodejs, whose `Available` hook calls
--- `http.get` on the Node.js dist index and maps the response. The list is
--- static here only because this demo plugin has no upstream.
---
--- These are versions of the TOOL. They are deliberately unrelated to
--- PLUGIN.version, which versions the plugin itself.
util.versions = {
    { version = "1.0.0", note = "" },
    { version = "2.0.0", note = "latest" },
    { version = "1.1.0", note = "LTS" },
}

local function parts(version)
    local numbers = {}
    for n in tostring(version):gmatch("%d+") do
        table.insert(numbers, tonumber(n))
    end
    return numbers
end

--- Order two Available entries newest first, so Available()[1] is the latest.
function util.compare_versions(a, b)
    local left, right = parts(a.version), parts(b.version)
    for i = 1, math.max(#left, #right) do
        local l, r = left[i] or 0, right[i] or 0
        if l ~= r then
            return l > r
        end
    end
    return false
end

return util
