local abr = tonumber(minetest.get_mapgen_setting('active_block_range')) or 2
local abs = math.abs
local random = water_life.random
local min=math.min
local max=math.max
local hdrops = minetest.get_modpath("water_life")
local mflowers = minetest.get_modpath("flowers")
local path = minetest.get_modpath(minetest.get_current_modname())


wildcow = {}
wildcow.spawnfreq = 30									-- spawn frequency
wildcow.maxheight = 80									-- max spawning height
wildcow.herdsize = 5									-- max member in a herd
wildcow.ptime = 360										-- time in secs until baby is born
wildcow.btime = 720										-- time needed for a calf to grew up to an adult
wildcow.lifetime = (wildcow.btime+wildcow.ptime)*4			-- lifetime in seconds
wildcow.fast_pf = false									-- faster pathfinding (false is better but slower)
wildcow.debug = false									-- show debug



-- shark and croc food for water_life
water_life.register_shark_food("wildcow:auroch_male")
water_life.register_shark_food("wildcow:auroch_female")
water_life.register_shark_food("wildcow:auroch_calf")




dofile(path.."/behaviors.lua")
dofile(path.."/male.lua")
dofile(path.."/female.lua")
dofile(path.."/calf.lua")
dofile(path.."/spawn.lua")


if mflowers then
	minetest.register_abm({
		label = "Wildcow flower spread",
		nodenames = {"group:flora"},
		interval = 30,
		chance = 4,
		catch_up = true,
		action = function(pos, node, active_object_count, active_object_count_wider)
			flowers.flower_spread(pos,node)
		end,
	})
end


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
