-- Sniper : Spotter: BLAST

local sprite = Resources.sprite_load("aphelion", "skill/sniper", PATH.."assets/sprites/skills/sniper.png", 2)
local explosive_192 = Resources.sprite_load("aphelion", "explosive_192", PATH.."assets/sprites/effects/explosive_192.png", 6, 96, 96)

local skill = Skill.new("aphelion", "sniperBlast")
skill:set_skill_icon(sprite, 0)
skill:set_skill_properties(0.0, 10 *60)
skill:set_skill_stock(1, 1, true, 1)
skill:set_skill_settings(
    true, false, 1,
    false, false,
    true, true,
    false
)
skill.require_key_press = true

skill:onActivate(function(actor, struct, index)
    local drone = GM._survivor_sniper_find_drone(actor)

    -- Select target
    local target = nil
    local max_dist = 968    -- Approx. SCAN distance
    local dist = 1000000
    local hp = 0
    local is_boss = false
    local actors = Instance.find_all(gm.constants.pActor)
    for _, a in ipairs(actors) do
        if a.team and a.team ~= actor.team then
            if (not is_boss) or (is_boss and a.enemy_party) then
                local d = GM.point_distance(a.x, a.y, actor.x, actor.y)
                if a.hp and a.hp >= hp and d <= max_dist then
                    if d < dist then
                        target = a
                        dist = d
                        hp = a.hp
                        if a.enemy_party then is_boss = true end
                    end
                end
            end
        end
    end

    if target then
        drone.tt = target
        actor:add_skill_override(index, Skill.find("ror-sniperVRecall"), 2)
    else
        actor:sound_play_at(gm.constants.wError, 1.0, 1.0, actor.x, actor.y, 1.0)
        actor:refresh_skill(index)
    end
end)

Player:onHit("aphelion-sniperBlast_onHit", function(actor, victim, damager)
    if actor:item_stack_count(Item.find("ror-ancientScepter")) > 0 then return end
    local drone = GM._survivor_sniper_find_drone(actor)
    if not drone:exists() then return end
    if drone.tt:same(victim) then
        local damager = actor:fire_explosion(
            victim.x, victim.y, -- change to damager hit location
            200, 200,
            damager.damage * 0.5,
            explosive_192
        )
        damager:use_raw_damage()
        damager:set_color(Color(0xffbb59))
        damager:set_critical(false)
        damager:set_proc(false)
        damager:set_stun(0.2)

        victim:sound_play_at(gm.constants.wExplosiveShot, 1.0, 1.0, victim.x, victim.y, 1.0)
    end
end)

Survivor.find("ror-sniper"):add_skill(skill, Skill.SLOT.special)