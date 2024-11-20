-- Calamari Skewers

local sprite = Resources.sprite_load("aphelion", "item/calamariSkewers", PATH.."assets/sprites/items/calamariSkewers.png", 1, 16, 16)
local spriteCooldown = Resources.sprite_load("aphelion", "cooldown/calamariSkewers", PATH.."assets/sprites/cooldowns/calamariSkewers.png", 1, 4, 4)

local item = Item.new("aphelion", "calamariSkewers")
item:set_sprite(sprite)
item:set_tier(Item.TIER.common)
item:set_loot_tags(Item.LOOT_TAG.category_healing)

item:onAcquire(function(actor, stack)
    local actorData = actor:get_data("calamariSkewers")
    if not actorData.count then
        actorData.count = 0
        actorData.timer = 0
    end
end)

item:onKillProc(function(actor, victim, stack)
    if Cooldown.get(actor, "aphelion-calamariSkewers") > 0 then return end
    local actorData = actor:get_data("calamariSkewers")
    actorData.count = actorData.count + 1
    actorData.timer = 1.5 *60
    if actorData.count >= 2 then
        local buff = Buff.find("aphelion-calamariSkewers")
        local count = 1
        if actor:buff_stack_count(buff) <= 0 then count = 2 end
        actor:buff_apply(buff, 1, count)
    end
end)

item:onPostStep(function(actor, stack)
    local actorData = actor:get_data("calamariSkewers")

    -- Consume all stacks if timer expires
    if actorData.timer > 0 then actorData.timer = actorData.timer - 1
    else
        if actorData.count >= 2 then
            local per = actor.maxhp * (0.02 + (actor:item_stack_count(item) * 0.01))
            actor:heal(per * actorData.count)

            -- Apply cooldown
            Cooldown.set(actor, "aphelion-calamariSkewers", 5 *60, spriteCooldown, Color(0xffcbcb))
        end

        actorData.count = 0
    end
end)



-- Buff

local sprite = Resources.sprite_load("aphelion", "buff/calamariSkewers", PATH.."assets/sprites/buffs/calamariSkewers.png", 1, 6, 8)

local buff = Buff.new("aphelion", "calamariSkewers")
buff.icon_sprite = sprite
buff.icon_stack_subimage = false
buff.draw_stack_number = true
buff.max_stack = 999
buff.is_timed = false

buff:onPostStep(function(actor, stack)
    local actorData = actor:get_data("calamariSkewers")

    -- Remove buff stacks if more than count
    if stack > actorData.count then actor:buff_remove(buff, stack - actorData.count) end
end)