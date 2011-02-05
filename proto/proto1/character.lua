require("lib/essential")
require("lib/math/rect")
require("projection")

Character = class("Character", StatefulObject)

Character.IMAGES = {
    rectprism = love.graphics.newImage("resources/images/characters/rectprism.png"),
}

Character.QUADS = {
    rectprism = {
        se = love.graphics.newQuad(0, 0, 64, 128, 512, 128),
        ne = love.graphics.newQuad(64, 0, 64, 128, 512, 128),
        nw = love.graphics.newQuad(128, 0, 64, 128, 512, 128),
        sw = love.graphics.newQuad(192, 0, 64, 128, 512, 128),
        s = love.graphics.newQuad(256, 0, 64, 128, 512, 128),
        e = love.graphics.newQuad(320, 0, 64, 128, 512, 128),
        n = love.graphics.newQuad(384, 0, 64, 128, 512, 128),
        w = love.graphics.newQuad(448, 0, 64, 128, 512, 128),
    }
}

function Character:initialize ()
    super.initialize(self)
    self.image = "rectprism"
    self.size = {width=51, height=77}
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    self.position = Vector2:new(w/2-self.size.width/2, h/2-self.size.height/2)
    self.velocity = Vector2:new(0, 0)
    self.bounds = Rect:new(200, 200, w-400, h-400)
    self.direction = "sw"
end

function Character:draw ()
    local image = Character.IMAGES[self.image]
    local quads = Character.QUADS[self.image]
    love.graphics.push()
    love.graphics.scale(self.scale)
    local x = math.floor(self.position.x)
    local y = math.floor(self.position.y)
    if quads then
        local quad = quads[self.direction]
        love.graphics.drawq(image, quad, x, y)
    else
        love.graphics.draw(image, x, y)
    end
    love.graphics.pop()
end

function Character:mousepressed (x, y, button)
    x = x - 30
    y = y - 15 - self.size.height
    self.goal = Vector2:new(x, y)
    self:gotoState('MoveToPosition')
end

--------------------------------------------------------------------------------
-- state: Base

local Base = Character:addState('Base')

local dict = {"ne", "n", "nw", "w", "sw", "s", "se", "e"}

local function getOrientation(vec)
    dir = math.floor(4*math.atan2(-vec.y,vec.x)/math.pi+0.5)%8+1
    return dict[dir]
end

function Base:update (dt, map)
    -- set the direction
    if math.abs(self.velocity.x)+math.abs(self.velocity.y)>0 then
        self.direction = getOrientation(self.velocity)
    end
    
    local coords = projection.worldToScreen({x=self.velocity.x,y=0,z=self.velocity.y})
    local temp = Vector2:new(coords.x,coords.y)

    local p = self.position + Vector2:new(self.size.width/2, self.size.height/2) + temp
    local s = self.scale
    local b = self.bounds
    local bp = b.position/s
    if p.x > bp.x + b.width/s or p.x < bp.x then
        -- Move the map along the x axis instead
        map.velocity.x = -temp.x
        if self.goal then
            self.goal.x = self.goal.x - temp.x
        end
        temp.x = 0
    end
    if p.y > bp.y + b.height/s or p.y < bp.y then
        -- Move the map along the y axis instead
        map.velocity.y = -temp.y
        if self.goal then
            self.goal.y = self.goal.y - temp.y
        end
        temp.y = 0
    end
    
    if not temp:isZero() then
        -- Get the rate of movement
        local speed = Map.WALK_SPEED
        if love.keyboard.isDown("lctrl") then
            speed = Map.SNEAK_SPEED
        elseif love.keyboard.isDown("lshift") then
            speed = Map.RUN_SPEED
        end
        temp = temp * speed
        self.position = self.position + temp
        temp:zero()
    end
end

--------------------------------------------------------------------------------
-- state: ArrowKeysMovement

local ArrowKeysMovement = Character:addState('ArrowKeysMovement', Base)

function ArrowKeysMovement:update (dt, map)
    self.scale = map.scale
 
    if map.editorEnabled then return end

    local move = map.BASE_SPEED * dt
    local d = Vector2:new(0,0)
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        d.y = -move
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        d.y = move
    end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        d.x = -move
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        d.x = move
    end
    
    if d.y ~= 0 and d.x ~= 0 then
        d.x = d.x/math.sqrt(2)
        d.y = d.y/math.sqrt(2)
    end

    self.velocity = d

    super.update(self, dt, map)
end

--------------------------------------------------------------------------------
-- state: MoveToPosition

local MoveToPosition = Character:addState('MoveToPosition', Base)

function MoveToPosition:update (dt, map)
    self.scale = map.scale
    
    if map.editorEnabled then return end
    if not self.goal then return end
    
    local p = self.position
    local test = Rect:new(p.x-5, p.y-5, 10, 10)
    
    if test:intersectsWithPoint(self.goal) then
        self:gotoState('ArrowKeysMovement')
    else
        local d = (self.goal - self.position)
        local temp = projection.screenToWorld(d)
        local angle = math.floor(math.atan2(temp.x,temp.z)/math.pi*4)*math.pi/4
        d = Vector2:new(math.sin(angle),math.cos(angle))
        d=d*map.BASE_SPEED*dt
        self.velocity=d
        super.update(self, dt, map)
    end
end

