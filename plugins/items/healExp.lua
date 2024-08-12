-- Heal Exp
-- temp name; rename to something later

local sprite = Resources.sprite_load(PATH.."assets/sprites/ballisticVest.png", 1, false, false, 16, 16)

local item = Item.create("aphelion", "healExp")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.common)
--Item.set_loot_tags(item, Item.LOOT_TAG.category_utility)

Item.add_callback(item, "onHeal", function(actor, amount, stack)
    local director = Instance.find(gm.constants.oDirectorControl)
    if director then
        local increase = amount * (0.5 + (stack * 0.5))
        director.player_exp = director.player_exp + increase
    end
end)