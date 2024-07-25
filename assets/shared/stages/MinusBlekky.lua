bgX = -150
bgY = -320
boppers = {}
function onCreate()
	makeBGSprite("sky", 0.3, 0.3)
	setProperty("sky.x", getProperty("sky.x") - 50)
	makeBGSprite("moon", 0.35, 0.35)
	makeBGSprite("cities2", 0.4, 0.4)
	makeBGSprite("cities1", 0.4, 0.4)
	setProperty("cities1.x", getProperty("cities1.x") - 50)
	setProperty("cities2.x", getProperty("cities2.x") - 50)
	makeBGSprite("ground2")
	makeBGSprite("ground1")
	makeBGSprite("middleGrass")
	makeBGSprite("mats")
	makeBopper("MINUS_FERI-BOP", 0, 560)
	makeBopper("MINUS_DOXXIE-BOP", 1500, 660)
	makeBopper("MINUS_SKY-BOP", -50, 900, 1.1, 1.1, true)
	makeBopper("MINUS_HORNSBOY-BOP", 1250, 900, 1.1, 1.1, true)
	
	makeLuaSprite("overlay", "backgrounds/MinusBlekky/overlay")
	setScrollFactor("overlay", 0, 0)
	setObjectCamera("overlay", "hud")
	setGraphicSize("overlay", screenWidth, screenHeight)
	addLuaSprite("overlay")
end

function makeBGSprite(name, scrollX, scrollY)
	scrollX = scrollX or 1
	scrollY = scrollY or 1
	makeLuaSprite(name, "backgrounds/MinusBlekky/"..name, bgX, bgY)
	setScrollFactor(name, scrollX, scrollY)
	addLuaSprite(name)
end

function makeBopper(name, x, y, scrollX, scrollY, over)
	scrollX = scrollX or 1
	scrollY = scrollY or 1
	over = over or false
	makeAnimatedLuaSprite(name, "backgrounds/MinusBlekky/"..name, bgX + x, bgY + y)
	addAnimation(name, "bop", {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13}, 24, false)
	setScrollFactor(name, scrollX, scrollY)
	addLuaSprite(name, over)
	table.insert(boppers, name)
end

function onCountdownTick()
	bop()
end

function onBeatHit()
	bop()
end

function bop()
	for k,v in ipairs(boppers) do
		playAnim(v, "bop", true)
	end
end