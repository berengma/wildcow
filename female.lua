local random = water_life.random


local function female_brain(self)
	if self.tamed == nil then self.tamed = false end
	if mobkit.timer(self,1) then wildcow.node_dps_dmg(self) end
	mobkit.vitals(self)

	if self.hp <= 0 then	
		mobkit.clear_queue_high(self)
		water_life.handle_drops(self)
		water_life.hq_die(self,"die")
		return
	end
	
	
	if mobkit.timer(self,120) then 
		if water_life.pregnant(self) < 0 then
			water_life.horny(self,-1)
		end
		if water_life.is_parent(self) > 0 then
			local baby = wildcow.whereismum(self,32,true)
			if not baby or #baby == 0 then
				water_life.is_parent(self,0)
			end
		end
		water_life.hunger(self,-5)
	end
	
	
	if mobkit.timer(self,10) then
		if water_life.hunger(self) < 10 then mobkit.hurt(self,5) end
		water_life.is_alive(self,-10)
	end
	
	if mobkit.timer(self,2) then
		local prty = mobkit.get_queue_priority(self)
		
		if water_life.is_alive(self) < 0 then
			mobkit.clear_queue_high(self)
			water_life.hq_die(self,"die")
			return
		end
		
		if prty < 15 then
			local members = water_life.get_herd_members(self,water_life.abr * 16)
			local score = 0
			local entity = {}
			-- this loop is searching for the herd boss with the highest score. All others will be deleted.
			if #members > 1 then
				for i = #members,1,-1 do
					entity = members[i]:get_luaentity()
					if entity then
						--minetest.chat_send_all(dump(entity.head).."   :   "..dump(score))
								
						if water_life.head(entity) <= score then
							table.remove(members,i)
							water_life.is_boss(entity,0)
						else
							score = water_life.head(entity)
						end
					else
						table.remove(members,i)
					end
				end
				
				local hpos = members[1]:get_pos()
				local obj = members[1]:get_luaentity()
				water_life.is_boss(obj,1)
				local showpos = mobkit.pos_shift(hpos,{y=2})
				--water_life.temp_show(showpos,2,5)
				--minetest.chat_send_all(dump("Boss-POS :"..minetest.pos_to_string(hpos)).."    score= "..dump(score))
				if water_life.head(self) ~= score then water_life.headpos(self,hpos) end			-- if active mob (self) is not boss then remember boss position
			
			end
		end
	end
	
	if mobkit.timer(self,1) then 
		local childent = nil
		local predator = nil
		local danger = ""
		local prty = mobkit.get_queue_priority(self)
		local obj = self.object
		local pos = self.object:get_pos()
		local bosspos = water_life.headpos(self)
		local calf = water_life.pregnant(self)
		local dna = water_life.dna(self)
		local baby = wildcow.whereismum(self,8,true)							-- true searches for calfs, not females
		if baby and #baby > 0 then
			childent = baby[1]:get_luaentity()								-- get the entity to do further checks
		end
		
		local rnd = random(1000)
		if rnd < 5 then
			mobkit.make_sound(self,"idle")
		end
		
		if childent then
			predator = water_life.get_closest_enemy(childent,true)
			if predator then
				if predator:is_player() then
					danger = "\n DANGER: "..predator:get_player_name()
				else
					danger = "\n DANGER: "..predator:get_luaentity().name
				end
			end
		end
		
		if calf > 0 then
			calf = os.clock() - calf
			if calf > wildcow.ptime then
				if random(100) < water_life.hunger(self) then
					
					local obj = minetest.add_entity(pos,'wildcow:auroch_calf')
								if obj then
										water_life.hunger(self,-30)
										water_life.is_parent(self,1)
										local entity = obj:get_luaentity()
										water_life.init_bio(entity)
										water_life.dna(entity,dna)
								end
				end
				water_life.pregnant(self,-1)
			end
		end
		
		
		
		if wildcow.debug then
			local kepala = ""
			local hamil = "not_pregnant"
			if water_life.is_boss(self) == 1 then kepala="BOSS" end
			if water_life.pregnant(self) >= 0 then
				local timer = wildcow.ptime - math.floor( os.clock() - water_life.pregnant(self))
				hamil=tostring(timer).." secs left"
			end
			if water_life.is_parent(self) > 0 then hamil = "Mama" end
			
			
			
			obj:set_nametag_attributes({
					color = '#ff7373',
					text = tostring(water_life.is_alive(self)).."\n"..kepala.."\n"..hamil.."\n"..tostring(water_life.hunger(self)).."% hunger\n"..tostring(water_life.horny(self)).."% horny"..danger,
					})
		end	
		
		if prty < 50 and predator and baby[1] then						-- do not mess with MAMA !
				local ppos = predator:get_pos()
				local bpos = baby[1]:get_pos()
				local dist = water_life.dist2tgt(childent,predator)
				if math.abs(ppos.y - bpos.y) < 3 and dist < 8 and not water_life.inwater(predator) then
					wildcow.hq_overrun(self,50,predator)
				end
		end
			
			
		
		
		if prty < 20 and water_life.inwater(self.object) then
			mobkit.hq_liquid_recovery(self,20)
			water_life.hunger(self,-5)
			return
		end
		
		 
		
		if prty < 15  then
			local pred = mobkit.get_closest_entity(self,'water_life:croc')
			if not pred then pred = mobkit.get_closest_entity(self,'water_life:snake') end
			
			if pred then 
				mobkit.clear_queue_high(self)
				mobkit.clear_queue_low(self)
				mobkit.hq_runfrom(self,15,pred)
				water_life.hunger(self,-1)
				return
			end
		end
		if prty < 13 then
			local plyr = mobkit.get_nearby_player(self)
			if plyr and vector.distance(pos,plyr:get_pos()) < 8 and not self.tamed then 
				mobkit.clear_queue_high(self)
				mobkit.clear_queue_low(self)
				mobkit.hq_runfrom(self,13,plyr)
				water_life.hunger(self,-1)
				return
			end
		end
		
		if prty < 9 then
			if random(100) > water_life.hunger(self) then
				local radius = 5 + math.floor((100 - water_life.hunger(self))/20) * 5
				if water_life.is_boss(self) > 0 then radius = radius * 2 end			-- boss sees everything
				wildcow.hq_find_food(self,9,radius)
				return
			end
		end
		
		if prty < 5 and bosspos then
			local boss = math.floor(vector.distance(pos,bosspos))
			--minetest.chat_send_all(dump(boss))
			if boss > 10 then
				water_life.hq_findpath(self,5,bosspos, 7,0.5,wildcow.fast_pf)
			end
		end
			
		
		if mobkit.is_queue_empty_high(self) then
			mobkit.hq_roam(self,0)
			water_life.hunger(self,-1)
		end
	end
end

minetest.register_entity("wildcow:auroch_female",{
											-- common props
	physical = true,
	stepheight = 0.1,				--EVIL!
	collide_with_objects = false,
	collisionbox = {-0.35, 0, -0.35, 0.35, 0.85, 0.35},
	visual = "mesh",
	mesh = "wildcow_auroch_female.b3d",
	textures = {"wildcow_auroch_female.png"},
	visual_size = {x = 1, y = 1},
	static_save = true,
	makes_footstep_sound = true,
	on_step = mobkit.stepfunc,	-- required
	on_activate = mobkit.actfunc,		-- required
	get_staticdata = mobkit.statfunc,
											-- api props
	springiness=0,
	buoyancy = 0.9,
	max_speed = 5,
	jump_height = 1.26,
	view_range = 12,
	lung_capacity = 20,			-- seconds
	max_hp = 25,
	timeout = -1*wildcow.lifetime,
	attack={range=0.5,damage_groups={fleshy=5}},
	animation = {
	def={range={x=31,y=74},speed=15,loop=true},
	walk={range={x=216,y=231},speed=10,loop=true},
	trot={range={x=85,y=114},speed=20,loop=true},
	run={range={x=120,y=140},speed=30,loop=true},
	stand={range={x=31,y=74},speed=15,loop=true},
	eat={range={x=0,y=30},speed=15,loop=true},
	attack={range={x=145,y=160},speed=20,loop=true},
	die={range={x=191,y=211},speed=10,loop=false},
	},
	drops = {
		{name = "default:diamond", chance = 20, min = 1, max = 3,},		
		{name = "water_life:meat_raw", chance = 2, min = 1, max = 3,},
	},
	sounds = {
		idle={
			{name = "wildcow_cow1",
			gain = water_life.soundadjust},
			{name = "wildcow_cow2",
			gain = water_life.soundadjust},
			{name = "wildcow_cow3",
			gain = water_life.soundadjust},
			}
		},
	brainfunc = female_brain,

	on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if puncher:is_player() and time_from_last_punch > 1 then
			local hvel = vector.multiply(vector.normalize({x=dir.x,y=0,z=dir.z}),4)
			self.object:set_velocity({x=hvel.x,y=2,z=hvel.z})
			mobkit.make_sound(self,'hurt')
			if water_life.bloody then water_life.spilltheblood(self.object) end
			mobkit.hurt(self,tool_capabilities.damage_groups.fleshy or 1)
		elseif not puncher:is_player() then
			mobkit.make_sound(self,'hurt')
			if water_life.bloody then water_life.spilltheblood(self.object) end
			mobkit.hurt(self,self.attack.damage_groups.fleshy or 1)
		end
	end,
	
	on_rightclick = function(self, clicker)
        if not clicker or not clicker:is_player() then return end
        local inv = clicker:get_inventory()
        local item = clicker:get_wielded_item()
        --minetest.chat_send_all(dump(item:get_name()))
        if not item or item:get_name() ~= water_life.catchBA then return end
        if not inv:room_for_item("main", "wildcow:auroch_female_item") then return end
        local pos = mobkit.get_stand_pos(self)
		local name = clicker:get_player_name()
		local hasowner = minetest.is_protected(pos)
        if hasowner and self.tamed then return end
                                            
        inv:add_item("main", "wildcow:auroch_female_item")
        self.object:remove()
    end,
})


