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

	state=0--0:default 1:pressed a character 2:moved and preparing an action 3:attack 4:skill

	state_stack={}
	state_stack.top=0
	state_stack.states={}
	state_stack.x={}
	state_stack.y={}

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
				damage=math.floor((other_unit.atk-self.dfs)*0.75)
			elseif self.defensing==2 then
				damage=math.floor((other_unit.atk-self.dfs)*0.5)
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
	mapstate_clear(moveable,1)
	atkable = {}
	mapstate_clear(atkable,0)
end

function love.draw(dt)
	draw_map()
	display_moveable()
	display_atkable()
	display_buttons()
	display_chara_info()
	display_main_info()
end

function love.update(dt)
	--playable character da hangdonghatna check
	if turn%2==0 then
		enemyTurn()
	end
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

function move_character(x,y)
	if x>=1 and x<=map_w and y>=1 and y<=map_h then
		if moveable[y][x]<=0 then
			save_state()
			player.x=x
			player.y=y
			state=2
			mapstate_set()
		end
	end
end

function action_buttons_click(pos_x,pos_y)
	for i=1,3 do
		if between(pos_x,action_buttons[i].x,action_buttons[i].x+action_buttons[i].width) and between(pos_y,action_buttons[i].y,action_buttons[i].y+action_buttons[i].height) then
			save_state()
			if i==1 then
				state=3
				mapstate_set()
			elseif i==2 then
				state=4
			elseif i==3 then
				doDefense(player)
				turn=turn+1
				state=0
			end
		end
	end
end

function atk_click(x,y)
	if x>=1 and x<=map_w and y>=1 and y<=map_h then
		if atkable[y][x]==0 then
			return
		end
		for k,unit in pairs(units) do
			if unit.x==x and unit.y==y and unit.type==2 then
				doAtk(player,unit)
				state_stack_clear()
				turn=turn+1
				state=0
			end
		end
	end
end

function mapstate_set()
	if state==1 then
		moveable_tiles(player.speed,player.x,player.y,player)
		atkable_tiles(player.x,player.y,player.atk_range)
	elseif state==2 or state==3 then
		atkable_tiles(player.x,player.y,player.atk_range)
	end
end

function mapstate_clear(mapstate,num)
	for y=1,map_h do
		mapstate[y] = {}
		for x=1,map_w do
			mapstate[y][x] = num
		end
	end
end

function save_state()
	if state==1 then
		mapstate_clear(moveable,1)
		mapstate_clear(atkable,0)
	elseif state==2 or state==3 then
		mapstate_clear(atkable,0)
	end
	table.insert(state_stack.states,state)
	table.insert(state_stack.x,player.x)
	table.insert(state_stack.y,player.y)
	state_stack.top=state_stack.top+1
end

function load_state()
	if state_stack.top==0 then
		return
	end
	if state==1 then
		mapstate_clear(moveable,1)
		mapstate_clear(atkable,0)
	elseif state==2 or state==3 then
		mapstate_clear(atkable,0)
	end
	state=state_stack.states[state_stack.top]
	table.remove(state_stack.states)
	player.x=state_stack.x[state_stack.top]
	table.remove(state_stack.x)
	player.y=state_stack.y[state_stack.top]
	table.remove(state_stack.y)
	state_stack.top=state_stack.top-1
	mapstate_set()
end

function state_stack_clear()
	mapstate_clear(moveable,1)
	mapstate_clear(atkable,0)
	state_stack.top=0
	state_stack.states={}
	state_stack.x={}
	state_stack.y={}
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

function doMove(unit,x,y)
	unit.x=x
	unit.y=y
end

function doAtk(attacking_unit,attacked_unit)
	attacking_unit.defensing=0
	info_displaying_chara_num=attacked_unit.num
	attacked_unit:get_attack(attacking_unit,true)
end

function doDefense(unit)
	unit.defensing=1
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
	for y=1, map_h do
		for x=1, map_w do
			if(moveable[y][x]<=0) then
				simul_enemysAtk(unit,x,y)
				simul_enemysDefense(unit,x,y)
			end
		end
	end
end

function enemyTurn()
	enemynumber=0
	for k,unit in pairs(units) do
		if unit.type==2 then
			enemynumber=enemynumber+1
			moveable_tiles(unit.speed,unit.x,unit.y,unit)
			simul_enemysActionAfterMove(unit)
			mapstate_clear(moveable,1)
			minReward=-999
			for i=1,AI_stack.top do
				print(AI_stack.reward[i])
				if AI_stack.reward[i]>minReward then
					minReward=AI_stack.reward[i]
					action=AI_stack.actions[i]
					dest_x=AI_stack.x[i]
					dest_y=AI_stack.y[i]
					aim_x=AI_stack.aim_x[i]
					aim_y=AI_stack.aim_y[i]
				end
			end
			doMove(unit,dest_x,dest_y)
			if action=="atk" then
				doAtk(unit,find_unit_on_this_point(aim_x,aim_y))
			elseif action=="defense" then
				doDefense(unit)
			end
			AI_stack_clear()
		end
	end
	if enemynumber==0 then
		ending=1
	end
	turn=turn+1
end

function love.mousepressed(pos_x, pos_y, button, istouch)
	if turn%2==0 then
		return
	end
	x,y=real_point_to_map_point(pos_x,pos_y)
	if button == 1 then
		if state==0 then
			if player.x==x and player.y==y then
				save_state()
				state=1
				mapstate_set()
			end
		elseif state==1 then
			move_character(x,y)
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
			for k,unit in pairs(units) do
				if unit.x==x and unit.y==y then
					info_displaying_chara_num=unit.num
				end
			end
			--maybe add option menu later
			--or display character infos like jojojeon
		elseif state==1 then
			load_state()
		elseif state==2 then
			load_state()
		elseif state==3 then
			load_state()
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
	unit_on_this_point=find_unit_on_this_point(x,y)
	if remainStep<0 or (unit_on_this_point~=nil and unit_on_this_point~=unit) then
		return
	end
	if moveable[y][x]<=-remainStep then
		return
	end
	moveable[y][x]=-remainStep
	if x-1>=1 then
		moveable_tiles(remainStep-(cost[map[y][x-1]+1]),x-1,y,unit)
	end
	if x+1<=map_w then
		moveable_tiles(remainStep-(cost[map[y][x+1]+1]),x+1,y,unit)
	end
	if y-1>=1 then
		moveable_tiles(remainStep-(cost[map[y-1][x]+1]),x,y-1,unit)
	end
	if y+1<=map_h then
		moveable_tiles(remainStep-(cost[map[y+1][x]+1]),x,y+1,unit)
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
	if state==1 or state==2 then
		for i=1, 3 do
			love.graphics.draw(action_buttons[i].img,action_buttons[i].x, action_buttons[i].y)
		end
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