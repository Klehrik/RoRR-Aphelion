-- Aphelion v1.0.0
-- Klehrik

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for _, m in pairs(mods) do if type(m) == "table" and m.RoRR_Modding_Toolkit then Actor = m.Actor Buff = m.Buff Callback = m.Callback Helper = m.Helper Instance = m.Instance Item = m.Item Net = m.Net Player = m.Player Resources = m.Resources Survivor = m.Survivor break end end end)

PATH = _ENV["!plugins_mod_folder_path"].."/plugins/"
-- Remove "/plugins" from PATH when uploading to Thunderstore

-- Testing
require("./testing")



-- ========== Main ==========

function __initialize()
    gm.translate_load_file(gm.variable_global_get("_language_map"), PATH.."language/english.json")

    -- Require all files in /plugins/items
    local names = path.get_files(PATH.."items")
    for _, name in ipairs(names) do require(name) end
end