-- Magic Dagger

local sprite = Resources.sprite_load(PATH.."assets/sprites/magicDagger.png", 2, false, false, 22, 22)

local equip = Equipment.create("aphelion", "magicDagger")
Equipment.set_sprite(equip, sprite)
Equipment.set_cooldown(equip, 45)
Equipment.set_loot_tags(equip, Item.LOOT_TAG.category_damage, Item.LOOT_TAG.category_utility)

Equipment.add_callback(equip, "onUse", function(actor)
    local inst = Object.spawn(Object.find("aphelion", "magicDaggerFreeze"), actor.x + (24 * gm.sign(actor.image_xscale)), actor.bbox_bottom + 1)
    inst.parent = actor
    inst.image_xscale = inst.image_xscale * gm.sign(actor.image_xscale)
end)



-- Object

local sprite = gm.constants.sChefIce

local obj = Object.create("aphelion", "magicDaggerFreeze")

Object.add_callback(obj, "Init", function(self)
    self.sprite_index = sprite
    self.image_index = 0
    self.image_speed = 0.18
    
    self.image_xscale = 3.0
    self.image_yscale = 2.0

    self.damage_coeff = 3.0
    self.freeze_time = 2.6
end)

Object.add_callback(obj, "Step", function(self)
    -- Freeze
    if (not self.hit) and self.image_index >= 1.5 then
        self.hit = true

        local radius_x = 29 * self.image_xscale
        local radius_y = 23 * self.image_yscale

        local damager = Actor.fire_explosion(self.parent, self.x + (radius_x * gm.sign(self.image_xscale)), self.y, radius_x, radius_y, self.damage_coeff, self.freeze_time + gm.random_range(0, 0.5))
        damager.knockback_kind = 3
        damager.damage_color = 14064784
    end

    -- Animate
    if self.image_index >= 7 then
        self.image_speed = 0.0
        self.image_alpha = self.image_alpha - 0.02
        if self.image_alpha <= 0 then gm.instance_destroy(self) end
    end
end)

Object.add_callback(obj, "Draw", function(self)
    gm.draw_sprite_ext(self.sprite_index, self.image_index, self.x, self.y, self.image_xscale, self.image_yscale, self.image_angle, 16777215, self.image_alpha)

    -- Debug: Draw hitbox
    local box = Object.get_collision_box(self)
    gm.draw_rectangle(box.left, box.top, box.right, box.bottom, true)
end)