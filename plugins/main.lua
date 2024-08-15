-- Aphelion v1.0.2

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for _, m in pairs(mods) do if type(m) == "table" and m.RoRR_Modding_Toolkit then Actor = m.Actor Buff = m.Buff Callback = m.Callback Helper = m.Helper Instance = m.Instance Item = m.Item Net = m.Net Object = m.Object Player = m.Player Resources = m.Resources Survivor = m.Survivor break end end end)

PATH = _ENV["!plugins_mod_folder_path"].."/plugins/"
-- Remove "/plugins" from PATH when uploading to Thunderstore



-- ========== Main ==========

function __initialize()
    gm.translate_load_file(gm.variable_global_get("_language_map"), PATH.."language/english.json")

    -- Require all files in items folder
    local names = path.get_files(PATH.."items")
    for _, name in ipairs(names) do require(name) end
end



-- gui.add_imgui(function()
--     if ImGui.Begin("Debug") then
--         local selectMenu = Instance.find(gm.constants.oSelectMenu)
--         local class_achievement = gm.variable_global_get("class_achievement")

        
--         if ImGui.Button("Add Achievement") then
--             local ach = gm.achievement_create("rmt", "test_achievement")

--             local item = Item.find("aphelion-sixShooter")
--             --gm.array_set(class_achievement, Achievement.PROPERTY.unlock_id)
--             gm.achievement_set_unlock_item(ach, item)
--             gm.achievement_set_requirement(ach, 10)

        
--         elseif ImGui.Button("Add Achievement progress") then
--             local ach = gm.achievement_find("rmt-test_achievement")

--             gm.achievement_add_progress(ach, 1)

        
--         elseif ImGui.Button("Add Achievement progress Gasoline") then
--             local ach = gm.achievement_find("ror-unlock_gasoline")

--             gm.achievement_add_progress(0, 1)


--         end
--     end
--     ImGui.End()
-- end)



-- gm.post_script_hook(gm.constants.achievement_add_progress, function(self, other, result, args)
--     Helper.log_hook(self, other, result, args)
-- end)