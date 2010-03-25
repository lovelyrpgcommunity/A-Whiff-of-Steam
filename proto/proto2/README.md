# Prototype 2

This is the second prototype for _A Whiff of Steam_. This prototype aims to add a few new features onto prototype 1, still heading in the same direction of a single somewhat functionally-complete map.

## Ticket

The ticket for this prototype can be found here: http://codaset.com/lovelyrpgcommunity/a-whiff-of-steam/tickets/2

And here are its contents:

	We are getting closer to second iteration, first one already seems to be stable and proven world scale is set-up correctly. This iteration will add scale to world, foliage and road sign, but most important - it will add hero. This time we will try to make the character move around and catch proper proportions.

	* Scale: lets for now assume for need of this prototype, that tile as we have it now, have side of 2 meters, making it screen height about 18 meters - Lets create character with height of about 60 pixels. We should have 8 sprites for now of character facing 8 different directions. Character could be made of cone or cylinder, with somehow marked direction it's pointing.

	* Character movement: character movement should be fluent, for now no collisions are needed, let's assume that walking from bottom to top of screen should take about 4 seconds running, 8 walking and 16 sneaking. For prototype it should be enough to implement one speed, say running. We should use two methods of walking, one based on keyboard, second by using mouse.

	* Foliage and sign: let's create simple higher brush grass asset to place around - reaching character's knees and one road sign a bit higher than character. Purpose of this is to test out drawing order and stuff assets placement, no collisions required yet. Assets should be placed on pixel based manner, i.e. it should be possible to place sign on left or right part of certain tile.

## Goals

The goals for this prototype are

1. Add a character to the map (can be anything: a cylinder, a cone, whatever)
	1. Give the character 8 different states, for the different directions the character will be facing when moving.
	2. Make the character be able to move on the map. We would like to give the character three different speeds (running: 1x, walking: .5x, and sneaking: .25x), but one speed will do.
	3. Make the character about 60 pixels tall, or whatever makes the world scale work.
