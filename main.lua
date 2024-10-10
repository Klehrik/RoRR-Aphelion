-- Aphelion

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for _, m in pairs(mods) do if type(m) == "table" and m.RoRR_Modding_Toolkit then for _, c in ipairs(m.Classes) do if m[c] then _G[c] = m[c] end end end end end)

PATH = _ENV["!plugins_mod_folder_path"].."/"



-- ========== Main ==========

function __initialize()
    -- Require all files in content folders
    local folders = {
        "items",
        "equipment",
        -- "skills"
    }
    for _, folder in ipairs(folders) do
        local names = path.get_files(PATH..folder)
        for _, name in ipairs(names) do require(name) end
    end

    -- Huntress : Set Stealth Hunting upgrade
    -- local skill = Skill.find("aphelion-huntressStealth")
    -- skill.upgrade_skill = Skill.find("aphelion-huntressStealthBoosted")
end