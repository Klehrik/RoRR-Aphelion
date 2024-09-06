-- Magic Dagger

local sprite = Resources.sprite_load(PATH.."assets/sprites/magicDagger.png", 2, false, false, 22, 22)

local equip = Equipment.new("aphelion", "magicDagger")
equip:set_sprite(sprite)
equip:set_loot_tags(Item.LOOT_TAG.category_damage, Item.LOOT_TAG.category_utility)
equip:set_cooldown(45)

equip:add_callback("onUse", function(actor)
    local use_dir = actor.value:player_util_local_player_get_equipment_activation_direction()
    if use_dir == true then use_dir = 1.0 end
    if use_dir == false then use_dir = -1.0 end

    local obj = Object.find("aphelion", "magicDaggerFreeze")
    local inst = obj:create(actor.x, actor.bbox_bottom + 1)
    inst.parent = actor
    inst.image_xscale = inst.image_xscale * use_dir
    inst.x_offset = 28 * use_dir
end)



-- Object

local sprite = gm.constants.sChefIce
local soundWindup = Resources.sfx_load(PATH.."assets/sounds/magicDaggerWindup.ogg")
local soundFreeze = Resources.sfx_load(PATH.."assets/sounds/magicDaggerFreeze.ogg")

local obj = Object.new("aphelion", "magicDaggerFreeze")
obj:set_sprite(sprite)
obj:set_depth(-1)

obj:add_callback("onCreate", function(self)
    self.image_index = 0
    self.image_speed = 0

    self.image_alpha = 0.0
    self.image_xscale = 4.0
    self.image_yscale = 2.0

    self.damage_coeff = 2.5
    self.freeze_time = 4.1  -- This is evidently not in seconds

    self.state = 0
    self.state_time = 0
end)

obj:add_callback("onStep", function(self)
    if self.state == 0 then
        self.state_time = self.state_time + 1

        self.x = self.parent.x + self.x_offset
        self.y = self.parent.bbox_bottom + 1

        if self.state_time == 1 then gm.sound_play_at(soundWindup, 1.0, 1.0, self.x, self.y, 1.0) end
        if self.state_time >= 30 then
            self.state = 1
            self.state_time = 0
            self.image_speed = 0.15
            self.image_alpha = 0.85
        end

    elseif self.state == 1 then
        self.state_time = self.state_time + 1

        if self.state_time == 1 then gm.sound_play_at(soundFreeze, 1.0, 1.0, self.x, self.y, 1.0) end

        -- Freeze
        if (not self.hit) and self.image_index >= 1.25 then
            self.hit = true

            local radius_x = 31 * math.abs(self.image_xscale)
            local radius_y = 18 * math.abs(self.image_yscale)

            local damager = self.parent:fire_explosion(self.x + (radius_x * gm.sign(self.image_xscale)), self.y - radius_y, radius_x, radius_y, self.damage_coeff, self.freeze_time)
            damager.aphelion_magicDagger_ice = true
            damager.knockback_kind = 3
            damager.damage_color = 14064784
        end

        -- Animate
        if self.image_index >= 7 then
            self.image_speed = 0.0
            self.image_alpha = self.image_alpha - 0.02
            if self.image_alpha <= 0 then self:destroy() end
        end
    end
end)

Actor.add_callback("onHit", function(actor, victim, damager)
    if ((not victim.stun_immune) or (victim.stun_immune == false))
    and damager and damager.aphelion_magicDagger_ice then
        victim:buff_apply(Buff.find("aphelion-magicDaggerFreeze"), 6 * 60.0)
    end
end)



-- Buff

local buff = Buff.new("aphelion", "magicDaggerFreeze")
buff.show_icon = false
buff.is_debuff = true

buff:add_callback("onApply", function(actor, stack)
    actor.aphelion_magicDagger_saved_x = actor.x
end)

buff:add_callback("onStep", function(actor, stack)
    actor.x = actor.aphelion_magicDagger_saved_x
    actor.pHspeed = 0.0

    -- Remove buff if no longer stunned
    if actor.stunned == 0.0 or actor.stunned == false then actor:buff_remove(buff) end
end)



-- Achievement
equip:add_achievement()

gm.pre_script_hook(gm.constants.__input_system_tick, function(self, other, result, args)
    if gm.variable_global_get("stage_id") == 10.0 then
        equip:progress_achievement()
    end
end)