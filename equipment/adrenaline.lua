-- Adrenaline

local sprite = Sprite.new("equipment/adrenaline", "~/assets/sprites/equipment/adrenaline.png", 2, 22, 22)

local equip = Equipment.new("adrenaline")
equip:set_sprite(sprite)
equip:set_loot_tags(Item.LootTag.CATEGORY_HEALING)
equip.cooldown = 30 *60
ItemLog.new_from_equipment(equip)

-- Doing Buff creation here to use the ID
local buff = Buff.new("adrenaline")

Callback.add(Callback.ON_EQUIPMENT_USE, function(player, equipment, bool, number)
    -- Check equipment
    if equipment ~= equip then return end

    -- Grant barrier and movement speed buff
    GM.actor_heal_barrier(player, player.maxbarrier * 0.65)
    player:buff_apply(buff, 5 *60)
end)



-- Buff

local sprite = Sprite.new("buff/adrenaline", "~/assets/sprites/buffs/adrenaline.png", 1, 7, 5)

buff.icon_sprite = sprite
buff.icon_stack_subimage = false

RecalculateStats.add(function(actor)
    -- Check buff count
    local stack = actor:buff_count(buff)
    if stack <= 0 then return end

    -- Increase movement speed by 40% (character base is 2.8)
    actor.pHmax = actor.pHmax + (0.4 *2.8)
end)