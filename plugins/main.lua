-- Aphelion v1.2.0

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for _, m in pairs(mods) do if type(m) == "table" and m.RoRR_Modding_Toolkit then Actor = m.Actor Alarm = m.Alarm Buff = m.Buff Callback = m.Callback Equipment = m.Equipment Helper = m.Helper Instance = m.Instance Item = m.Item Net = m.Net Object = m.Object Player = m.Player Resources = m.Resources Survivor = m.Survivor
    survivor_setup = m.survivor_setup
    break end end end)

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
        "skills"
    }
    for _, folder in ipairs(folders) do
        local names = path.get_files(PATH..folder)
        for _, name in ipairs(names) do require(name) end
    end
end