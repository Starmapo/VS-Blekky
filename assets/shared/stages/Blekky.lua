bgX = -280
bgY = -480

function onCreate()
	makeBGSprite("bg", 0.3, 0.3)
	makeBGSprite("mineBG")
	makeBGSprite("mine")
	
	makeAnimatedLuaSprite("aura", "characters/BLEKKY-AURA", getProperty("dadGroup.x") - 160, getProperty("dadGroup.y") - 40)
	addAnimationByPrefix("aura", "appear", "AuraAppear", 24, false)
	addAnimationByPrefix("aura", "idle", "Aura0")
	addOffset("aura", "appear", 7, 68)
	addOffset("aura", "idle", 0, 0)
	setProperty("aura.alpha", 0.00001)
	addLuaSprite("aura")
	
	makeLuaSprite("overlay", "backgrounds/"..curStage.."/overlay")
	setScrollFactor("overlay", 0, 0)
	setObjectCamera("overlay", "hud")
	setGraphicSize("overlay", screenWidth, screenHeight)
	setScrollFactor("overlay", 1, 1)
	addLuaSprite("overlay")
end

function onCreatePost()
	setProperty("jufan.alpha", 0.00001)
end

function onUpdatePost(elapsed)
	if getProperty("aura.animation.name") == "appear" and getProperty("aura.animation.finished") then
		playAnim("aura", "idle", true)
	end
end

function onEvent(name, v1, v2, t)
	if name == "Aura Appear" then
		playAnim("aura", "appear", true)
		setProperty("aura.alpha", 1)
		setProperty("jufan.alpha", 1)
		playAnim("jufan", "appear", true)
		setProperty("jufan.specialAnim", true)
	end
end

function makeBGSprite(name, scrollX, scrollY)
	scrollX = scrollX or 1
	scrollY = scrollY or 1
	makeLuaSprite(name, "backgrounds/"..curStage.."/"..name, bgX, bgY)
	setScrollFactor(name, scrollX, scrollY)
	addLuaSprite(name)
end