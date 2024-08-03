-- Aphelion v1.0.0
-- Klehrik

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function() for _, m in pairs(mods) do if type(m) == "table" and m.RoRR_Modding_Toolkit then Buff = m.Buff Callback = m.Callback Helper = m.Helper Instance = m.Instance Item = m.Item Net = m.Net Player = m.Player Resources = m.Resources Survivor = m.Survivor break end end end)

local Sprites = {}
local Sounds = {}



-- ========== Main ==========

function __initialize()

    Sprites = {
        ballisticVest       = Resources.sprite_load(_ENV["!plugins_mod_folder_path"].."/plugins/ballisticVest.png", 1, false, false, 16, 16),
        heartLocket         = Resources.sprite_load(_ENV["!plugins_mod_folder_path"].."/plugins/heartLocket.png", 1, false, false, 16, 16),
        ration              = Resources.sprite_load(_ENV["!plugins_mod_folder_path"].."/plugins/ration.png", 1, false, false, 16, 16),
        rationUsed          = Resources.sprite_load(_ENV["!plugins_mod_folder_path"].."/plugins/rationUsed.png", 1, false, false, 16, 16),
        sixShooter          = Resources.sprite_load(_ENV["!plugins_mod_folder_path"].."/plugins/sixShooter.png", 1, false, false, 16, 16),
        overloadedCapacitor = Resources.sprite_load(_ENV["!plugins_mod_folder_path"].."/plugins/overloadedCapacitor.png", 1, false, false, 16, 16),
        stiletto            = Resources.sprite_load(_ENV["!plugins_mod_folder_path"].."/plugins/stiletto.png", 1, false, false, 16, 16)
    }
    
    Sounds = {
        ration          = Resources.sfx_load(_ENV["!plugins_mod_folder_path"].."/plugins/ration.ogg")
    }

    gm.translate_load_file(gm.variable_global_get("_language_map"), _ENV["!plugins_mod_folder_path"].."/plugins/language/english.json")


    local item = Item.create("aphelion", "ballisticVest")
    Item.set_sprite(item, Sprites.ballisticVest)
    Item.set_tier(item, Item.TIER.common)
    Item.set_loot_tags(item, Item.LOOT_TAG.category_healing)

    Item.add_callback(item, "onPickup", function(actor, stack)
        actor.armor_base = actor.armor_base + 5
        actor.maxshield_base = actor.maxshield_base + 10
    end)

    Item.add_callback(item, "onRemove", function(actor, stack)
        actor.armor_base = actor.armor_base - 5
        actor.maxshield_base = actor.maxshield_base - 10
    end)


    local item = Item.create("aphelion", "heartLocket")
    Item.set_sprite(item, Sprites.heartLocket)
    Item.set_tier(item, Item.TIER.common)
    Item.set_loot_tags(item, Item.LOOT_TAG.category_healing)

    Item.add_callback(item, "onInteract", function(actor, interactable, stack)
        gm.actor_heal_networked(actor, actor.maxhp * Helper.mixed_hyperbolic(stack, 0.035, 0.07), false)
    end)


    local item = Item.create("aphelion", "ration")
    Item.set_sprite(item, Sprites.ration)
    Item.set_tier(item, Item.TIER.common)
    Item.set_loot_tags(item, Item.LOOT_TAG.category_healing)

    Item.add_callback(item, "onPickup", function(actor, stack)
        -- Restore all used Rations
        local item      = Item.find("aphelion-ration")
        local item_used = Item.find("aphelion-rationUsed")
        local normal    = Item.get_stack_count(actor, item_used, Item.TYPE.real)
        local temp      = Item.get_stack_count(actor, item_used, Item.TYPE.temporary)
        gm.item_take(actor, item_used, normal, false)
        gm.item_take(actor, item_used, temp, true)
        gm.item_give(actor, item, normal, false)
        gm.item_give(actor, item, temp, true)
    end)

    Item.add_callback(item, "onStep", function(actor, stack)
        -- Heal when at <= 25% health
        if actor.hp <= actor.maxhp * 0.25 then
            gm.actor_heal_networked(actor, actor.maxhp * 0.5, false)
            gm.audio_play_sound(Sounds.ration, 0, false)

            -- Remove stacks and give used stacks
            local item      = Item.find("aphelion-ration")
            local item_used = Item.find("aphelion-rationUsed")
            local normal    = Item.get_stack_count(actor, item, Item.TYPE.real)
            local temp      = Item.get_stack_count(actor, item, Item.TYPE.temporary)
            gm.item_take(actor, item, normal, false)
            gm.item_take(actor, item, temp, true)
            gm.item_give(actor, item_used, normal, false)
            gm.item_give(actor, item_used, temp, true)
        end
    end)


    local item = Item.create("aphelion", "rationUsed", true)
    Item.set_sprite(item, Sprites.rationUsed)

    Item.add_callback(item, "onPickup", function(actor, stack)
        actor.aphelion_ration_cooldown = 120 * 60 * (1 - Helper.mixed_hyperbolic(stack, 0.2, 0))
    end)

    Item.add_callback(item, "onStep", function(actor, stack)
        -- Tick down timer
        if actor.aphelion_ration_cooldown > 0 then actor.aphelion_ration_cooldown = actor.aphelion_ration_cooldown - 1
        else
            -- Restore all used Rations
            local item      = Item.find("aphelion-ration")
            local item_used = Item.find("aphelion-rationUsed")
            local normal    = Item.get_stack_count(actor, item_used, Item.TYPE.real)
            local temp      = Item.get_stack_count(actor, item_used, Item.TYPE.temporary)
            gm.item_take(actor, item_used, normal, false)
            gm.item_take(actor, item_used, temp, true)
            gm.item_give(actor, item, normal, false)
            gm.item_give(actor, item, temp, true)
        end
    end)


    local item = Item.create("aphelion", "sixShooter")
    Item.set_sprite(item, Sprites.sixShooter)
    Item.set_tier(item, Item.TIER.uncommon)
    Item.set_loot_tags(item, Item.LOOT_TAG.category_damage)

    Item.add_callback(item, "onPickup", function(actor, stack)
        if not actor.aphelion_six_shooter then actor.aphelion_six_shooter = 0 end
        if not actor.aphelion_six_shooter_crit_boost then actor.aphelion_six_shooter_crit_boost = 0 end
    end)

    Item.add_callback(item, "onBasicUse", function(actor, stack)
        actor.aphelion_six_shooter = actor.aphelion_six_shooter + 1
    end)

    Item.add_callback(item, "onAttack", function(actor, damager, stack)
        -- Crit every 6 basic attacks
        -- Additional stacks increase the attack's damage by 20%
        if actor.aphelion_six_shooter >= 6 then
            actor.aphelion_six_shooter = actor.aphelion_six_shooter - 6

            -- Increases actor crit for the purposes of Stiletto
            actor.aphelion_six_shooter_crit_boost = actor.aphelion_six_shooter_crit_boost + 1
            actor.critical_chance = actor.critical_chance + 100.0

            if not damager.critical then
                damager.critical = true
                damager.damage = damager.damage * 2.0
            end

            if stack > 1 then
                damager.damage = damager.damage * (0.8 + (0.2 * stack))
            end
        end
    end)

    Item.add_callback(item, "onPostAttack", function(actor, damager, stack)
        if actor.aphelion_six_shooter_crit_boost > 0 then
            actor.aphelion_six_shooter_crit_boost = actor.aphelion_six_shooter_crit_boost - 1
            actor.critical_chance = actor.critical_chance - 100.0
        end
    end)


    local item = Item.create("aphelion", "overloadedCapacitor")
    Item.set_sprite(item, Sprites.overloadedCapacitor)
    Item.set_tier(item, Item.TIER.uncommon)
    Item.set_loot_tags(item, Item.LOOT_TAG.category_damage)

    Item.add_callback(item, "onStep", function(actor, stack)
        if actor.hud_hp_frame - actor.in_combat_last_frame >= 2 *60 then
            actor.barrier = math.max(actor.barrier, actor.maxbarrier * 0.06)
        end

        if actor.barrier > 0 then
            Buff.apply(actor, Buff.find("aphelion-overloadedCapacitor"), 2)
        end
    end)

    Item.add_callback(item, "onAttack", function(actor, damager, stack)
        if actor.barrier > 0 then
            local bonus = 0.2 + (0.1 * (stack - 1))
            damager.damage = damager.damage * (1 + bonus)
        end
    end)


    local buff = Buff.create("aphelion", "overloadedCapacitor")
    Buff.set_property(buff, Buff.PROPERTY.icon_sprite, Sprites.overloadedCapacitor)


    local item = Item.create("aphelion", "stiletto")
    Item.set_sprite(item, Sprites.stiletto)
    Item.set_tier(item, Item.TIER.rare)
    Item.set_loot_tags(item, Item.LOOT_TAG.category_damage)

    Item.add_callback(item, "onPickup", function(actor, stack)
        -- Gain 5% crit on the first stack, and 10% on subsequent ones
        local amount = 5.0
        if stack > 1 then amount = 10.0 end
        actor.critical_chance_base = actor.critical_chance_base + amount
    end)

    Item.add_callback(item, "onRemove", function(actor, stack)
        local amount = 5.0
        if stack > 1 then amount = 10.0 end
        actor.critical_chance_base = actor.critical_chance_base - amount
    end)

    Item.add_callback(item, "onAttack", function(actor, damager, stack)
        if actor.critical_chance <= 100.0 then return end
        if damager.critical then
            local excess = actor.critical_chance - 100.0
            if stack > 1 then excess = excess * (0.5 + (stack * 0.5)) end   -- Increase overcrit damage with stacks
            local bonus = (damager.damage / 2.0) * (excess / 100.0)
            damager.damage = damager.damage + bonus
        end
    end)

end



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

        elseif ImGui.Button("Apply max Standoff") then
            Buff.apply(Player.get_client(), 36, 300.0, 5)

        elseif ImGui.Button("Remove Standoff") then
            Buff.remove(Player.get_client(), 36)
            

        end
    end
    ImGui.End()
end)


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