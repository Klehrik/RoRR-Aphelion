-- Stiletto

local sprite = Resources.sprite_load("aphelion", "item/stiletto", PATH.."assets/sprites/items/stiletto.png", 1, 16, 16)

local item = Item.new("aphelion", "stiletto")
item:set_sprite(sprite)
item:set_tier(Item.TIER.rare)
item:set_loot_tags(Item.LOOT_TAG.category_damage)

item:onStatRecalc(function(actor, stack)
    actor.critical_chance = actor.critical_chance + (10 * stack)
end)

item:onAttackCreate(function(actor, stack, attack_info)
    local total_crit = actor.critical_chance
    if attack_info.bonus_crit then total_crit = total_crit + attack_info.bonus_crit end

    if attack_info.critical then
        if stack > 1 then total_crit = total_crit * (0.5 + (stack * 0.5)) end   -- Increase crit damage scaling with stacks
        local bonus = (attack_info.damage / 2.0) * (total_crit / 100.0)
        attack_info.damage = attack_info.damage + bonus
    end
end)



-- Achievement
item:add_achievement()

Player:onStatRecalc("aphelion-stilettoUnlock", function(actor)
    if actor.critical_chance >= 100.0 then
        item:progress_achievement()
    end
end)