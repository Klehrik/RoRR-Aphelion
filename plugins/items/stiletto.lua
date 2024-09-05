-- Stiletto

local sprite = Resources.sprite_load(PATH.."assets/sprites/stiletto.png", 1, false, false, 16, 16)

local item = Item.new("aphelion", "stiletto")
item:set_sprite(sprite)
item:set_tier(Item.TIER.rare)
item:set_loot_tags(Item.LOOT_TAG.category_damage)

item:add_callback("onPickup", function(actor, stack)
    -- Gain 20% crit on the first stack, and 10% on subsequent ones
    local amount = 20.0
    if stack > 1 then amount = 10.0 end
    actor.critical_chance_base = actor.critical_chance_base + amount
end)

item:add_callback("onRemove", function(actor, stack)
    local amount = 20.0
    if stack > 1 then amount = 10.0 end
    actor.critical_chance_base = actor.critical_chance_base - amount
end)

item:add_callback("onAttack", function(actor, damager, stack)
    if actor.critical_chance <= 100.0 then return end
    if damager.critical then
        local excess = actor.critical_chance - 100.0
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