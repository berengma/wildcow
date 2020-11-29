local abr = tonumber(minetest.get_mapgen_setting('active_block_range')) or 2
local abs = math.abs
local random = water_life.random

wildcow = {}
wildcow.spawn_rate = 0.5		-- less is more
wildcow.spawnfreq = 10		-- spawn frequency
wildcow.herdsize = 5	

local min=math.min
local max=math.max

wildcow.spawn_rate = 1 - max(min(minetest.settings:get('wildcow_spawn_chance') or 0.2,1),0)
wildcow.spawn_reduction = minetest.settings:get('wildcow_spawn_reduction') or 0.5

local hdrops = minetest.get_modpath("water_life")

water_life.register_shark_food("wildcow:auroch_male")


local path = minetest.get_modpath(minetest.get_current_modname())


dofile(path.."/male.lua")
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

local function sortout(self,ftable)
	if not ftable or #ftable < 1 then return ftable end
	local pos = mobkit.get_stand_pos(self)
	pos.y = pos.y + 0.5
	
	for i = #ftable,1,-1 do
		--[[
		if water_life.find_collision(pos,ftable[i],true) then 
			table.remove(ftable,i)
		end]]
		local way = water_life.find_path(pos, ftable[i], self, self.dtime)
		if not way or #way < 2 then table.remove(ftable,i) end
	end
	return ftable
end
		

function wildcow.hq_goto(self,prty,tpos)
	local func = function(self)
		if mobkit.is_queue_empty_low(self) and self.isonground then
			local pos = mobkit.get_stand_pos(self)
			if vector.distance(pos,tpos) > 1 then
				wildcow.goto_next_waypoint(self,tpos,0.5)
			else
				return true
			end
		end
	end
	mobkit.queue_high(self,func,prty)
end


function wildcow.goto_next_waypoint(self,tpos,speedfactor)
	local height, pos2 = mobkit.get_next_waypoint(self,tpos)
	if not speedfactor then speedfactor = 1 end
	
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
	local pos2 = {x=pos.x +radius,y=pos.y+1,z=pos.z+radius}  --mobkit.pos_translate2d(pos,yaw,radius)
	local food = minetest.find_nodes_in_area(pos1,pos2, {"group:growing","group:plant"})
	if not food or #food < 1 then food = minetest.find_nodes_in_area(pos1,pos2, {"group:flora"}) end
	food = sortout(self,food)
	if #food < 1 then return true end
	--minetest.chat_send_all("### "..dump(#food).." ###")
	local snack = food[random(#food)]
	local anim = false
	local func = function(self)
	local pos = mobkit.get_stand_pos(self)
	--water_life.temp_show(snack,10)
	
    
    if mobkit.is_queue_empty_low(self) and self.isonground then
			
			if vector.distance(pos,snack) > 2 then
				if init then
					--wildcow.hq_goto(self,prty+1,snack)
					water_life.hq_findpath(self,prty+1,snack, 2,0.5)
					init=false
				end
			else
				self.object:set_velocity({x=0,y=0,z=0})
				mobkit.animate(self,'eat')
				minetest.after(2,function ()
					minetest.set_node(snack,{name="air"})
					anim = true
				end)
				if anim then
					water_life.hunger(self,5)
					return true 
				end
			end
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


