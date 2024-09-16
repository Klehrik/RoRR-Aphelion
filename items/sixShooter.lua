-- Six Shooter

local sprite = Resources.sprite_load("aphelion", "sixShooter", PATH.."assets/sprites/sixShooter.png", 1, 16, 16)

local item = Item.new("aphelion", "sixShooter")
item:set_sprite(sprite)
item:set_tier(Item.TIER.uncommon)
item:set_loot_tags(Item.LOOT_TAG.category_damage)

item:onPickup(function(actor, stack)
    local actor_data = actor:get_data("aphelion-sixShooter")
    if not actor_data.count then actor_data.count = 0 end
end)

item:onBasicUse(function(actor, stack)
    local actor_data = actor:get_data("aphelion-sixShooter")
    actor_data.count = actor_data.count + 1
end)

item:onAttack(function(actor, damager, stack)
    local actor_data = actor:get_data("aphelion-sixShooter")

    -- Crit every 6 basic attacks
    -- Additional stacks increase the attack's damage by 25%
    if actor_data.count >= 6 then
        actor_data.count = actor_data.count - 6

        -- For Stiletto
        if not damager.bonus_crit then damager.bonus_crit = 0 end
        damager.bonus_crit = damager.bonus_crit + 100

        if not damager.critical then
            damager.critical = true
            damager.damage = damager.damage * 2.0
        end

        if stack > 1 then
            damager.damage = damager.damage * (0.75 + (0.25 * stack))
        end
    end
end)



-- Achievement
item:add_achievement()

Actor.add_callback("onPreStep", function(actor)
    if not actor:same(Player.get_client()) then return end
    local actor_data = actor:get_data("aphelion-sixShooter")

    if not actor_data.achievement_counter then actor_data.achievement_counter = 0 end

    if actor:buff_stack_count(Buff.find("ror-banditSkull")) >= 5.0 then
        actor_data.achievement_counter = actor_data.achievement_counter + 1
    else actor_data.achievement_counter = 0
    end

    if actor_data.achievement_counter >= 60 *60 then
        item:progress_achievement()
    end
end)