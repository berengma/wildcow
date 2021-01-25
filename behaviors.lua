local abr = tonumber(minetest.get_mapgen_setting('active_block_range')) or 2
local abs = math.abs
local random = water_life.random
local min=math.min
local max=math.max
local p2s = minetest.pos_to_string


function wildcow.whereismum(self,radius,reverse)
	if not self then return nil end
	if not radius then radius = self.view_range end
	local pos = mobkit.get_stand_pos(self)
	local name = "wildcow:auroch_female"
	if reverse then name = "wildcow:auroch_calf" end
	
	local otable = minetest.get_objects_inside_radius(pos,radius)
	local dna = water_life.dna(self)
	
	for i = #otable,1,-1 do
				local entity = otable[i]:get_luaentity()
				if entity and entity.name == name  then 
					if water_life.dna(entity) ~= dna then
						table.remove(otable,i)
					end
				else
					table.remove(otable,i)
				end
	end
	
	return otable
	
end


local function find_matching_partners(self)
	local pos = mobkit.get_stand_pos(self)
	local name = "wildcow:auroch_female"
	local otable = minetest.get_objects_inside_radius(pos,self.view_range)
	local horny = water_life.horny(self)
	
	for i = #otable,1,-1 do
				local entity = otable[i]:get_luaentity()
				if entity and entity.name == name then
					if abs(water_life.horny(entity) - horny) > 50 or water_life.pregnant(entity) > 0 or water_life.is_parent(entity) > 0 then
						table.remove(otable,i)
					end
				else
					table.remove(otable,i)
				end
	end
	return otable
end


local function sortout(self,ftable)
	if not ftable or #ftable < 1 then return ftable end
	local pos = mobkit.get_stand_pos(self)
	pos.y = pos.y + 0.5
	
	
	
	for i = #ftable,1,-1 do
		
		--[[
		if water_life.find_collision(pos,ftable[i],true) then 
			table.remove(ftable,i)
		end
		]]
		local way = water_life.find_path(pos, ftable[i], self, self.dtime,true)
		--minetest.chat_send_all(dump(way))
		if not way or #way < 2 then table.remove(ftable,i) end
	end
	return ftable
end
		

function wildcow.hq_overrun(self,prty,target)
	local pos = mobkit.get_stand_pos(self)
	local tpos = target:get_pos()
	local tyaw = water_life.get_yaw_to_object(self,target)
	tpos = mobkit.pos_translate2d(mobkit.get_stand_pos(self),tyaw,10)
	local dir = vector.subtract(tpos,pos)
	mobkit.clear_queue_high(self)
	local hit = false
	
	local func = function(self)
		
		if not mobkit.is_alive(target) then return true end
		local dist = water_life.dist2tgt(self,target)
		if dist > self.view_range then return true end
		dist = math.floor(dist + 0.5)
		
		
		if dist == 1 and not hit then
			mobkit.animate(self,'attack')
			target:punch(self.object,1,self.attack) 
			water_life.knockback_player(self,target,20)
			hit = true
		end
		
		if mobkit.is_queue_empty_low(self) and self.isonground then
			local pos = mobkit.get_stand_pos(self)
			if vector.distance(pos,tpos) >= 1.3 then
				wildcow.goto_next_waypoint(self,tpos,2)
			else
				return true
			end
		end
	end
	mobkit.queue_high(self,func,prty)

end


function wildcow.hq_meetmygirl(self,prty)
	local name ="wildcow:auroch_female"
	local pos = self.object:get_pos()
	local found = water_life.count_objects(pos,48,name)
	local init = true
	local passangan = {}
	local tpos = {}
	
	local func = function(self)
		
		if init then 
			if not found[name] then return true end
			
			
			local otable = minetest.get_objects_inside_radius(pos, 48)
			for _,obj in ipairs(otable) do
				local luaent = obj:get_luaentity()
				if luaent and luaent.name == name and water_life.is_boss(luaent) then
					passangan = obj 
					break
				end
			end
			init = false
			if passangan == {} or not mobkit.is_alive(passangan:get_luaentity())  then return true end
			tpos = passangan:get_pos()
			--water_life.temp_show(tpos,5,5)
			if not water_life.gopath(self,tpos,nil,wildcow.fast_pf) then
				--minetest.chat_send_all("No way to there")
				return true
			end
		end
		
		if mobkit.is_queue_empty_low(self) and self.isonground then
			if not mobkit.is_alive(passangan:get_luaentity()) then return true end
			pos = mobkit.get_stand_pos(self)
			tpos = passangan:get_pos()
			
			if vector.distance(pos,tpos) >= 5 then
				wildcow.goto_next_waypoint(self,tpos,1)
			else
				local mate = find_matching_partners(self)
				local hunger = math.floor(water_life.hunger(self)/20) -1
				
				--minetest.chat_send_all(dump(#mate).." matches found, energy for "..hunger.." of them")
				if not mate or #mate < 1 then return true end
				
				if hunger > #mate then hunger = #mate end
				
				for i = 1,hunger,1 do
					water_life.hunger(self,-20)
					local choice = mate[i]:get_luaentity()
					water_life.pregnant(choice,os.clock())
					water_life.horny(choice,100)
					
				end
				
				water_life.horny(self,100)
				return true
					
			end
		end
		 
		
	end
	
	
	mobkit.queue_high(self,func,prty)
end
	
	
	

function wildcow.hq_stare(self,prty,target)
	local init = true
	local gethim = 7
	
	local func = function(self)
		if not mobkit.is_alive(target) then return true end
		if init then
			mobkit.animate(self,"headdown")
			if random(100) < 33 then
				mobkit.make_sound(self,"angry")
			end
			init = false
		end
		local pos = self.object:get_pos()
		local tyaw = water_life.get_yaw_to_object(self,target)
		local yaw = self.object:get_yaw()
		local tpos = target:get_pos()
		local raypos = mobkit.pos_shift(pos,{y=1})
		gethim = gethim - self.dtime
		
		if mobkit.timer(self,1) and target:is_player() and water_life.find_collision(raypos,{x=tpos.x, y=tpos.y + 1.8, z= tpos.z},true,true) then return true end
		if water_life.dist2tgt(self,target) > 15 then return true end
		if water_life.dist2tgt(self,target) < 8 or gethim < 0 then
			water_life.hunger(self,-5)
			wildcow.hq_overrun(self,prty+1,target)
			--return true
		end
		
		--minetest.chat_send_all(dump(yaw).." : "..dump(tyaw).."  >>  "..dump(abs(tyaw-yaw)))
		
		if abs(tyaw-yaw) > 0.25 and mobkit.is_queue_empty_low(self) then
			mobkit.lq_turn2pos(self,tpos) 
		end
	end
	mobkit.queue_high(self,func,prty)
end

function wildcow.hq_goto(self,prty,tpos)
	local func = function(self)
		if mobkit.is_queue_empty_low(self) and self.isonground then
			local pos = mobkit.get_stand_pos(self)
			if vector.distance(pos,tpos) >= 3 then          --1.2
				wildcow.goto_next_waypoint(self,tpos)
			else
				return true
			end
		end
	end
	mobkit.queue_high(self,func,prty)
end


function wildcow.goto_next_waypoint(self,tpos,speedfactor)
	local height, pos2 = mobkit.get_next_waypoint(self,tpos)
	if not speedfactor or speedfactor < 1 then speedfactor = 1 end
	
	if not height then return false end
	
	if height <= 0.01 then
		local yaw = self.object:get_yaw()
		local tyaw = minetest.dir_to_yaw(vector.direction(self.object:get_pos(),pos2))
		if abs(tyaw-yaw) > 1 then
			mobkit.lq_turn2pos(self,pos2) 
		end
		mobkit.lq_dumbwalk(self,pos2,speedfactor)
	else
		mobkit.lq_turn2pos(self,pos2) 
		mobkit.lq_dumbjump(self,height) 
	end
	return true
end


function wildcow.hq_find_food(self,prty,radius)
    
	local init = true
	local yaw =  self.object:get_yaw()
	local pos = mobkit.get_stand_pos(self)
	local pos1 = {x=pos.x -radius,y=pos.y-1,z=pos.z-radius}
	local pos2 = {x=pos.x +radius,y=pos.y+1,z=pos.z+radius}
	local food = minetest.find_node_near(pos,radius, {"group:growing","group:plant"})
	if not food then food = minetest.find_node_near(pos,radius, {"group:flora","default:papyrus","default:dry_shrub"}) end
	if not food then food =  minetest.find_node_near(pos, radius, {"default:dirt_with_grass"}) end
	if not food then return true end
	local snack = food
	local anim = false
	local sinit = false
	
	local func = function(self)
		local pos = mobkit.get_stand_pos(self)
		--water_life.temp_show(snack,1,5)
		
		-- if too near pathfinder returns nil. You already stand on top of it !
		if vector.distance(pos,snack) > 2 and not water_life.find_path(pos, snack, self, self.dtime,true) then return true end 
		
		if mobkit.is_queue_empty_low(self) and self.isonground then
					if vector.distance(pos,snack) > 1.6 then
						if init then
							--wildcow.hq_goto(self,prty+1,snack)
							water_life.hq_findpath(self,prty+1,snack, 1.5,0.5,wildcow.fast_pf)
							init=false
						end
					else
						if not anim and not sinit then
							self.object:set_velocity({x=0,y=0,z=0})
							mobkit.animate(self,'eat')
							--water_life.temp_show(snack,5)
							sinit = true
							
							minetest.after(2,function ()
								local nname = minetest.get_node(snack).name
								if nname == "default:papyrus" then
									minetest.dig_node(snack)
								elseif nname == "default:dirt_with_grass" then
									minetest.set_node(snack,{name="default:dirt"})
								else
									minetest.set_node(snack,{name="air"})
								end
								anim = true
							end)
						elseif anim and sinit then
							water_life.hunger(self,5)
							return true 
						end
					end
		else
			return true
		end
	end
    mobkit.queue_high(self,func,prty)
end


function wildcow.node_dps_dmg(self)
	local pos = self.object:get_pos()
	local box = self.object:get_properties().collisionbox
	local pos1 = {x = pos.x + box[1], y = pos.y + box[2], z = pos.z + box[3]}
	local pos2 = {x = pos.x + box[4], y = pos.y + box[5], z = pos.z + box[6]}
	local nodes_overlap = mobkit.get_nodes_in_area(pos1, pos2)
	local total_damage = 0

	for node_def, _ in pairs(nodes_overlap) do
		local dps = node_def.damage_per_second
		if dps then
			total_damage = math.max(total_damage, dps)
		end
	end

	if total_damage ~= 0 then
		mobkit.hurt(self, total_damage)
	end
end


