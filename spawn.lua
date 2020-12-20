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
			local toomuch = false
			local pos = plyr:get_pos()
			local yaw = plyr:get_look_horizontal()
			local animal = water_life.count_objects(pos)
			if animal.all > water_life.maxmobs then toomuch = true end
			if pos.y < 0 or pos.y > wildcow.maxheight then toomuch = true end						-- no spawn under 0 and above maxheight
			
			local radius = (water_life.abr * 12)												-- 75% from 16 = 12 nodes
			radius = random(16,radius)														-- not nearer than 7 nodes in front of player
			local angel = math.rad(random(80))                                       					-- look for random angel 0 - 80 degrees
			if water_life.leftorright() then yaw = yaw + angel else yaw = yaw - angel end   			-- add or substract to/from yaw
			local pos2 = mobkit.pos_translate2d(pos,yaw,radius)									-- calculate position
			local bdata =  water_life_get_biome_data(pos2)										-- get biome data at spawn position
			local landpos = water_life.find_node_under_air(pos2,5,{"group:crumbly"})
			if not landpos then																-- maybe too steep, try from above
				
				local factor = water_life.abr * 8
				local pos_up = {x=pos2.x, y=pos2.y + factor, z=pos2.z}									-- max y position
				local pos_down = {x=pos2.x, y=pos2.y - factor, z=pos2.z}								-- min y position
				local surface = water_life.find_collision(pos_up,pos_down,true)							-- find surface
				if surface then pos2 = {x=pos_up.x, y= pos_up.y - surface, z=pos_up.z} end					-- new surface position
				landpos = water_life.find_node_under_air(pos2,5,{"group:crumbly"})
			end
			
			local cows = getcount(animal["wildcow:auroch_female"])
			local bulls = getcount(animal["wildcow:auroch_male"])
			local calf = getcount(animal["wildcow:auroch_calf"])
			
			if cows + bulls + calf > wildcow.herdsize * 2 then toomuch = true end
			
			if bulls > cows then mobname = "wildcow:auroch_female" end
			
			--minetest.chat_send_all(dump(bulls).." : "..dump(cows).." : "..dump(calf).." : "..dump(toomuch))
			

			if landpos and not toomuch then
				if not minetest.is_protected(landpos,mobname) then					-- do not spawn in protected areas
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

