-- Six Shooter

local sprite = Resources.sprite_load(PATH.."assets/sprites/sixShooter.png", 1, false, false, 16, 16)

local item = Item.new("aphelion", "sixShooter")
item:set_sprite(sprite)
item:set_tier(Item.TIER.uncommon)
item:set_loot_tags(Item.LOOT_TAG.category_damage)

item:add_callback("onPickup", function(actor, stack)
    if not actor.aphelion_sixShooter then actor.aphelion_sixShooter = 0 end
    if not actor.aphelion_sixShooter_crit_boost then actor.aphelion_sixShooter_crit_boost = 0 end
end)

item:add_callback("onBasicUse", function(actor, stack)
    actor.aphelion_sixShooter = actor.aphelion_sixShooter + 1
end)

item:add_callback("onAttack", function(actor, damager, stack)
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
            damager.damage = damager.damage * (0.75 + (0.25 * stack))
        end
    end
end)

item:add_callback("onPostAttack", function(actor, damager, stack)
    if actor.aphelion_sixShooter_crit_boost > 0 then
        actor.aphelion_sixShooter_crit_boost = actor.aphelion_sixShooter_crit_boost - 1
        actor.critical_chance = actor.critical_chance - 100.0
    end
end)



-- Achievement
item:add_achievement()

Actor.add_callback("onPreStep", function(actor)
    if not actor:same(Player.get_client()) then return end
    if not actor.aphelion_sixShooter_achievement_counter then actor.aphelion_sixShooter_achievement_counter = 0 end

    if actor:buff_stack_count(Buff.find("ror-banditSkull")) >= 5.0 then
        actor.aphelion_sixShooter_achievement_counter = actor.aphelion_sixShooter_achievement_counter + 1
    else actor.aphelion_sixShooter_achievement_counter = 0
    end

    if actor.aphelion_sixShooter_achievement_counter >= 60 *60 then
        item:progress_achievement()
    end
end)