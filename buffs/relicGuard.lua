-- Relic Guard (Buff)

local buff = Buff.new("relicGuard")


-- ===== Assets =====

local sprite = Sprite.new("buff/relicGuard", "~/assets/sprites/buffs/relicGuard.png", 1, 8, 8)


-- ===== Properties =====

buff.icon_sprite = sprite
buff.max_stack = 999
buff.is_debuff = false


-- ===== Callbacks =====

RecalculateStats.add(function(actor, api)
    -- Check buff count
    local stack = actor:buff_count(buff)
    if stack <= 0 then return end

    -- Add stats
    -- Each stack is worth 10 armor
    api.armor_add(10 * stack)
end)