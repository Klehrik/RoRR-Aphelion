-- Heart Locket

local sprite = Resources.sprite_load(PATH.."assets/sprites/heartLocket.png", 1, false, false, 16, 16)

local item = Item.new("aphelion", "heartLocket")
item:set_sprite(sprite)
item:set_tier(Item.TIER.common)
item:set_loot_tags(Item.LOOT_TAG.category_healing)

item:onInteract(function(actor, interactable, stack)
    actor:heal(actor.maxhp * Helper.mixed_hyperbolic(stack, 0.045, 0.09))
end)