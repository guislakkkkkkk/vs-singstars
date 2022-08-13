function onCreatePost()
	luaDebugMode = true;
	addCharacterToList('solid-guitar', 'boyfriend')
end

--function onCountdownStarted()
	--debugPrint('X: ', getProperty('camFollow.x'))
	--debugPrint('Y: ', getProperty('camFollow.y'))
--end

--function onSongStart()
	--makeAnimatedLuaSprite('micthrow', 'micthrow', defaultBoyfriendX * -0.75, defaultBoyfriendY * 1.55)
	--addAnimationByPrefix('micthrow', 'hit', 'micthrow hit', 24, false)
	--playAnim('micthrow', 'hit', false)
	--triggerEvent('Play Animation', 'hurt', 'Dad')
	--addLuaSprite('micthrow', true)
--end


local lockcam = false
function goodNoteHit()
	setProperty('camZooming', true)
	if curStep >= 782 and curStep < 786 or curStep >= 1712 and curStep < 1732 then -- patch
		setProperty('camFollow.x', 867.5)
		setProperty('camFollow.y', 545)
		setProperty('newpoint.x', 867.5)
		setProperty('newpoint.y', 545)
		setProperty('defaultCamZoom', 0.9)
		cancelTween('jerk >:')
		lockcam = false
	end
end

local num = -2
function opponentNoteHit(id, dir, nt, sus)
	if curStep < 128 then
		setProperty('defaultCamZoom', 0.9)
	end
	if getProperty('health') >= 0.0182 then
		addHealth(-0.0182)
	end
	if curStep >= 1072 and curStep < 1174 then
		createShadow()
	end
	if curStep >= 1295 and curStep <= 1308 and not sus then
		runTimer('doublehit', 0.01, 40)
	end
	if nt == 'Alt Animation' then
		cancelTween('glow')
		cancelTween('glow')
		lockcam = false
		setProperty('camZooming', true)
		setProperty('cameraSpeed', 1)
		setProperty('defaultCamZoom', 0.7)
		--doTweenZoom('sighs sexily', 
		makeAnimatedLuaSprite('evenmoresparkles', 'sparkles', getProperty('sparkles.x'), getProperty('sparkles.y') - 20)
		addAnimationByPrefix('evenmoresparkles', 'sparkle 2: sparkle harder', 'cool sparkles0', 16, true)
		playAnim('evenmoresparkles', 'sparkle 2: sparkle harder', true)
		addLuaSprite('evenmoresparkles', true)
	end
	if sus and (curStep >= 1160 and curStep < 1167 or curStep >= 1377 and curStep < 1390) then
		setProperty('dad.animation.curAnim.curFrame', getProperty('dad.animation.curAnim.curFrame') + 1)
	end
end



-- 626362
function onStepHit()
	if stepHitFuncs[curStep] then 
		stepHitFuncs[curStep]() -- Executes function at curStep in stepHitFuncs
	end
	
	if curStep >= 1072 and curStep < 1174 and not lowQuality then
		createShadow('dad', curStep > 1168 and true)
	end
	-- DEBUGGING, DO IGNORE.
	--debugPrint('X: ', getProperty('camFollow.x'))
	--debugPrint(getProperty('camFollow.y'))
	--debugPrint('X :', getProperty('newpoint.x'))
	--debugPrint(getProperty('newpoint.y'))
end

function onEvent(n, v1, v2)
	if n == 'Change Character' then
		if v2 == 'solid-mad' then
			setPropertyFromClass('GameOverSubstate', 'characterName', 'solid-mad-dead'); --Character json file for the death animation
			setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'fnf_loss_sfx_mad'); --put in mods/sounds/
		elseif v2 == 'solid-guitar' then
			setPropertyFromClass('GameOverSubstate', 'characterName', 'solid-guitar-dead'); --Character json file for the death animation
			setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'fnf_loss_sfx_guitar'); --put in mods/sounds/
		elseif v2 == 'liquid' then
			setProperty('dad.color', getProperty('gf.color'))
		elseif v2 == 'liquid-guitar' then
			triggerEvent('Play Animation', 'hey', 'Dad')
		end
	elseif n == 'Play Animation' then
		if v1 == 'no' then
			lockcam = true
			setProperty('camFollow.x', 867.5)
			makeLuaSprite('newpoint', nil, getProperty('camFollow.x'), 545)
			makeLuaSprite('newal', nil, 0.01, getProperty('camFollow.y'))
			makeLuaSprite('newcl', nil, 1, 1)
			doTweenX('newpoint', 'newpoint', getProperty('newpoint.x') + 150, (stepCrochet / 1000) * 16, 'quadOut')
			setProperty('camZooming', false)
			doTweenZoom('noyoudont teehee', 'camGame', 1.4, (stepCrochet / 1000) * 16, 'quadIn')
		elseif v1 == 'hurt' then
			triggerEvent('Add Camera Zoom')
			lockcam = false
			setProperty('camZooming', true)
			playAnim('micthrow', 'hit', false)
		end
	end
end

-- To anybody reading: Always convert your if stacks to tables, looks SOOOOO much cleaner (equavelent to haxe switch statements) - Kevin Kuntz

--if getProperty('boyfriend.animation.curAnim.name') == 'no' or curStep >= 880 and curStep < 896 or curStep >= 1072 and curStep < 1167 or curStep > 1174 and curStep < 1184 or curStep >= 1696 and curStep < 1724 then

stepHitFuncs = {
	[783] = function()
		setProperty('camZooming', true)
		lockcam = false;
	end,
	
	[871] = function()
		setProperty('newpoint.x', getProperty('camFollow.x'))
		setProperty('newpoint.y', getProperty('camFollow.y'))
		lockcam = true
		doTweenX('newpoint', 'newpoint', getProperty('newpoint.x') + 150, (stepCrochet / 1000) * 24, 'sineOut')
		doTweenY('newpointY', 'newpoint', getProperty('newpoint.y') + 100, (stepCrochet / 1000) * 24, 'sineIn')
		doTweenZoom('backup', 'camGame', 0.7, (stepCrochet / 1000) * 20, 'quintIn')
	end,
	
	[880] = function()
		setProperty('newpoint.x', getProperty('camFollow.x'))
		setProperty('newpoint.y', getProperty('camFollow.y'))
		--doTweenX('newpoint', 'newpoint', getProperty('newpoint.x') + 150, (stepCrochet / 1000) * 15, 'sineOut')
		--doTweenY('newpointY', 'newpoint', getProperty('newpoint.y') + 100, (stepCrochet / 1000) * 15, 'sineIn')
		--doTweenY('newpoint', 'newpoint', 545, (stepCrochet / 1000) * 15, 'quadOut')
		doTweenZoom('backup', 'camGame', 0.7, (stepCrochet / 1000) * 15, 'quadIn')
	end,
	
	[1072] = function()
		makeLuaSprite('redmenace', 'liquidred', -605, -190)
		setScrollFactor('redmenace', 0.9, 0.9)
		setProperty('redmenace.alpha', 0)
		addLuaSprite('redmenace', false)
		doTweenAlpha('redmenace', 'redmenace', 1, ((stepCrochet / 1000) * 16) * 6 / 2, 'quadIn')
		lockcam = true
		setProperty('newpoint.x', getProperty('camFollow.x'))
		setProperty('newpoint.y', getProperty('camFollow.y'))
		doTweenZoom('popoff', 'camGame', 1.4, ((stepCrochet / 1000) * 16) * 6, 'quadIn')
		doTweenX('newpoint', 'newpoint', getProperty('newpoint.x') - 100, ((stepCrochet / 1000) * 16) * 6, 'quadOut')
		doTweenX('newal', 'newal', getRandomFloat(0.8, 1), ((stepCrochet / 1000) * 16) * 6, 'linear')
		doTweenColor('newcl', 'newcl', '626362', ((stepCrochet / 1000) * 16) * 6, 'linear')
		setProperty('camZooming', false)
	end,
	
	[1150] = function()
		cancelTween('newpoint')
		setProperty('newpoint.x', 867.5 + 150)
		setProperty('newpoint.y', 545)
		setProperty('cameraSpeed', 2)
	end,
	
	[1156] = function()
		setProperty('newpoint.x', 408)
		setProperty('newpoint.y', 326.5)
	end,
	
	[1168] = function()
		cancelTween('glow')
		cancelTween('glow')
		setProperty('redmenace.alpha', 1)
		doTweenAlpha('byemenace', 'redmenace', 0, 0.7, 'quadOut')
		doTweenColor('newcl', 'newcl', 'FFFFFF', 0.6, 'quadOut')
	end,
	
	[1172] = function()
		setProperty('dad.animation.paused', true)
		setProperty('dad.specialAnim', true)
	end,
	
	[1174] = function()
		setProperty('newpoint.x', getProperty('camFollow.x'))
		setProperty('newpoint.y', getProperty('camFollow.y'))
		setProperty('defaultCamZoom', 0.9)
	end,
	
	[1696] = function()
		setProperty('newpoint.x', 867.5)
		setProperty('newpoint.y', 545)
	end,

	[1184] = function()
		setProperty('dad.animation.curAnim.paused', false)
		setProperty('camZooming', true)
		removeLuaSprite('evenmoresparkles', true)
	end,
	
	[1710] = function()
		lockcam = true
		doTweenX('newpoint', 'newpoint', getProperty('newpoint.x') + 200, (stepCrochet / 1000) * (16 - 2), 'quadInOut')
		doTweenZoom('jerk >:', 'camGame', 1.5, (stepCrochet / 1000) * (16 - 2), 'quadIn')
	end,
	
	[1724] = function()
		setProperty('newpoint.x', 867.5)
		setProperty('newpoint.y', 545)
	end,
	
}

local shadowTag = 'shadow'
local shadowCount = 0
local shadowAlpha = 0.1
function createShadow(char, strong)
	char = getCharacter(char)
	
	if (shadowCount > 999) then shadowCount = 0 end
	local tag = shadowTag .. char .. shadowCount
	
	local props = getProperties(char, {
		image = 'imageFile',
		frame = 'animation.frameName',
		x = 'x',
		y = 'y',
		scaleX = 'scale.x',
		scaleY = 'scale.y',
		offsetX = 'offset.x',
		offsetY = 'offset.y',
		flipX = 'flipX'
	})
	
	--local Ctable = {'000000', 'FFFFFF', '696969', '626362', '9E9E9E'}
	local wackyCtable = {'E0CE5D', 'E0B05D', 'E0835D', 'CFE05D', '9E9E9E'}
	
	makeAnimatedLuaSprite(tag, props.image, props.x, props.y)
	addAnimationByPrefix(tag, 'stuff', props.frame, 0, false)
	scaleObject(tag, props.scaleX, props.scaleY, false)
	setProperty(tag .. '.flipX', props.flipX)
	offsetObject(tag, props.offsetX, props.offsetY)
	setProperty(tag .. '.alpha', shadowAlpha)
	setBlendMode(tag, 'add')
	setProperty(tag .. '.color', getColorFromHex(wackyCtable[math.random(1, 5)]))
	
	addLuaSprite(tag, false)
	setObjectOrder(tag, getObjectOrder(char .. 'Group') - 1)
	
	if strong then
		doTweenY('YAx' .. tag, tag, props.y - 500, 1.5, 'quadOut')
		doTweenAlpha('Ang' .. tag, tag, 0, 1, 'quadIn')
		doTweenColor('COL' .. tag, tag, 'FFFFFF', 1.3, 'linear')
	else
		doTweenY('YAx' .. tag, tag, props.y - 300, 0.85, 'quadIn')
		doTweenAlpha('Ang' .. tag, tag, 0, 0.8, 'quadOut')
	end
	
	shadowCount = shadowCount + 1
end

function offsetObject(obj, x, y)
	setProperty(obj .. '.offset.x', x)
	setProperty(obj .. '.offset.y', y)
end

function getProperties(par, props)
	local t = {}
	for i, v in pairs(props) do
		local ind = type(i) == 'string' and i or v
		t[ind] = getProperty(par .. '.' .. v)
	end
	return t
end

function getCharacter(char)
	if (type(char) ~= 'string') then return 'dad' end; char = char:lower()
	if (char:sub(1, 2) == 'bf' or char:sub(1, 3) == 'boy') then return 'boyfriend'
	elseif (char:sub(1, 2) == 'gf' or char:sub(1, 4) == 'girl') then return 'gf' end
	return 'dad'
end

function onTimerCompleted(t, l, ll)
	if t == 'doublehit' then
		if l % 2 == 0 then
			playAnim('dad', 'singLEFT', true)
		else
			playAnim('dad', 'singRIGHT', true)
		end
	end
	if t == 'noyoudont teehee' or t == 'jerk >:' then
		setProperty('camZooming', true)
		doTweenZoom('backup', 'camGame', 0.7, 0.3, 'quadOut')
	end
end

function onMoveCamera()
	if curStep >= 1160 and curStep <= 1174 then
		setProperty('camFollow.y', getProperty('camFollow.y') + 100)
	end
end

function onTweenCompleted(t)
	if (t:sub(4, 3 + #shadowTag) == shadowTag) then
		local spr = t:sub(4, #t)
		removeLuaSprite(spr, true)
	end
	if t == 'redmenace' then
		doTweenAlpha('glow', 'redmenace', getRandomFloat(0.7, 1), 0.4, 'linear')
	elseif t == 'glow'  then
		if curStep < 1168 then
			if getProperty('redmenace.alpha') < 1 then 
				doTweenAlpha('glow', 'redmenace', 1, 0.6, 'linear') else doTweenAlpha('glow', 'redmenace', getRandomFloat(0.4, 0.7), 0.6, 'linear') 
			end
		else 
			cancelTween('glow') 
		end
	elseif t == 'byemenace' then
		removeLuaSprite('redmenace', true)
	end
end

function onUpdatePost(el)
	shadowAlpha = getProperty('newal.x')
	if getProperty('dad.animation.curAnim.name') == 'singDOWN-alt' and getProperty('dad.animation.curAnim.finished') and curStep < 1184 then
		setProperty('dad.animation.paused', true)
	end
	--local camZoomCons = curStep >= 1072 and curStep < 1168 or curStep > 1174 and curStep < 1184 or curStep >= 1696 and curStep < 1724 -- MUCH easier to edit (doesnt work)
	if lockcam then
		setProperty('camZooming', false)
		setProperty('camFollow.x', getProperty('newpoint.x'))
		setProperty('camFollow.y', getProperty('newpoint.y'))
	end
	for i = 0, getProperty('members.length') - 1 do -- THATS RIGHT MOTHERFUCKER WERE USING DEFAULT STAGE
		if curStep >= 1072 and string.find(getPropertyFromGroup('members', i, 'graphic.key'), 'shared:assets/shared/images/stage') and getProperty('newcl.color') ~= getColorFromHex('FFFFFF') then
			setPropertyFromGroup('members', i, 'color', getProperty('newcl.color'))
		end
	end
	if getProperty('boyfriend.curCharacter') == 'solid' and getProperty('boyfriend.animation.curAnim.name') == 'transition' then
		if getProperty('boyfriend.animation.curAnim.curFrame') >= 9 and getProperty('micthrow.active') == 'micthrow.active' then
			makeAnimatedLuaSprite('micthrow', 'micthrow', defaultBoyfriendX * -0.75, defaultBoyfriendY * 1.55)
			addAnimationByPrefix('micthrow', 'micthrow anim', 'micthrow anim', 24, false)
			addAnimationByPrefix('micthrow', 'hit', 'micthrow hit', 24, false)
			addLuaSprite('micthrow', true)
			playAnim('micthrow', 'micthrow anim', false)
		end
		if getProperty('boyfriend.animation.curAnim.finished') then
			triggerEvent('Change Character', '0', 'solid-guitar')
			triggerEvent('Play Animation', 'hey', 'BF')
		end
	end
	if getProperty('boyfriend.curCharacter') == 'solid-mad' and getProperty('boyfriend.animation.curAnim.name') == 'transition' and getProperty('boyfriend.animation.curAnim.curFrame') >= 9 and getProperty('dad.animation.curAnim.name') ~= 'shocked' then
		triggerEvent('Play Animation', 'shocked', 'Dad')
		triggerEvent('Play Animation', 'shocked', 'GF')
	end
	if getProperty('dad.animation.curAnim.name') == 'hurt' and getProperty('dad.animation.curAnim.curFrame') > 8 then
		removeLuaSprite('micthrow', true)
	end
end