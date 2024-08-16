-- Six Shooter

local sprite = Resources.sprite_load(PATH.."assets/sprites/sixShooter.png", 1, false, false, 16, 16)

local item = Item.create("aphelion", "sixShooter")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.uncommon)
Item.set_loot_tags(item, Item.LOOT_TAG.category_damage)

Item.add_callback(item, "onPickup", function(actor, stack)
    if not actor.aphelion_sixShooter then actor.aphelion_sixShooter = 0 end
    if not actor.aphelion_sixShooter_crit_boost then actor.aphelion_sixShooter_crit_boost = 0 end
end)

Item.add_callback(item, "onBasicUse", function(actor, stack)
    actor.aphelion_sixShooter = actor.aphelion_sixShooter + 1
end)

Item.add_callback(item, "onAttack", function(actor, damager, stack)
    -- Crit every 6 basic attacks
    -- Additional stacks increase the attack's damage by 20%
    if actor.aphelion_sixShooter >= 6 then
        actor.aphelion_sixShooter = actor.aphelion_sixShooter - 6

        -- Increases actor crit for the purposes of Stiletto
        actor.aphelion_sixShooter_crit_boost = actor.aphelion_sixShooter_crit_boost + 1
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
    if actor.aphelion_sixShooter_crit_boost > 0 then
        actor.aphelion_sixShooter_crit_boost = actor.aphelion_sixShooter_crit_boost - 1
        actor.critical_chance = actor.critical_chance - 100.0
    end
end)



-- Achievement
Item.add_achievement(item)

Actor.add_callback("onPreStep", function(actor)
    if actor ~= Player.get_client() then return end
    if not actor.aphelion_sixShooter_achievement_counter then actor.aphelion_sixShooter_achievement_counter = 0 end

    if Buff.get_stack_count(actor, Buff.find("ror-banditSkull")) >= 5.0 then
        actor.aphelion_sixShooter_achievement_counter = actor.aphelion_sixShooter_achievement_counter + 1
    else actor.aphelion_sixShooter_achievement_counter = 0
    end

    if actor.aphelion_sixShooter_achievement_counter >= 60 *60 then
        Item.progress_achievement(Item.find("aphelion-sixShooter"))
    end
end)