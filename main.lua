--[[ 

This example demonstrates physics collisions by Alexandros Tsompolis - demo

]]

-- include box2d
require "box2d"

--let's create separate scene and hold everything there
--then it will be easier to reuse it if you want to use SceneManager class
scene = gideros.class(Sprite)

--scene initialization
function scene:init()
	--createworld instance
	self.world = b2.World.new(0, 10, true)

	local screenW = application:getContentWidth()
	local screenH = application:getContentHeight()
	--create bounding walls  outside the scene
	self:wall(0,screenH/2, 10, screenH * 10)
	self:wall(screenW, screenH/2, 10, screenH * 10)
	self:wall(screenW/2, screenH , screenW, 10)
	
	self.custom1 = self:customObject(0, 80, "corner_1")
	self.custom2 = self:customObject(480, 60, "corner_2")
	self.custom3 = self:customObject(50, 350, "curved_object_1")
	
	self.custom4 = self:customObject(480, 220, "curved_object_2")
	self.custom5 = self:customObject(300, 550, "bouncy")
	self.custom6 = self:customObject(240, 800, "base_triangle")
	
	self.a = {}    -- new array of created objects
	self.stringArray = {"ball", "star", "poly", "rect"} --array of object names
	
	self.timer = Timer.new(1000, 4)
	self.i = 1
	math.randomseed( os.time() )
	function scene:onTimer(event)
		--self.a[self.i] = self:ball(math.random(0,430),-250, self.stringArray[self.i] .. ".png")
		self.a[self.i] = self:touchObject(self.stringArray[self.i])
		self.i = self.i + 1
	end
	self.timer:start()
	
	--create empty box2d body for joint
	--since mouse cursor is not a body
	--we need dummy body to create joint
	local groundBody = self.world:createBody({})
	
	--create empty box2d body for joint
	local groundBody2 = self.world:createBody({})
	groundBody2:setPosition(200, 250)
	
	--create object
	self.customRev = self:customObject(200, 250, "joint")
	local jointDef = b2.createRevoluteJointDef(self.customRev.body, groundBody2, 200, 250)
	local revoluteJoint = self.world:createJoint(jointDef)
	--this will not let object spin for ever
	revoluteJoint:setMaxMotorTorque(0.01)
	revoluteJoint:enableMotor(true)
	
	--joint with dummy body
	local mouseJoint = nil
	
	-- create a mouse joint on mouse down
	function scene:onTouchesBegin(event)
		for i=1, 4 do
     		if self.a[i]:hitTestPoint(event.touch.x, event.touch.y) then
				local jointDef = b2.createMouseJointDef(groundBody, self.a[i].body, event.touch.x, event.touch.y, 100000)
				mouseJoint = self.world:createJoint(jointDef)
			end	
		end
	end

	-- update the target of mouse joint on mouse move
	function scene:onTouchesMove(event)
		if mouseJoint ~= nil then
			mouseJoint:setTarget(event.touch.x, event.touch.y)
		end
	end

	-- destroy the mouse joint on mouse up
	function scene:onTouchesEnd(event)
		if mouseJoint~=nil then
			self.world:destroyJoint(mouseJoint)
			mouseJoint = nil
		end
	end 
		
	--[[set up debug drawing
	local debugDraw = b2.DebugDraw.new()
	debugDraw:setFlags(b2.DebugDraw.SHAPE_BIT + b2.DebugDraw.JOINT_BIT)
	self.world:setDebugDraw(debugDraw)
	self:addChild(debugDraw)]]
	
	
	--run world
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
	
	--add timer event
	self.timer:addEventListener(Event.TIMER, self.onTimer, self)
	
	--collision events
	--self:addEventListener(Event.BEGIN_CONTACT, self.onBeginContact, self)
	self.world:addEventListener(Event.BEGIN_CONTACT, self.onBeginContact, self)
	
	--dispach touch events when all the object have been created
	function self:onTimerComplete(event)
		-- will be executed after the specified number of timer events (4) are dispatched
		--touch events
		self:addEventListener(Event.TOUCHES_BEGIN , self.onTouchesBegin, self)
		self:addEventListener(Event.TOUCHES_MOVE , self.onTouchesMove, self)
		self:addEventListener(Event.TOUCHES_END , self.onTouchesEnd, self)
	end
	
	-- add timer complete event
	self.timer:addEventListener(Event.TIMER_COMPLETE, self.onTimerComplete, self)
	
	--remove event on exiting scene
	self:addEventListener("exitBegin", self.onExitBegin, self)
end

-- for creating objects using shape
-- as example - bounding walls
function scene:wall(x, y, width, height)
	local wall = Shape.new()
	--define wall shape
		
	wall:beginPath()
	
	--we make use (0;0) as center of shape,
    --thus we have half of width and half of height in each direction	
	wall:moveTo(-width/2, -height/2)
	wall:lineTo(width/2, -height/2)
	wall:lineTo(width/2, height/2)
	wall:lineTo(-width/2, height/2)
	wall:closePath()
	wall:endPath()
	wall:setPosition(x,y)
	
	--create box2d physical object
	local body = self.world:createBody{type = b2.STATIC_BODY}
	body:setPosition(wall:getX(), wall:getY())
	body:setAngle(wall:getRotation() * math.pi/180)
	local poly = b2.PolygonShape.new()
	poly:setAsBox(wall:getWidth()/2, wall:getHeight()/2)
	local fixture = body:createFixture{shape = poly, density = 0.1, friction = 0.1, restitution = 0.2}
	wall.body = body
	wall.body.type = "wall"
	
	--add to scene
    self:addChild(wall)
     
    --return created object
    return wall
end

-- for creating objects using image
-- as example - ball
--[[function scene:ball(x, y, name)
    --create ball bitmap object from ball graphic
    local ball = Bitmap.new(Texture.new("./ArtAssets/" .. name .. ".png"))
    --reference center of the ball for positioning
    ball:setAnchorPoint(0.5,0.5)
     
    ball:setPosition(x,y)
     
    --get radius
    local radius = ball:getWidth()/2
     
    --create box2d physical object
    local body = self.world:createBody{type = b2.DYNAMIC_BODY}
    body:setPosition(ball:getX(), ball:getY())
    body:setAngle(ball:getRotation() * math.pi/180)
    local circle = b2.CircleShape.new(0, 0, radius)
    local fixture = body:createFixture{shape = circle, density = 1, 
    friction = 1, restitution = 0.5}
	print(name)
	--local scaleFactor = 0.1
	--local physics = (loadfile "physicsData.lua")().physicsData(scaleFactor)			
	--physics:addFixture(body, name)
    --ball.body = body
    --ball.body.type = name	
	
	--ball:setAnchorPoint(physics:getAnchorPoint(name))
     
    --add to scene
    self:addChild(ball)
     
    --return created object
    return ball
end]]

-- for creating physical custom objects using image
function scene:customObject(x, y, name)
    --create customObj bitmap object from ball graphic
    local customObj = Bitmap.new(Texture.new("./ArtAssets/" .. name .. ".png"))
    
    customObj:setPosition(x,y)
     
    --create box2d physical object
	local type1
	if (name == "joint" or name == "ball") then
		type1 = b2.DYNAMIC_BODY
	else
		type1 = b2.STATIC_BODY
	end
	local body = self.world:createBody{type = type1}
    body:setPosition(customObj:getX(), customObj:getY())
	
	local scaleFactor = 0.1
	local physics = (loadfile "physicsData.lua")().physicsData(scaleFactor)			
	physics:addFixture(body, name)
	customObj.body = body
    customObj.body.type = name
	
	customObj:setAnchorPoint(physics:getAnchorPoint(name))
	     
    --add to scene
    self:addChild(customObj)
     
    --return created object
    return customObj
end

--for creating interacrive game objects using image
function scene:touchObject(name)
	--create touchObj bitmap object from the appropriate image
	local touchObj = Bitmap.new(Texture.new("./ArtAssets/" .. name .. ".png"))
	
	touchObj:setPosition(math.random(0,430),-250)
	
	--create box2d physical object by PhysicsEditor
	local touchBody = self.world:createBody{type = b2.DYNAMIC_BODY}
	touchBody:setPosition(touchObj:getX(), touchObj:getY())
	
	local scaleFactorTouch = 0.1
	local physics = (loadfile "PhysicsData.lua")().physicsData(scaleFactor)
	
	physics:addFixture(touchBody,name)
	touchObj.body = touchBody
	touchObj.body.type = name
	
	touchObj:setAnchorPoint(physics:getAnchorPoint(name))
	
	--add to scene
	self:addChild(touchObj)
	
	--return created object
	return touchObj
end

--running the world
function scene:onEnterFrame()
	-- edit the step values if required. These are good defaults!
	self.world:step(1/30, 8, 3)
	--iterate through all child sprites
	for i = 1, self:getNumChildren() do
		--get specific sprite
		local sprite = self:getChildAt(i)
		-- check if sprite HAS a body (ie, physical object reference we added)
		if sprite.body then
			--update position to match box2d world object's position
            --get physical body reference
			local body = sprite.body
			--get body coordinates
			local bodyX, bodyY = body:getPosition()
			
			--test velocity
			local type = body.type
			if (type == "ball" or type == "star" or type == "poly" or type == "rect") then
				local velX,velY = body:getLinearVelocity()
				print(type .. " velocity:  " .. velX,velY)
			end
			--apply coordinates to sprite
			sprite:setPosition(bodyX, bodyY)
			--apply rotation to sprite
			sprite:setRotation(body:getAngle() * 180/math.pi)
		end
	end
end

--define collision event handler function
function scene:onBeginContact(e)
    --getting contact bodies
    local fixtureA = e.fixtureA
    local fixtureB = e.fixtureB
    local bodyA = fixtureA:getBody()
    local bodyB = fixtureB:getBody()
	
	local sound = Sound.new("./Sound Effects/single-vocal-bounce.wav")
	local sound2 = Sound.new("./Sound Effects/click_x.mp3")
     
    --check if first colliding body is bouncy
    --it should be first, because it was created before dragging ball object
    if bodyA.type and bodyA.type == "bouncy" then
		--creating timer to delay changing world
        --because by default you can't change world settings 
        --in event callback function
        --delay 1 milisecond for 1 time
        local timer = Timer.new(1, 1)
        --setting timer callback

        timer:addEventListener(Event.TIMER, function()
            			
			local channel = sound:play()
        end)
		
        --start timer
        timer:start()
	end
	if bodyA.type and bodyA.type == "joint" then
		--creating timer to delay changing world
        --because by default you can't change world settings 
        --in event callback function
        --delay 1 milisecond for 1 time
        local timer = Timer.new(1, 1)
        --setting timer callback
        timer:addEventListener(Event.TIMER, function()
            --local channel = sound2:play()
        end)
        --start timer
        timer:start()		
    end
end


--removing event on exiting scene
--just in case you're using SceneManager
function scene:onExitBegin()
  self:removeEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
end

--add created scene to stage or sceneManager
local mainScene = scene.new()
stage:addChild(mainScene)