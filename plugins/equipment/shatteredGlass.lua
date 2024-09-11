-- Shattered Glass

local sprite = Resources.sprite_load("aphelion", "shatteredGlass", PATH.."assets/sprites/magicDagger.png", 2, 22, 22)

local equip = Equipment.new("aphelion", "shatteredGlass")
equip:set_sprite(sprite)
equip:set_loot_tags(Item.LOOT_TAG.category_damage)
equip:set_passive(true)

equip:onPostStatRecalc(function(actor)
    actor.damage = actor.damage * 1.5

    -- Prevent health farming from quickly swapping equipment
    local percent_33 = actor.maxhp * 0.33
    actor.maxhp = gm.round(actor.maxhp * 0.67)
    actor.hp = actor.hp - percent_33
end)