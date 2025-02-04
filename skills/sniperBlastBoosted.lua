-- Sniper : Spotter: DETONATE

local sprite = Resources.sprite_load("aphelion", "skill/sniper", PATH.."assets/sprites/skills/sniper.png", 2)
local spriteCooldown = Resources.sprite_load("aphelion", "cooldown/sniperBlast", PATH.."assets/sprites/cooldowns/sniperBlast.png", 1, 4, 4)
local explosive_256 = Resources.sprite_load("aphelion", "explosive_256", PATH.."assets/sprites/effects/explosive_256.png", 6, 128, 128, 0.8)

local skill = Skill.new("aphelion", "sniperBlastBoosted")
skill:set_skill_icon(sprite, 1)
skill:set_skill_properties(0.0, 10 *60)
skill:set_skill_stock(1, 1, true, 1)
skill:set_skill_settings(
    true, false, 3,
    false, false,
    true, true,
    false
)
skill.require_key_press = true

skill:onActivate(function(actor, struct, slot)
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
        actor:add_skill_override(slot, Skill.find("ror-sniperVRecall"), 2)
    else
        actor:sound_play_at(gm.constants.wError, 1.0, 1.0, actor.x, actor.y, nil)
        actor:refresh_skill(slot)
    end
end)

-- Skill.find("ror-sniperVRecall"):onStep(function(actor, struct, slot)
--     actor:freeze_default_skill(slot)
-- end)

Player:onHitProc("aphelion-sniperBlastBoosted_onHit", function(actor, victim, hit_info)
    if actor:get_default_skill(Skill.SLOT.special).skill_id ~= Skill.find("aphelion-sniperBlast").value then return end
    if actor:item_stack_count(Item.find("ror-ancientScepter")) <= 0 then return end
    if Cooldown.get(actor, "aphelion-sniperBlast") > 0 then return end

    local drone = GM._survivor_sniper_find_drone(actor)
    if not Instance.exists(drone) then return end
    if Instance.exists(drone.tt) and drone.tt:same(victim) then
        local hit_x = victim.bbox_left
        if actor.x > victim.x then hit_x = victim.bbox_right end
        local hit_y = actor.y

        local attack_info2 = actor:fire_explosion(
            hit_x, hit_y,
            250, 250,
            hit_info.damage * 0.5,
            explosive_256, nil,
            false
        ).attack_info
        attack_info2:use_raw_damage()
        attack_info2:add_climb(hit_info)
        attack_info2:set_color(Color(0xffbb59))
        attack_info2:set_critical(false)
        attack_info2:set_stun(1.7)

        victim:sound_play_at(gm.constants.wExplosiveShot, 1.0, 1.0, victim.x, victim.y, nil)
        
        -- Apply cooldown
        Cooldown.set(actor, "aphelion-sniperBlast", 5 *60, spriteCooldown, Color(0xffbb59))
    end
end)