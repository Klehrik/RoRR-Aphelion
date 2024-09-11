-- Adrenaline

local sprite = Resources.sprite_load("aphelion", "adrenaline", PATH.."assets/sprites/adrenaline.png", 2, 22, 22)

local equip = Equipment.new("aphelion", "adrenaline")
equip:set_sprite(sprite)
equip:set_loot_tags(Item.LOOT_TAG.category_healing)
equip:set_cooldown(45)

equip:onUse(function(actor)
    actor:add_barrier(actor.maxbarrier * 0.75)
    actor:set_immune(1.2 *60)
    actor:buff_apply(Buff.find("aphelion-adrenaline"), 5 *60)
end)



-- Buff

local increase = 2.8 * 0.4

local sprite = Resources.sprite_load("aphelion", "buffAdrenaline", PATH.."assets/sprites/buffAdrenaline.png", 1, 7, 5)

local buff = Buff.new("aphelion", "adrenaline")
buff.icon_sprite = sprite
buff.icon_stack_subimage = false

buff:onApply(function(actor, stack)
    actor.pHmax_base = actor.pHmax_base + increase
end)

buff:onRemove(function(actor, stack)
    actor.pHmax_base = actor.pHmax_base - increase
end)