-- Aphelion v1.0.0
-- Klehrik

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods.on_all_mods_loaded(function()
    for _, m in pairs(mods) do
        if type(m) == "table" and m.RoRR_Modding_Toolkit then
            Callback = m.Callback
            Helper = m.Helper
            Instance = m.Instance
            Item = m.Item
            Net = m.Net
            Player = m.Player
            break
        end
    end
end)



-- ========== Main ==========

function __initialize()

    gm.translate_load_file(gm.variable_global_get("_language_map"), _ENV["!plugins_mod_folder_path"].."/plugins/language/english.json")


    local item = Item.create("aphelion", "ballisticVest")
    Item.set_sprite(item, gm.sprite_add(_ENV["!plugins_mod_folder_path"].."/plugins/ballisticVest.png", 1, false, false, 16, 16))
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
    Item.set_sprite(item, gm.sprite_add(_ENV["!plugins_mod_folder_path"].."/plugins/heartLocket.png", 1, false, false, 16, 16))
    Item.set_tier(item, Item.TIER.common)
    Item.set_loot_tags(item, Item.LOOT_TAG.category_healing)

    Item.add_callback(item, "onInteract", function(actor, interactable, stack)
        actor.hp = actor.hp + (actor.maxhp * Helper.mixed_hyperbolic(stack, 0.035, 0.07))
    end)


    local item = Item.create("aphelion", "sixShooter")
    Item.set_sprite(item, gm.sprite_add(_ENV["!plugins_mod_folder_path"].."/plugins/sixShooter.png", 1, false, false, 16, 16))
    Item.set_tier(item, Item.TIER.uncommon)
    Item.set_loot_tags(item, Item.LOOT_TAG.category_damage)

    Item.add_callback(item, "onPickup", function(actor, stack)
        if not actor.aphelion_six_shooter then actor.aphelion_six_shooter = 0 end
    end)

    Item.add_callback(item, "onShoot", function(actor, damager, stack)
        -- Crit every 6 shots
        -- Additional stacks increase the shot's damage by 20%
        actor.aphelion_six_shooter = actor.aphelion_six_shooter + 1
        if actor.aphelion_six_shooter >= 6 then
            actor.aphelion_six_shooter = 0

            -- Increases crit for the purposes of Stiletto
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

    Item.add_callback(item, "onPostShoot", function(actor, damager, stack)
        if actor.aphelion_six_shooter == 0 then
            actor.critical_chance = actor.critical_chance - 100.0
        end
    end)


    local item = Item.create("aphelion", "stiletto")
    Item.set_sprite(item, gm.sprite_add(_ENV["!plugins_mod_folder_path"].."/plugins/stiletto.png", 1, false, false, 16, 16))
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

    Item.add_callback(item, "onShoot", function(actor, damager, stack)
        if actor.critical_chance <= 100.0 then return end
        if damager.critical then
            local excess = actor.critical_chance - 100.0
            if stack > 1 then excess = excess * (0.5 + (stack * 0.5)) end   -- Increase overcrit damage with stacks
            local bonus = (damager.damage / 2.0) * (excess / 100.0)
            damager.damage = damager.damage + bonus
        end
    end)

end