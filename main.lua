function love.update(dt)
	if dt < 1/30 then
		love.timer.sleep(1/30 - dt)
		frame_count=frame_count+1
	end
	if frame_count%10==0 then
		if do_move ~= nil and coroutine.status (do_move) ~= "dead" then
			coroutine.resume (do_move)
		elseif do_atk ~= nil and coroutine.status (do_atk) ~= "dead" then
			coroutine.resume (do_atk)
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
	display_allHP()
	display_chara_info()
	display_main_info()
end

function love.load(arg)
	map_w=20
	map_h=20
	map_x=0
	map_y=0
	map_offset_x=10
	map_offset_y=10
	map_display_w=20
	map_display_h=13
	tile_w=35
	tile_h=33

	temp_x=0
	temp_y=0

	ending=0

	turn=1

	frame_count=0

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

	atk_ranges={}
	atk_ranges[1]={
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
	atk_ranges[2]={
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
	atk_ranges[3]={
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
	atk_ranges[4]={
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
	atk_ranges[5]={
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
	atk_ranges[6]={
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
	units={}
	units_number=0
	Unit = {}  
	Unit.new = function(type,name, HP,speed,x,y,atk,dfs,atk_range,img)
		units_number=units_number+1
		local instance = {}
		instance.type=type
		instance.num=units_number
		units[instance.num]=instance
		instance.name = name
		instance.maxHP = HP
		instance.nowHP = HP
		instance.speed=speed
		instance.x=x
		instance.y=y
		instance.atk=atk
		instance.dfs=dfs
		instance.atk_range=atk_range
		instance.defensing=0--0:not defensing 1:defensing 2:super defensing?(skill)
		instance.img=love.graphics.newImage(img..".png")
   
		instance.setHP = function(self, hp,real)
			if real then
				self.nowHP = math.max(0,math.min(hp,self.maxHP))
			end
			if self.nowHP==0 then
				if real then
					if self==player then
						ending=2
					end	
					units[instance.num]=nil
				end
				return true--died
			end
			return false--didn't die
		end

		instance.print_info = function(self)
			print("name : " .. self.name , "HP : " .. self.nowHP.."/"..self.maxHP)  
		end

		instance.get_attack = function(self,other_unit,real)
			if self.defensing==0 then
				damage=math.floor(other_unit.atk-self.dfs)
			elseif self.defensing==1 then
				damage=math.floor((other_unit.atk-self.dfs)*0.6)
			elseif self.defensing==2 then
				damage=math.floor((other_unit.atk-self.dfs)*0.25)
			end
			damage=math.max(1,damage)
			died=self:setHP(self.nowHP-damage,real)
			return damage,died
		end
   
		return instance
	end
	player= Unit.new(1,"Player",100,6,1,1,40,30,atk_ranges[4],"player")

	unit1 = Unit.new(2,"Jol1",80,5,7,10,70,10,atk_ranges[3],"jol")
	unit2 = Unit.new(2,"Jol2",50,5,2,5,40,15,atk_ranges[1],"jol")
	unit3 = Unit.new(2,"Jol3",30,5,20,5,40,0,atk_ranges[4],"jol")

	map={
	   { 0, 0, 3, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3}, 
	   { 0, 0, 3, 0, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0},
	   { 0, 0, 3, 0, 2, 2, 2, 0, 3, 3, 3, 3, 1, 0, 0, 0, 0, 0, 0, 0},
	   { 3, 0, 3, 0, 2, 2, 2, 0, 3, 3, 0, 3, 1, 1, 3, 0, 0, 0, 0, 0},
	   { 0, 0, 0, 3, 3, 0, 0, 0, 3, 3, 0, 3, 1, 0, 3, 0, 0, 0, 0, 0},
	   { 0, 1, 0, 1, 3, 3, 3, 3, 3, 3, 0, 3, 1, 1, 3, 0, 0, 0, 0, 0},
	   { 0, 1, 0, 1, 3, 3, 3, 3, 3, 3, 0, 3, 3, 3, 3, 0, 0, 0, 0, 0},
	   { 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	   { 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	   { 0, 1, 0, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	   { 0, 0, 0, 3, 3, 3, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0},
	   { 0, 2, 2, 3, 3, 3, 3, 1, 1, 1, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0},
	   { 0, 2, 0, 3, 3, 3, 3, 1, 2, 2, 2, 2, 1, 0, 0, 0, 0, 0, 0, 0},
	   { 0, 2, 0, 3, 3, 3, 3, 1, 2, 2, 2, 2, 1, 0, 0, 0, 0, 0, 0, 0},
	   { 0, 2, 2, 3, 3, 3, 3, 1, 2, 2, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0},
	   { 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0},
	   { 3, 3, 3, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	   { 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	   { 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	   { 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	}
	tile = {}
	for i=0,3 do
		tile[i]=love.graphics.newImage("tile"..i..".png")
	end
	cost={1,2,4,9}
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
		coroutine.yield()
		unit.x=stack_x[i]
		unit.y=stack_y[i]
	end
	mapstate_clear(moveable,1)
	afterMovingCharacter(unit)
end

function co_atk(attacking_unit,attacked_unit)
	print(attacking_unit.name.." is attacking "..attacked_unit.name)
	atkable_tiles(attacking_unit.x,attacking_unit.y,attacking_unit.atk_range)
	attacking_unit.defensing=0
	info_displaying_chara_num=attacked_unit.num
	coroutine.yield()
	coroutine.yield()
	attacked_unit:get_attack(attacking_unit,true)
	mapstate_clear(atkable,0)
	
	state_stack_clear()
	if turn%2==1 then
		pass_turn()
	elseif turn%2==0 then
		AI_stack_clear()
	end
end

function co_defense(unit)
	coroutine.yield()
	unit.defensing=1
	state_stack_clear()
	if turn%2==1 then
		pass_turn()
	elseif turn%2==0 then
		AI_stack_clear()
	end
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
			state=1
			save_state()
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
	if x>=1 and x<=map_w and y>=1 and y<=map_h then
		if moveable[y][x]<=0 then
			save_state()
			doMove(unit,x,y)
		end
	end
end

function action_buttons_click(pos_x,pos_y)
	for i=1,3 do
		if between(pos_x,action_buttons[i].x,action_buttons[i].x+action_buttons[i].width) and between(pos_y,action_buttons[i].y,action_buttons[i].y+action_buttons[i].height) then
			if i==1 then
				save_state()
				state=3
				mapstate_set(player)
			elseif i==2 then
				--do nothing
			elseif i==3 then
				save_state()
				do_defense=coroutine.create(co_defense)
				coroutine.resume(do_defense,player)
			end
		end
	end
end

function atk_click(x,y)
	if x>=1 and x<=map_w and y>=1 and y<=map_h then
		if atkable[y][x]==0 then
			return
		end
		unit=find_unit_on_this_point(x,y)
		if unit~=nil and unit.type==2 then
			do_atk=coroutine.create(co_atk)
			coroutine.resume(do_atk,player,unit)
		end
	end
end

function mapstate_set(unit)
	mapstate_clear(moveable,1)
	mapstate_clear(atkable,0)
	if state==1 then
		moveable_tiles(unit.speed,unit.x,unit.y,unit)
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
	state_stack.x[top]=player.x
	state_stack.y[top]=player.y
	state_stack.moveable[top]=mapstate_copy_and_return(moveable)
	state_stack.moveable_prev_x[top]=mapstate_copy_and_return(moveable_prev_x)
	state_stack.moveable_prev_y[top]=mapstate_copy_and_return(moveable_prev_y)
	state_stack.atkable[top]=mapstate_copy_and_return(atkable)
end

function load_state(unit)
	if state_stack.top==0 then
		print("can't load (top==0)")
		return
	end
	local top=state_stack.top
	state=state_stack.states[top]
	print("load"..state)
	state_stack.states[top]=nil
	player.x=state_stack.x[top]
	state_stack.x[top]=nil
	player.y=state_stack.y[top]
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
	moveable_tiles(unit.speed,unit.x,unit.y,unit)
	do_move = coroutine.create(co_moving)
	coroutine.resume(do_move,unit,dest_x,dest_y)
end

function simul_enemysAtk(unit,x,y)
	atkable_tiles(x,y,unit.atk_range)
	for aim_y=1, map_h do
		for aim_x=1, map_w do
			if(atkable[aim_y][aim_x]==1) then
				our_unit=find_unit_on_this_point(aim_x,aim_y)
				if our_unit~=nil and our_unit.type==1 then
					damage,died=our_unit:get_attack(unit,false)
					AI_stack.top=AI_stack.top+1
					AI_stack.actions[AI_stack.top]="atk"
					AI_stack.x[AI_stack.top]=x
					AI_stack.y[AI_stack.top]=y
					AI_stack.aim_x[AI_stack.top]=aim_x
					AI_stack.aim_y[AI_stack.top]=aim_y
					AI_stack.reward[AI_stack.top]=damage
					if died then
						AI_stack.reward[AI_stack.top]=100
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
end

function simul_enemysActionAfterMove(unit)
	moveable_tiles(unit.speed,unit.x,unit.y,unit)
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

function love.mousepressed(pos_x, pos_y, button, istouch)
	if turn%2==0 or (do_move ~= nil and coroutine.status(do_move)~="dead") or 
		(do_atk ~= nil and coroutine.status(do_atk)~="dead") or
		(do_enemy_control ~= nil and coroutine.status(do_enemy_control)~="dead") then
		print("ignore mouse click")
		return
	end
	local x,y=real_point_to_map_point(pos_x,pos_y)
	if button == 1 then
		if state==0 then
			if player.x==x and player.y==y then
				save_state()
				state=1
				mapstate_set(player)
			end
		elseif state==1 then
			move_character(player,x,y)
			atk_click(x,y)
			action_buttons_click(pos_x,pos_y)
		elseif state==2 then
			atk_click(x,y)
			action_buttons_click(pos_x,pos_y)
		elseif state==3 then
			atk_click(x,y)
		end
	elseif button == 2 then
		if state==0 then
			local unit=find_unit_on_this_point(x,y)
			if unit~=nil then
				info_displaying_chara_num=unit.num
			end
			--maybe add option menu later
			--or display character infos like jojojeon
		elseif state==1 or state==2 or state==3 then
			load_state(player)
		end
	end
end

function draw_map()
	for y=1, map_display_h do
		for x=1, map_display_w do
			pos_x,pos_y=map_point_to_real_point(x+map_x,y+map_y)
			love.graphics.draw(tile[map[y+map_y][x+map_x]], pos_x, pos_y)
			for k,unit in pairs(units) do
				if y+map_y==unit.y and x+map_x==unit.x then
					love.graphics.draw(unit.img, pos_x, pos_y)
				end
			end
		end
	end
end

	
function moveable_tiles(remainStep,x,y,unit)
	local unit_on_this_point=find_unit_on_this_point(x,y)
	if remainStep<0 or (unit_on_this_point~=nil and unit_on_this_point~=unit) then
		return
	end
	if moveable[y][x]<=-remainStep then
		return
	end
	moveable[y][x]=-remainStep
	moveable_prev_x[y][x]=temp_x
	moveable_prev_y[y][x]=temp_y
	temp_x=x
	temp_y=y
	if x-1>=1 then
		moveable_tiles(remainStep-(cost[map[y][x-1]+1]),x-1,y,unit)
	end
	temp_x=x
	temp_y=y
	if x+1<=map_w then
		moveable_tiles(remainStep-(cost[map[y][x+1]+1]),x+1,y,unit)
	end
	temp_x=x
	temp_y=y
	if y-1>=1 then
		moveable_tiles(remainStep-(cost[map[y-1][x]+1]),x,y-1,unit)
	end
	temp_x=x
	temp_y=y
	if y+1<=map_h then
		moveable_tiles(remainStep-(cost[map[y+1][x]+1]),x,y+1,unit)
	end
	temp_x=0
	temp_y=0
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
end

function display_allHP()
	for k,unit in pairs(units) do
		pos_x,pos_y=map_point_to_real_point(unit.x,unit.y)
		love.graphics.print(unit.nowHP.."/"..unit.maxHP,pos_x+20,pos_y-20)
	end
end

function display_chara_info()
	if(info_displaying_chara_num==0) then
		return
	end
	unit=units[info_displaying_chara_num]
	if unit==nil then
		return
	end
	pos_x,pos_y=map_point_to_real_point(unit.x,unit.y)
	love.graphics.print(unit.nowHP.."/"..unit.maxHP,pos_x+20,pos_y-20)
end

function display_main_info()
	love.graphics.setNewFont(40)
	if ending==2 then
		love.graphics.print("Game Over...",250,500)
	elseif ending==1 then
		love.graphics.print("Mission Success!",250,500)
	end
	love.graphics.setNewFont(20)
end

function between(x,min,max)
	return x>=min and x<=max
end