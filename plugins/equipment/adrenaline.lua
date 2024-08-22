-- Adrenaline

local sprite = Resources.sprite_load(PATH.."assets/sprites/adrenaline.png", 2, false, false, 22, 22)

local equip = Equipment.create("aphelion", "adrenaline")
Equipment.set_sprite(equip, sprite)
Equipment.set_cooldown(equip, 45)
Equipment.set_loot_tags(equip, Item.LOOT_TAG.category_healing)

Equipment.add_callback(equip, "onUse", function(actor)
    Actor.add_barrier(actor, actor.maxbarrier * 0.75)
    if actor.invincible == false then actor.invincible = 0 end
    actor.invincible = math.max(actor.invincible, 1.2 *60)
    Buff.apply(actor, Buff.find("aphelion-adrenaline"), 5 *60)
end)



-- Buff

local increase = 2.8 * 0.4

local sprite = Resources.sprite_load(PATH.."assets/sprites/buffAdrenaline.png", 1, false, false, 7, 5)

local buff = Buff.create("aphelion", "adrenaline")
Buff.set_property(buff, Buff.PROPERTY.icon_sprite, sprite)
Buff.set_property(buff, Buff.PROPERTY.icon_stack_subimage, false)

Buff.add_callback(buff, "onApply", function(actor, stack)
    actor.pHmax_base = actor.pHmax_base + increase
end)

Buff.add_callback(buff, "onRemove", function(actor, stack)
    actor.pHmax_base = actor.pHmax_base - increase
end)