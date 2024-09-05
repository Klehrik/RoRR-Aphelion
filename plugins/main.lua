-- Aphelion v1.2.0

log.info("Successfully loaded ".._ENV["!guid"]..".")
-- mods.on_all_mods_loaded(function() for _, m in pairs(mods) do if type(m) == "table" and m.RoRR_Modding_Toolkit then Actor = m.Actor Alarm = m.Alarm Buff = m.Buff Callback = m.Callback Class = m.Class Helper = m.Helper Instance = m.Instance Item = m.Item Net = m.Net Object = m.Object Player = m.Player Resources = m.Resources Survivor = m.Survivor
--     survivor_setup = m.survivor_setup
--     break end end end)
mods.on_all_mods_loaded(function() for _, m in pairs(mods) do if type(m) == "table" and m.RoRR_Modding_Toolkit then Actor = m.Actor Alarm = m.Alarm Buff = m.Buff Callback = m.Callback Class = m.Class Color = m.Color Equipment = m.Equipment Helper = m.Helper Instance = m.Instance Item = m.Item Net = m.Net Object = m.Object Player = m.Player Resources = m.Resources Skill = m.Skill Survivor = m.Survivor break end end end)

Aphelion = true

PATH = _ENV["!plugins_mod_folder_path"].."/plugins/"
-- Remove "/plugins" from PATH when uploading to Thunderstore



-- ========== Main ==========

function __initialize()
    gm.translate_load_file(gm.variable_global_get("_language_map"), PATH.."language/english.json")

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
    -- local skill = Actor.find_skill_id("aphelion-huntressStealth")
    -- local skill_upg = Actor.find_skill_id("aphelion-huntressStealthBoosted")
    -- gm.array_set(gm.array_get(Class.SKILL, skill), 29, skill_upg)
end