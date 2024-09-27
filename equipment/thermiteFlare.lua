-- -- Thermite Flare

-- local sprite = Resources.sprite_load("aphelion", "magicDagger", PATH.."assets/sprites/magicDagger.png", 2, 22, 22)

-- local equip = Equipment.new("aphelion", "thermiteFlare")
-- equip:set_sprite(sprite)
-- equip:set_loot_tags(Item.LOOT_TAG.category_damage)
-- equip:set_cooldown(20)

-- equip:onUse(function(actor)
--     local use_dir = actor:get_equipment_use_direction()

--     local obj = Object.find("aphelion", "thermiteFlareObject")
--     local inst = obj:create(actor.x, actor.y - 4)
--     local instData = inst:get_data()
--     instData.parent = actor
--     instData.hsp = 8.0 * use_dir
-- end)



-- -- Parameters

-- local damage_coeff = 0.6
-- local speed_mult = 0.6
-- local frame_max = 12
-- local duration = 10     -- in seconds



-- -- Object

-- local sprite = gm.constants.sBanditDynamite
-- -- local soundWindup = Resources.sfx_load(PATH.."assets/sounds/magicDaggerWindup.ogg")
-- -- local soundFreeze = Resources.sfx_load(PATH.."assets/sounds/magicDaggerFreeze.ogg")

-- local obj = Object.new("aphelion", "thermiteFlareObject")
-- obj:set_sprite(sprite)
-- obj:set_depth(-1)

-- obj:onCreate(function(self)
--     local selfData = self:get_data()

--     self.image_speed = 0.25
--     self.image_angle = gm.irandom_range(0, 359)

--     selfData.vsp = -2.0
--     selfData.grav = 0.18
-- end)

-- obj:onStep(function(self)
--     local selfData = self:get_data()
    
--     -- Move
--     self.x = self.x + selfData.hsp
--     self.y = self.y + selfData.vsp
--     selfData.vsp = selfData.vsp + selfData.grav

--     -- Rotate
--     self.image_angle = self.image_angle + 2

--     -- Actor collision
--     local actors = self:get_collisions(gm.constants.pActor)
--     for _, actor in ipairs(actors) do
--         if actor.team and actor.team ~= selfData.parent.team then
--             actor:buff_apply(Buff.find("aphelion-thermiteFlareIgnite"), duration *60)
--             actor:get_data("thermiteFlare").attacker = selfData.parent
--             self:destroy()
--             break
--         end
--     end

--     -- Worm body collision
--     local actors = self:get_collisions(Instance.worm_bodies)
--     for _, actor in ipairs(actors) do
--         if actor.parent and actor.parent.team and actor.parent.team ~= selfData.parent.team then
--             actor.parent:buff_apply(Buff.find("aphelion-thermiteFlareIgnite"), duration *60)
--             actor.parent:get_data("thermiteFlare").attacker = selfData.parent
--             self:destroy()
--             break
--         end
--     end

--     -- Wall collision
--     if self:is_colliding(gm.constants.oB) then
--         self:destroy()
--     end
-- end)



-- -- Buff

-- local buff = Buff.new("aphelion", "thermiteFlareIgnite")
-- buff.show_icon = false
-- buff.is_debuff = true

-- buff:onApply(function(actor, stack)
--     local actorData = actor:get_data("thermiteFlare")
--     actorData.frame = 0
-- end)

-- buff:onStep(function(actor, stack)
--     local actorData = actor:get_data("thermiteFlare")
--     if actorData.frame > 0 then actorData.frame = actorData.frame - 1
--     else
--         actorData.frame = frame_max
--         -- actor:take_damage(damage_coeff, actorData.attacker, Color.TEXT_ORANGE)

--         local damager = actorData.attacker:fire_direct(actor, damage_coeff)
--         damager:set_color(Color.TEXT_ORANGE)
--         damager:set_critical(false)
--         damager:set_proc(false)
--     end
-- end)

-- buff:onPostStatRecalc(function(actor, stack)
--     actor.pHmax = actor.pHmax * speed_mult
-- end)



-- -- Hooks

-- Actor:onPreStep(function(self)
--     local selfData = self:get_data("thermiteFlare")

--     -- Allow the debuff to affect worms/wurms
--     if (self.object_index == gm.constants.oWorm
--     or self.object_index == gm.constants.oWurmHead)
--     and not selfData.remove_immunity then
--         selfData.remove_immunity = true
--         self.buff_immune:set(buff, false)
--     end
-- end)