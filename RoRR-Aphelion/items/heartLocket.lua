-- Heart Locket

local sprite = Resources.sprite_load("aphelion", "item/heartLocket", PATH.."assets/sprites/items/heartLocket.png", 1, 16, 16)

local item = Item.new("aphelion", "heartLocket")
item:set_sprite(sprite)
item:set_tier(Item.TIER.common)
item:set_loot_tags(Item.LOOT_TAG.category_healing)

item:onInteractableActivate(function(actor, stack, interactable)
    actor:heal(actor.maxhp * Helper.mixed_hyperbolic(stack, 0.045, 0.09))
end)