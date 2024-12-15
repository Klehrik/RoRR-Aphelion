-- Six Shooter

local sprite = Resources.sprite_load("aphelion", "item/sixShooter", PATH.."assets/sprites/items/sixShooter.png", 1, 16, 16)

local item = Item.new("aphelion", "sixShooter")
item:set_sprite(sprite)
item:set_tier(Item.TIER.uncommon)
item:set_loot_tags(Item.LOOT_TAG.category_damage)

item:onAcquire(function(actor, stack)
    local actorData = actor:get_data("sixShooter")
    if not actorData.count then actorData.count = 0 end
end)

item:onPrimaryUse(function(actor, stack, active_skill)
    if active_skill.skill_id == Skill.find("ror-sniperZReload").value then return end
    local actorData = actor:get_data("sixShooter")
    actorData.count = actorData.count + 1
end)

item:onAttackCreateProc(function(actor, stack, attack_info)
    local actorData = actor:get_data("sixShooter")

    -- Crit every 6 basic attacks
    -- Additional stacks increase the attack's damage
    if actorData.count >= 6 then
        actorData.count = actorData.count - 6

        attack_info:set_damage(attack_info.damage * (1 + (0.33 * stack)))
        attack_info:set_critical(true)

        -- For Stiletto
        if not attack_info.bonus_crit then attack_info.bonus_crit = 0 end
        attack_info.bonus_crit = attack_info.bonus_crit + 100
    end
end)



-- Achievement
item:add_achievement()

Buff.find("ror-banditSkull"):onPostStep(function(actor, stack)
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