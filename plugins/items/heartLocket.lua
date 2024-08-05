-- Heart Locket

local sprite = Resources.sprite_load(PATH.."/assets/sprites/heartLocket.png", 1, false, false, 16, 16)

local item = Item.create("aphelion", "heartLocket")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.common)
Item.set_loot_tags(item, Item.LOOT_TAG.category_healing)

Item.add_callback(item, "onInteract", function(actor, interactable, stack)
    Actor.heal(actor, actor.maxhp * Helper.mixed_hyperbolic(stack, 0.045, 0.09))
end)