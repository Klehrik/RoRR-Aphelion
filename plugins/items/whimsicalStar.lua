-- Whimsical Star

local sprite = Resources.sprite_load(PATH.."assets/sprites/ballisticVest.png", 1, false, false, 16, 16)

local item = Item.create("aphelion", "whimsicalStar")
Item.set_sprite(item, sprite)
Item.set_tier(item, Item.TIER.rare)
Item.set_loot_tags(item, Item.LOOT_TAG.category_utility)

Item.add_callback(item, "onPickup", function(actor, stack)
    if not actor.aphelion_whimsicalStar_insts then actor.aphelion_whimsicalStar_insts = gm.ds_list_create() end

    local count = 3
    if stack >= 2 then count = 2 end
    local prev = nil
    for i = 1, count do
        local inst = Object.spawn(Object.find("aphelion", "whimsicalStar"), actor.x, actor.y)
        inst.parent = actor
        inst.radius = 32 + (gm.ds_list_size(actor.aphelion_whimsicalStar_insts) * 2)
        inst.prev = actor
        if i > 1 then inst.prev = prev end
        prev = inst
        gm.ds_list_add(actor.aphelion_whimsicalStar_insts, inst)
    end
end)

Item.add_callback(item, "onRemove", function(actor, stack)
    local count = 3
    if stack >= 2 then count = 2 end
    for i = 1, count do
        local inst = gm.ds_list_find_value(actor.aphelion_whimsicalStar_insts, gm.ds_list_size(actor.aphelion_whimsicalStar_insts) - 1)
        if Instance.exists(inst) then gm.instance_destroy(inst) end
        gm.ds_list_delete(actor.aphelion_whimsicalStar_insts, gm.ds_list_size(actor.aphelion_whimsicalStar_insts) - 1)
    end
end)



-- Object

local sprite = Resources.sprite_load(PATH.."assets/sprites/ration.png", 1, false, false, 16, 16)

local obj = Object.create("aphelion", "whimsicalStar")
Object.set_hitbox(obj, -8, -8, 8, 8)

Object.add_callback(obj, "Init", function(self)
    self.persistent = true
    self.sprite_index = sprite
    self.hsp = gm.random_range(-3.0, 3.0)
    self.vsp = gm.random_range(-3.0, 3.0)
    self.cooldown = 0
    self.cooldown_max = 120
    self.damage_coeff = 2.5
end)

Object.add_callback(obj, "Step", function(self)
    -- Follow "previous" star
    local acc = 0.2

    if self.prev.x < self.x then self.hsp = self.hsp - acc
    else self.hsp = self.hsp + acc
    end

    if self.prev.y < self.y then self.vsp = self.vsp - acc
    else self.vsp = self.vsp + acc
    end

    -- Clamp max speed
    local max_speed = gm.clamp(gm.point_distance(self.x, self.y, self.parent.x, self.parent.y) / 28.0, 4.0, 12.0)
    if math.abs(self.hsp) > max_speed then self.hsp = max_speed * gm.sign(self.hsp) end
    if math.abs(self.vsp) > max_speed then self.vsp = max_speed * gm.sign(self.vsp) end

    -- Move
    self.x = self.x + self.hsp
    self.y = self.y + self.vsp
end)

Object.add_callback(obj, "Step", function(self)
    -- Reduce cooldown
    if self.cooldown > 0 then
        self.cooldown = self.cooldown - 1
        return
    end

    -- Get all collisions with pActors
    local actors = Object.get_collisions(self, gm.constants.pActor)

    -- Deal damage to an enemy
    for _, actor in ipairs(actors) do
        if actor.team and actor.team ~= self.parent.team then
            Actor.damage(actor, self.parent, self.parent.damage * self.damage_coeff, actor.x, actor.y - 36)
            self.cooldown = self.cooldown_max
            break
        end
    end
end)

Object.add_callback(obj, "Draw", function(self)
    -- TEMP: draw a circle for now
    --gm.draw_circle(self.x, self.y, 6, false)
    local alpha = 1.0
    if self.cooldown > 0 then alpha = 0.5 end
    gm.draw_sprite_ext(self.sprite_index, 0, self.x, self.y, 1, 1, 0, 16777215, alpha)

    -- gm.draw_circle(self.x, self.y, 3, false)

    -- local hitbox = Object.get_collision_box(self)
    -- gm.draw_rectangle(hitbox.left, hitbox.top, hitbox.right, hitbox.bottom, true)
end)