-- Explosive Spear

local sprite = Resources.sprite_load("aphelion", "explosiveSpear", PATH.."assets/sprites/explosiveSpear.png", 1, 16, 16)
local sound = Resources.sfx_load(PATH.."assets/sounds/explosiveSpearThrow.ogg")

local item = Item.new("aphelion", "explosiveSpear")
item:set_sprite(sprite)
item:set_tier(Item.TIER.uncommon)
item:set_loot_tags(Item.LOOT_TAG.category_damage)

item:onHit(function(actor, victim, damager, stack)
    local cooldownBuff = Buff.find("aphelion-explosiveSpearDisplay")
    if actor:buff_stack_count(cooldownBuff) > 0 then return end
    
    -- Do not proc if the hit does not deal at least 200%
    if damager.damage < actor.damage * 2.0 then return end

    local dir = actor.image_xscale

    -- Create object
    local obj = Object.find("aphelion-explosiveSpearObject")
    local inst = obj:create(actor.x + (dir * 36.0), actor.y - 4.0)
    local instData = inst:get_data()
    instData.parent = actor
    instData.hsp = 20.0 * dir
    gm.sound_play_at(sound, 1.0, 1.0, actor.x, actor.y, 1.0)

    -- Calculate damage
    instData.pop_damage = damager.damage * (0.06 + (actor:item_stack_count(item) * 0.06))
    instData.damage = damager.damage * (1.0 + (actor:item_stack_count(item) * 1.5))

    -- Apply cooldown
    actor:buff_apply(cooldownBuff, 1, 10)
end)



-- Object

local sprite = Resources.sprite_load("aphelion", "explosiveSpearProjectile", PATH.."assets/sprites/explosiveSpearProjectile.png", 1, 36, 3, 1, -20, -5, -3, 3)
local soundHit = Resources.sfx_load(PATH.."assets/sounds/explosiveSpearHit.ogg")
local soundExplode = Resources.sfx_load(PATH.."assets/sounds/explosiveSpearExplode.ogg")

local obj = Object.new("aphelion", "explosiveSpearObject")
obj:set_sprite(sprite)
obj:set_depth(-1)

obj:onCreate(function(self)
    local selfData = self:get_data()

    selfData.vsp = -2.0
    selfData.grav = 0.18

    selfData.hit = Instance.wrap_invalid()
    selfData.hit_type = 0   -- 1 for ground
    selfData.hit_offset_x = 0
    selfData.hit_offset_y = 0

    selfData.tick = 85
end)

obj:onStep(function(self)
    local selfData = self:get_data()

    if not selfData.flag_hit then
        -- Move
        self.x = self.x + selfData.hsp
        self.y = self.y + selfData.vsp
        selfData.vsp = selfData.vsp + selfData.grav

        -- Actor collision
        local actors = self:get_collisions(gm.constants.pActor, table.unpack(Instance.worm_bodies))
        for _, actor in ipairs(actors) do
            if (actor.team and actor.team ~= selfData.parent.team)
            or (actor.parent and actor.parent.team and actor.parent.team ~= selfData.parent.team) then
                selfData.flag_hit = true
                selfData.hit = actor
                selfData.hit_offset_x = actor.x - self.x
                selfData.hit_offset_y = actor.y - self.y
                gm.sound_play_at(soundHit, 1.0, 1.0, self.x, self.y, 1.0)
                break
            end
        end

        -- Wall collision
        if self:is_colliding(gm.constants.oB) then
            selfData.flag_hit = true
            selfData.hit_type = 1
            gm.sound_play_at(soundHit, 1.0, 1.0, self.x, self.y, 1.0)
        end

        -- Set image_angle
        self.image_angle = gm.point_direction(0, 0, selfData.hsp, selfData.vsp)
    end
end)

obj:onStep(function(self)
    local selfData = self:get_data()

    if selfData.flag_hit then
        selfData.tick = selfData.tick - 1

        local c_red = Color(0xFF004D)

        if selfData.hit:exists() then
            -- Embed into hit actor
            self.x = selfData.hit.x - selfData.hit_offset_x
            self.y = selfData.hit.y - selfData.hit_offset_y

            -- Deal pop damage
            if selfData.tick % 25 == 0 then
                local actor = selfData.hit
                if actor.RMT_object ~= "Actor" then actor = actor.parent end

                local damager = selfData.parent:fire_direct(actor, selfData.pop_damage)
                damager:use_raw_damage()
                damager:set_color(c_red)
                damager:set_critical(false)
                damager:set_proc(false)
                damager:set_stun(1)
            end
        end

        -- Explode
        if selfData.tick <= -20 or (selfData.hit_type == 0 and not selfData.hit:exists()) then
            local damager = selfData.parent:fire_explosion(self.x, self.y, 200, 200, selfData.damage)
            damager:use_raw_damage()
            damager:set_color(c_red)
            damager:set_critical(false)
            damager:set_proc(false)
            damager:set_stun(2.5)

            gm.sound_play_at(soundExplode, 1.0, 1.0, self.x, self.y, 1.0)
            self:destroy()
        end
    end
end)

obj:onStep(function(self)
    local selfData = self:get_data()

    -- Destroy when falling out of map
    if self.y >= gm.variable_global_get("room_height") and not selfData.hit then
        self:destroy()
    end
end)

obj:onDraw(function(self)
    local selfData = self:get_data()

    if selfData.flag_hit then
        -- Show explosion radius
        local radius = Helper.ease_out(math.min(85.0 - selfData.tick, 45.0) / 45.0) * 100
        gm.draw_set_circle_precision(64)
        gm.draw_set_alpha(0.5)
        local c = Color.WHITE
        gm.draw_circle(self.x, self.y, radius, c, c, true)
        gm.draw_set_alpha(1)
        gm.draw_set_circle_precision(24)
    end
end)



-- Buffs

local sprite = Resources.sprite_load("aphelion", "buffExplosiveSpear", PATH.."assets/sprites/buffExplosiveSpear.png", 1, 7, 9)

local buff = Buff.new("aphelion", "explosiveSpearDisplay")
buff.icon_sprite = sprite
buff.icon_stack_subimage = false
buff.draw_stack_number = true
buff.stack_number_col = Array.new(1, Color(0xBEBEBE))
buff.max_stack = 10
buff.is_timed = false
buff.is_debuff = true

buff:onApply(function(actor, stack)
    local actorData = actor:get_data("explosiveSpear")
    actorData.cooldown = 60.0
end)

buff:onStep(function(actor, stack)
    local actorData = actor:get_data("explosiveSpear")

    actorData.cooldown = actorData.cooldown - 1

    if actorData.cooldown <= 0 then
        actorData.cooldown = 60
        actor:buff_remove(buff, 1)
    end
end)