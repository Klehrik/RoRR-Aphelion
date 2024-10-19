-- Sniper : Spotter: DETONATE

local sprite = Resources.sprite_load("aphelion", "skill/sniper", PATH.."assets/sprites/skills/sniper.png", 2)
local explosive_256 = Resources.sprite_load("aphelion", "explosive_256", PATH.."assets/sprites/effects/explosive_256.png", 6, 128, 128, 0.8)

local skill = Skill.new("aphelion", "sniperBlastBoosted")
skill:set_skill_icon(sprite, 1)
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
    
    local set_new_target = function(self, d)
        target = self
        dist = d
        hp = self.maxhp
        if self.enemy_party then is_boss = true end
    end

    local actors = Instance.find_all(gm.constants.pActor)
    for _, a in ipairs(actors) do
        -- Check if on enemy team
        if a.team and a.team ~= actor.team then

            -- If current target is a boss, reject all normal enemies
            if (not is_boss) or (is_boss and a.enemy_party) then
                local d = GM.point_distance(a.x, a.y, actor.x, actor.y)

                -- Max distance check
                if d <= max_dist then

                    -- Boss is prioritized over normal enemy
                    if a.enemy_party and (not is_boss) then
                        set_new_target(a, d)

                    -- Pick closest target with >= current target's maxhp
                    else
                        if a.maxhp and a.maxhp >= hp and d < dist then
                            set_new_target(a, d)
                        end

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

Player:onHit("aphelion-sniperBlastBoosted_onHit", function(actor, victim, damager)
    if actor:item_stack_count(Item.find("ror-ancientScepter")) <= 0 then return end
    if actor:buff_stack_count(Buff.find("aphelion-sniperBlastCooldown")) > 0 then return end

    local drone = GM._survivor_sniper_find_drone(actor)
    if not Instance.exists(drone) then return end
    if Instance.exists(drone.tt) and drone.tt:same(victim) then
        local damager = actor:fire_explosion(
            victim.x, victim.y, -- change to damager hit location
            250, 250,
            damager.damage * 0.5,
            explosive_256
        )
        damager:use_raw_damage()
        damager:set_color(Color(0xffbb59))
        damager:set_critical(false)
        damager:set_proc(false)
        damager:set_stun(1.7)

        victim:sound_play_at(gm.constants.wExplosiveShot, 1.0, 1.0, victim.x, victim.y, 1.0)
        
        -- Apply cooldown
        actor:buff_apply(Buff.find("aphelion-sniperBlastCooldown"), 1, 5)   -- Stack count is seconds
    end
end)