local width, height = 0,0
local centerX, centerY = 0,0
local maze = {}
local player = {}


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
	love.graphics.setColor( 1, 1, 1, 1 )
	-- love.graphics.line( 0,centerY, width,centerY )  -- horizon
	-- love.graphics.line( centerX,height, centerX,centerY )
	-- love.graphics.line( centerX,centerY, 0,height ) -- left vanish line
	-- love.graphics.line( centerX,centerY, width,height ) -- right vanish line
	-- love.graphics.line( 0,height, width,centerY )  -- right vanish point


	-- x6 = width / 6
	-- y6 = height / 6

	-- love.graphics.line( centerX+x6,centerY+y6, centerX-x6,centerY+y6 )  -- next edge line

	-- love.graphics.line( 0,height, centerX+x6+(x6/2),centerY )

	-- love.graphics.line( centerX-(x6-(x6/2.5)),centerY+(y6-(y6/2.5)), centerX+(x6-(x6/2.5)),centerY+(y6-(y6/2.5)) )


	-- try this:
	-- love.graphics.line( 0,0, centerX,centerY )
	-- love.graphics.line( width,0, centerX, centerY )

	for i=2,#roomEdges do
		-- ceiling
		love.graphics.setColor( 0, 0, 1, 1 )
		-- love.graphics.line( centerX-roomEdges[i-1][1],centerY-roomEdges[i-1][2], centerX+roomEdges[i-1][1],centerY-roomEdges[i-1][2] )
		-- love.graphics.line( centerX+roomEdges[i-1][1],centerY-roomEdges[i-1][2], centerX+roomEdges[i][1],centerY-roomEdges[i][2] )
		-- love.graphics.line( centerX+roomEdges[i][1],centerY-roomEdges[i][2], centerX-roomEdges[i][1],centerY-roomEdges[i][2] )
		love.graphics.polygon( "fill", centerX-roomEdges[i-1][1],centerY-roomEdges[i-1][2], centerX+roomEdges[i-1][1],centerY-roomEdges[i-1][2],
							centerX+roomEdges[i][1],centerY-roomEdges[i][2], centerX-roomEdges[i][1],centerY-roomEdges[i][2] )
		love.graphics.setColor( 1, 1, 1, 1 )
		love.graphics.polygon( "line", centerX-roomEdges[i-1][1],centerY-roomEdges[i-1][2], centerX+roomEdges[i-1][1],centerY-roomEdges[i-1][2],
							centerX+roomEdges[i][1],centerY-roomEdges[i][2], centerX-roomEdges[i][1],centerY-roomEdges[i][2] )

--		love.graphics.line( centerX-edges[1],centerY-edges[2], centerX+edges[1],centerY-edges[2], centerX+edges[1],centerY+edges[2], centerX-edges[1],centerY+edges[2], centerX-edges[1],centerY-edges[2] )
	end

end

function loadMaze( id )
	fileName = string.format( "%03i.maze", id )
	fileInfo = love.filesystem.getInfo( fileName )
	if fileInfo then
		for line in love.filesystem.lines( fileName ) do

		end
	end
	maze.width  = 3  -- x
	maze.length = 3  -- y
	maze.height = nil-- z
	maze.startX = 2
	maze.startY = 2
	maze.startZ = nil
	maze.endX = 3
	maze.endY = 1
	maze.endZ = nil

	maze.maze = {}
	maze.maze[1] = {}  -- z
	maze.maze[1][1] = {09,05,07} -- y
	maze.maze[1][2] = {10,13,03}
	maze.maze[1][3] = {12,05,06}
end

function setupPlayer()
	player.currentX = maze.startX
	player.currentY = maze.startY
	player.currentZ = maze.startZ
	player.facing = "West"
end
