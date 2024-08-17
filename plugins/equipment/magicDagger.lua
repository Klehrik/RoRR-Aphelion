-- Magic Dagger

local sprite = Resources.sprite_load(PATH.."assets/sprites/magicDagger.png", 2, false, false, 22, 22)

local equip = Equipment.create("aphelion", "magicDagger")
Equipment.set_sprite(equip, sprite)
Equipment.set_cooldown(equip, 45)
Equipment.set_loot_tags(equip, Item.LOOT_TAG.category_damage, Item.LOOT_TAG.category_utility)

Equipment.add_callback(equip, "onUse", function(actor)
    actor.hp = 1.0
end)