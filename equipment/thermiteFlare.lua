-- Thermite Flare

local sprite = Resources.sprite_load("aphelion", "equipment/thermiteFlare", PATH.."assets/sprites/equipment/thermiteFlare.png", 2, 22, 22)

local equip = Equipment.new("aphelion", "thermiteFlare")
equip:set_sprite(sprite)
equip:set_loot_tags(Item.LOOT_TAG.category_damage)
equip:set_cooldown(6)

equip:onUse(function(actor)
    local use_dir = actor:get_equipment_use_direction()

    local obj = Object.find("aphelion", "thermiteFlareObject")
    local inst = obj:create(actor.x, actor.y - 4)
    local instData = inst:get_data()
    instData.parent = actor
    instData.hsp = 6.0 * use_dir

    actor:set_equipment(Equipment.find("aphelion-thermiteFlareLast"))
end)



-- Parameters

local damage_coeff = 0.6
local damage_extra = 0.3
local frame_max = 10    -- frames between damage ticks
local duration = 20     -- in seconds



-- Object

local sprite = Resources.sprite_load("aphelion", "objects/thermiteFlare", PATH.."assets/sprites/objects/thermiteFlare.png", 5, 13, 5)

local obj = Object.new("aphelion", "thermiteFlareObject")
obj:set_sprite(sprite)
obj:set_depth(-1)

obj:onCreate(function(self)
    local selfData = self:get_data()

    self.image_speed = 0.25
    self.image_angle = gm.irandom_range(0, 359)

    selfData.vsp = -2.0
    selfData.grav = 0.18
end)

obj:onStep(function(self)
    local selfData = self:get_data()
    
    -- Move
    self.x = self.x + selfData.hsp
    self.y = self.y + selfData.vsp
    selfData.vsp = selfData.vsp + selfData.grav

    -- Rotate
    self.image_angle = self.image_angle + 2

    -- Actor collision
    local actors = self:get_collisions(gm.constants.pActor)
    for _, actor in ipairs(actors) do
        if actor.team and actor.team ~= selfData.parent.team
        and actor:buff_stack_count(Buff.find("aphelion-thermiteFlareIgnite")) <= 0 then
            actor:buff_apply(Buff.find("aphelion-thermiteFlareIgnite"), duration *60)
            actor:get_data("thermiteFlare").attacker = selfData.parent
            self:destroy()
            break
        end
    end

    -- Worm body collision
    local actors = self:get_collisions(Instance.worm_bodies)
    for _, actor in ipairs(actors) do
        if actor.parent and actor.parent.team and actor.parent.team ~= selfData.parent.team then
            actor.parent:buff_apply(Buff.find("aphelion-thermiteFlareIgnite"), duration *60)
            actor.parent:get_data("thermiteFlare").attacker = selfData.parent
            self:destroy()
            break
        end
    end

    -- Bounce on ground
    local obj = gm.constants.pSolidBulletCollision
    if selfData.vsp > 0 and self:is_colliding(obj, self.x, self.y + selfData.vsp) then
        selfData.vsp = selfData.vsp * -0.65
    end

    -- Bounce off of wall
    if self:is_colliding(obj, self.x + selfData.hsp, self.y + selfData.vsp) then
        selfData.hsp = selfData.hsp * -0.65
    end
end)



-- Buff
local dmg_col = Color(0x9c6228)

local buff = Buff.new("aphelion", "thermiteFlareIgnite")
buff.show_icon = false
buff.is_debuff = true

buff:onApply(function(actor, stack)
    local actorData = actor:get_data("thermiteFlare")
    actorData.frame = 0

    if not actor:callback_exists("aphelion-thermiteFlareWeaken") then
        actor:onDamaged("aphelion-thermiteFlareWeaken", function(actor, damager)
            if damager.parent and damager.parent:exists() and (not damager.aphelion_thermiteFlare) then
                local damager2 = damager.parent:fire_direct(actor, damager.damage * damage_extra)
                damager2:use_raw_damage()
                damager2:add_offset(damager)
                damager2:set_color(dmg_col)
                damager2:set_critical(false)
                damager2:set_proc(false)
                damager2.aphelion_thermiteFlare = true
            end
        end)
    end
end)

buff:onRemove(function(actor, stack)
    actor:remove_callback("aphelion-thermiteFlareWeaken")
end)

buff:onStep(function(actor, stack)
    local actorData = actor:get_data("thermiteFlare")
    if actorData.frame > 0 then actorData.frame = actorData.frame - 1
    else
        actorData.frame = frame_max

        local damager = actorData.attacker:fire_direct(actor, damage_coeff)
        damager:set_color(dmg_col)
        damager:set_critical(false)
        damager:set_proc(false)
        damager.aphelion_thermiteFlare = true
    end
end)



-- Hooks

Actor:onPreStep("aphelion-thermiteFlare_removeWurmImmunity", function(self)
    local selfData = self:get_data("thermiteFlare")

    -- Allow the debuff to affect worms/wurms
    if (self.object_index == gm.constants.oWorm
    or self.object_index == gm.constants.oWurmHead)
    and not selfData.remove_immunity then
        selfData.remove_immunity = true
        self.buff_immune:set(buff, false)
    end
end)



-- Achievement
equip:add_achievement(60)

Player:onKill("aphelion-thermiteFlareUnlock", function(actor, victim)
    if GM.actor_is_boss(victim) then
        equip:progress_achievement(1)
    end
end)