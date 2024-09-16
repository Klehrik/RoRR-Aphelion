-- Testing
gui.add_imgui(function()
    if ImGui.Begin("Aphelion Debug") then


        if ImGui.Button("Buff create") then
            local buff = Buff.create("aphelion", "testBuff")

            Buff.set_property(buff, Buff.PROPERTY.max_stack, 10)

            Buff.add_callback(buff, "onApply", function(actor, stack)
                actor.hp = 10.0 * stack
            end)

        elseif ImGui.Button("Apply customBuff") then
            --log.info(Buff.find("aphelion-testBuff"))
            Buff.apply(Player.get_client(), Buff.find("aphelion-testBuff"), 300.0, 5)
            --Buff.apply(Player.get_client(), Buff.find("aphelion-overloadedCapacitor"), 2)

        elseif ImGui.Button("Apply 1 Standoff") then
            Buff.apply(Player.get_client(), 36, 300.0)

        elseif ImGui.Button("Apply 1 Standoff shorter") then
            Buff.apply(Player.get_client(), 36, 120.0)

        elseif ImGui.Button("Remove 2 Standoff") then
            Buff.remove(Player.get_client(), 36, 2)
            --gm.remove_buff(Player.get_client(), 36, 2)

        
        elseif ImGui.Button("Log") then
            local player = Player.get_client()

            player.critical_chance = player.critical_chance + 100.0

            --log.info(gm.is_struct(player.component_data))

            --local names = gm.struct_get_names(player.component_data)
            log.info(player.component_data)
            local names = gm.ds_map_keys_to_array(player.component_data)
            for _, n in ipairs(names) do
                log.info(n.." = "..tostring(gm.ds_map_find_value(player.component_data, n)))
            end
            log.info("")

            -- local names = gm.ds_map_keys_to_array(player.component_scripts)
            for _, n in ipairs(player.component_scripts) do
                log.info(n)
                n()
                --log.info(gm.ds_priority_size(n))
                --log.info(gm.ds_list_find_value(n, 0))
                --log.info(n[1])
                --log.info(gm.ds_map_keys_to_array(n))
            end
            log.info("")

            -- local prop = Buff.get_property(Buff.find("ror-handDroneSpeed"), Buff.PROPERTY.stack_number_col)
            -- log.info(prop)
            -- for _, a in ipairs(prop) do
            --     log.info(a)
            -- end

            -- log.info("")

            -- local prop = Buff.get_property(Buff.find("aphelion-crimsonScarf"), Buff.PROPERTY.stack_number_col)
            -- log.info(prop)
            -- for _, a in ipairs(prop) do
            --     log.info(a)
            -- end

            --gm.remove_buff(Player.get_client(), 36, 2)

            -- local item_log_order = gm.variable_global_get("item_log_display_list")
            -- -- for i = 0, gm.ds_list_size(item_log_order) - 1 do
            -- --     log.info(gm.ds_list_find_value(item_log_order, i))
            -- -- end
            -- -- log.info(gm.ds_list_find_index(item_log_order, 35))
            
            -- local num = Item.find("aphelion-overloadedCapacitor")
            -- log.info(num)
            -- log.info(gm.ds_list_find_index(item_log_order, num))

            -- gm.ds_list_insert(item_log_order, 0, 100)


        elseif ImGui.Button("Damage inflict to player") then
            local player = Player.get_client()
            --local target = Player.get_client()
            --gm.damage_inflict(target, 10.0, 0.0, nil, target.x, target.y - 36, 0.0, 1.0, 255255.0, true)

            Actor.damage(player, nil, 10.0, player.x - 26, player.y - 36)
        
        elseif ImGui.Button("Fire bullet") then
            local player = Player.get_client()
            --local damager = Actor.fire_bullet(player, player.x, player.y, 1.0, 400.0, 180.0, gm.constants.sSparks1)
            --local damager = Actor.fire_bullet(player, player.x, player.y, 180.0, 400.0, 1.0)
            --local damager = player:fire_bullet(0, player.x, player.y, true, 1.0, 400.0, -1, 180.0, 1.0, 1.0, -1.0)
            --damager.target_true = player

            local damager = player:fire_explosion(0, player.x, player.y, 1.0, -1, 2, -1, 2.5, 23)
            damager.stun = 2.0
            -- increments of 32(?) radius x and 8(?) radius y
            -- tile width/height then

            -- log.info((0.5 and 1) or 0)
            -- log.info(("yes" and 1) or 0)
            -- log.info((nil and 1) or 0)

            --damager.knockback_kind = 4

            --damager.hit_number = 20
            --damager.attack_flags = 1 << 5

            -- attack_flags
            -- 1 << 0 : ?
            -- 1 << 1 : Acrid thing (deals extra damage)
            -- 1 << 2 : ?
            -- 1 << 3 : noticeable hit effect
            -- 1 << 4 : Boxing Glove proc (deals extra damage)
            -- 1 << 5 : Ukelele proc
            -- 1 << 6 : pink number (Sniper perfect)
            -- 1 << 7 : dark pink number (Sniper half)
            -- 1 << 8 : ?
            -- 1 << 9 : ?
            -- 1 << 10 : Generates scrap
            -- 1 << 11 : ?
            -- 1 << 12 : ?
            -- 1 << 13 : ?
            -- 1 << 14 : Commando Wound debuff
            -- 1 << 15 : ?
            -- 1 << 16 : ?
            -- 1 << 17 : ?
            -- 1 << 18 : ?
            -- 1 << 19 : ?
            -- 1 << 20 : ?
            -- 1 << 21 : debuff (weird Shustice)
            -- 1 << 22 : arti burn (flamethrower)
            -- 1 << 23 : ?
            -- 1 << 24 : Pilot alt V
            -- 1 << 25 : Pilot alt V upgraded
            -- 1 << 26 : ?
            -- 1 << 27 : arti burn (chakram)
            -- 1 << 28 to 65 : ?

            --gm.fire_bullet(0, player.x, player.y, 0, 1.0, 400.0, gm.constants.sSparks1, 180.0, 1.0, 1.0, -1.0)

            --log.info(player)
            --local damager = player:fire_bullet(0, player.x, player.y, 0, 10.0,   1400.0,    -1.0,   180.0, 1.0, 1.0, -1.0)
            --                      x          y      ? damage  range(px)  spr(hit)    dir    ?    ?     ?
            -- spr(hit) -1 to display no sprite

            --log.info(gm.sprite_get_name(1632.0))
            --log.info(damager.damage)
        

        elseif ImGui.Button("Heal 10 HP") then
            local player = Instance.find(gm.constants.oP)
            if player then
                Actor.heal(player, 10.0)
            end

            -- local hud = Instance.find(gm.constants.oHUD)
            -- if gm.is_struct(hud.player_hud_display_info[1].value) then
            --     local names = gm.struct_get_names(hud.player_hud_display_info[1].value)
            --     for j, name in ipairs(names) do
            --         log.info("    "..name.." = "..tostring(gm.variable_struct_get(hud.player_hud_display_info[1].value, name)))
            --     end
            -- end

            -- for k, v in ipairs(hud.player_hud_display_info) do
            --     log.info(v)
            --     if gm.is_struct(v) then
            --         local names = gm.struct_get_names(v)
            --         for j, name in ipairs(names) do
            --             log.info("    "..name.." = "..tostring(gm.variable_struct_get(v, name)))
            --         end
            --     end
            -- end

        elseif ImGui.Button("Heal 20 barrier") then
            local player = Player.get_client()
            if player then
                Actor.heal_barrier(player, 20.0)
            end


        elseif ImGui.Button("Drop custom item") then
            local player = Player.get_client()
            if player then
                --gm.item_drop_object(Item.get_data(Item.find("aphelion-ballisticVest")).object_id, player.x + 600, player.y, player, false)
                Item.spawn_drop(Item.find("aphelion-ballisticVest"), player.x, player.y, player)
            end


        elseif ImGui.Button("Create custom object") then
            local object = gm.object_add_w("test", "object", gm.constants.oCustomObject)
            log.info(object)

            local player = Player.get_client()
            if player then
                --local obj = gm.instance_create_depth(player.x, player.y, 0, gm.constants.oCustomObject_pInteractableCrate)
                --local obj = gm.item_drop_object(object, player.x, player.y, player, false)
            end


        end
    end
    ImGui.End()
end)


-- gm.pre_script_hook(gm.constants.fire_explosion, function(self, other, result, args)
--     Helper.log_hook(self, other, result, args)
-- end)

-- gm.post_script_hook(gm.constants.instance_create, function(self, other, result, args)
--     Helper.log_hook(self, other, result, args)
-- end)

-- gm.pre_script_hook(gm.constants.damage_inflict_raw, function(self, other, result, args)
--     -- Helper.log_hook(self, other, result, args)

--     local vars = gm.variable_instance_get_names(self)
--     for _, n in ipairs(vars) do
--         log.info(n.." = "..tostring(gm.variable_instance_get(self, n)))
--     end
--     log.info("")
-- end)

-- gm.pre_script_hook(gm.constants.damager_hit_process, function(self, other, result, args)
--     Helper.log_hook(self, other, result, args)
-- end)



-- local damage_real = 0.0

-- local go = false

-- gm.post_script_hook(gm.constants.item_drop_object, function(self, other, result, args)
--     Helper.log_hook(self, other, result, args)
-- end)

-- gm.post_script_hook(gm.constants.actor_heal_networked, function(self, other, result, args)
--     --Helper.log_hook(self, other, result, args)

--     go = false

--     local hud = Instance.find(gm.constants.oHUD)
--     for k, v in ipairs(hud.player_hud_display_info) do
--         log.info(v)
--         if gm.is_struct(v) then
--             local names = gm.struct_get_names(v)
--             for j, name in ipairs(names) do
--                 log.info("    "..name.." = "..tostring(gm.variable_struct_get(v, name)))
--             end
--         end
--     end
-- end)

-- gm.pre_script_hook(gm.constants.__input_system_tick, function(self, other, result, args)
--     if go then
--         go = false

--         local hud = Instance.find(gm.constants.oHUD)
--         for k, v in ipairs(hud.player_hud_display_info) do
--             log.info(v)
--             if gm.is_struct(v) then
--                 local names = gm.struct_get_names(v)
--                 for j, name in ipairs(names) do
--                     log.info("    "..name.." = "..tostring(gm.variable_struct_get(v, name)))
--                 end
--             end
--         end
--     end
-- end)

-- gm.pre_script_hook(gm.constants.damager_calculate_damage, function(self, other, result, args)
--     -- log.info("")
--     -- log.info("FIRST")
--     -- -- log.info("BULLET")
--     -- Helper.log_hook(self, other, result, args)

--     -- log.info(self)

--     damage_real = args[4].value

--     -- if self.target then log.info(gm.object_get_name(self.target.object_index)) end
--     -- if self.target_true then log.info("true") log.info(gm.object_get_name(self.target_true.object_index)) end

--     --damage_real = result.value.damage_true

--     --result.value.damage_fake = result.value.damage_true

--     --result.damage_fake = result.damage_true
-- end)

-- gm.post_script_hook(gm.constants.fire_explosion, function(self, other, result, args)
--     log.info("EXPLOSION")
--     Helper.log_hook(self, other, result, args)
-- end)

-- gm.pre_script_hook(gm.constants.run_create, function()
--     frame = 0
-- end)

-- gm.pre_script_hook(gm.constants.__input_system_tick, function()
--     frame = frame + 1
-- end)


-- local callbacks = {}
-- gm.post_script_hook(gm.constants.callback_execute, function(self, other, result, args)
--     if not Helper.table_has(callbacks, args[1].value) then
--         log.info(args[1].value)
--         table.insert(callbacks, args[1].value)
--     end
-- end)


-- gm.post_script_hook(gm.constants.skill_util_update_heaven_cracker, function(self, other, result, args)
--     log.info(gm.object_get_name(self.object_index))
--     log.info(gm.object_get_name(other.object_index))
--     log.info(result.value)
--     for _, a in ipairs(args) do
--         log.info(a.value)
--     end
--     log.info(gm.object_get_name(args[1].value.object_index))
--     log.info("")
-- end)



-- Testing
gui.add_imgui(function()
    if ImGui.Begin("Debug") then
        local selectMenu = Instance.find(gm.constants.oSelectMenu)

        
        if ImGui.Button("Add Game Style") then
            log.info(selectMenu.mode_dropdown_options)
            log.info(gm.array_length(selectMenu.mode_dropdown_options))
            local new = gm.array_create(2)
            gm.array_set(new, 0, "TEST")
            gm.array_set(new, 1, 3.0)
            gm.array_push(selectMenu.mode_dropdown_options, new)


        elseif ImGui.Button("Add Section") then
            local section = gm.struct_create()
            section.open_bump = 0.0
            section.open_height = 200.0
            section.opening = false
            section.name = "TESTING"
            section.open = true
            section.index = 13.0    -- 13+ is empty section
            section.open_window_percent = 1.0
            section.opening_time = 0.0
            section.force_scroll_to = false
            section.closing = false
            section.content_offset = 0.0
            gm.array_push(selectMenu.sections, section)
            selectMenu.section_number = selectMenu.section_number + 1

        
        elseif ImGui.Button("Init sections") then
            --gm.call(selectMenu.init_sections)

            --log.info(gm.ui_checkbox("test_button", 130, 400, 13.0))


        elseif ImGui.Button("SelectMenu debug") then
            log.info(gm.instance_number(gm.constants.oSelectMenu))
            log.info(gm.instance_find(gm.constants.oSelectMenu, 0))
            gm.api_instance_section("testing", "desc")


        end
    end
    ImGui.End()
end)


gm.post_script_hook(gm.constants.__input_system_tick, function(self, other, result, args)
    local selectMenu = Instance.find(gm.constants.oSelectMenu)

    local gp_index = gm.array_create(4)
    gm.array_set(gp_index, 3, 1)
    selectMenu:ui_checkbox("test_button", 130, 200, gp_index, gm.variable_global_get("_ui_style_default"), 0.0)
end)


-- selectMenu.set_active_page
-- self/other : oSelectMenu
-- result (pre/post): nil / nil
-- args[1] : 0.0 on page 1 and 1.0 on page 2
-- gm.post_script_hook(106212.0, function(self, other, result, args)
--     Helper.log_hook(self, other, result, args)
-- end)

-- gm.constants.ui_checkbox
-- self/other : oSelectMenu
-- result (pre/post) : nil / -2.0
-- args : Discord
-- gm.post_script_hook(gm.constants.ui_checkbox, function(self, other, result, args)
--     Helper.log_hook(self, other, result, args)
-- end)

-- selectMenu.init_sections
-- self/other : 
-- result (pre/post): 
-- args[1] : 
-- gm.post_script_hook(106209.0, function(self, other, result, args)
--     Helper.log_hook(self, other, result, args)
-- end)

-- selectMenu.ui_button_category_header_overlay
-- self/other : 
-- result (pre/post): 
-- args[1] : 
-- gm.post_script_hook(106256.0, function(self, other, result, args)
--     Helper.log_hook(self, other, result, args)
-- end)

-- selectMenu.init_sections
-- self/other : 
-- result (pre/post): 
-- args[1] : 
-- gm.post_script_hook(gm.constants._ui_draw_button, function(self, other, result, args)
--     Helper.log_hook(self, other, result, args)
-- end)



gui.add_imgui(function()
    if ImGui.Begin("Debug") then
        local selectMenu = Instance.find(gm.constants.oSelectMenu)

        
        if ImGui.Button("Create tracer") then
            local p = Player.get_client()
            local tracer = gm.instance_create_depth(p.x, p.y, 0, gm.constants.oEfLineTracer)
            tracer.xend = tracer.x + 100
            tracer.yend = tracer.y
            tracer.bm = 1
            tracer.rate = 0.15
            tracer.sprite_index = 3682.0
            tracer.image_blend = 4434400

            local sparks = gm.instance_create_depth(p.x, p.y, 0, gm.constants.oEfSparks)
            sparks.sprite_index = 1632.0


        end
    end
    ImGui.End()
end)



gui.add_imgui(function()
    if ImGui.Begin("Debug") then
        local selectMenu = Instance.find(gm.constants.oSelectMenu)

        
        if ImGui.Button("Create equipment") then
            local equip = Equipment.create("rmt", "test")
            Equipment.set_sprite(equip, Resources.sprite_load(PATH.."assets/sprites/relicGuard.png", 1, false, false, 16, 16))
            Equipment.set_cooldown(equip, 30)
            Equipment.set_loot_tags(equip, Item.LOOT_TAG.damage)

            Equipment.add_callback(equip, "onUse", function(actor)
                actor.hp = 1.0
            end)

        
        elseif ImGui.Button("Find equipment") then
            log.info(Equipment.find("ror-instantMinefield"))


            -- local equip = gm.equipment_create(
            --     "rmt",
            --     "test",
            --     gm.array_length(gm.variable_global_get("class_equipment")),
            --     3.0,
            --     gm.object_add_w("rmt", "test", gm.constants.pPickupItem),
            --     1.0,    -- ?
            --     104215.0,   -- ? (sprite maybe; nvm)
            --     30.0,   -- ? (cd maybe but some have nil ?)
            --     true,   -- ? (all)
            --     6.0,    -- ? (all)
            --     nil,    -- ? (all)
            --     nil     -- ? (all)
            -- )

            -- local class_equipment = gm.variable_global_get("class_equipment")

            -- local equip = gm.equipment_create(
            --     "ror",
            --     "rottenBrain2",
            --     gm.array_length(class_equipment),   -- this is supposed to be class_equipment index but actually
            --             -- appending to the end just turns the equip into Strange Battery,
            --             -- but replacing existing number does not delete the previous equipment (???)
            --     3.0,    -- tier (3 is equipment)
            --     gm.object_add_w("rmt", "rottenBrain2", gm.constants.pPickupEquipment),  -- pickup object
            --     Item.LOOT_TAG.category_damage,    -- loot tags
            --     nil,    -- ? (sprite maybe; nvm might be an anon function call)
            --     45.0,   -- ? (cd maybe but some have nil ?)
            --     true,   -- ? (all)
            --     6.0,    -- ? (all)
            --     nil,    -- ? (all)
            --     nil     -- ? (all)
            -- )

            -- local sprite = Resources.sprite_load(PATH.."assets/sprites/relicGuard.png", 1, false, false, 16, 16)

            -- local array = class_equipment[equip + 1]
            -- gm.array_set(array, 7, sprite)
            -- gm.object_set_sprite_w(array[9], sprite)

            -- local log_array = gm.variable_global_get("class_item_log")[array[10] + 1]
            -- gm.array_set(log_array, 9, sprite)

            -- gm.variable_global_set("count_equipment", gm.variable_global_get("count_equipment") + 1.0)

            -- on_use is array[5]


        end
    end
    ImGui.End()
end)



-- gm.pre_script_hook(gm.constants.equipment_create, function(self, other, result, args)
--     Helper.log_hook(self, other, result, args)
-- end)

-- gm.pre_script_hook(gm.constants.object_add_w, function(self, other, result, args)
--     Helper.log_hook(self, other, result, args)
-- end)

-- gm.post_script_hook(gm.constants.callback_execute, function(self, other, result, args)
--     if args[1].value == 3239.0 then log.info("used!") end
-- end)