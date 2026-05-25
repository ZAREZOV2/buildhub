local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
Junkie.service = "BuildHub"
Junkie.identifier = "1112148"
Junkie.provider = "BuildHub"

WindUI.Services.junkiedevelopment = {
    Name = "Junkie Development", 
    Icon = "shield-check",
    Args = { "ServiceId", "ApiKey", "Provider" },

    New = function()
        local function Verify(key)
            local result = Junkie.check_key(key)
            if result and result.valid then
                if result.message == "KEYLESS" then
                    getgenv().SCRIPT_KEY = "KEYLESS"
                    return true, "Keyless mode"
                elseif result.message == "KEY_VALID" then
                    getgenv().SCRIPT_KEY = key
                    return true, "Key valid"
                else
                    return false, "Invalid key"
                end
            end
        end

        local function Copy()
            local link = Junkie.get_key_link()
            if setclipboard then setclipboard(link) end
            return link
        end

        return { Verify = Verify, Copy = Copy }
    end
}

local Window = WindUI:CreateWindow({
    Title = "BuildHub",
    Theme = "Dark",
    Transparent = true,
    Resizable = true,

    KeySystem = {
        Note = "Enter your key to continue.",
        SaveKey = true,
        API = {
            {
                Title = "Junkie",
                Desc  = "Click to copy link",
                Icon  = "key-round",
                Type  = "junkiedevelopment"
            }
        }
    }
})

getgenv().WindUI = WindUI
getgenv().BuildHubWindow = Window

while not getgenv().SCRIPT_KEY do
    task.wait(0.1)
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/ZAREZOV2/buildhub/refs/heads/main/buildhub.luau"))()
