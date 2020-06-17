pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
function _init()
	tile_w = 4
	tile_h = 6
	def_fg = 7
	def_bg = 2
	new_tile(4,3,"",1,1)
end

function _update()
	attempt_move()
end

function _draw()
	clear_console()
	draw_tiles()
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
	put_char("@",px,py)
end

function attempt_move()
	for i=0,4 do
		if btnp(i) then
			px += dirs[i+1][1]
			py += dirs[i+1][2]
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
