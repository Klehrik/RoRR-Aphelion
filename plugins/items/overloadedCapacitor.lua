-- Overloaded Capacitor

local sprite = Resources.sprite_load(PATH.."assets/sprites/overloadedCapacitor.png", 1, false, false, 16, 16)

local item = Item.create("aphelion", "overloadedCapacitor")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.rare)
Item.set_loot_tags(item, Item.LOOT_TAG.category_damage, Item.LOOT_TAG.category_healing)

Item.add_callback(item, "onPickup", function(actor, stack)
    if not actor.aphelion_overloadedCapacitor_increase then
        actor.aphelion_overloadedCapacitor_increase = 0
    end
end)

Item.add_callback(item, "onRemove", function(actor, stack)
    if stack == 1 then
        actor.maxshield_base = actor.maxshield_base - actor.aphelion_overloadedCapacitor_increase
        actor.maxshield = actor.maxshield - actor.aphelion_overloadedCapacitor_increase
        actor.aphelion_overloadedCapacitor_increase = nil
    end
end)

Item.add_callback(item, "onStep", function(actor, stack)
    -- Scale shield increase with max health
    local goal = actor.maxhp * Helper.mixed_hyperbolic(stack, 0.18, 0.18)

    if actor.aphelion_overloadedCapacitor_increase ~= goal then
        local diff = goal - actor.aphelion_overloadedCapacitor_increase
        actor.aphelion_overloadedCapacitor_increase = goal

        actor.maxshield_base = actor.maxshield_base + diff
        actor.maxshield = actor.maxshield + diff
    end
end)

Item.add_callback(item, "onHit", function(actor, victim, damager, stack)
    if actor.shield > 0 then
        local lightning = gm.instance_create_depth(victim.x, victim.y, 0, gm.constants.oChainLightning)
        lightning.damage = damager.damage * (stack * 0.3)
        lightning.bounce = 2
        lightning.range = 150.0
    end
end)