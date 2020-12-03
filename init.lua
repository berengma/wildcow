local abr = tonumber(minetest.get_mapgen_setting('active_block_range')) or 2
local abs = math.abs
local random = water_life.random
local min=math.min
local max=math.max

wildcow = {}
wildcow.spawn_rate = 0.5		-- less is more
wildcow.spawnfreq = 10		-- spawn frequency
wildcow.herdsize = 5	

wildcow.spawn_rate = 1 - max(min(minetest.settings:get('wildcow_spawn_chance') or 0.2,1),0)
wildcow.spawn_reduction = minetest.settings:get('wildcow_spawn_reduction') or 0.5

local hdrops = minetest.get_modpath("water_life")

water_life.register_shark_food("wildcow:auroch_male")
water_life.register_shark_food("wildcow:auroch_female")


local path = minetest.get_modpath(minetest.get_current_modname())


dofile(path.."/behaviors.lua")
dofile(path.."/male.lua")
dofile(path.."/female.lua")
dofile(path.."/spawn.lua")



minetest.override_item("default:marram_grass_1", {
    groups = {snappy = 3, flammable = 3, attached_node = 1, flora = 1},
})

minetest.override_item("default:marram_grass_2", {
    groups = {snappy = 3, flammable = 3, attached_node = 1,
			not_in_creative_inventory=1, flora = 1},
})


minetest.override_item("default:marram_grass_3", {
    groups = {snappy = 3, flammable = 3, attached_node = 1,
			not_in_creative_inventory=1, flora = 1},
})
