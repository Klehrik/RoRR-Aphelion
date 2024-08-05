-- Stiletto

local sprite = Resources.sprite_load(_ENV["!plugins_mod_folder_path"].."/plugins/assets/sprites/stiletto.png", 1, false, false, 16, 16)

local item = Item.create("aphelion", "stiletto")
Item.set_sprite(item, sprite)
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