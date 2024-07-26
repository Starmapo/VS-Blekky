bgX = -280
bgY = -480
bgWidth = 0
walkerCount = 0
cooldown = 0
spawnedBonie = false
spawnedLucius = false
spawnedQinsil = false

function onCreate()
	luaDebugMode = true
	makeBGSprite("bg", 0.75, 0.75)
	makeBGSprite("fg")
	bgWidth = getProperty("bg.width")
	
	precacheImage("backgrounds/Intrude/walkers")
end

function onBeatHit()
	cooldown = cooldown + 1
	
	if math.fmod(curBeat, 8) == 4 and getRandomBool(50) and cooldown > 8 then
		cooldown = getRandomInt(-4, 0)
		makeRandomWalker()
	end
end

function onTweenCompleted(tag, vars)
	if string.sub(tag, -1) == "x" then
		local name = string.sub(tag, 1, -2)
		debugPrint(name)
		removeLuaSprite(name)
		
		if name == "Bonie" then
			spawnedBonie = false
		elseif name == "Lucius" then
			spawnedLucius = false
		elseif name == "Qinsil" then
			spawnedQinsil = false
		end
	end
end

function makeBGSprite(name, scrollX, scrollY)
	scrollX = scrollX or 1
	scrollY = scrollY or 1
	makeLuaSprite(name, "backgrounds/Intrude/"..name, bgX, bgY)
	setScrollFactor(name, scrollX, scrollY)
	addLuaSprite(name)
end

function makeRandomWalker()
	if getRandomBool(10) and (not spawnedBonie) then
		makeWalker("BonieGuard1", 2.4)
		makeWalker("Bonie", 1.2)
		makeWalker("BonieGuard2")
		spawnedBonie = true
		return
	elseif getRandomBool(20) and (not spawnedQinsil) then
		if getRandomBool(20) and (not spawnedLucius) then
			makeWalker("Lucius")
			spawnedLucius = true
		else
			makeWalker("Qinsil")
			spawnedQinsil = true
		end
		return
	end
	
	makeWalker("Generic"..getRandomInt(1, 2))
end

function makeWalker(name, delay)
	delay = delay or 0
	
	local obj = name
	if string.sub(obj, 1, -2) == "Generic" then
		obj = obj..walkerCount
		walkerCount = walkerCount + 1
	end
	
	makeAnimatedLuaSprite(obj, "backgrounds/Intrude/walkers", bgX - 934, bgY + 600)
	addAnimationByPrefix(obj, "idle", name, 0)
	setScrollFactor(obj, 1.1, 1.1)
	scaleObject(obj, 0.5, 0.5)
	addLuaSprite(obj, true)
	startTween(obj.."x", obj, {x = bgX + bgWidth}, 7, {onComplete = "onTweenCompleted", startDelay = delay})
	startTween(obj.."y", obj, {y = bgY + 550}, 0.5, {onComplete = "onTweenCompleted", type = "pingpong", ease = "quadInOut"})
end