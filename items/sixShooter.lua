-- Six Shooter

local sprite = Resources.sprite_load("aphelion", "item/sixShooter", PATH.."assets/sprites/items/sixShooter.png", 1, 16, 16)

local item = Item.new("aphelion", "sixShooter")
item:set_sprite(sprite)
item:set_tier(Item.TIER.uncommon)
item:set_loot_tags(Item.LOOT_TAG.category_damage)

item:onPickup(function(actor, stack)
    local actorData = actor:get_data("sixShooter")
    if not actorData.count then actorData.count = 0 end
end)

item:onBasicUse(function(actor, stack)
    local actorData = actor:get_data("sixShooter")
    actorData.count = actorData.count + 1
end)

item:onAttack(function(actor, damager, stack)
    local actorData = actor:get_data("sixShooter")

    -- Crit every 6 basic attacks
    -- Additional stacks increase the attack's damage by 25%
    if actorData.count >= 6 then
        actorData.count = actorData.count - 6

        -- For Stiletto
        if not damager.bonus_crit then damager.bonus_crit = 0 end
        damager.bonus_crit = damager.bonus_crit + 100

        if not damager.critical then
            damager.critical = true
            damager.damage = damager.damage * 2.0
        end

        if stack > 1 then
            damager.damage = damager.damage * (0.5 + (0.5 * stack))
        end
    end
end)



-- Achievement
item:add_achievement()

Buff.find("ror-banditSkull"):onStep(function(actor, stack)
    local actorData = actor:get_data("sixShooter")
    if not actorData.achievement_counter then actorData.achievement_counter = 0 end

    if stack < 5 then
        actorData.achievement_counter = 0
        return
    end

    actorData.achievement_counter = actorData.achievement_counter + 1
    if actorData.achievement_counter >= 60 *60 then
        item:progress_achievement()
    end
end)