local spawntimer = 0
local random = water_life.random
local abr = tonumber(minetest.get_mapgen_setting('active_block_range')) or 2
local abs = math.abs


local function getcount(name)
	if not name then
		return 0 
	else
		return name
	end
end


local function spawnstep(dtime)
    
    spawntimer = spawntimer + dtime
    
	if spawntimer < wildcow.spawnfreq then return end
	--minetest.chat_send_all("SpawnTime")
	
	for _,plyr in ipairs(minetest.get_connected_players()) do

			local mobname = "wildcow:auroch_male"
			
			spawntimer = 0
			local pos = plyr:get_pos()
			local yaw = plyr:get_look_horizontal()
			local animal = water_life.count_objects(pos)
			if animal.all > water_life.maxmobs then toomuch = true end
			
			local radius = (water_life.abr * 12)												-- 75% from 16 = 12 nodes
			radius = random(16,radius)														-- not nearer than 7 nodes in front of player
			local angel = math.rad(random(90))                                       					-- look for random angel 0 - 75 degrees
			if water_life.leftorright() then yaw = yaw + angel else yaw = yaw - angel end   			-- add or substract to/from yaw
				
			local pos2 = mobkit.pos_translate2d(pos,yaw,radius)									-- calculate position
			local bdata =  water_life_get_biome_data(pos2)										-- get biome data at spawn position
			local landpos = water_life.find_node_under_air(pos2,5,{"group:crumbly"})
			local cows = getcount(animal["wildcow:auroch_female"])
			local bulls = getcount(animal["wildcow:auroch_male"])
			local calf = getcount(animal["wildcow:auroch_calf"])
			
			if cows + bulls + calf > wildcow.herdsize * 2 then toomuch = true end
			
			if bulls > cows then mobname = "wildcow:auroch_female" end
			

			if landpos and not toomuch then
				if not minetest.is_protected(landpos,mobname) then
					local obj = minetest.add_entity(landpos,mobname)
					if obj then
						local entity = obj:get_luaentity()
						water_life.init_bio(entity)
					end
						
				end
				
			end
		
	end
end


minetest.register_globalstep(spawnstep)

