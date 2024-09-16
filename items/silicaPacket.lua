-- Silica Packet

local sprite = Resources.sprite_load("aphelion", "silicaPacket", PATH.."assets/sprites/silicaPacket.png", 1, 16, 16)

local item = Item.new("aphelion", "silicaPacket")
item:set_sprite(sprite)
item:set_tier(Item.TIER.common)
item:set_loot_tags(Item.LOOT_TAG.category_utility)

item:onPickup(function(actor, stack)
    local actor_data = actor:get_data("aphelion-silicaPacket")
    actor_data.increase = 0.06 + (0.12 * stack)
end)

item:onRemove(function(actor, stack)
    local actor_data = actor:get_data("aphelion-silicaPacket")
    actor_data.increase = 0.06 + (0.12 * (stack - 1))
    if stack <= 1 then actor_data.increase = nil end
end)

item:onNewStage(function(actor, stack)
    local tier = Item.TIER.common
    if Helper.chance(0.25) then tier = Item.TIER.uncommon
    elseif Helper.chance(0.025) then tier = Item.TIER.rare
    end

    for i = 1, 1 + stack do
        actor:item_give(Item.get_random(tier), 1, true)
    end
end)

gm.post_script_hook(gm.constants.actor_get_blue_temp_item_duration, function(self, other, result, args)
    local actor = Instance.wrap(args[1].value)
    local actor_data = actor:get_data("aphelion-silicaPacket")
    if actor_data.increase then
        result.value = result.value * (1 + actor_data.increase)
    end
end)



-- Achievement
item:add_achievement(50)

Actor.add_callback("onPostAttack", function(actor, damager)
    if not actor:same(Player.get_client()) then return end
    if (damager.attack_flags & (1 << 12)) > 0 then
        item:progress_achievement(damager.kill_number)
    end
end)