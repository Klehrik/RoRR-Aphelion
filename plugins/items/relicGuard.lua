-- Relic Guard

local sprite = Resources.sprite_load(PATH.."assets/sprites/relicGuard.png", 1, false, false, 16, 16)

local item = Item.create("aphelion", "relicGuard")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.uncommon)
Item.set_loot_tags(item, Item.LOOT_TAG.category_healing)

Item.add_callback(item, "onPickup", function(actor, stack)
    local increase = 20
    if stack > 1 then increase = 20 end
    actor.maxshield_base = actor.maxshield_base + increase
end)

Item.add_callback(item, "onRemove", function(actor, stack)
    local increase = 20
    if stack > 1 then increase = 20 end
    actor.maxshield_base = actor.maxshield_base - increase
end)

Item.add_callback(item, "onShieldBreak", function(actor, stack)
    log.info("shieldbreak")
    -- TODO for later: Apply to all nearby allies
    -- and change description wording
    Actor.add_barrier(actor, actor.maxshield * (0.25 + (stack * 0.25)))
end)



-- Achievement
Item.add_achievement(item)

Actor.add_callback("onPreStep", function(actor)
    if actor ~= Player.get_client() then return end
    if actor.maxshield >= 400.0 then
        Item.progress_achievement(Item.find("aphelion-relicGuard"))
    end
end)