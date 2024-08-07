-- Explosive Spear

local sprite = Resources.sprite_load(PATH.."assets/sprites/explosiveSpear.png", 1, false, false, 16, 16)
local spriteProj = Resources.sprite_load(PATH.."assets/sprites/explosiveSpearProjectile.png", 1, false, false, 23, 3)
local sound = Resources.sfx_load(PATH.."assets/sounds/explosiveSpearThrow.ogg")

local item = Item.create("aphelion", "explosiveSpear")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.uncommon)
Item.set_loot_tags(item, Item.LOOT_TAG.category_damage)

Item.add_callback(item, "onPickup", function(actor, stack)
    if not actor.aphelion_explosiveSpear_cooldown then actor.aphelion_explosiveSpear_cooldown = 0 end
end)

Item.add_callback(item, "onHit", function(actor, victim, damager, stack)
    if not damager.aphelion_explosiveSpear then
        if actor.aphelion_explosiveSpear_cooldown > 0 then return end
        
        -- Do not proc if the hit does not deal at least 200%
        if damager.damage < actor.damage * 2.0 then return end

        actor.aphelion_explosiveSpear_cooldown = 10 *60
        actor.aphelion_explosiveSpear_thrown = true

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
        gm.sound_play_at(sound, 1.0, 1.0, actor.x, actor.y, 1.0)

        -- Calculate original damage coeff
        inst.damage_coeff = damager.damage / actor.damage

        -- Encode the fact that the damage source is this item in the damage value itself (+1,000,000,000)
        -- I can't think of another way to pass info, as the actual damager is NOT oHuntressBolt1
        -- NOTE (to fix): Bug where it occasionally deals this full value damage and I don't know why or how
        local encoding = 1000000000.0 / actor.damage
        inst.damage_coeff = inst.damage_coeff + encoding

    -- Explosive Spear onHit
    else
        victim.aphelion_explosiveSpear_attacker = actor
        victim.aphelion_explosiveSpear_damage = damager.aphelion_explosiveSpear_damage
        Buff.apply(victim, Buff.find("aphelion-explosiveSpear"), 1)

    end
end)

Item.add_callback(item, "onAttack", function(actor, damager, stack)
    -- Check if this is from an Explosive Spear
    if actor.aphelion_explosiveSpear_thrown and damager.damage >= 1000000000.0 then
        actor.aphelion_explosiveSpear_thrown = nil
        damager.aphelion_explosiveSpear = true
        damager.aphelion_explosiveSpear_damage = damager.damage - 1000000000.0
        damager.damage = 1.0
    end
end)

Item.add_callback(item, "onStep", function(actor, stack)
    if actor.aphelion_explosiveSpear_cooldown > 0 then
        actor.aphelion_explosiveSpear_cooldown = actor.aphelion_explosiveSpear_cooldown - 1
    else
        Buff.apply(actor, Buff.find("aphelion-explosiveSpearDisplay"), 2)
    end
end)



-- Buffs

local sprite = Resources.sprite_load(PATH.."assets/sprites/buffExplosiveSpear.png", 1, false, false, 6, 7)

local buff = Buff.create("aphelion", "explosiveSpearDisplay")
Buff.set_property(buff, Buff.PROPERTY.icon_sprite, sprite)



local sound = Resources.sfx_load(PATH.."assets/sounds/explosiveSpearExplode.ogg")

local buff = Buff.create("aphelion", "explosiveSpear")
Buff.set_property(buff, Buff.PROPERTY.max_stack, 999)
Buff.set_property(buff, Buff.PROPERTY.is_timed, false)
Buff.set_property(buff, Buff.PROPERTY.is_debuff, true)

Buff.add_callback(buff, "onApply", function(actor, stack)
    if (not actor.aphelion_explosiveSpear_timers) or stack == 1 then actor.aphelion_explosiveSpear_timers = gm.ds_list_create() end

    local array = gm.array_create(4)
    gm.array_set(array, 0, 80.0)
    gm.array_set(array, 1, actor.aphelion_explosiveSpear_attacker)
    gm.array_set(array, 2, actor.aphelion_explosiveSpear_damage)
    gm.array_set(array, 3, Item.get_stack_count(actor.aphelion_explosiveSpear_attacker, Item.find("aphelion-explosiveSpear")))
    gm.ds_list_add(actor.aphelion_explosiveSpear_timers, array)
end)

Buff.add_callback(buff, "onStep", function(actor, stack)
    local lethal = false

    -- Decrease stack timers
    for i = 0, gm.ds_list_size(actor.aphelion_explosiveSpear_timers) - 1 do
        local array = gm.ds_list_find_value(actor.aphelion_explosiveSpear_timers, i)
        local new_time = array[1] - 1
        gm.array_set(array, 0, new_time)

        -- Pop every 20 frames
        local damage = array[3] * (0.06 + (array[4] * 0.06))
        if damage >= actor.hp then
            lethal = true
            break
        end

        if new_time % 20 == 0 and Instance.exists(array[2]) then
            Actor.damage(actor, array[2], damage, actor.x, actor.y - 36, 5046527)
        end
    end

    -- Remove and explode oldest stack if expired
    -- or if about to die
    local array = gm.ds_list_find_value(actor.aphelion_explosiveSpear_timers, 0)
    if array[1] <= 0 or lethal then
        local raw_damage = array[3] * (0.75 + (array[4] * 0.75))
        local explosion = Actor.fire_explosion(array[2], actor.x, actor.y, 90, 90, raw_damage / array[2].damage, 2.0)
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
        local radius = Helper.ease_out(1 - (math.min(array[1], 40.0) / 40.0)) * 90
        gm.draw_set_circle_precision(64)
        gm.draw_set_alpha(0.5)
        gm.draw_circle(actor.x, actor.y, radius, true)
        gm.draw_set_alpha(1)
        gm.draw_set_circle_precision(24)
    end
end)