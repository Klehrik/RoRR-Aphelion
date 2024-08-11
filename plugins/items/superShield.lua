-- Super Shield

local sprite = Resources.sprite_load(PATH.."assets/sprites/ballisticVest.png", 1, false, false, 16, 16)

local item = Item.create("aphelion", "superShield")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.rare)
Item.set_loot_tags(item, Item.LOOT_TAG.category_healing)

Item.add_callback(item, "onPickup", function(actor, stack)
    if not actor.aphelion_superShield_increase then actor.aphelion_superShield_increase = 0.0 end
end)

Item.add_callback(item, "onRemove", function(actor, stack)
    if stack == 1 then
        actor.maxshield_base = actor.maxshield_base - actor.aphelion_superShield_increase
        actor.maxshield = actor.maxshield - actor.aphelion_superShield_increase
        actor.aphelion_superShield_increase = nil
    end
end)

Item.add_callback(item, "onStep", function(actor, stack)
    local goal = actor.maxhp * Helper.mixed_hyperbolic(stack, 0.15, 0.2)

    if actor.aphelion_superShield_increase ~= goal then
        local diff = goal - actor.aphelion_superShield_increase
        actor.aphelion_superShield_increase = goal

        actor.maxshield_base = actor.maxshield_base + diff
        actor.maxshield = actor.maxshield + diff
    end
end)

Item.add_callback(item, "onShieldBreak", function(actor, stack)
    
end)