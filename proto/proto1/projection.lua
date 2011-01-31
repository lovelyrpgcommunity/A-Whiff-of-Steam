--[[

projection setup:

I) 3D space

   We have axis Y pointing upwards, axis X pointing right and axis Z pointing
outside of screen. To create projection of 1x1 tile, we do:

   1) apply scale to tile, equal in each X,Y,Z directions
   2) apply additional scale of up to +/- 5% to Y axis
   3) rotate by beta around Y
   4) rotate by alpha around X
   5) project to screen place (Z=0)

II) 2D Space

  We have axis X pointing right, and axis Y pointing down, with (0,0) in
top-left corner of screen. Because axis Y is mirrored (poiting downward), we
have to apply one more correction:

   5) mirror axis Y

III) World to screen transformation

Point (x,y,z) in world coordinates, scales to point (x',y') in screen
coordinates by:

  x' = scale*(cos(beta)*x + sin(beta)*z)
  y' = -scale*(sin(alpha)*sin(beta)*x + yrescale*cos(alpha)*y - sin(alpha)*cos(beta)*z)

IV) 1x1x1 cube

In world coordinates tile is crated by vectors v1=(1,0,0) and v2=(0,0,1), i.e. they
are 1x1 squares on ground plane (Y=0).

New vectors have coordinates:

v1' = (scale*cos(beta), -scale*sin(alpha)*sin(beta))
v2' = (scale*sin(beta), scale*sin(alpha)*cos(beta))

When we take:

scale = 20*math.sqrt(5)
yrescale = 4/math.sqrt(15)
alpha = math.pi/6
beta = math.atan(1/2)

because

math.sin(math.atan(x)) = x/math.sqrt(x^2+1)
math.cos(math.atan(x)) = 1/math.sqrt(x^2+1)

we have

sin(beta) = 1/math.sqrt(5)
cos(beta) = 2/math.sqrt(5)

and of course

sin(alpha) = 1/2
scale*cos(beta) = 20*math.sqrt(5)*2/math.sqrt(5) = 40
scale*sin(alpha)*sin(beta) = 20*math.sqrt(5)*1/2*1/math.sqrt(5) = 10
scale*sin(beta) = 20*math.sqrt(5)*1/math.sqrt(5) = 20
scale*sin(alpha)*cos(beta) = 20*math.sqrt(5)*1/2*2/math.sqrt(5) = 20

which finally leads to

v1' = (40, -10)
v2' = (20,  20)

Taking into account height v3=(0,1,0) we get:

v3' = (0, -scale*rescale*cos(alpha))

which is equal to

v3' = (0, -40)

]]

-- projection setup
local scale = 20*math.sqrt(5)
local yrescale = 4/math.sqrt(15) -- make everything 3.28% higher
local alpha = math.pi/6
local beta = math.atan(1/2)

-- useful constants, recalculate if projection changes!
local cb = 40 -- scale*math.cos(beta)
local sb = 20 -- scale*math.sin(beta)
local sasb = 10 -- scale*math.sin(alpha)*math.sin(beta)
local sacb = 20 -- scale*math.sin(alpha)*math.cos(beta)
local rca = 40 -- rescale*scale*math.cos(alpha)
local sa2 = 1000 -- scale^2*math.sin(alpha)

projection = {}

-- World coordinates to screen coordinates conversion

function projection.worldToScreen(w)
    local x,y
    x = cb*w.x+sb*w.z
    y = sacb*w.z-sasb*w.x-rca*w.y
    return {x=x,y=y}
end

-- Screen coordinates to world coordinates conversion

function projection.screenToWorld(s, y) -- assuming y
    y = y or 0
    local x,z
    x = (sacb*s.x-sb*s.y-rca*sb*y)/sa2
    z = (s.x-cb*x)/sb
    return {x=x,y=y,z=z}
end

-- spanning vectors v1', v2' and v3' of unit cube

projection.SPAN_V1_x = cb -- 40
projection.SPAN_V1_y = -sasb -- -10
projection.SPAN_V2_x = sb -- 20
projection.SPAN_V2_y = sacb -- 20
projection.SPAN_V3_x = 0 -- 0
projection.SPAN_V3_y = rca -- 40

