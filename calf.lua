local random = water_life.random


local function calf_brain(self)
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
		water_life.hunger(self,-5)
	end
	
	
	if mobkit.timer(self,10) then
		if water_life.hunger(self) < 10 then mobkit.hurt(self,5) end
	end
	
	
	
	if mobkit.timer(self,1) then 
		local prty = mobkit.get_queue_priority(self)
		local obj = self.object
		local pos = self.object:get_pos()
		local mama = wildcow.whereismum(self,16)
		local bosspos = pos
		if mama and #mama > 0 then 
			bosspos = mama[1]:get_pos()
		end
		
		if self.time_total > wildcow.btime then
			local name = "wildcow:auroch_female"
			if random(100) > 50 then name = "wildcow:auroch_male" end
			mobkit.clear_queue_high(self)
			water_life.hq_die(self,"die")
			--self.object:remove()
			local obj = minetest.add_entity(pos,name)
			if obj then
				local entity = obj:get_luaentity()
				water_life.init_bio(entity)
			end
			return
		end
		
		if wildcow.debug then
			obj:set_nametag_attributes({
					color = '#ff7373',
					text = tostring(wildcow.btime - math.floor(self.time_total*100)/100).."\n"..tostring(water_life.is_alive(self)),
					})
		end
		
        
		if prty < 20 and self.isinliquid then
			mobkit.hq_liquid_recovery(self,20)
			water_life.hunger(self,-5)
			return
		end
		
		
		if prty < 15 then
			if random(100) > water_life.hunger(self) then
				local radius = 5 + math.floor((100 - water_life.hunger(self))/20) * 5
				wildcow.hq_find_food(self,15,radius)
				return
			end
		end
		
		if prty < 10 and bosspos then
			local boss = math.floor(vector.distance(pos,bosspos))
			--minetest.chat_send_all(dump(boss))
			if boss > 5 then
				water_life.hq_findpath(self,10,bosspos, 3,0.5,wildcow.fast_pf)
			end
		end
			
		
		if mobkit.is_queue_empty_high(self) then
			mobkit.hq_roam(self,0)
			water_life.hunger(self,-1)
		end
	end
end

minetest.register_entity("wildcow:auroch_calf",{
											-- common props
	physical = true,
	stepheight = 0.1,				--EVIL!
	collide_with_objects = false,
	collisionbox = {-0.35, 0, -0.35, 0.35, 0.75, 0.35},
	visual = "mesh",
	mesh = "wildcow_auroch_calf.b3d",
	textures = {"wildcow_auroch_calf_male.png"},
	visual_size = {x = 1, y = 1},
	static_save = true,
	makes_footstep_sound = true,
	on_step = mobkit.stepfunc,	-- required
	on_activate = mobkit.actfunc,		-- required
	get_staticdata = mobkit.statfunc,
											-- api props
	springiness=0,
	buoyancy = 0.9,
	max_speed = 4,
	jump_height = 1.26,
	view_range = 10,
	lung_capacity = 20,			-- seconds
	max_hp = 13,
	timeout = 0,
	attack={range=0.5,damage_groups={fleshy=5}},
	sounds = {
		--scared='deer_scared',
		--hurt = 'deer_hurt',
		},
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
		{name = "default:diamond", chance = 50, min = 1, max = 1,},		
		{name = "water_life:meat_raw", chance = 2, min = 1, max = 1,},
	},
	mama = {},
	predators = {["water_life:croc"]=1,
                  ["water_life:alligator"]=1,
                  ["water_life:snake"]=1,
                  },
	
	brainfunc = calf_brain,

	on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		local hvel = vector.multiply(vector.normalize({x=dir.x,y=0,z=dir.z}),4)
		self.object:set_velocity({x=hvel.x,y=2,z=hvel.z})
		mobkit.make_sound(self,'hurt')
		if water_life.bloody then water_life.spilltheblood(self.object) end
		mobkit.hurt(self,tool_capabilities.damage_groups.fleshy or 1)
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

