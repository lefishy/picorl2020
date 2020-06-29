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
	cls()
	print(px..":"..py)
	if not gen then
		gen_map()
		gen = true
	end
	--test_map()
	--clear_console()
	--draw_tiles()
	draw_map()
	draw_player()
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
tiles = {}

function new_tile(x,y,c,fg,bg,block,opaque)
	nt = {}
	nt.x = x
	nt.y = y
	nt.c = c or " "
	nt.fg = fg or def_fg
	nt.bg = bg or def_bg
	nt.block = false or block
	nt.opaque = false or opaque
	add(tiles,nt)
end

function get_tile(x,y)
	local idx = x + (map_w*y)
	return tiles[idx]
end

function draw_tiles()
	for t in all(tiles) do
		put_char(t.c,t.x,t.y,t.fg,t.bg)
	end
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
	put_char("@",15,10,3,0)
end

function attempt_move()
	for i=0,4 do
		if btnp(i) then
			local mx = px + dirs[i+1][1]
			local my = py + dirs[i+1][2]
			if tilemap[mx][my] then
				px += dirs[i+1][1]
				py += dirs[i+1][2]
			end
			--camera(px*tile_w,py*tile_h)
		end
	end
end
-->8
--map stuff
tilemap = {}

function new_rect(x,y,w,h)
	local r = {
			x1=x,
			x2=x+w,
			y1=y,
			y2=y+h
	}
	return r	
end

function gen_map()
	num_rooms = 30
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
	
	layout[4][3] = {
			x=4,
			y=3,
			e={x=0,y=0}
			}
	
	for i=1,num_rooms do
		local rx = 4
		local ry = 3
		local d
		while layout[rx][ry] do
			d = dirs[flr(rnd(4))+1]
			rx += d[1]
			ry += d[2]
			if rx > room_w then
				rx = room_w
			elseif rx < 1 then
				rx = 1
			end
			if ry > room_h then
				ry = room_h
			elseif ry < 1 then
				ry = 1
			end
			--print(rx..":"..ry)
		end
		
		layout[rx][ry] = {
			x=rx,
			y=ry,
			e={x=-d[1],y=-d[2]}
			}
	end
	
	for x=0,map_w do
		local row = {}
		for y=0,map_h do
			add(row,false)
			--new_tile(x,y,"#",5,1,false,false)
		end
		add(tilemap,row)
	end
	
	px=35
	py=35
	
	for x=1,count(layout) do
		for y=1,count(layout[x]) do
			if layout[x][y] then
				xs = (x-1) * 10
				xy = (y-1) * 10
				for rx=xs+1,xs+9 do
					for ry=xy+1,xy+9 do
						tilemap[rx][ry] = true
					end
				end
				local r = layout[x][y]
				tilemap[xs+5+(5*r.e.x)][xy+5+(5*r.e.y)] = true
			end
		end
	end
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
			if cx+x > 0 and cx+x < map_w then
				if tilemap[cx+x][cy+y] then
					put_char('.',x,y,5,0)
				else
					put_char('#',x,y,6,0)
				end
			end
		end
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
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
