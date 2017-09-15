-- firing solution

require("mathlib")
require("firingsolution")

sWidth, sHeight = display.contentWidth, display.contentHeight

local towers = display.newGroup()

local targets = display.newGroup()

local bullets = display.newGroup()

local bulletSpeed = 2

-- animate
function enterFrame()
	-- removes body and returns true if the body is off the screen
	local function isOffScreen(body)
		if (body.x < 0 or body.x > sWidth or body.y < 0 or body.y > sHeight) then
			body:removeSelf()
			return true
		end
		return false
	end
	
	-- returns true if bullet is close enough to position of a target
	local function isCollided(bullet)
		for i=targets.numChildren, 1, -1 do
			local target = targets[i]
			local len = lengthOf( target, bullet )
			if (len < 5) then
				target:removeSelf()
				bullet:removeSelf()
				return true
			end
		end
	end
	
	-- update position of body with velocity values of body
	local function updatePosition(body)
		body.x, body.y = body.x + body.vx, body.y + body.vy
	end
	
	-- animate targets
	for i=targets.numChildren, 1, -1 do
		updatePosition(targets[i])
	end
	
	-- animate and check bullet positions
	for i=bullets.numChildren, 1, -1 do
		updatePosition(bullets[i])
		isCollided(bullets[i])
	end
end
Runtime:addEventListener("enterFrame", enterFrame)

-- add a tower
function tap(e)
	local tower = display.newRect( towers, 0, 0, 50, 50 )
	tower.x, tower.y = e.x, e.y
	tower:setFillColor(255,0,0)
end
Runtime:addEventListener("tap",tap)

-- generate random targets
function generate()
	local target = display.newCircle( targets, 0, 0, 20 )
	target.x, target.y, target.vx, target.vy = math.random(0,sWidth), math.random(0,sHeight), math.random(-4,4), math.random(-4,4)
	target:setFillColor(0,0,255)
end
timer.performWithDelay(6000, generate, 0)

-- fires bullet
function fire( tower, target )
	local solution, success = intercept( tower, target, bulletSpeed )
	if (success) then
		-- calculate vx and vy
		local angle = angleOf( tower, solution )
		local pt = rotateTo( {x=bulletSpeed, y=0}, angle )
		-- fire bullet
		local bullet = display.newCircle( bullets, 0, 0, 10 )
		bullet.x, bullet.y, bullet.vx, bullet.vy, bullet.solution = tower.x, tower.y, pt.x, pt.y, solution
		bullet:setFillColor(0,255,0)
	end
end
function aim()
	for i=towers.numChildren, 1, -1 do
		for t=targets.numChildren, 1, -1 do
			fire( towers[i], targets[t] )
		end
	end
end
timer.performWithDelay(3000,aim,0)
