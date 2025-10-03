-- Shattered Glass

local sprite = Sprite.new("equipment/shatteredGlass", "~/assets/sprites/equipment/shatteredGlass.png", 2, 22, 22)

local equip = Equipment.new("shatteredGlass")
equip:set_sprite(sprite)
equip.loot_tags = Item.LootTag.CATEGORY_DAMAGE
                + Item.LootTag.EQUIPMENT_BLACKLIST_ENIGMA
                + Item.LootTag.EQUIPMENT_BLACKLIST_ACTIVATOR
equip:set_passive(true)

ItemLog.new_from_equipment(equip)

RecalculateStats.add(Callback.Priority.AFTER, function(actor)
    -- Check equipment
    if actor:equipment_get() ~= equip then return end

    -- TODO remake cursehelper
    actor.maxhp = actor.maxhp * 0.67
    actor.damage = actor.damage * 2
end)

-- equip:onPickup(function(actor)
--     Curse.apply(actor, "aphelion-shatteredGlass", 0.33)
-- end)

-- equip:onDrop(function(actor, new_equipment)
--     Curse.remove(actor, "aphelion-shatteredGlass")
-- end)

-- equip:onPostStatRecalc(function(actor)
--     actor.damage = actor.damage * 1.5

--     -- Prevent health farming from quickly swapping equipment
--     -- local percent_33 = actor.maxhp * 0.33
--     -- actor.maxhp = gm.round(actor.maxhp * 0.67)
--     -- actor.hp = math.max(actor.hp - percent_33, 1)
    
--     -- TODO: Make health bar blue maybe
-- end)