-- Aphelion

local envy = mods["LuaENVY-ENVY"]
envy.auto()
mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto()
Cooldown = mods["Klehrik-CooldownHelper"].setup()
Curse = mods["Klehrik-CurseHelper"].setup()

PATH = _ENV["!plugins_mod_folder_path"].."/"

banlist = mods["Klehrik-Lost_in_Orbit"].aphelion_banlist



-- ========== Main ==========

Initialize(function()
    -- Require all files in content folders
    local folders = {
        "items",
        "equipment",
        "skills"
    }
    for _, folder in ipairs(folders) do
        local names = path.get_files(PATH..folder)
        for _, name in ipairs(names) do
            if  banlist[folder]
            and (not Helper.table_has(banlist[folder], path.stem(name))) then
                require(name)
            end
        end
    end

    -- Misc
    require("./misc")
end)