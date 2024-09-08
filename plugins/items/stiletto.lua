-- Stiletto

local sprite = Resources.sprite_load(PATH.."assets/sprites/stiletto.png", 1, false, false, 16, 16)

local item = Item.new("aphelion", "stiletto")
item:set_sprite(sprite)
item:set_tier(Item.TIER.rare)
item:set_loot_tags(Item.LOOT_TAG.category_damage)

item:onStatRecalc(function(actor, stack)
    actor.critical_chance = actor.critical_chance + 10 + (10 * stack)
end)

item:onAttack(function(actor, damager, stack)
    local total_crit = actor.critical_chance
    if damager.bonus_crit then total_crit = total_crit + damager.bonus_crit end

    if total_crit <= 100.0 then return end
    if damager.critical then
        local excess = total_crit - 100.0
        if stack > 1 then excess = excess * (0.5 + (stack * 0.5)) end   -- Increase overcrit damage with stacks
        local bonus = (damager.damage / 2.0) * (excess / 100.0)
        damager.damage = damager.damage + bonus
    end
end)



-- Achievement
item:add_achievement()

Actor.add_callback("onPreStep", function(actor)
    if not actor:same(Player.get_client()) then return end
    if actor.critical_chance >= 100.0 then
        item:progress_achievement()
    end
end)