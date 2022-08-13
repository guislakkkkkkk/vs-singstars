package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

class MenuItem extends FlxSprite
{
	public var targetX:Float = 0;

	public function new(x:Float, y:Float, weekName:String = '')
	{
		super(x, y);
		loadGraphic(Paths.image('storymenu/' + weekName));
		//trace('Test added: ' + WeekData.getWeekNumber(weekNum) + ' (' + weekNum + ')');
		antialiasing = ClientPrefs.globalAntialiasing;
		if (weekName == 'locked') alpha = 0;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		x = FlxMath.lerp(x, (targetX * 120) + 480, CoolUtil.boundTo(elapsed * 15.2, 0, 1));
	}
}
