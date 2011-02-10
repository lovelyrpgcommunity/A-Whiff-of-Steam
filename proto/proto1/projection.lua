--[[

projection setup:

I) 3D space

   We have axis Y pointing upwards, axis X pointing right and axis Z pointing
outside of screen. To create projection we do:

   1) apply scale equal in each X,Y,Z directions
   2) apply additional scale of up to +/- 5% to Y axis if necessary
   3) rotate by beta around Y
   4) rotate by alpha around X
   5) project to screen plane (Z=0)

II) 2D Space

  We have axis X pointing right, and axis Y pointing down, with (0,0) in
top-left corner of screen. Because axis Y is mirrored (pointing downward), we
have to apply one more correction:

   6) mirror axis Y

III) World to screen transformation

Point (x,y,z) in world coordinates, scales to point (x',y') in screen
coordinates by:

  x' = scale*(cos(beta)*x + sin(beta)*z)
  y' = -scale*(sin(alpha)*sin(beta)*x + yrescale*cos(alpha)*y - sin(alpha)*cos(beta)*z)

IV) Spanning vectors

In world coordinates unit cube is spanned by vectors
vx=(1,0,0), vy=(0,1,0) and vz=(0,0,1).

Projected vectors have coordinates:

vx' = (scale*cos(beta), -scale*sin(alpha)*sin(beta))
vy' = (0              , -scale*yrescale*cos(alpha))
vz' = (scale*sin(beta), scale*sin(alpha)*cos(beta))

When we take:

scale = 30*math.sqrt(2)
yrescale = 1 -- exact projection
alpha = math.asin(1/3)
beta = math.pi/4 -- dimetric

we have

sin(beta)  = 1/2*math.sqrt(2)
cos(beta)  = 1/2*math.sqrt(2)
sin(alpha) = 1/3
cos(alpha) = 2/3*math.sqrt(2)

which leads to

vx'.x = scale*cos(beta) = 30*math.sqrt(2)*1/2*math.sqrt(2) = 30
vx'.y = -scale*sin(alpha)*sin(beta) = -30*math.sqrt(2)*1/3*1/2*math.sqrt(2) = -10
vy'.x = 0
vy'.y = -scale*yrescale*cos(alpha) = -30*math.sqrt(2)*1*2/3*math.sqrt(2) = -40
vz'.x = scale*sin(beta) = 30*math.sqrt(2)*1/2*math.sqrt(2) = 30
vz'.y = scale*sin(alpha)*cos(beta) = 30*math.sqrt(2)*1/3*1/2*math.sqrt(2) = 10

So

vx' = (30, -10)
vz' = ( 0, -40)
vz' = (30,  10)

and the projection can be written in matrix form using only integer values:

| x'|   | 30   0  30   0| |x|
| y'| = |-10 -40  10   0|*|y|
| 0 |   |  0   0   0   0| |z|
| 1 |   |  0   0   0   1| |1|

]]

require("lib/math/vector2")

projection = {}

local vx = Vector2:new(30,-10)
local vy = Vector2:new( 0,-40)
local vz = Vector2:new(30, 10)
local perpdot = vx:perpdot(vz)

-- spanning vectors
projection.vx = vx
projection.vy = vy
projection.vz = vz

-- World coordinates to screen coordinates conversion
function projection.worldToScreen(w)
    local x = vx.x*w.x            + vz.x*w.z
    local y = vx.y*w.x + vy.y*w.y + vz.y*w.z
    return {x=x,y=y}
end

-- Screen coordinates to world coordinates conversion assuming y
function projection.screenToWorld(s, y)
    local y = y or 0
    local x = (vz.y*s.x - vz.x*(s.y-vy.y*y))/perpdot
    local z = (s.x - vx.x*x)/vz.x
    return {x=x,y=y,z=z}
end

