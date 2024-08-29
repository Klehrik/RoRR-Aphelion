-- Explosive Spear

local sprite = Resources.sprite_load(PATH.."assets/sprites/explosiveSpear.png", 1, false, false, 16, 16)
local spriteProj = Resources.sprite_load(PATH.."assets/sprites/explosiveSpearProjectile.png", 1, false, false, 23, 3)
local sound = Resources.sfx_load(PATH.."assets/sounds/explosiveSpearThrow.ogg")
local soundHit = Resources.sfx_load(PATH.."assets/sounds/explosiveSpearHit.ogg")

local item = Item.create("aphelion", "explosiveSpear")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.uncommon)
Item.set_loot_tags(item, Item.LOOT_TAG.category_damage)

Item.add_callback(item, "onHit", function(actor, victim, damager, stack)
    if not damager.aphelion_explosiveSpear then
        local cooldownBuff = Buff.find("aphelion-explosiveSpearDisplay")
        if Buff.get_stack_count(actor, cooldownBuff) > 0 then return end
        
        -- Do not proc if the hit does not deal at least 200%
        if damager.damage < actor.damage * 2.0 then return end

        local dir = actor.image_xscale

        -- Create oHuntressBolt1 as base object
        local inst = gm.instance_create_depth(actor.x + (dir * 24.0), actor.y - 4.0, 0, gm.constants.oHuntressBolt1)
        inst.sprite_index = spriteProj
        inst.parent = actor
        inst.team = inst.parent.team
        inst.hspeed = inst.hspeed * 1.25 * dir
        inst.vspeed = -2.0
        inst.gravity = 0.15
        inst.image_yscale = dir     -- lmao they swapped xscale and yscale when drawing this object
        inst.aphelion_explosiveSpear_owner = actor
        gm.sound_play_at(sound, 1.0, 1.0, actor.x, actor.y, 1.0)

        -- Calculate original damage coeff
        inst.damage_coeff = damager.damage / actor.damage

        -- Apply cooldown
        Buff.apply(actor, cooldownBuff, 1, 10)

        
    -- Explosive Spear onHit
    else
        victim.aphelion_explosiveSpear_attacker = actor
        victim.aphelion_explosiveSpear_damage = damager.aphelion_explosiveSpear_damage
        Buff.apply(victim, Buff.find("aphelion-explosiveSpear"), 1)

    end
end)

Item.add_callback(item, "onAttack", function(actor, damager, stack)
    if actor.aphelion_explosiveSpear_hit then
        actor.aphelion_explosiveSpear_hit = nil
        damager.aphelion_explosiveSpear = true
        damager.aphelion_explosiveSpear_damage = damager.damage
        damager.damage = 1.0
        gm.sound_play_at(soundHit, 1.0, 1.0, actor.x, actor.y, 1.0)
    end
end)



-- Buffs

local sprite = Resources.sprite_load(PATH.."assets/sprites/buffExplosiveSpear.png", 1, false, false, 7, 9)

local buff = Buff.create("aphelion", "explosiveSpearDisplay")
Buff.set_property(buff, Buff.PROPERTY.icon_sprite, sprite)
Buff.set_property(buff, Buff.PROPERTY.icon_stack_subimage, false)
Buff.set_property(buff, Buff.PROPERTY.draw_stack_number, true)
Buff.set_property(buff, Buff.PROPERTY.stack_number_col, gm.array_create(1, 12500670))
Buff.set_property(buff, Buff.PROPERTY.max_stack, 10)
Buff.set_property(buff, Buff.PROPERTY.is_timed, false)
Buff.set_property(buff, Buff.PROPERTY.is_debuff, true)

Buff.add_callback(buff, "onApply", function(actor, stack)
    actor.aphelion_explosiveSpear_cooldown = 60.0
end)

Buff.add_callback(buff, "onStep", function(actor, stack)
    actor.aphelion_explosiveSpear_cooldown = actor.aphelion_explosiveSpear_cooldown - 1

    if actor.aphelion_explosiveSpear_cooldown <= 0 then
        actor.aphelion_explosiveSpear_cooldown = 60
        Buff.remove(actor, Buff.find("aphelion-explosiveSpearDisplay"), 1)
    end
end)



local sound = Resources.sfx_load(PATH.."assets/sounds/explosiveSpearExplode.ogg")

local buff = Buff.create("aphelion", "explosiveSpear")
Buff.set_property(buff, Buff.PROPERTY.max_stack, 999)
Buff.set_property(buff, Buff.PROPERTY.is_timed, false)
Buff.set_property(buff, Buff.PROPERTY.is_debuff, true)

Buff.add_callback(buff, "onApply", function(actor, stack)
    if not actor.aphelion_explosiveSpear_timers then actor.aphelion_explosiveSpear_timers = gm.ds_list_create() end

    if actor.aphelion_explosiveSpear_attacker then
        local array = gm.array_create(4)
        gm.array_set(array, 0, 100.0)
        gm.array_set(array, 1, actor.aphelion_explosiveSpear_attacker)
        gm.array_set(array, 2, actor.aphelion_explosiveSpear_damage)
        gm.array_set(array, 3, Item.get_stack_count(actor.aphelion_explosiveSpear_attacker, Item.find("aphelion-explosiveSpear")))
        gm.ds_list_add(actor.aphelion_explosiveSpear_timers, array)
    end
end)

Buff.add_callback(buff, "onStep", function(actor, stack)
    local lethal = false

    -- Decrease stack timers
    for i = 0, gm.ds_list_size(actor.aphelion_explosiveSpear_timers) - 1 do
        local array = gm.ds_list_find_value(actor.aphelion_explosiveSpear_timers, i)
        local new_time = gm.array_get(array, 0) - 1
        gm.array_set(array, 0, new_time)

        -- Pop every 25 frames
        -- unless damage will be lethal
        local damage = gm.array_get(array, 2) * (0.06 + (gm.array_get(array, 3) * 0.06))
        if damage >= actor.hp then
            lethal = true
            break
        end

        if new_time % 25 == 0 and Instance.exists(gm.array_get(array, 1)) then
            Actor.damage(actor, gm.array_get(array, 1), damage, actor.x, actor.y - 36, 5046527)
        end
    end

    -- Remove and explode oldest stack if expired
    -- or if about to die
    -- TODO for multiplayer later: explode ALL remaining stacks if about to die
    local array = gm.ds_list_find_value(actor.aphelion_explosiveSpear_timers, 0)
    if gm.array_get(array, 0) <= 0 or lethal then
        local raw_damage = gm.array_get(array, 2) * (1.0 + (gm.array_get(array, 3) * 1.5))
        local explosion = Actor.fire_explosion(gm.array_get(array, 1), actor.x, actor.y, 95, 95, raw_damage / gm.array_get(array, 1).damage, 2.0)
        explosion.proc = false
        explosion.damage_color = 5046527
        gm.sound_play_at(sound, 1.0, 1.0, actor.x, actor.y, 1.0)

        gm.ds_list_delete(actor.aphelion_explosiveSpear_timers, 0)
        Buff.remove(actor, Buff.find("aphelion-explosiveSpear"), 1)
    end
end)

Buff.add_callback(buff, "onDraw", function(actor, stack)
    if actor.aphelion_explosiveSpear_timers then
        local array = gm.ds_list_find_value(actor.aphelion_explosiveSpear_timers, 0)
        if array then
            local radius = Helper.ease_out(math.min(100.0 - gm.array_get(array, 0), 50.0) / 50.0) * 100
            gm.draw_set_circle_precision(64)
            gm.draw_set_alpha(0.5)
            gm.draw_circle(actor.x, actor.y, radius, true)
            gm.draw_set_alpha(1)
            gm.draw_set_circle_precision(24)
        end
    end
end)

Buff.add_callback(buff, "onChange", function(actor, to, stack)
    -- Pass timers array to new actor instance
    to.aphelion_explosiveSpear_timers = actor.aphelion_explosiveSpear_timers
end)



-- Hooks

gm.pre_code_execute(function(self, other, code, result, flags)
    if code.name:match("oHuntressBolt1_Collision_pActor") then
        if self.aphelion_explosiveSpear_owner and Instance.exists(self.aphelion_explosiveSpear_owner) then
            self.aphelion_explosiveSpear_owner.aphelion_explosiveSpear_hit = true
        end
    end
end)


gm.pre_script_hook(gm.constants.step_actor, function(self, other, result, args)
    -- Allow the spear "buff" to affect worms/wurms
    if (self.object_index == gm.constants.oWorm
    or self.object_index == gm.constants.oWurmHead)
    and not self.aphelion_explosiveSpear_remove_immunity then
        self.aphelion_explosiveSpear_remove_immunity = true
        gm.array_set(self.buff_immune, Buff.find("aphelion-explosiveSpear"), false)
    end
end)