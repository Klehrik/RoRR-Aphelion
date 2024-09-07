-- Relic Guard

local sprite = Resources.sprite_load(PATH.."assets/sprites/relicGuard.png", 1, false, false, 16, 16)

local item = Item.new("aphelion", "relicGuard")
item:set_sprite(sprite)
item:set_tier(Item.TIER.uncommon)
item:set_loot_tags(Item.LOOT_TAG.category_healing)

item:onPickup(function(actor, stack)
    local increase = 20
    actor.maxshield_base = actor.maxshield_base + increase
end)

item:onRemove(function(actor, stack)
    local increase = 20
    actor.maxshield_base = actor.maxshield_base - increase
end)

item:onShieldBreak(function(actor, stack)
    -- TODO for later: Apply to all nearby allies
    -- and change description wording
    actor:add_barrier(actor.maxshield * (0.25 + (stack * 0.25)))
end)



-- Achievement
item:add_achievement()

Actor.add_callback("onPreStep", function(actor)
    if not actor:same(Player.get_client()) then return end
    if actor.maxshield >= 400.0 then
        item:progress_achievement()
    end
end)