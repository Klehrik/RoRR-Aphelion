-- Explosive Spear

local sprite = Resources.sprite_load(PATH.."assets/sprites/explosiveSpear.png", 1, 16, 16)
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
    inst.parent = actor
    inst.hsp = 20.0 * dir
    gm.sound_play_at(sound, 1.0, 1.0, actor.x, actor.y, 1.0)

    -- Calculate damage
    inst.pop_damage = damager.damage * (0.06 + (actor:item_stack_count(item) * 0.06))
    inst.damage = damager.damage * (1.0 + (actor:item_stack_count(item) * 1.5))

    -- Apply cooldown
    actor:buff_apply(cooldownBuff, 1, 10)
end)



-- Object

local sprite = Resources.sprite_load(PATH.."assets/sprites/explosiveSpearProjectile.png", 1, 36, 3, false, false, 1, -20, -5, -3, 3)
local soundHit = Resources.sfx_load(PATH.."assets/sounds/explosiveSpearHit.ogg")
local soundExplode = Resources.sfx_load(PATH.."assets/sounds/explosiveSpearExplode.ogg")

local obj = Object.new("aphelion", "explosiveSpearObject")
obj:set_sprite(sprite)
obj:set_depth(-1)

obj:onCreate(function(self)
    self.vsp = -2.0
    self.grav = 0.18

    self.hit = nil
    self.hit_offset_x = 0
    self.hit_offset_y = 0

    self.tick = 85
end)

obj:onStep(function(self)
    if not self.flag_hit then
        -- Move
        self.x = self.x + self.hsp
        self.y = self.y + self.vsp
        self.vsp = self.vsp + self.grav

        -- Actor collision
        local actors = self:get_collisions(gm.constants.pActor)
        for _, actor in ipairs(actors) do
            if actor.team and actor.team ~= self.parent.team then
                self.flag_hit = true
                self.hit = actor
                self.hit_offset_x = actor.x - self.x
                self.hit_offset_y = actor.y - self.y
                gm.sound_play_at(soundHit, 1.0, 1.0, self.x, self.y, 1.0)
                break
            end
        end

        -- Wall collision
        if self:is_colliding(gm.constants.oB) then
            self.flag_hit = true
            gm.sound_play_at(soundHit, 1.0, 1.0, self.x, self.y, 1.0)
        end

        -- Set image_angle
        self.image_angle = gm.point_direction(0, 0, self.hsp, self.vsp)
    end
end)

obj:onStep(function(self)
    if self.flag_hit then
        self.tick = self.tick - 1

        if self.hit then
            -- Embed into hit actor
            self.x = self.hit.x - self.hit_offset_x
            self.y = self.hit.y - self.hit_offset_y

            -- Deal pop damage
            if self.tick % 25 == 0 then
                self.hit:take_damage(self.pop_damage, self.parent, self.hit.x, self.hit.y - 36, 5046527)
            end
        end

        -- Explode
        if self.tick <= -20 or (self.hit and not Instance.exists(self.hit)) then
            local explosion = self.parent:fire_explosion(self.x, self.y, 95, 95, self.damage / self.parent.damage, 2.0)
            explosion.proc = false
            explosion.damage_color = 5046527
            if explosion.critical then
                explosion.critical = false
                explosion.damage = explosion.damage / 2.0
            end
            gm.sound_play_at(soundExplode, 1.0, 1.0, self.x, self.y, 1.0)
            self:destroy()
        end
    end
end)

obj:onStep(function(self)
    -- Destroy when falling out of map
    if self.y >= gm.variable_global_get("room_height") then
        self:destroy()
    end
end)

obj:onDraw(function(self)
    if self.flag_hit then
        -- Show explosion radius
        local radius = Helper.ease_out(math.min(85.0 - self.tick, 45.0) / 45.0) * 110
        gm.draw_set_circle_precision(64)
        gm.draw_set_alpha(0.5)
        local c = Color.WHITE
        gm.draw_circle(self.x, self.y, radius, c, c, true)
        gm.draw_set_alpha(1)
        gm.draw_set_circle_precision(24)
    end
end)



-- Buffs

local sprite = Resources.sprite_load(PATH.."assets/sprites/buffExplosiveSpear.png", 1, 7, 9)

local buff = Buff.new("aphelion", "explosiveSpearDisplay")
buff.icon_sprite = sprite
buff.icon_stack_subimage = false
buff.draw_stack_number = true
buff.stack_number_col = gm.array_create(1, 12500670)
buff.max_stack = 10
buff.is_timed = false
buff.is_debuff = true

buff:onApply(function(actor, stack)
    local actor_data = actor:get_data("aphelion-explosiveSpear")
    actor_data.cooldown = 60.0
end)

buff:onStep(function(actor, stack)
    local actor_data = actor:get_data("aphelion-explosiveSpear")

    actor_data.cooldown = actor_data.cooldown - 1

    if actor_data.cooldown <= 0 then
        actor_data.cooldown = 60
        actor:buff_remove(buff, 1)
    end
end)