-- Thermite Flare (Last)

local sprite = Resources.sprite_load("aphelion", "equipment/thermiteFlareLast", PATH.."assets/sprites/equipment/thermiteFlareLast.png", 2, 22, 22)

local equip = Equipment.new("aphelion", "thermiteFlareLast", true)
equip:set_sprite(sprite)
equip:set_loot_tags(Item.LOOT_TAG.category_damage, Item.LOOT_TAG.equipment_blacklist_enigma, Item.LOOT_TAG.equipment_blacklist_activator)
equip:set_cooldown(30)
equip:toggle_loot(false)

equip:onUse(function(actor)
    local use_dir = actor:get_equipment_use_direction()

    local obj = Object.find("aphelion", "thermiteFlareObject")
    local inst = obj:create(actor.x, actor.y - 4)
    local instData = inst:get_data()
    instData.parent = actor
    instData.hsp = 8.0 * use_dir

    if actor:get_equipment().value == equip.value then
        actor:set_equipment(-1)
    end
end)