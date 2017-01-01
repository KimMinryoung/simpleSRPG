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

	state=0--0:default 1:pressed a character 2:moved and preparing an action 3:attack 4:skill

	state_stack={}
	state_stack.top=0
	state_stack.states={}
	state_stack.x={}
	state_stack.y={}

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
	Unit = {}  
	Unit.new = function(name, HP,speed,x,y,atk_range,img)  
		local instance = {}  
		local defaultHP = 100
		instance.name = name
		instance.maxHP = HP
		instance.nowHP = HP
		instance.speed=speed
		instance.x=x
		instance.y=y
		instance.atk_range=atk_range
		instance.img=love.graphics.newImage(img..".png")
   
		instance.setHP = function(self, hp)
			self.nowHP = math.min(hp,self.maxHP)  
		end

		instance.printInfo = function(self)  
			print("name : " .. self.name , "HP : " .. self.nowHP.."/"..self.maxHP)  
		end  
   
		return instance  
	end
	units={}
	player= Unit.new("Player",100,6,1,1,atk_ranges[4],"player")
	units[1]=player

	unit1 = Unit.new("Jol1", 80,5,7,10,atk_ranges[3],"jol")
	units[2]=unit1
	unit2 = Unit.new("Jol2", 80,5,2,5,atk_ranges[1],"jol")
	units[3]=unit2
	unit1:setHP(70)
	unit1:printInfo()

	map={
	   { 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, 
	   { 0, 0, 3, 0, 2, 2, 2, 0, 3, 0, 3, 0, 1, 1, 1, 0, 0, 0, 0, 0},
	   { 0, 0, 3, 0, 2, 2, 2, 0, 3, 0, 3, 0, 1, 0, 0, 0, 0, 0, 0, 0},
	   { 3, 0, 3, 0, 2, 2, 2, 0, 0, 3, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0},
	   { 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0},
	   { 0, 1, 0, 1, 3, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0},
	   { 0, 1, 0, 1, 0, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	   { 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	   { 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	   { 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	   { 0, 2, 2, 2, 0, 3, 3, 3, 0, 1, 1, 1, 0, 2, 0, 0, 0, 0, 0, 0},
	   { 0, 2, 0, 0, 0, 3, 0, 3, 0, 1, 0, 1, 0, 2, 0, 0, 0, 0, 0, 0},
	   { 0, 2, 0, 0, 0, 3, 0, 3, 0, 1, 0, 1, 0, 2, 0, 0, 0, 0, 0, 0},
	   { 0, 2, 2, 2, 0, 3, 3, 3, 0, 1, 1, 1, 0, 2, 2, 2, 0, 0, 0, 0},
	   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	   { 3, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	   { 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	   { 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	   { 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	}
	tile = {}
	for i=0,3 do
		tile[i]=love.graphics.newImage("tile"..i..".png")
	end
	cost={1,2,4,9}
	love.graphics.setNewFont(12)
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
end

function love.update(dt)
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

function mouse_to_map_point(mouse_x,mouse_y)
	x=math.floor((mouse_x-map_offset_x)/tile_w)+map_x
	y=math.floor((mouse_y-map_offset_y)/tile_h)+map_y
	return x,y
end

function move_character(x,y)
	if x>=1 and x<=map_w and y>=1 and y<=map_h then
		if moveable[y][x]<=0 then
			print("moveable point")
			save_state()
			player.x=x
			player.y=y
			state=2
			mapstate_set()
		else
			print("not moveable point")
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
				state_stack_clear()
				state=0
			end
		end
	end
end

function mapstate_set()
	if state==1 then
		moveable_tiles(player.speed,player.x,player.y)
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
	state_stack.top=0
	state_stack.states={}
	state_stack.x={}
	state_stack.y={}
end

function love.mousepressed(pos_x, pos_y, button, istouch)
	x,y=mouse_to_map_point(pos_x,pos_y)
	if button == 1 then
		if state==0 then
			if player.x==x and player.y==y then
				save_state()
				state=1
				mapstate_set()
			end
		elseif state==1 then
			move_character(x,y)
			action_buttons_click(pos_x,pos_y)
		elseif state==2 then
			action_buttons_click(pos_x,pos_y)
		end
	elseif button == 2 then
		if state==0 then
			--do nothing
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
			love.graphics.draw( 
			tile[map[y+map_y][x+map_x]],
			(x*tile_w)+map_offset_x, 
			(y*tile_h)+map_offset_y )
			for k,unit in pairs(units) do
				if y+map_y==unit.y and x+map_x==unit.x then
					love.graphics.draw( 
					unit.img, 
					(x*tile_w)+map_offset_x, 
					(y*tile_h)+map_offset_y )
				end
			end
		end
	end
end

	
function moveable_tiles(remainStep,x,y)
	if remainStep<0 then
		return
	end
	if moveable[y][x]<=-remainStep then
		return
	end
	moveable[y][x]=-remainStep
	if x-1>=1 then
		moveable_tiles(remainStep-(cost[map[y][x-1]+1]),x-1,y)
	end
	if x+1<=map_w then
		moveable_tiles(remainStep-(cost[map[y][x+1]+1]),x+1,y)
	end
	if y-1>=1 then
		moveable_tiles(remainStep-(cost[map[y-1][x]+1]),x,y-1)
	end
	if y+1<=map_h then
		moveable_tiles(remainStep-(cost[map[y+1][x]+1]),x,y+1)
	end
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
	love.graphics.setColor(255, 255, 255, 100)
	for y=1, map_display_h do
		for x=1, map_display_w do
			if(moveable[y+map_y][x+map_x]<=0) then
				love.graphics.draw( 
					moveable_layer, 
					(x*tile_w)+map_offset_x, 
					(y*tile_h)+map_offset_y )
			end
		end
	end
	love.graphics.setColor(255, 255, 255, 255)
end

function display_atkable()
	love.graphics.setColor(255, 255, 255, 150)
	for y=1, map_display_h do
		for x=1, map_display_w do
			if(atkable[y+map_y][x+map_x]==1) then
				love.graphics.draw( 
					atkable_layer, 
					(x*tile_w)+map_offset_x, 
					(y*tile_h)+map_offset_y )
			end
		end
	end
	love.graphics.setColor(255, 255, 255, 255)
end

function display_buttons()
	if state==1 or state==2 then
		for i=1, 3 do
			love.graphics.draw( 
				action_buttons[i].img,
				action_buttons[i].x, 
				action_buttons[i].y )
		end
	end
end

function between(x,min,max)
	return x>=min and x<=max
end