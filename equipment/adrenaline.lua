-- Adrenaline

local sprite = Resources.sprite_load("aphelion", "equipment/adrenaline", PATH.."assets/sprites/equipment/adrenaline.png", 2, 22, 22)

local equip = Equipment.new("aphelion", "adrenaline")
equip:set_sprite(sprite)
equip:set_loot_tags(Item.LOOT_TAG.category_healing)
equip:set_cooldown(30)

equip:onUse(function(actor)
    actor:add_barrier(actor.maxbarrier * 0.65)
    -- actor:set_immune(1.2 *60)
    actor:buff_apply(Buff.find("aphelion-adrenaline"), 5 *60)
end)



-- Buff

local increase = 2.8 * 0.4

local sprite = Resources.sprite_load("aphelion", "buff/adrenaline", PATH.."assets/sprites/buffs/adrenaline.png", 1, 7, 5)

local buff = Buff.new("aphelion", "adrenaline")
buff.icon_sprite = sprite
buff.icon_stack_subimage = false

buff:onStatRecalc(function(actor, stack)
    actor.pHmax = actor.pHmax + increase
end)