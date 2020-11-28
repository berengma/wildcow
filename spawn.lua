local spawntimer = 0
local random = water_life.random
local abr = tonumber(minetest.get_mapgen_setting('active_block_range')) or 2
local abs = math.abs

local function spawnstep(dtime)
    
    spawntimer = spawntimer + dtime
    if spawntimer < 10 then return end

	for _,plyr in ipairs(minetest.get_connected_players()) do
            
			spawntimer = 0
			
			local mobname =  'wildcow:auroch_male'
			local yaw = plyr:get_look_horizontal() + random()*0.35 - 0.75
			local pos = plyr:get_pos()
			local dir = vector.multiply(minetest.yaw_to_dir(yaw),abr*16)
			local pos2 = vector.add(pos,dir)
			pos2.y=pos2.y-5
			local height, liquidflag = mobkit.get_terrain_height(pos2,32)
			local friends = water_life.count_objects(pos,abr*16, mobname)
			if not friends[mobname] then friends[mobname] = 0 end
			
			if random(100) < (100 - ((100/wildcow.herdsize * friends[mobname]) or 1)) then
	
				if height and height >= 0 and height <= 100 and not liquidflag -- and math.abs(height-pos2.y) <= 30 testin
				and mobkit.nodeatpos({x=pos2.x,y=height-0.01,z=pos2.z}).is_ground_content then

						

						pos2.y = height+0.5
						
						--minetest.chat_send_all(dump(friends[mobname]).." : "..dump(wildcow.herdsize))

						if not minetest.is_protected(pos2,mobname) then
							local obj = minetest.add_entity(pos2,mobname)
							if obj then
									local entity = obj:get_luaentity()
									entity.base = pos2
									entity.head = random(65535)
									mobkit.remember(entity,"life",math.floor(os.clock()))
							end
						
					end
					
					
				end
			end
		
	end
end


minetest.register_globalstep(spawnstep)
