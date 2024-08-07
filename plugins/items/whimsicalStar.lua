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
    for i = 1, count do
        local inst = Object.spawn(Object.find("aphelion", "whimsicalStar"), actor.x, actor.y)
        inst.parent = actor
        inst.radius = 32 + (gm.ds_list_size(actor.aphelion_whimsicalStar_insts) * 2)
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

local obj = Object.create("aphelion", "whimsicalStar")

Object.add_callback(obj, "Init", function(self)
    self.persistent = true
    self.vec_x = 0
    self.vec_y = 0
    self.dir_to = gm.irandom_range(0, 359)
    self.force_new_dest = 120.0
end)

Object.add_callback(obj, "Step", function(self)
    local x_to = gm.dcos(self.dir_to) * self.radius
    local y_to = -gm.dsin(self.dir_to) * self.radius

    local max_speed = math.max(gm.point_distance(self.x, self.y, self.parent.x, self.parent.y) / 12.0, 3.0)
    
    -- Move towards destination
    local dir = gm.point_direction(self.x, self.y, self.parent.x + x_to, self.parent.y + y_to)
    local vec_m = math.max(max_speed / 24.0, 0.2)  -- Acceleration value
    local vec_x = gm.dcos(dir) * vec_m
    local vec_y = -gm.dsin(dir) * vec_m

    -- Add dir vector to current
    self.vec_x = self.vec_x + vec_x
    self.vec_y = self.vec_y + vec_y

    -- Clamp max speed
    local speed = gm.point_distance(0, 0, self.vec_x, self.vec_y)
    if speed > max_speed then
        speed = max_speed
        local current_dir = gm.point_direction(0, 0, self.vec_x, self.vec_y)
        self.vec_x = gm.dcos(current_dir) * max_speed
        self.vec_y = -gm.dsin(current_dir) * max_speed
    end

    -- Move
    self.x = self.x + self.vec_x
    self.y = self.y + self.vec_y

    -- Pick new destination if reached
    -- or when timer expires
    self.force_new_dest = self.force_new_dest - 1
    if gm.point_distance(self.x, self.y, self.parent.x + x_to, self.parent.y + y_to) <= math.max(speed, 2.0)
    or self.force_new_dest <= 0 then
        self.dir_to = self.dir_to + gm.irandom_range(90, 180)
        self.force_new_dest = 120.0
    end
end)

Object.add_callback(obj, "Draw", function(self)
    -- temp: draw a circle for now
    gm.draw_circle(self.x, self.y, 6, false)

    -- DEBUG: Show destination
    -- local x_to = gm.dcos(self.dir_to) * self.radius
    -- local y_to = -gm.dsin(self.dir_to) * self.radius
    -- gm.draw_circle(self.parent.x + x_to, self.parent.y + y_to, 6, true)
end)