package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class DisclaimerState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	var smallText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnText = new FlxText(20, 0, FlxG.width,
			"NOTICE TO THE DENSE\n
			For that itty bitty 2.3% of people who think making a mod of CWC is somehow glorifying/supporting him, I'll spell it out.\n
			We're ripping on him. We don't condone the actions of the sole living mistake of God.", 32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
		
		smallText = new FlxText(20, 0, FlxG.width,
			"The fact that we even have to add this in is going to make me lose sleep - Saddam Hussein, disclaimer writer", 15);
		smallText.setFormat("VCR OSD Mono", 15, FlxColor.WHITE, CENTER);
		smallText.screenCenter(Y);
		smallText.y *= 1.5;
		add(smallText);
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				FlxG.save.data.seenDisclaimer = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
						onComplete: function (twn:FlxTween) {
							MusicBeatState.switchState(new TitleState());
						}
					});
				FlxTween.tween(smallText, {alpha: 0}, 1, {
						onComplete: function (twn:FlxTween) {
							MusicBeatState.switchState(new TitleState());
						}
					});
			}
		}
		super.update(elapsed);
	}
}
