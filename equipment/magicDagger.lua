-- Magic Dagger

local sprite = Resources.sprite_load("aphelion", "equipment/magicDagger", PATH.."assets/sprites/equipment/magicDagger.png", 2, 22, 22)

local equip = Equipment.new("aphelion", "magicDagger")
equip:set_sprite(sprite)
equip:set_loot_tags(Item.LOOT_TAG.category_damage, Item.LOOT_TAG.category_utility)
equip:set_cooldown(45)

equip:onUse(function(actor)
    local use_dir = actor:get_equipment_use_direction()

    local obj = Object.find("aphelion", "magicDaggerFreeze")
    local inst = obj:create(actor.x, actor.bbox_bottom + 1)
    local instData = inst:get_data()
    instData.parent = actor
    instData.x_offset = 28 * use_dir
    inst.image_xscale = inst.image_xscale * use_dir
end)



-- Object
local sprite = gm.constants.sChefIce
local soundWindup = Resources.sfx_load("aphelion", "magicDaggerWindup", PATH.."assets/sounds/magicDaggerWindup.ogg")
local soundFreeze = Resources.sfx_load("aphelion", "magicDaggerFreeze", PATH.."assets/sounds/magicDaggerFreeze.ogg")

local obj = Object.new("aphelion", "magicDaggerFreeze")
obj:set_sprite(sprite)
obj:set_depth(-1)

obj:onCreate(function(self)
    local selfData = self:get_data()

    self.image_index = 0
    self.image_speed = 0

    self.image_alpha = 0.0
    self.image_xscale = 4.0
    self.image_yscale = 2.0

    selfData.damage_coeff = 2.5
    selfData.freeze_time = 9.1  -- in seconds

    selfData.state = 0
    selfData.state_time = 0
end)

obj:onStep(function(self)
    local selfData = self:get_data()
    
    if selfData.state == 0 then
        selfData.state_time = selfData.state_time + 1

        self.x = selfData.parent.x + selfData.x_offset
        self.y = selfData.parent.bbox_bottom + 1

        if selfData.state_time == 1 then gm.sound_play_at(soundWindup, 1.0, 1.0, self.x, self.y, 1.0) end
        if selfData.state_time >= 30 then
            selfData.state = 1
            selfData.state_time = 0
            self.image_speed = 0.15
            self.image_alpha = 0.85
        end

    elseif selfData.state == 1 then
        selfData.state_time = selfData.state_time + 1

        if selfData.state_time == 1 then gm.sound_play_at(soundFreeze, 1.0, 1.0, self.x, self.y, 1.0) end

        -- Freeze
        if (not selfData.hit) and self.image_index >= 1.25 then
            selfData.hit = true

            local radius_x = 29 * math.abs(self.image_xscale)
            local radius_y = 18 * math.abs(self.image_yscale)
            
            local attack_info = selfData.parent:fire_explosion(self.x + (radius_x * gm.sign(self.image_xscale)), self.y - radius_y, radius_x * 2, radius_y * 2, selfData.damage_coeff, nil, nil, true).attack_info
            attack_info:set_color(Color(0x909CD6))
            attack_info:set_critical(false)
            attack_info:set_stun(selfData.freeze_time, nil, Attack_Info.KNOCKBACK_KIND.deepfreeze)
            attack_info.aphelion_magicDagger_ice = true

            Object.find("aphelion-magicDaggerTrunic"):create(selfData.parent.x, selfData.parent.bbox_top - 24)
        end

        -- Animate
        if self.image_index >= 7 then
            self.image_speed = 0.0
            self.image_alpha = self.image_alpha - 0.02
            if self.image_alpha <= 0 then self:destroy() end
        end
    end
end)

Actor:onAttackHit("aphelion-magicDaggerFreeze", function(actor, victim, hit_info)
    if ((not victim.stun_immune) or (victim.stun_immune == false))
    and hit_info and hit_info.aphelion_magicDagger_ice then
        victim:buff_apply(Buff.find("aphelion-magicDaggerFreeze"), 6 * 60.0)
    end
end)



-- Trunic
local sprite = Resources.sprite_load("aphelion", "effects/trunic", PATH.."assets/sprites/effects/trunic.png", 1, 20, 12)

local obj = Object.new("aphelion", "magicDaggerTrunic")
obj:set_sprite(sprite)
obj:set_depth(-1)

obj:onCreate(function(self)
    local selfData = self:get_data()

    selfData.oy = self.y
    selfData.px_up = 8

    selfData.frame = 0
    selfData.ease = 1/30
    selfData.fade = 1/20
end)

obj:onStep(function(self)
    local selfData = self:get_data()
    
    selfData.frame = selfData.frame + 1
    self.y = selfData.oy - (Helper.ease_out(math.min(selfData.ease * selfData.frame, 1.0)) * selfData.px_up)

    if selfData.frame >= 60 then
        self.image_alpha = self.image_alpha - selfData.fade
        if self.image_alpha <= 0 then self:destroy() end
    end
end)



-- Buff
local buff = Buff.new("aphelion", "magicDaggerFreeze")
buff.show_icon = false
buff.is_debuff = true

buff:onApply(function(actor, stack)
    local actorData = actor:get_data("magicDagger")
    actorData.saved_x = actor.x
end)

buff:onPostStep(function(actor, stack)
    local actorData = actor:get_data("magicDagger")
    actor.x = actorData.saved_x
    actor.pHspeed = 0.0

    -- Remove buff if no longer stunned
    if actor.stunned == 0.0 or actor.stunned == false then actor:buff_remove(buff) end
end)



-- Achievement
equip:add_achievement()

Callback.add("onStageStart", "aphelion-magicDaggerUnlock", function(self, other, result, args)
    if gm.variable_global_get("stage_id") == 10.0 then
        equip:progress_achievement()
    end
end, true)