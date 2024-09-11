-- Shattered Glass

local sprite = Resources.sprite_load("aphelion", "shatteredGlass", PATH.."assets/sprites/magicDagger.png", 2, 22, 22)

local equip = Equipment.new("aphelion", "shatteredGlass")
equip:set_sprite(sprite)
equip:set_loot_tags(Item.LOOT_TAG.category_damage)
equip:set_cooldown(30)

equip:onPostStatRecalc(function(actor)
    actor.damage = actor.damage * 1.25

    -- Prevent health farming from quickly swapping equipment
    local percent_25 = actor.maxhp * 0.25
    actor.maxhp = gm.round(actor.maxhp * 0.75)
    actor.hp = actor.hp - percent_25
end)