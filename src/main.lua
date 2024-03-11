require "bit"

print( #arg )
print( arg[1], arg[2] )

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
local directionWallBits = {  -- front, back, left, right, top, bottom
	["north"] = {1, 4, 8, 2, 16, 32},
	["east"] = {2, 8, 1, 4, 16, 32},
	["south"] = {4, 1, 2, 8, 16, 32},
	["west"] = {8, 2, 4, 1, 16, 32},
	-- ["up"] = { },  -- OI!
	-- ["down"] = {}
}
local newRoom = false

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

	loadMaze(4)
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
		--print( x, y, z, currentRoom )
		drawCeiling( depth )
		drawFloor( depth )
		wallBits = directionWallBits[player.facing]
		if bit.band( currentRoom, wallBits[3] ) ~= 0 then
			drawLeft( depth )
		else
			-- print( "Empty left wall" )
			roomToTheDirection = wallBits[3]
			-- get east from 2
			for d,dirs in pairs( directionWallBits ) do
				if roomToTheDirection == dirs[1] then
					side = {}
					for i, v in ipairs( directionVectors[d] ) do
						side[i] = player.current[i] + v
					end
				end
			end
			-- get room to the d dir
			sideRoom = maze.maze[side[3]][side[2]][side[1]]
			-- ceiling
			love.graphics.setColor( ceilingColor )
			edgeCoords = { centerX-roomEdges[depth][1],centerY-roomEdges[depth][2], centerX-roomEdges[depth+1][1],centerY-roomEdges[depth+1][2],
							centerX-roomEdges[depth][1],centerY-roomEdges[depth+1][2] }
			love.graphics.polygon( "fill", edgeCoords )
			love.graphics.setColor( 1, 1, 1, 1 )
			love.graphics.polygon( "line", edgeCoords )
			-- floor
			love.graphics.setColor( floorColor )
			edgeCoords = { centerX-roomEdges[depth][1],centerY+roomEdges[depth+1][2], centerX-roomEdges[depth+1][1],centerY+roomEdges[depth+1][2],
							centerX-roomEdges[depth][1],centerY+roomEdges[depth][2] }
			love.graphics.polygon( "fill", edgeCoords )
			love.graphics.setColor( 1, 1, 1, 1 )
			love.graphics.polygon( "line", edgeCoords )
			-- wall (only 1)
			if bit.band( sideRoom, wallBits[1] ) ~= 0 then
				love.graphics.setColor( wallColor )
				edgeCoords = { centerX-roomEdges[depth][1],centerY-roomEdges[depth+1][2], centerX-roomEdges[depth+1][1],centerY-roomEdges[depth+1][2],
								centerX-roomEdges[depth+1][1],centerY+roomEdges[depth+1][2], centerX-roomEdges[depth][1],centerY+roomEdges[depth+1][2] }
				love.graphics.polygon( "fill", edgeCoords )
				love.graphics.setColor( 1, 1, 1, 1 )
				love.graphics.polygon( "line", edgeCoords )
			end

			-- print( player.facing, roomToTheDirection, directionWallBits[player.facing], sideRoom )
		end
		if bit.band( currentRoom, wallBits[4] ) ~= 0 then
			drawRight( depth )
		else
			-- print( "Empty right wall" )
			roomToTheDirection = wallBits[4]
			for d,dirs in pairs( directionWallBits ) do
				if roomToTheDirection == dirs[1] then
					side = {}
					for i, v in ipairs( directionVectors[d] ) do
						side[i] = player.current[i] + v
					end
				end
			end
			sideRoom = maze.maze[side[3]][side[2]][side[1]]
			-- ceiling
			love.graphics.setColor( ceilingColor )
			edgeCoords = { centerX+roomEdges[depth][1],centerY-roomEdges[depth][2], centerX+roomEdges[depth][1],centerY-roomEdges[depth+1][2],
							centerX+roomEdges[depth+1][1],centerY-roomEdges[depth+1][2] }
			love.graphics.polygon( "fill", edgeCoords )
			love.graphics.setColor( 1, 1, 1, 1 )
			love.graphics.polygon( "line", edgeCoords )
			-- floor
			love.graphics.setColor( floorColor )
			edgeCoords = { centerX+roomEdges[depth][1],centerY+roomEdges[depth][2], centerX+roomEdges[depth][1],centerY+roomEdges[depth+1][2],
							centerX+roomEdges[depth+1][1],centerY+roomEdges[depth+1][2] }
			love.graphics.polygon( "fill", edgeCoords )
			love.graphics.setColor( 1, 1, 1, 1 )
			love.graphics.polygon( "line", edgeCoords )
			if bit.band( sideRoom, wallBits[1] ) ~= 0 then
				love.graphics.setColor( wallColor )
				edgeCoords = { centerX+roomEdges[depth+1][1],centerY-roomEdges[depth+1][2], centerX+roomEdges[depth][1],centerY-roomEdges[depth+1][2],
								centerX+roomEdges[depth][1],centerY+roomEdges[depth+1][2], centerX+roomEdges[depth+1][1],centerY+roomEdges[depth+1][2] }
				love.graphics.polygon( "fill", edgeCoords )
				love.graphics.setColor( 1, 1, 1, 1 )
				love.graphics.polygon( "line", edgeCoords )
			end


			-- print( player.facing, roomToTheDirection, directionWallBits[player.facing], sideRoom )
		end
		if bit.band( currentRoom, wallBits[1] ) ~= 0 then
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
function love.keypressed( key, scancode, isrepeat )
	local newFront
	if key == "left" then
		newFront = directionWallBits[player.facing][3]
	elseif key == "right" then
		newFront = directionWallBits[player.facing][4]
	end
	if newFront then
		for d, dirs in pairs( directionWallBits ) do
			if newFront == dirs[1] then
				player.facing = d
			end
		end
	end
	if key == "up" then
		-- print( directionWallBits[player.facing][1], maze.maze[player.current[3]][player.current[2]][player.current[1]],
		-- 	bit.band( directionWallBits[player.facing][1], maze.maze[player.current[3]][player.current[2]][player.current[1]] ) )
		if bit.band( directionWallBits[player.facing][1], maze.maze[player.current[3]][player.current[2]][player.current[1]] ) == 0 then
			for i,v in ipairs( directionVectors[player.facing] ) do
				player.current[i] = player.current[i] + v
			end
			newRoom = true
		end
	end
	print( newFront, player.facing, unpack( player.current ) )
end
function love.update( dt )
	if newRoom then
		for i, v in ipairs( player.current ) do
			newRoom = newRoom and (player.current[i] == maze.finish[i])
		end
		if newRoom then
			print( "Found the end!" )
			love.event.quit()
		end
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
	fileIn = {}
	if fileInfo then
		for line in love.filesystem.lines( fileName ) do
			table.insert( fileIn, line )
		end
	end
	_3csv = "^(%d+),(%d+)[,]*(%d*)$"

	_, _, x,y,z = string.find( fileIn[1], _3csv )   -- maze.dimension = line 1
	maze.dimension = { tonumber(x), tonumber(y), z=="" and 1 or tonumber(z) }

	_, _, x,y,z = string.find( fileIn[2], _3csv )   -- maze.start = line 2
	maze.start = { tonumber(x), tonumber(y), z=="" and 1 or tonumber(z) }

	_, _, x,y,z = string.find( fileIn[3], _3csv )   -- maze.finish = line 3
	maze.finish = { tonumber(x), tonumber(y), z=="" and 1 or tonumber(z) }

	-- line 4 should be blank
	maze.maze = {}

	for z = 1,maze.dimension[3] do
		-- print( "z="..z )
		maze.maze[z] = {}
		for y = 1,maze.dimension[2] do
			-- print( "y="..y )
			maze.maze[z][y] = {}
			lineNum = ((z-1)*maze.dimension[2])+y + 4
			-- print( "line#="..lineNum )
			for v in string.gmatch( fileIn[lineNum], "([^,]+)" ) do
				table.insert( maze.maze[z][y], tonumber(v) )
				-- print(v)
			end
		end
	end
end

function setupPlayer()
	player.current = maze.start
	player.facing = "east"
end
