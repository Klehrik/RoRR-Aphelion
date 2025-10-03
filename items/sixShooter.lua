-- Six Shooter

local sprite = Sprite.new("item/sixShooter", "~/assets/sprites/items/sixShooter.png", 1, 16, 16)

local item = Item.new("sixShooter")
item:set_sprite(sprite)
item:set_tier(ItemTier.UNCOMMON)
item.loot_tags = Item.LootTag.CATEGORY_DAMAGE

ItemLog.new_from_item(item)

Callback.add(item.on_acquired, function(actor, stack)
    local actor_data = Instance.get_data(actor, "sixShooter")
    if not actor_data.count then actor_data.count = 0 end
end)

gm.post_script_hook(gm.constants.skill_activate, function(self, other, result, args)
    -- Check if primary skill
    if args[1].value ~= Skill.Slot.PRIMARY then return end

    local actor = Instance.wrap(self)

    -- Check item count
    local stack = actor:item_count(item)
    if stack <= 0 then return end

    -- Increment counter
    local actor_data = Instance.get_data(actor, "sixShooter")
    actor_data.count = actor_data.count + 1
end)

DamageCalculate.add(function(api)
    -- Check if actor exists
    local actor = api.parent
    if not Instance.exists(actor) then return end

    -- Check item count
    local stack = actor:item_count(item)
    if stack <= 0 then return end

    -- Check if the attack can proc
    -- At the very least, this will prevent
    -- accidental proc of this on item attacks
    if not api.proc then return end

    -- Proc every 6 basic hits
    -- Increase damage by 33% per stack and force crit
    local actor_data = Instance.get_data(actor, "sixShooter")
    if actor_data.count >= 6 then
        actor_data.count = actor_data.count - 6
        api.damage_mult(1 + (0.33 * stack))
        api.set_critical(true)
    end
end)