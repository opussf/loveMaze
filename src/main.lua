require "bit"

local width, height = 0,0
local centerX, centerY = 0,0
local maze = {}
local player = {}
local ceilingColor = {0, 0, 1, 1}
local floorColor = {0.2, 0.7, 0.2, 1}
local wallColor = {0.7, 0.2, 0.2, 1}
local directionVectors = {
	["north"] = {0,-1,0},
	["east"] = {1,0,0},
	["south"] = {0,1,0},
	["west"] = {-1,0,0},
	["up"] = {0,0,-1},
	["down"] = {0,0,1}
}
local directionWallBits = {  -- left, right, top, bottom, front
	["north"] = {8, 2, 16, 32, 1},
	["east"] = {1, 4, 16, 32, 2},
	["south"] = {2, 8, 16, 32, 4},
	["west"] = {4, 1, 16, 32, 8},
	["up"] = { },  -- OI!
	["down"] = {}
}

function love.load()
	width, height = love.graphics.getDimensions()
	centerX = width/2
	centerY = height/2

	roomEdges = {
		{centerX,centerY},
		{width/3,height/3},
		{width/6.0,height/6.0},
		{width/6.0-((width/6)/2.5), height/6.0-((height/6)/2.5)},
	}

	loadMaze(1)
	setupPlayer()

	for i, coords in ipairs( roomEdges ) do
		print( i, coords[1], coords[2] )
	end
end

function love.draw()
	drawCurrent = {}
	for i, v in ipairs( player.current ) do
		drawCurrent[i] = v
	end
	local drawRooms = true
	local depth = 1
	while drawRooms do
		local x,y,z = unpack( drawCurrent )
		local currentRoom = maze.maze[z][y][x]
		print( x, y, z, currentRoom )
		drawCeiling( depth )
		drawFloor( depth )
		wallBits = directionWallBits[player.facing]
		if bit.band( currentRoom, wallBits[1] ) ~= 0 then
			drawLeft( depth )
		end
		if bit.band( currentRoom, wallBits[2] ) ~= 0 then
			drawRight( depth )
		end
		if bit.band( currentRoom, wallBits[5] ) ~= 0 then
			drawFront( depth )
			drawRooms = false
		end

		if drawRooms then
			for i,v in ipairs( directionVectors[player.facing] ) do
				drawCurrent[i] = drawCurrent[i] + v
			end
			depth = depth + 1
		end

		if depth >= #roomEdges then drawRooms = false end
	end

end
function drawCeiling( depth )
	edgeCoords = { centerX-roomEdges[depth][1],centerY-roomEdges[depth][2], centerX+roomEdges[depth][1],centerY-roomEdges[depth][2],
					centerX+roomEdges[depth+1][1],centerY-roomEdges[depth+1][2], centerX-roomEdges[depth+1][1],centerY-roomEdges[depth+1][2] }
	love.graphics.setColor( ceilingColor )
	love.graphics.polygon( "fill", edgeCoords )
	love.graphics.setColor( 1, 1, 1, 1 )
	love.graphics.polygon( "line", edgeCoords )
end
function drawFloor( depth )
	edgeCoords = { centerX-roomEdges[depth+1][1],centerY+roomEdges[depth+1][2], centerX+roomEdges[depth+1][1],centerY+roomEdges[depth+1][2],
					centerX+roomEdges[depth][1],centerY+roomEdges[depth][2], centerX-roomEdges[depth][1],centerY+roomEdges[depth][2] }
	love.graphics.setColor( floorColor )
	love.graphics.polygon( "fill",  edgeCoords )
	love.graphics.setColor( 1, 1, 1, 1 )
	love.graphics.polygon( "line", edgeCoords )
end
function drawLeft( depth )
	edgeCoords = { centerX-roomEdges[depth][1],centerY-roomEdges[depth][2], centerX-roomEdges[depth+1][1],centerY-roomEdges[depth+1][2],
					centerX-roomEdges[depth+1][1],centerY+roomEdges[depth+1][2], centerX-roomEdges[depth][1],centerY+roomEdges[depth][2] }
	love.graphics.setColor( wallColor )
	love.graphics.polygon( "fill", edgeCoords )
	love.graphics.setColor( 1, 1, 1, 1 )
	love.graphics.polygon( "line", edgeCoords )
end
function drawRight( depth )
	edgeCoords = { centerX+roomEdges[depth+1][1],centerY-roomEdges[depth+1][2], centerX+roomEdges[depth][1],centerY-roomEdges[depth][2],
					centerX+roomEdges[depth][1],centerY+roomEdges[depth][2], centerX+roomEdges[depth+1][1],centerY+roomEdges[depth+1][2] }
	love.graphics.setColor( wallColor )
	love.graphics.polygon( "fill", edgeCoords )
	love.graphics.setColor( 1, 1, 1, 1 )
	love.graphics.polygon( "line", edgeCoords )
end
function drawFront( depth )
	love.graphics.setColor( wallColor )
	love.graphics.polygon( "fill", centerX-roomEdges[depth+1][1],centerY-roomEdges[depth+1][2], centerX+roomEdges[depth+1][1],centerY-roomEdges[depth+1][2],
								centerX+roomEdges[depth+1][1],centerY+roomEdges[depth+1][2], centerX-roomEdges[depth+1][1],centerY+roomEdges[depth+1][2] )
end

function loadMaze( id )
	fileName = string.format( "%03i.maze", id )
	fileInfo = love.filesystem.getInfo( fileName )
	if fileInfo then
		for line in love.filesystem.lines( fileName ) do

		end
	end
	maze.dimension = { 3, 3, 1 }
	maze.start = { 2, 2, 1 }
	maze.finish = { 3, 1, 1 }

	maze.maze = {}
	maze.maze[1] = {}  -- z
	maze.maze[1][1] = {09,05,07} -- y
	maze.maze[1][2] = {10,13,03}
	maze.maze[1][3] = {12,05,06}
end

function setupPlayer()
	player.current = maze.start
	player.facing = "east"
end
