// Sprite Utilities

import "importUtil"
ensureImport "qa"

// drawBounds: draw a bounding box on the given PixelDisplay 
// (or gfx, if not specified).  `b` here may be any of:
//	- a Bounds object
//  - a Sprite (draws its worldBounds)
//  - a list (draws worldBounds of all sprites therein)
//  - a SpriteDisplay (draws worldBounds of all sprites it contains)
drawBounds = function(b, disp=null, color="#FF00FF", penSize=1)
	if disp == null then disp = gfx
	if b isa SpriteDisplay then b = b.sprites
	if not b isa list then b = [b]
	for item in b
		if item isa Bounds then
			disp.drawPoly item.corners, color, penSize
		else if item isa Sprite and item.worldBounds != null then
			disp.drawPoly item.worldBounds.corners, color, penSize
		else if item isa list then
			drawBounds item, disp, color, penSize
		end if
	end for
end function

// addBounds: Helper function to add or update sprite bounds based on its image
// (possibly inset by an amount).  Inset may be a single number to use for
// both X and Y, or an [x,y] list.  The amount given is subtracted from both
// size of the image (so we actually reduce the width/height by twice that
// amount.)
addBounds = function(sprite, inset=0)
	if sprite.localBounds then
		b = sprite.localBounds
	else
		b = new Bounds
		sprite.localBounds = b
	end if
	if inset isa list then
		ix = inset[0]
		iy = inset[1]
	else
		ix = inset
		iy = inset
	end if
	b.width = sprite.image.width - ix * 2
	b.height = sprite.image.height - iy * 2
	return b
end function

// addSprite: Helper function to create a sprite from an image or image
// path, add it to the given display at a given position, and optionally
// give it a bounds that fits the image.
addSprite = function(imageOrPath, display, x=480, y=320, withBounds=true)
	if imageOrPath isa string then
		img = file.loadImage(imageOrPath)
		if img == null then qa.abort "Unable to load image: " + imageOrPath
		imageOrPath = img
	else if not imageOrPath isa Image then
		qa.abort "addSprite needs an image or path; got: " + str(imageOrPath)
	end if
	noob = new Sprite
	noob.image = imageOrPath
	noob.x = x
	noob.y = y
	if withBounds then addBounds noob
	if display != null then
		qa.assert display isa SpriteDisplay, "invalid display in addSprite"
		display.sprites.push noob
	end if
	return noob
end function

demo = function
	clear
	wumpus = addSprite("/sys/pics/Wumpus.png", display(4))
	
	while true
		yield
		
		gfx.clear
		wumpus.rotation += 2
		wumpus.scale = 1 + sin(time) * 0.25
		drawBounds display(4)
	end while
end function

if locals == globals then demo

