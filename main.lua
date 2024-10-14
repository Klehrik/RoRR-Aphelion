-- Aphelion

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto()

PATH = _ENV["!plugins_mod_folder_path"].."/"



-- ========== Main ==========

Initialize(function()
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
end)