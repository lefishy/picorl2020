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
	draw_player()
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
px = 0
py = 0
dirs = {
	{-1,0},
	{1,0},
	{0,-1},
	{0,1}
}

function draw_player()
	put_char("@",15,10,3,5)
end

function attempt_move()
	for i=0,4 do
		if btnp(i) then
			local mx = px + dirs[i+1][1]
			local my = py + dirs[i+1][2]
			if mx > 0 and mx < map_w and my > 0 and my < map_h and not types[sget(mx,my)].solid then
				px += dirs[i+1][1]
				py += dirs[i+1][2]
			end
			--camera(px*tile_w,py*tile_h)
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
	local cx = px - 15
	local cy = py - 10
	for x=0,32 do
		for y=0,20 do
			if cx+x > 0 and cx+x < map_w and cy+y > 0 and cy+y < map_h then
				if check_visible(cx+x,cy+y) then
					local t = types[sget(cx+x,cy+y)]
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
	local x2=px
	local y2=py
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

function entity(x,y,c,fg)

end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
