function onCreatePost()
	defaultX = getProperty('dad.x') + 10
	defaultY = getProperty('dad.y')
	
	makeAnimatedLuaSprite('sparkles', 'sparkles', defaultX, defaultY)
	setProperty('sparkles.offset.x', getProperty('dad.offset.x'))
	setProperty('sparkles.offset.y', getProperty('dad.offset.y'))
	addAnimationByPrefix('sparkles', 'sparkle', 'cool sparkles0', 24, true)
	addAnimationByPrefix('sparkles', 'sparkleH', 'cool sparkles hey', 24, true)
	playAnim('sparkles', 'sparkle', true)
	addLuaSprite('sparkles', true)
end

function onUpdatePost()
	setProperty('sparkles.color', getProperty('dad.color'))
	if string.find(getProperty('dad.animation.curAnim.name'), 'hey') and getProperty('sparkles.animation.curAnim.name') ~= 'sparkleH' then
		playAnim('sparkles', 'sparkleH', true)
		setProperty('sparkles.x', defaultX)
		setProperty('sparkles.y', defaultY)
	elseif string.find(getProperty('dad.animation.curAnim.name'), 'idle') then
		if getProperty('sparkles.animation.curAnim.name') ~= 'sparkle' then
			playAnim('sparkles', 'sparkle', true) 
		end
		if getProperty('dad.animation.curAnim.curFrame') == 0 then
			setProperty('sparkles.x', defaultX)
			setProperty('sparkles.y', defaultY)
		end
	elseif string.find(getProperty('dad.animation.curAnim.name'), 'hurt' or 'shocked') then
		setProperty('sparkles.visible', false)
	else
		setProperty('sparkles.visible', true)
	end
	if getProperty('dad.curCharacter') == 'liquid-guitar' and getProperty('dad.animation.curAnim.name') == 'transition' and getProperty('dad.animation.curAnim.finished') then
		triggerEvent("Change Character", '1', 'liquid')
	end
end

function opponentNoteHit(id, dir)
	local X = dir == 0 and defaultX - 75 or dir == 1 and defaultX + 100 or dir == 2 and defaultX - 25 or dir == 3 and defaultX + 50
	local Y = dir == 1 and defaultY + 50 or dir == 2 and defaultY - 50 or (dir == 0 or dir == 3) and defaultY
	setProperty('sparkles.x', X)
	setProperty('sparkles.y', Y)
end