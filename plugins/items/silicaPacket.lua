-- Silica Packet

local sprite = Resources.sprite_load(PATH.."assets/sprites/silicaPacket.png", 1, false, false, 16, 16)

local item = Item.create("aphelion", "silicaPacket")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.common)
Item.set_loot_tags(item, Item.LOOT_TAG.category_utility)

Item.add_callback(item, "onPickup", function(actor, stack)
    actor.aphelion_silicaPacket_increase = 0.04 + (0.12 * stack)
end)

Item.add_callback(item, "onRemove", function(actor, stack)
    actor.aphelion_silicaPacket_increase = 0.04 + (0.12 * (stack - 1))
    if stack <= 1 then actor.aphelion_silicaPacket_increase = nil end
end)

gm.post_script_hook(gm.constants.actor_get_blue_temp_item_duration, function(self, other, result, args)
    local actor = args[1].value
    if actor.aphelion_silicaPacket_increase then
        result.value = result.value * (1 + actor.aphelion_silicaPacket_increase)
    end
    log.info(result.value)
end)



-- Achievement
Item.add_achievement(item, 50)

local function attack_flags_to_table(value)
    local flags = {}
    for i = 1, 30 do flags[i] = 0 end
    local pos = 1
    while value > 0 do
        flags[pos] = (value % 2)
        pos = pos + 1
        value = math.floor(value / 2.0)
    end
    return flags
end

Actor.add_callback("onPostAttack", function(actor, damager)
    if actor ~= Player.get_client() then return end
    local flags = attack_flags_to_table(damager.attack_flags)
    if flags[13] == 1.0 then
        Item.progress_achievement(Item.find("aphelion-silicaPacket"), damager.kill_number)
    end
end)