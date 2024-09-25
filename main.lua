-- Aphelion v1.2.0

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for _, m in pairs(mods) do if type(m) == "table" and m.RoRR_Modding_Toolkit then Achievement = m.Achievement Actor = m.Actor Alarm = m.Alarm Array = m.Array Artifact = m.Artifact Buff = m.Buff Callback = m.Callback Class = m.Class Color = m.Color Equipment = m.Equipment Helper = m.Helper Instance = m.Instance Interactable = m.Interactable Item = m.Item Language = m.Language List = m.List Net = m.Net Object = m.Object Player = m.Player Resources = m.Resources Skill = m.Skill State = m.State Survivor_Log = m.Survivor_Log Survivor = m.Survivor Wrap = m.Wrap break end end end)

Aphelion = true

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
    -- local skill = Actor.find_skill_id("aphelion-huntressStealth")
    -- local skill_upg = Actor.find_skill_id("aphelion-huntressStealthBoosted")
    -- gm.array_set(gm.array_get(Class.SKILL, skill), 29, skill_upg)
end