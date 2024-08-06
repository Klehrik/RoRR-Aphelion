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