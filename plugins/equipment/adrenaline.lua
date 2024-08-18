-- Adrenaline

local sprite = Resources.sprite_load(PATH.."assets/sprites/adrenaline.png", 2, false, false, 22, 22)

local equip = Equipment.create("aphelion", "adrenaline")
Equipment.set_sprite(equip, sprite)
Equipment.set_cooldown(equip, 45)
Equipment.set_loot_tags(equip, Item.LOOT_TAG.category_healing)

Equipment.add_callback(equip, "onUse", function(actor)
    Actor.add_barrier(actor, actor.maxbarrier * 0.75)
    actor.invincible = math.max(actor.invincible, 1.2 *60)
end)