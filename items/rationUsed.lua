-- Ration (Used)

local sprite = Resources.sprite_load("aphelion", "item/rationUsed", PATH.."assets/sprites/items/rationUsed.png", 1, 16, 16)
local spriteCooldown = Resources.sprite_load("aphelion", "cooldown/ration", PATH.."assets/sprites/cooldowns/ration.png", 1, 4, 4)

local item = Item.new("aphelion", "rationUsed", true)
item:set_sprite(sprite)

item:onAcquire(function(actor, stack)
    local cd = 240 *60 * (1 - Helper.mixed_hyperbolic(stack, 0.2, 0))
    actor:get_data("ration").cooldown = cd

    -- Apply cooldown
    Cooldown.set(actor, "aphelion-ration", cd, spriteCooldown, Color(0xf0e07d))
end)

local function restore_stacks(actor)
    -- Restore all used Rations
    local item_ready = Item.find("aphelion-ration")
    local normal    = actor:item_stack_count(item, Item.STACK_KIND.normal)
    local temp      = actor:item_stack_count(item, Item.STACK_KIND.temporary_blue)
    if normal > 0 then
        actor:item_remove(item, normal)
        actor:item_give(item_ready, normal)
    end
    if temp > 0 then
        actor:item_remove(item, temp, Item.STACK_KIND.temporary_blue)
        actor:item_give(item_ready, temp, Item.STACK_KIND.temporary_blue)
    end
end

item:onPostStep(function(actor, stack)
    if actor.dead == true or actor.dead == 1.0 then return end
    local actorData = actor:get_data("ration")

    -- Tick down timer
    if actorData.cooldown > 0 then actorData.cooldown = actorData.cooldown - 1
    else restore_stacks(actor)
    end
end)

item:onStageStart(function(actor, stack)
    restore_stacks(actor)
end)