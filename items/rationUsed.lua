-- Ration (Used)

local sprite = Resources.sprite_load("aphelion", "rationUsed", PATH.."assets/sprites/rationUsed.png", 1, 16, 16)

local item = Item.new("aphelion", "rationUsed", true)
item:set_sprite(sprite)

item:onPickup(function(actor, stack)
    actor:get_data("ration").cooldown = 240 *60 * (1 - Helper.mixed_hyperbolic(stack, 0.2, 0))
end)

local function restore_stacks(actor)
    -- Restore all used Rations
    local item_ready = Item.find("aphelion-ration")
    local normal    = actor:item_stack_count(item, Item.TYPE.real)
    local temp      = actor:item_stack_count(item, Item.TYPE.temporary)
    if normal > 0 then
        actor:item_remove(item, normal, false)
        actor:item_give(item_ready, normal, false)
    end
    if temp > 0 then
        actor:item_remove(item, temp, true)
        actor:item_give(item_ready, temp, true)
    end
end

item:onStep(function(actor, stack)
    local actorData = actor:get_data("ration")

    -- Tick down timer
    if actorData.cooldown and (actorData.cooldown > 0) then actorData.cooldown = actorData.cooldown - 1
    else restore_stacks(actor)
    end
end)

item:onNewStage(function(actor, stack)
    restore_stacks(actor)
end)