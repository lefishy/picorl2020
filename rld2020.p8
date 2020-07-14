pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
function _init()
	tile_w = 4
	tile_h = 6
	map_w = 80
	map_h = 80
	def_fg = 7
	def_bg = 2
	gen=false
	camx = 0
	camy = 0
	camw = 32
	camh = 15
	player = entity(35,35,"@",7,"player",true)
end

function _update()
	attempt_move()
end

function _draw()
	cls(1)
	if not gen then
		gen_map()
		gen = true
	end
	--test_map()
	--clear_console()
	--draw_tiles()
	draw_map()
	--draw_player()
	draw_entities()
	--sspr(0,0,80,50,0,0)
	print(stat(0),0,0,0)
end

function round(n)
	if n%1 >= 0.5 then
			n = -flr(-n)
		else
			n = flr(n)
		end
		return n
end
-->8
--console things
function clear_console(bg)
	bg = bg or def_bg
	cls()
	rectfill(0,0,128,128,bg)
end

function put_char(c,x,y,fg,bg)
	fg = fg or def_fg
	bg = bg or def_bg
	x = x*tile_w
	y = y*tile_h
	rectfill(x,y,x+tile_w-1,y+tile_h-1,bg)
	print(c,x+1,y+1,fg)
end

function set_default_bg(bg)
	def_bg = bg
end

function set_default_fg(fg)
	def_fg = fg
end
-->8
--tiles

function new_tile(c,fg,bg,solid,opaque)
	nt = {}
	nt.c = c
	nt.fg = fg
	nt.bg = bg
	nt.solid = solid or true
	nt.opaque = opaque or solid
	nt.seen = false
	return nt
end

function get_tile(x,y)
	local idx = x + (map_w*y)
	return tilemap[idx]
end
-->8
--player
--px = 0
--py = 0
dirs = {
	{-1,0},
	{1,0},
	{0,-1},
	{0,1}
}

--[[function draw_player()
	put_char("@",15,10,3,2)
end]]--

function attempt_move()
	for i=0,4 do
		if btnp(i) then
			local mx = player.x + dirs[i+1][1]
			local my = player.y + dirs[i+1][2]
			if not is_blocked(mx,my) then
				local t = get_blocking_entities(mx,my)
				if t then
					
				else
					player.x += dirs[i+1][1]
					player.y += dirs[i+1][2]
					camx += dirs[i+1][1]
					camy += dirs[i+1][2]
				end
			end
		end
	end
end
-->8
--map stuff
types = {
	{
		solid=true,
		opaque=true,
		c=' ',
		fg=1,
		bg=1
	},
	{},
	{},
	{},
	{},
	{},
	{
		solid=false,
		opaque=false,
		c='.'
	}
}

function gen_map()
	num_rooms = 15
	room_w = 7
	room_h = 7
	
	layout = {}
	
	for x=0,room_w do
		local row = {}
		for y=0,room_h do
			add(row,false)
		end
		add(layout,row)
	end
	
	for i=1,num_rooms do
		local rx = 4
		local ry = 3
		local d
		while layout[rx][ry] do
			d = dirs[flr(rnd(4))+1]
			rx += d[1]
			ry += d[2]
			makedr = true
			if rx > room_w then
				rx = room_w
				makedr = false
			elseif rx < 1 then
				rx = 1
				makedr = false
			end
			if ry > room_h then
				ry = room_h
				makedr = false
			elseif ry < 1 then
				ry = 1
				makedr = false
			end
			if makedr then
				sset(((rx-1)*10)+5+(5*-d[1]),((ry-1)*10)+5+(5*-d[2]),7)
			end
			--print(rx..":"..ry)
		end
		
		layout[rx][ry] = true
		
		max_mon = 3
		moncount = 0
		
		xs = (rx-1) * 10
		xy = (ry-1) * 10
		for rx=xs,xs+10 do
			for ry=xy,xy+10 do
				if rx == xs or rx == xs+10 or ry==xy or ry == xy + 10 then
					if sget(rx,ry) != 7 then
						sset(rx,ry,1)
					end
				else
					sset(rx,ry,7)
					if moncount < max_mon and rnd(1) > 0.9 then
						entity(rx,ry,"t",3,"troll",true)
						moncount += 1
					end
				end
			end
		end
	end
	
	--[[for x=0,map_w do
		local row = {}
		for y=0,map_h do
			add(row,false)
			--new_tile(x,y,"#",5,1,false,false)
		end
		add(tilemap,row)
	end]]--
	
	px=35
	py=35
	camx = 35-15
	camy = 35-10
	
	--[[for x=1,count(layout) do
		for y=1,count(layout[x]) do
			if layout[x][y] then
				
				local r = layout[x][y]
			end
		end
	end]]--
end

function remove_wall(x,y)
	local t = tilemap[x][y]
	t.solid = false
	t.opaque = false
	t.c = "."
	t.fg = 6
	t.bg = 5
end

function all_locked(rooms)
	local yes = true
	for r in all(rooms) do
		yes = r.locked
	end
	return yes
end

function draw_map()
	--local cx = px - 15
	--local cy = py - 10
	for x=0,camw do
		for y=0,camh do
			if camx+x >= 0 and camx+x < map_w and camy+y > 0 and camy+y < map_h then
				if check_visible(camx+x,camy+y) then
					local t = types[sget(camx+x,camy+y)]
					put_char(t.c,x,y,t.fg,t.bg)
				else
					put_char(' ',x,y,1,1)
				end
			end
		end
	end
end

function check_visible(x,y)
	local x1=x
	local y1=y
	local x2=player.x
	local y2=player.y
	local len = max(abs(x2-x1), abs(y2-y1))
	for i=1,len do
		local t = i/len
		x = x1*(1-t) + x2 * t
		y = y1*(1-t) + y2 * t
		x = round(x)
		y = round(y)
		if sget(x,y) == 0 or types[sget(x,y)].opaque then
			return false
		end
	end
	return true
end

function is_blocked(x,y)
	if x < 0 or x > map_w or y < 0 or y > map_h or types[sget(x,y)].solid then
		return true
	else
		return false
	end
end

function test_map()
	yc=0
	xc=0
	for row in all(tilemap) do
		yc += 1
		xc = 0
		for t in all(row) do
			xc += 1
			if t then
				pset(xc,yc,10)
			else
				--pset(xc,yc,0)
			end
		end
	end
end
-->8
--entity
entities = {}

function entity(x,y,c,fg,name,solid)
	ne = {}
	ne.x = x
	ne.y = y
	ne.c = c
	ne.fg = fg
	ne.solid = solid or false
	ne.name = name
	add(entities,ne)
	return ne
end

function get_screen_coords(e)
	if e.x >= camx and e.x < camx + camw and e.y >= camy and e.y < camy+camh then
		local sx = e.x - camx
		local sy = e.y - camy
		return {sx,sy}
	end
	return false
end

function get_blocking_entities(x,y)
	for e in all(entities) do
		if e.solid and e.x == x and e.y == y then
			return e
		end
	end
	return false
end

function draw_entities()
	for ent in all(entities) do
		local dp = get_screen_coords(ent)
		if dp and check_visible(ent.x,ent.y) then
			put_char(ent.c,dp[1],dp[2],ent.fg)
		end
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
