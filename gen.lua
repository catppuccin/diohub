local cp = require("catppuccin")

if not cp[arg[1]] then
    error(("invalid flavor: '%s'"):format(arg[1]))
end

if arg[2] and not (arg[2] == "link" or arg[2] == "md") then
    error(("invalid generate type: '%s'"):format(arg[2]))
end

local function table_copy(tbl)
    local new_tbl = {}
    for k, v in pairs(tbl) do
        new_tbl[k] = v
    end
    return new_tbl
end

local flavor_name, gentype = arg[1], arg[2] or "link"

local accent_colors = {
    "rosewater",
    "flamingo",
    "pink",
    "mauve",
    "red",
    "maroon",
    "peach",
    "yellow",
    "green",
    "teal",
    "sky",
    "sapphire",
    "blue",
    "lavender",
    "text",
}

local flavor = {}
for k, v in pairs(cp[flavor_name]()) do
    if k ~= "name" then
        flavor[k] = v.hex:sub(2)
    end
end

local url = "https://theme.felix.diohub?format_ver=0"
local url_table = {
    primary = flavor.base,
    secondary = flavor.crust,
    baseElements = flavor.subtext0,
    elementsOnColors = flavor.subtext1,
    green = flavor.green,
    red = flavor.red,
    faded1 = flavor.overlay0,
    faded2 = flavor.overlay1,
    faded3 = flavor.overlay2,
}

local flavor_emote = {
    latte = "🌻",
    frappe = "🪴",
    macchiato = "🌺",
    mocha = "🌿",
}

local accent_url = {}
local acci = 1
for _, acc in ipairs(accent_colors) do
    local ut = table_copy(url_table)
    ut.accent = flavor[acc]
    accent_url[acci] = url

    for pname, phex in pairs(url_table) do
        accent_url[acci] = accent_url[acci] .. ("&%s=ff%s"):format(pname, phex)
    end

    if gentype == "link" then
        print(("\n[\x1b[1m%s\x1b[0m]"):format(acc:upper()))
        print(accent_url[acci])
    end
    acci = acci + 1
end

if gentype == "md" then
    print(([[
<details>
<summary>%s %s</summary>
]]):format(flavor_emote[flavor_name], flavor_name:sub(1, 1):upper() .. flavor_name:sub(2)))
    for i, v in ipairs(accent_url) do
        local accent_name = accent_colors[i]
        local accent_uname = accent_name:sub(1, 1):upper() .. accent_name:sub(2)
        print(
            ([[- <img alt="%s" src="https://github.com/catppuccin/catppuccin/raw/main/assets/palette/circles/%s.png" height="12" weight="12"> **<a href="%s">&nbsp;%s</a>**]]):format(
                flavor_name:sub(1, 1):upper() .. flavor_name:sub(2) .. " " .. accent_uname,
                flavor_name .. "_" .. accent_name,
                v,
                accent_uname
            )
        )
    end
    print("</details>")
end
