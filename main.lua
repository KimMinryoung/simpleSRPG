--testModule = require "test"

function love.update(dt)
	if dt < 1/30 then
		love.timer.sleep(1/30 - dt)
		frame_count=frame_count+1
	end
	if frame_count%7==0 then
		if do_move ~= nil and coroutine.status (do_move) ~= "dead" then
			coroutine.resume (do_move)
		elseif do_atk ~= nil and coroutine.status (do_atk) ~= "dead" then
			coroutine.resume (do_atk)
		elseif do_skill ~= nil and coroutine.status (do_skill) ~= "dead" then
			coroutine.resume (do_skill)
		elseif do_defense ~= nil and coroutine.status (do_defense) ~= "dead" then
			coroutine.resume (do_defense)
		elseif do_enemy_control ~= nil and coroutine.status (do_enemy_control) ~= "dead" then
			coroutine.resume (do_enemy_control)
		elseif state==-1 then
			state=0
			pass_turn()
		end
	end
end

function love.draw(dt)
	draw_map()
	display_moveable()
	display_atkable()
	display_buttons()
	display_chara_info()
	display_main_info()
end

function love.load(arg)
	--testModule.print_rsp()

	map_w=20
	map_h=20
	map_x=0
	map_y=0
	map_offset_x=10
	map_offset_y=10
	map_display_w=15
	map_display_h=13
	tile_w=35
	tile_h=33

	ending=0

	ambush=false

	turn=1

	frame_count=0

	selected_unit=nil

	state=0--0:default 1:pressed a character 2:moved and preparing an action 3:attack 4:skill

	state_stack={}
	state_stack.top=0
	state_stack.states={}
	state_stack.x={}
	state_stack.y={}
	state_stack.moveable={}
	state_stack.moveable_prev_x={}
	state_stack.moveable_prev_y={}
	state_stack.atkable={}

	AI_stack={}
	AI_stack.top=0
	AI_stack.actions={}
	AI_stack.x={}
	AI_stack.y={}
	AI_stack.aim_x={}
	AI_stack.aim_y={}
	AI_stack.reward={}

	info_displaying_chara_num=0

	ranges={}
	ranges[0]={
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0}
	}
	ranges[1]={
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,1,0,0,0,0},
		{0,0,0,1,0,1,0,0,0},
		{0,0,0,0,1,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0}
	}
	ranges[2]={
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,1,1,1,0,0,0},
		{0,0,0,1,0,1,0,0,0},
		{0,0,0,1,1,1,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0}
	}
	ranges[3]={
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,1,0,0,0,0},
		{0,0,0,1,0,1,0,0,0},
		{0,0,1,0,0,0,1,0,0},
		{0,0,0,1,0,1,0,0,0},
		{0,0,0,0,1,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0}
	}
	ranges[4]={
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,1,0,0,0,0},
		{0,0,0,1,1,1,0,0,0},
		{0,0,1,1,0,1,1,0,0},
		{0,1,1,0,0,0,1,1,0},
		{0,0,1,1,0,1,1,0,0},
		{0,0,0,1,1,1,0,0,0},
		{0,0,0,0,1,0,0,0,0},
		{0,0,0,0,0,0,0,0,0}
	}
	ranges[5]={
		{0,0,0,0,1,0,0,0,0},
		{0,0,0,1,0,1,0,0,0},
		{0,0,1,0,0,0,1,0,0},
		{0,1,0,0,0,0,0,1,0},
		{1,0,0,0,0,0,0,0,1},
		{0,1,0,0,0,0,0,1,0},
		{0,0,1,0,0,0,1,0,0},
		{0,0,0,1,0,1,0,0,0},
		{0,0,0,0,1,0,0,0,0}
	}
	ranges[7]={
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,1,1,1,0,0,0},
		{0,0,0,1,1,1,0,0,0},
		{0,0,0,1,1,1,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0}
	}
	ranges[8]={
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,1,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0}
	}
	units={}
	units_number=0
	Unit = {}
	--unit type : 1 - agun, if die game over 0 - agun, even if it dies not game over 2 - enemy
	Unit.new = function(type,name, HP,MP,speed,x,y,atk,dfs,mag,atk_range,img)
		units_number=units_number+1
		local instance = {}
		instance.type=type
		instance.num=units_number
		units[instance.num]=instance
		instance.name = name
		instance.maxHP = HP
		instance.nowHP = HP
		instance.maxMP = MP
		instance.nowMP = MP
		instance.speed=speed
		instance.x=x
		instance.y=y
		instance.atk=atk
		instance.dfs=dfs
		instance.mag=mag
		instance.atk_range=atk_range
		instance.img=img

		instance.action_end=false
		instance.defensing=0--0:not defensing 1:defensing 2:super defensing?(skill)

		instance.skills={}

		instance.addSkill=function(self,skillID)
			table.insert(self.skills,skillID)
		end
   
		instance.setHP = function(self, hp,real)
			if real then
				self.nowHP = math.max(0,math.min(hp,self.maxHP))
			end
			if self.nowHP==0 then
				if real then
					SE_retreat:play()
					if self.type==1 then
						ending=2
					end	
					units[instance.num]=nil
				end
				return true--died
			end
			return false--didn't die
		end

		instance.setMP = function(self, mp)
			self.nowMP = math.max(0,math.min(mp,self.maxMP))
		end

		instance.get_attack = function(self,other_unit,real)
			if self.defensing==0 then
				damage=math.floor(other_unit.atk-self.dfs)
			elseif self.defensing==1 then
				damage=math.floor((other_unit.atk-self.dfs)*0.75)
			elseif self.defensing==2 then
				damage=math.floor((other_unit.atk-self.dfs)*0.5)
			end
			local damage=math.max(1,damage)
			local died=self:setHP(self.nowHP-damage,real)
			return damage,died
		end

		instance.get_casted = function(self,casting_unit,skill,real)
			local power=0
			power=skill_power_calculate(skill,casting_unit,self)
			if skill.ID==1 then
				self:setHP(self.nowHP+power,real)
			end
		end

		return instance
	end

	player_img=love.graphics.newImage("player.png")
	Alchem_img=love.graphics.newImage("Alchem.png")
	jol_img=love.graphics.newImage("jol.png")
	player= Unit.new(1,"Red Mage",80,40,6,1,5,40,30,30,ranges[4],player_img)
	alchem= Unit.new(0,"Alchem",42,98,4,2,5,22,25,43,ranges[2],Alchem_img)
	alchem2= Unit.new(0,"Alchem2",42,98,4,2,4,22,25,43,ranges[2],Alchem_img)
	alchem:addSkill(1)
	alchem2:addSkill(1)

	Unit.new(2,"Blue Mage",60,30,6,7,11,50,10,30,ranges[3],jol_img)
	Unit.new(2,"Matial",50,1,5,7,10,40,15,1,ranges[1],jol_img)
	Unit.new(2,"Archer",20,1,5,8,11,40,0,1,ranges[4],jol_img)
	Unit.new(2,"Swordman",50,1,4,20,10,40,10,1,ranges[2],jol_img)

	skills={}
	skills_number=0
	Skill = {}
	Skill.new = function(ID,name,target_type,MPcost,effect_type,power,target_range)
		skills_number=skills_number+1
		local instance = {}
		instance.ID=ID
		skills[instance.ID]=instance
		instance.name = name
		instance.target_type=target_type--true : target is the same team false : other team
		instance.MPcost = MPcost
		instance.effect_type=effect_type
		instance.power=power
		instance.target_range = target_range
   
		return instance
	end

	heal=Skill.new(1,"Heal",true,10,1,0.5,ranges[7])

	map={
	   { 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 3, 3, 2, 2}, 
	   { 0, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 3, 2, 2, 2},
	   { 0, 0, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 3, 3, 0, 0, 0},
	   { 0, 0, 0, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 3, 0, 0, 0, 0},
	   { 0, 0, 0, 0, 1, 2, 2, 2, 2, 2, 2, 2, 2, 1, 3, 3, 0, 0, 0, 0},
	   { 0, 0, 0, 0, 0, 1, 2, 2, 2, 2, 2, 2, 2, 1, 3, 3, 0, 0, 0, 0},
	   { 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3, 0, 0, 0, 0},
	   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0},
	   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0},
	   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0},
	   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0},
	   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0},
	   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0},
	   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0},
	   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0},
	   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0},
	   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0},
	   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0},
	   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0, 0},
	   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 0, 0, 0, 0, 0},
	}
	tile = {}
	for i=0,3 do
		tile[i]=love.graphics.newImage("tile"..i..".png")
	end
	cost={1,2,3,99}
	love.graphics.setNewFont(20)
	moveable_layer=love.graphics.newImage("moveable_layer.png")
	atkable_layer=love.graphics.newImage("atkable_layer.png")
	button_atk={}
	button_skill={}
	button_dfs={}
	button_atk.img=love.graphics.newImage("button_atk.png")
	button_skill.img=love.graphics.newImage("button_skill.png")
	button_dfs.img=love.graphics.newImage("button_dfs.png")
	button_atk.x=200
	button_atk.y=500
	button_skill.x=300
	button_skill.y=500
	button_dfs.x=400
	button_dfs.y=500
	button_atk.width=67
	button_atk.height=67
	button_skill.width=67
	button_skill.height=67
	button_dfs.width=67
	button_dfs.height=67
	action_buttons={button_atk,button_skill,button_dfs}
	skill_button=love.graphics.newImage("skill_button.png")

	-- sound effects

	SE_click=love.audio.newSource("SE_click.wav","static")
	SE_cancel=love.audio.newSource("SE_cancel.wav","static")
	SE_cantclick=love.audio.newSource("SE_cantclick.wav","static")
	SE_get_atk=love.audio.newSource("SE_get_atk.wav","static")
	SE_heal=love.audio.newSource("SE_heal.wav","static")
	SE_walk=love.audio.newSource("SE_walk.wav","static")
	SE_retreat=love.audio.newSource("SE_retreat.wav","static")

	moveable = {}
	for y=1,map_h do
		moveable[y]={}
	end
	mapstate_clear(moveable,1)
	moveable_prev_x={}
	for y=1,map_h do
		moveable_prev_x[y]={}
	end
	mapstate_clear(moveable_prev_x,0)
	moveable_prev_y={}
	for y=1,map_h do
		moveable_prev_y[y]={}
	end
	mapstate_clear(moveable_prev_y,0)
	atkable = {}
	for y=1,map_h do
		atkable[y]={}
	end
	mapstate_clear(atkable,0)
end

function co_moving(unit,dest_x,dest_y)
	mapstate_clear(atkable,0)
	t_x=dest_x
	t_y=dest_y
	stack_x={}
	stack_y={}
	top=1
	stack_x[top]=dest_x
	stack_y[top]=dest_y
	while not (t_x==unit.x and t_y==unit.y) do
		top=top+1
		stack_x[top]=moveable_prev_x[t_y][t_x]
		stack_y[top]=moveable_prev_y[t_y][t_x]
		t_x=stack_x[top]
		t_y=stack_y[top]
	end
	for i=top,1,-1 do
		SE_walk:play()
		coroutine.yield()
		unit.x=stack_x[i]
		unit.y=stack_y[i]
	end
	mapstate_clear(moveable,1)
	afterMovingCharacter(unit)
end

function co_atk(attacking_unit,attacked_unit)
	SE_get_atk:play()
	atkable_tiles(attacking_unit.x,attacking_unit.y,attacking_unit.atk_range)
	info_displaying_chara_num=attacked_unit.num
	coroutine.yield()
	coroutine.yield()
	attacked_unit:get_attack(attacking_unit,true)
	coroutine.yield()
	mapstate_clear(atkable,0)
	attacking_unit.defensing=0

	action_end_process(attacking_unit)
end

function co_skill(casting_unit,target_unit,skill)
	if skill.ID==1 then
		SE_heal:play()
	end
	atkable_tiles(casting_unit.x,casting_unit.y,skill.target_range)
	info_displaying_chara_num=target_unit.num
	coroutine.yield()
	coroutine.yield()
	target_unit:get_casted(casting_unit,skill,true)
	casting_unit:setMP(casting_unit.nowMP-skill.MPcost)
	coroutine.yield()
	mapstate_clear(atkable,0)
	casting_unit.defensing=0

	action_end_process(casting_unit)
end

function co_defense(unit)
	coroutine.yield()
	unit.defensing=1

	action_end_process(unit)
end

function ambush_appear()
	Unit.new(2,"Matial",50,1,5,11,6,40,15,1,ranges[1],jol_img)
	Unit.new(2,"Matial",50,1,5,10,6,40,15,1,ranges[1],jol_img)
	Unit.new(2,"Matial",50,1,5,12,6,40,15,1,ranges[1],jol_img)
end

function action_end_process(unit)
	unit.action_end=true
	selected_unit=nil
	selected_skill=nil
	state_stack_clear()
	if ambush==false then
		if is_same_team(unit,player) then
			if unit.x>=10 then
				ambush_appear()
				ambush=true
			end
		end
	end
	if turn%2==1 then
		if check_all_acted() then
			pass_turn()
		end
	elseif turn%2==0 then
		AI_stack_clear()
	end
end

function check_all_acted()
	for k,unit in pairs(units) do
		if unit.type<=1 and unit.action_end==false then
			return false
		end
	end
	return true
end

function enemyAI_choose_best(unit)
	minReward=-999
	for i=1,AI_stack.top do
		if AI_stack.reward[i]>minReward then
			minReward=AI_stack.reward[i]
			action=AI_stack.actions[i]
			dest_x=AI_stack.x[i]
			dest_y=AI_stack.y[i]
			aim_x=AI_stack.aim_x[i]
			aim_y=AI_stack.aim_y[i]
		end
	end
	AI_stack_clear()
end

function co_enemy_control()
	local enemynumber=0
	for k,unit in pairs(units) do
		if unit.type==2 then
			enemynumber=enemynumber+1
			simul_enemysActionAfterMove(unit)
			enemyAI_choose_best(unit)
			doMove(unit,dest_x,dest_y)
			coroutine.yield()
		end
	end
	if enemynumber==0 then
		ending=1
	end
	state=-1
end

function love.keypressed(key, unicode)
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
	if key=='up' then
		map_y=math.max(map_y-1,0)
	end
	if key=='down' then
		map_y=math.min(map_y+1,map_h-map_display_h)
	end
	if key=='left' then
		map_x=math.max(map_x-1,0)
	end
	if key=='right' then
		map_x=math.min(map_x+1,map_w-map_display_w)
	end
end

function real_point_to_map_point(pos_x,pos_y)
	x=math.floor((pos_x-map_offset_x)/tile_w)+map_x
	y=math.floor((pos_y-map_offset_y)/tile_h)+map_y
	return x,y
end
function map_point_to_real_point(x,y)
	pos_x=((x-map_x)*tile_w)+map_offset_x
	pos_y=((y-map_y)*tile_h)+map_offset_y
	return pos_x,pos_y
end

function pass_turn()
	for k,unit in pairs(units) do
		unit.action_end=false
	end
	turn=turn+1
	if turn%2==0 then
		enemyTurn()
	end
end

function enemyTurn()
	do_enemy_control=coroutine.create(co_enemy_control)
	coroutine.resume(do_enemy_control)
end

function move_character(unit,x,y)
	if in_displayed_map(x,y) then
		if moveable[y][x]<=0 then
			SE_click:play()
			save_state()
			doMove(unit,x,y)
		end
	end
end

function doSkill(doing_unit,target_unit,skill)
	do_skill=coroutine.create(co_skill)
	coroutine.resume(do_skill,doing_unit,target_unit,skill)
end

function skill_buttons_click(unit,pos_x,pos_y)
	local i=0
	for k,skillID in pairs(unit.skills) do
		i=i+1
		if between(pos_x,600,725) and between(pos_y,30*i+60,30*i+90) then
			local skill=skills[skillID]
			if unit.nowMP>=skill.MPcost then
				SE_click:play()
				save_state()
				state=5
				selected_skill=skill
				atkable_tiles(unit.x,unit.y,skill.target_range)
			else
				SE_cantclick:play()
			end
			break
		end
	end
end

function action_buttons_click(unit,pos_x,pos_y)
	for i=1,3 do
		if between(pos_x,action_buttons[i].x,action_buttons[i].x+action_buttons[i].width) and between(pos_y,action_buttons[i].y,action_buttons[i].y+action_buttons[i].height) then
			if i==1 then
				SE_click:play()
				save_state()
				state=3
				mapstate_set(unit)
			elseif i==2 then
				SE_click:play()
				save_state()
				state=4
			elseif i==3 then
				SE_click:play()
				do_defense=coroutine.create(co_defense)
				coroutine.resume(do_defense,unit)
			end
		end
	end
end

function in_displayed_map(x,y)
	return between(x,1+map_x,map_display_w+map_x) and between(y,1+map_y,map_display_h+map_y)
end

function skill_target_click(x,y,skill)
	if in_displayed_map(x,y) then
		if atkable[y][x]==0 then
			return
		end
		local unit=find_unit_on_this_point(x,y)
		if unit~=nil and is_same_team(selected_unit,unit)==skill.target_type then
			SE_click:play()
			doSkill(selected_unit,unit,skill)
		else
			SE_cantclick:play()
		end
	end
end
function atk_click(x,y)
	if in_displayed_map(x,y) then
		if atkable[y][x]==0 then
			return
		end
		local unit=find_unit_on_this_point(x,y)
		if unit~=nil and is_same_team(selected_unit,unit)==false then
			SE_click:play()
			do_atk=coroutine.create(co_atk)
			coroutine.resume(do_atk,selected_unit,unit)
		else
			SE_cantclick:play()
		end
	end
end
function defense_click(x,y)
	if in_displayed_map(x,y) then
		if x==selected_unit.x and y==selected_unit.y then
			SE_click:play()
			do_defense=coroutine.create(co_defense)
			coroutine.resume(do_defense,selected_unit)
		end
	end
end

function mapstate_set(unit)
	mapstate_clear(moveable,1)
	mapstate_clear(atkable,0)
	if state==1 then
		calcul_moveable_tiles(unit)
		atkable_tiles(unit.x,unit.y,unit.atk_range)
	elseif state==2 or state==3 then
		atkable_tiles(unit.x,unit.y,unit.atk_range)
	end
end

function mapstate_clear(mapstate,num)
	for y=1,map_h do
		for x=1,map_w do
			mapstate[y][x] = num
		end
	end
end

function mapstate_copy(mapstate,copy_map)
	for y=1,map_h do
		for x=1,map_w do
			mapstate[y][x] = copy_map[y][x]
		end
	end
end

function mapstate_copy_and_return(copy_map)
	local new_map={}
	for y=1,map_h do
		new_map[y]={}
	end
	mapstate_copy(new_map,copy_map)
	return new_map
end

function save_state()
	state_stack.top=state_stack.top+1
	local top=state_stack.top
	state_stack.states[top]=state
	state_stack.x[top]=selected_unit.x
	state_stack.y[top]=selected_unit.y
	state_stack.moveable[top]=mapstate_copy_and_return(moveable)
	state_stack.moveable_prev_x[top]=mapstate_copy_and_return(moveable_prev_x)
	state_stack.moveable_prev_y[top]=mapstate_copy_and_return(moveable_prev_y)
	state_stack.atkable[top]=mapstate_copy_and_return(atkable)
end

function load_state()
	local top=state_stack.top
	state=state_stack.states[top]
	state_stack.states[top]=nil
	selected_unit.x=state_stack.x[top]
	state_stack.x[top]=nil
	selected_unit.y=state_stack.y[top]
	state_stack.y[top]=nil
	mapstate_copy(moveable,state_stack.moveable[top])
	state_stack.moveable[top]=nil
	mapstate_copy(moveable_prev_x,state_stack.moveable_prev_x[top])
	state_stack.moveable_prev_x[top]=nil
	mapstate_copy(moveable_prev_y,state_stack.moveable_prev_y[top])
	state_stack.moveable_prev_y[top]=nil
	mapstate_copy(atkable,state_stack.atkable[top])
	state_stack.atkable[top]=nil
	state_stack.top=state_stack.top-1
end

function state_stack_clear()
	mapstate_clear(moveable,1)
	mapstate_clear(atkable,0)
	state_stack.top=0
	state_stack.states={}
	state_stack.x={}
	state_stack.y={}
	state=0
end

function AI_stack_clear()
	AI_stack.top=0
	AI_stack.actions={}
	AI_stack.x={}
	AI_stack.y={}
	AI_stack.aim_x={}
	AI_stack.aim_y={}
	AI_stack.reward={}
end
function doMove(unit,dest_x,dest_y)
	calcul_moveable_tiles(unit)
	do_move = coroutine.create(co_moving)
	coroutine.resume(do_move,unit,dest_x,dest_y)
end

function simul_enemysAtk(unit,x,y)
	atkable_tiles(x,y,unit.atk_range)
	for aim_y=1, map_h do
		for aim_x=1, map_w do
			if(atkable[aim_y][aim_x]==1) then
				our_unit=find_unit_on_this_point(aim_x,aim_y)
				if our_unit~=nil and our_unit.type<=1 then
					local damage,died=our_unit:get_attack(unit,false)
					AI_stack.top=AI_stack.top+1
					AI_stack.actions[AI_stack.top]="atk"
					AI_stack.x[AI_stack.top]=x
					AI_stack.y[AI_stack.top]=y
					AI_stack.aim_x[AI_stack.top]=aim_x
					AI_stack.aim_y[AI_stack.top]=aim_y
					AI_stack.reward[AI_stack.top]=damage
					if died then
						AI_stack.reward[AI_stack.top]=damage+100
					end
				end
			end
		end
	end
	mapstate_clear(atkable,0)
end


function simul_enemysDefense(unit,x,y)
	AI_stack.top=AI_stack.top+1
	AI_stack.actions[AI_stack.top]="defense"
	AI_stack.x[AI_stack.top]=x
	AI_stack.y[AI_stack.top]=y
	AI_stack.aim_x[AI_stack.top]=x
	AI_stack.aim_y[AI_stack.top]=y
	AI_stack.reward[AI_stack.top]=0-math.abs(player.x-x)-math.abs(player.y-y)--must change...
	--move cost to nearest agun
end

function simul_enemysActionAfterMove(unit)
	calcul_moveable_tiles(unit)
	for y=1, map_h do
		for x=1, map_w do
			if(moveable[y][x]<=0) then
				simul_enemysAtk(unit,x,y)
				simul_enemysDefense(unit,x,y)
			end
		end
	end
	mapstate_clear(moveable,1)
end

function afterMovingCharacter(unit)
	state=2
	mapstate_set(unit)
	if unit.type==2 then
		if action=="atk" then
			do_atk=coroutine.create(co_atk)
			coroutine.resume(do_atk,unit,find_unit_on_this_point(aim_x,aim_y))
		elseif action=="defense" then
			do_defense=coroutine.create(co_defense)
			coroutine.resume(do_defense,unit)
		end
	end
end

function should_not_get_input()
	return ending~=0 or turn%2==0 or
		(do_move ~= nil and coroutine.status(do_move)~="dead") or 
		(do_atk ~= nil and coroutine.status(do_atk)~="dead") or
		(do_skill ~= nil and coroutine.status(do_skill)~="dead") or
		(do_defense ~= nil and coroutine.status(do_defense)~="dead") or
		(do_enemy_control ~= nil and coroutine.status(do_enemy_control)~="dead")
end

function love.mousepressed(pos_x, pos_y, button, istouch)
	if should_not_get_input() then
		print("ignore mouse click")
		return
	end
	local x,y=real_point_to_map_point(pos_x,pos_y)
	local clicked_unit=nil
	if in_displayed_map(x,y) then
		clicked_unit=find_unit_on_this_point(x,y)
	end
	if button == 1 then
		if state==0 then
			if clicked_unit~=nil and clicked_unit.type<=1 and clicked_unit.action_end==false then
				selected_unit=clicked_unit
				info_displaying_chara_num=clicked_unit.num
				SE_click:play()
				save_state()
				state=1
				mapstate_set(selected_unit)
			end
		elseif state==1 then
			move_character(selected_unit,x,y)
			atk_click(x,y)
			action_buttons_click(selected_unit,pos_x,pos_y)
		elseif state==2 then
			atk_click(x,y)
			defense_click(x,y)
			action_buttons_click(selected_unit,pos_x,pos_y)
		elseif state==3 then
			atk_click(x,y)
		elseif state==4 then
			skill_buttons_click(selected_unit,pos_x,pos_y)
		elseif state==5 then
			skill_target_click(x,y,selected_skill)
		end
	elseif button == 2 then
		if state==0 then
			if clicked_unit~=nil then
				state=-2
				info_displaying_chara_num=clicked_unit.num
				calcul_moveable_tiles(clicked_unit)
				atkable_tiles(clicked_unit.x,clicked_unit.y,clicked_unit.atk_range)
			end
			--maybe add option menu later
			--or display character infos like jojojeon
		elseif state==1 or state==2 or state==3 or state==4 or state==5 then
			SE_cancel:play()
			load_state()
		elseif state==-2 then
			SE_cancel:play()
			mapstate_clear(moveable,1)
			mapstate_clear(atkable,0)
			info_displaying_chara_num=0
			state=0
		end
	end
end

function draw_map()
	love.graphics.setNewFont(20)
	for y=1, map_display_h do
		for x=1, map_display_w do
			pos_x,pos_y=map_point_to_real_point(x+map_x,y+map_y)
			love.graphics.draw(tile[map[y+map_y][x+map_x]], pos_x, pos_y)
			local unit=find_unit_on_this_point(x+map_x,y+map_y)
			if unit~=nil then
				love.graphics.draw(unit.img, pos_x, pos_y)
				love.graphics.print(unit.nowHP.."/"..unit.maxHP,pos_x+0,pos_y-20)
			end
		end
	end
end

function is_same_team(unit1,unit2)
	if unit1.type<=1 then
		if unit2.type<=1 then
			return true
		else
			return false
		end
	else
		if unit2.type<=1 then
			return false
		else
			return true
		end
	end
end

function calcul_moveable_tiles(unit)
	moveable_tiles(unit.speed,unit.x,unit.y,unit,0,0)

	--if there is an ally unit, I can pass the point but can't arrive at the point
	for y=1,map_h do
		for x=1,map_w do
			local unit_on_this_point=find_unit_on_this_point(x,y)
			if unit_on_this_point~=nil and unit_on_this_point~=unit then
				moveable[y][x]=1
			end
		end
	end
end

function moveable_tiles(remainStep,x,y,unit,prev_x,prev_y)
	if remainStep<0 then
		return
	end
	if moveable[y][x]<=-remainStep then
		return
	end
	local unit_on_this_point=find_unit_on_this_point(x,y)
	if unit_on_this_point~=nil and unit_on_this_point~=unit then
		if is_same_team(unit,unit_on_this_point)==false then
			return
		end
	end
	moveable[y][x]=-remainStep
	moveable_prev_x[y][x]=prev_x
	moveable_prev_y[y][x]=prev_y
	if x-1>=1 then
		moveable_tiles(remainStep-(cost[map[y][x-1]+1]),x-1,y,unit,x,y)
	end
	if x+1<=map_w then
		moveable_tiles(remainStep-(cost[map[y][x+1]+1]),x+1,y,unit,x,y)
	end
	if y-1>=1 then
		moveable_tiles(remainStep-(cost[map[y-1][x]+1]),x,y-1,unit,x,y)
	end
	if y+1<=map_h then
		moveable_tiles(remainStep-(cost[map[y+1][x]+1]),x,y+1,unit,x,y)
	end
end

function find_unit_on_this_point(x,y)
	for k,unit in pairs(units) do
		if unit.x==x and unit.y==y then
			return unit
		end
	end
	return nil
end

function atkable_tiles(ctr_x,ctr_y,atk_range)
	for y=1,9 do
		for x=1,9 do
			if atk_range[y][x]==1 and between(ctr_x+(x-5),1,map_w) and between(ctr_y+(y-5),1,map_h) then
				atkable[ctr_y+(y-5)][ctr_x+(x-5)]=1
			end
		end
	end
end

function display_moveable()
	for y=1, map_display_h do
		for x=1, map_display_w do
			if(moveable[y+map_y][x+map_x]<=0) then
				pos_x,pos_y=map_point_to_real_point(x+map_x,y+map_y)
				love.graphics.draw(moveable_layer, pos_x, pos_y)
			end
		end
	end
end

function display_atkable()
	for y=1, map_display_h do
		for x=1, map_display_w do
			if(atkable[y+map_y][x+map_x]==1) then
				pos_x,pos_y=map_point_to_real_point(x+map_x,y+map_y)
				love.graphics.draw(atkable_layer, pos_x, pos_y)
			end
		end
	end
end

function display_buttons()
	if turn%2==0 then
		return
	end
	if state==1 or state==2 then
		for i=1, 3 do
			love.graphics.draw(action_buttons[i].img,action_buttons[i].x, action_buttons[i].y)
		end
	end
	if state==4 then
		local i=0
		for k,skillID in pairs(selected_unit.skills) do
			i=i+1
			local skill=skills[skillID]
			love.graphics.draw(skill_button,600,30*i+60)
    			love.graphics.setColor(0,0,0,255)
			love.graphics.print(skill.name,600+5,30*i+60+5)
    			love.graphics.setColor(255,255,255,255)
			love.graphics.print(skill.MPcost,725+5,30*i+60+5)
		end
		if i==0 then
			love.graphics.draw(skill_button,600,30*1+60)
    			love.graphics.setColor(100,100,100,255)
			love.graphics.print("no skill",600+5,30*1+60+5)
    			love.graphics.setColor(255,255,255,255)
    		end
	end
end

function display_chara_info()
	if(info_displaying_chara_num==0) then
		return
	end
	local unit=units[info_displaying_chara_num]
	if unit==nil then
		return
	end
	if unit.type<=1 then
		love.graphics.print("playable character",600,300)
	else
		love.graphics.print("enemy",600,300)
	end
	love.graphics.print("name\t"..unit.name,600,330)
	love.graphics.print("HP\t"..unit.nowHP.."/"..unit.maxHP,600,360)
	love.graphics.print("MP\t"..unit.nowMP.."/"..unit.maxMP,600,390)
	love.graphics.print("mobility\t"..unit.speed,600,420)
	love.graphics.print("attack\t"..unit.atk,600,450)
	love.graphics.print("defense\t"..unit.dfs,600,480)
	love.graphics.print("magic\t"..unit.mag,600,510)
end

function display_main_info()
	love.graphics.setNewFont(20)
	love.graphics.print("Turn\t"..math.floor((turn+1)/2),600,20)
	love.graphics.print("State\t"..state,600,50)
	love.graphics.setNewFont(40)
	if ending==2 then
		love.graphics.print("Game Over...",250,500)
	elseif ending==1 then
		love.graphics.print("Mission Success!",250,500)
	end
	love.graphics.setNewFont(20)
end

function skill_power_calculate(skill,casting_unit,target_unit)
	local power=0
	if skill.effect_type==1 then
		power=math.floor(casting_unit.mag*skill.power)
	end
	return power
end

function between(x,min,max)
	return x>=min and x<=max
end