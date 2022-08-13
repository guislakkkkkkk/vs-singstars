package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.util.FlxGradient;
import flash.geom.Rectangle;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxBackdrop;
import WeekData;
import openfl.Assets;
import flixel.addons.display.FlxGridOverlay;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story',
		'freeplay',
		'options',
		'credits',
		'quit'
	];
	
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;
	
	var backdro:FlxBackdrop;
	
	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		
		WeekData.setDirectoryFromWeek();
		WeekData.reloadWeekFiles(true);
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('mMBG'));
		bg.scrollFactor.set(0, 0);
		bg.scale.set(0.75, 0.75);
		bg.updateHitbox();
		bg.screenCenter();
		bg.y /= 2;
		bg.x /= 2;
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		
		backdro = new FlxBackdrop(Paths.image('titlegrid'), 0.4, 1, true, true);
		//backdro.scale.set(0.7, 0.7);
		backdro.y = 56 * 2;
		backdro.alpha = 0.27;
		backdro.color = 0xFF000000;
		add(backdro);
		
		var logo:FlxSprite = new FlxSprite(720, 10);
		logo.frames = Paths.getSparrowAtlas('singstarlogo');
		logo.animation.addByPrefix('idle', "logosmall", 24, true);
		logo.animation.play('idle');
		logo.centerOrigin();
		logo.scale.x = 0.6;
		logo.scale.y = 0.6;
		logo.scrollFactor.set(0, 0);
		logo.updateHitbox();
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		add(logo);
		
		
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 0.7;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		for (i in 0...optionShit.length)
		{
			var offset:Float = 218 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite((i * 350) + offset, i);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " static", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " selected", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			if (menuItem.ID <= 1) {
				menuItem.screenCenter(Y); 
			}
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, 0);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		backdro.x += (90 * 2) * elapsed;
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									/*case 'play':
										var songArray:Array<String> = [];
										var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[0]).songs;
										for (i in 0...leWeek.length) {
											songArray.push(leWeek[i][0]);
										}

										// Nevermind that's stupid lmao
										PlayState.storyPlaylist = songArray;
										PlayState.isStoryMode = true;
										
										CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
										
										var curDifficulty:Int = 2;
										var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
										
										if (diffic == null) {
											diffic = '';
											trace(diffic);
										}

										PlayState.storyDifficulty = curDifficulty;

										PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
										PlayState.campaignScore = 0;
										PlayState.campaignMisses = 0;
										{
											LoadingState.loadAndSwitchState(new PlayState(), true);
											FreeplayState.destroyFreeplayVocals();
										};*/
									case 'story':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
									case 'quit':
										Sys.exit(0);
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
		
		menuItems.forEach(function(spr:FlxSprite)
		{
			if (spr.ID <= 1) {
				spr.screenCenter(Y);
				spr.y += 50;
			} else {
				switch(spr.ID) {
					case 2:
						spr.y = 200;
					case 3:
						spr.y = 200 * 1.8;
						spr.x = 838 * 1;
					case 4:
						spr.x = 838 * 1.050;
						spr.y = 250 * 2;
				}	
			}
		});
	}
	

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}
