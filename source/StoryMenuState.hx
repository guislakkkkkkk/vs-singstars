package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxGridOverlay;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.math.FlxPoint;
import flixel.text.FlxBitmapText;
import flixel.addons.plugin.FlxScrollingText;
import flixel.util.FlxGradient;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flash.geom.Rectangle;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.graphics.FlxGraphic;
import flixel.addons.display.FlxBackdrop;
import WeekData;
import openfl.Assets;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	private static var lastDifficultyName:String = '';
	var curDifficulty:Int = 1;

	var txtWeekDesc:FlxSprite;
	var bgYellow:FlxBackdrop;
	var bgCol:FlxSprite;
	var black:FlxSprite; // im tired
	var blackBottom:FlxSprite;

	private static var curWeek:Int = 0;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var upArrow:FlxSprite;
	var downArrow:FlxSprite;
	
	var strikethrough:FlxSprite;
	var VS:FlxSprite;
	var oppName:FlxSprite;
	var playerName:FlxSprite;
	var gradbg:FlxSprite;

	var loadedWeeks:Array<WeekData> = [];

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(0, FlxG.height / 1.055, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);
		
		FlxG.plugins.add(new FlxScrollingText());
		
		var textBytes = Assets.getText("assets/fonts/VCRF.fnt");
		var XMLData = Xml.parse(textBytes);
		var font = FlxBitmapFont.fromAngelCode("assets/fonts/VCRF_0.png", XMLData);
		
		var tex = new FlxBitmapText(font);
		
		txtWeekDesc = FlxScrollingText.add(tex, new Rectangle(0, 0, FlxG.width * 5, 69), 2, 0, 'Uh oh');
		txtWeekDesc.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		//var bgYellow:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 386, 0xFFF9CF51);
		//var bgYellow:FlxSprite = new FlxSprite(0, 56).makeGraphic(1344, 669, FlxColor.gradient[0xFFF5400, 0xFFFD200, 2]);
		//var bgYellow:FlxSprite = new FlxSprite(0, 56).loadGraphic(Paths.image('overlay'));
		
		gradbg = new FlxSprite(0, 56).makeGraphic(FlxG.width, 386, 0xFFF9CF51); // bad way to do this, should use an actual FlxGradient but im not good at coding :P
		black = new FlxSprite(0, 56).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		black.alpha = 0;
		FlxGradient.overlayGradientOnFlxSprite(gradbg, 1344, 669, [0xFFFF5400,  0xFFFFD200]);
		bgCol = new FlxSprite(0, 56);
		bgCol.alpha = 0.55;
		bgCol.blend = HARDLIGHT;
		
		bgYellow = new FlxBackdrop(Paths.image('pattern'), 1, 0, true, false);
		
		bgYellow.y = 56;

		bgYellow.setGraphicSize(Std.int(gradbg.width), Std.int(gradbg.height));
		
		
		add(gradbg);
		add(bgYellow);
		add(bgCol);
		add(black);
		
		Conductor.changeBPM(101);
		
		//var backdrops:FlxBackdrop = new FlxBackdrop(Paths.image('backdrop'), 0.2, 0.2, true, true);
		
		//createGradientFlxSprite(width:Int, height:Int, colors:Array<FlxColor>, chunkSize:UInt = 1, rotation:Int = 90, interpolate:Bool = true):FlxSprite
		
		grpWeekText = new FlxTypedGroup<MenuItem>();
		
		
		strikethrough = new FlxSprite(0, 0);
		strikethrough.frames = Paths.getSparrowAtlas('storyassets/strikethrough');
		strikethrough.scale.set(0.9, 1);
		strikethrough.screenCenter();
		//strikethrough.x += 100;
		strikethrough.animation.addByPrefix('thing', "thing", 24, true);
		strikethrough.animation.play('thing');
		strikethrough.antialiasing = ClientPrefs.globalAntialiasing;
		add(strikethrough);
		
		VS = new FlxSprite(strikethrough.x, strikethrough.y * 5);
		VS.frames = Paths.getSparrowAtlas('storyassets/vs');
		VS.animation.addByPrefix('vsd', "vsd", 24, true);
		VS.animation.addByPrefix('confirm', "vsfade", 24, false);
		VS.animation.play('vsd');
		VS.antialiasing = ClientPrefs.globalAntialiasing;
		add(VS);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 69, FlxColor.BLACK);
		add(blackBarThingie);
		
		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		
		
		
		blackBottom = new FlxSprite(0, 442).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		
		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		
		add(grpWeekCharacters);
		
		add(blackBottom);
		add(grpLocks);
		add(grpWeekText);
		
		var num:Int = 0;
		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
			if(!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);
				var weekThing:MenuItem = new MenuItem(0, bgYellow.y + 396, WeekData.weeksList[i]);
				weekThing.scale.x = 0.8;
				weekThing.scale.y = 0.8;
				weekThing.y += ((weekThing.height + 20) * num);
				
				weekThing.targetY = num;
				grpWeekText.add(weekThing);
				
				weekThing.screenCenter(X);
				weekThing.antialiasing = ClientPrefs.globalAntialiasing;
				// weekThing.updateHitbox();

				// Needs an offset thingie
				if (isLocked)
				{
					var lock:FlxSprite = new FlxSprite(weekThing.x - 20);
					lock.frames = ui_tex;
					lock.animation.addByPrefix('lock', 'lock');
					lock.animation.play('lock');
					lock.ID = i;
					lock.antialiasing = ClientPrefs.globalAntialiasing;
					grpLocks.add(lock);
				}
				num++;
			}
		}

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);
		var charArray:Array<String> = loadedWeeks[0].weekCharacters;
		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, charArray[char]);
			//weekCharacterThing.y += 70;
			weekCharacterThing.y += 70;
			grpWeekCharacters.add(weekCharacterThing);
		}

		upArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y);
		upArrow.y /= 1.025;
		upArrow.screenCenter(X);
		upArrow.x -= 40;
		upArrow.frames = ui_tex;
		//animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
		upArrow.animation.addByIndices('idle', "arrow up", [0], "", 24, false);
		upArrow.animation.addByIndices('press', "arrow up", [1], "", 24, false);
		upArrow.animation.play('idle');
		upArrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(upArrow);

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));

		downArrow = new FlxSprite(upArrow.x, upArrow.y * 1.5);
		downArrow.frames = ui_tex;
		downArrow.animation.addByIndices('idle', 'arrow down', [0], "", 24, false);
		downArrow.animation.addByIndices('press', "arrow down", [1], "", 24, false);
		downArrow.animation.play('idle');
		downArrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(downArrow);

		add(scoreText);
		add(txtWeekDesc);
		
		oppName = new FlxSprite(grpWeekCharacters.members[0].x / 3.5, grpWeekCharacters.members[0].y * 5.5);
		oppName.antialiasing = ClientPrefs.globalAntialiasing;
		add(oppName);
		
		playerName = new FlxSprite(grpWeekCharacters.members[1].x * 1.6, grpWeekCharacters.members[1].y * 5.5);
		playerName.antialiasing = ClientPrefs.globalAntialiasing;
		add(playerName);

		changeWeek();

		super.create();
	}
	
	
	
	override public function destroy():Void
	{
		//	Important! Clear out the plugin otherwise it'll crash when changing state
		FlxScrollingText.clear();
		
		super.destroy();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}
	
		
	

	override function update(elapsed:Float)
	{
		if (!stopspamming) bgYellow.x -= (90 * 2) * elapsed;
		
		
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		scoreText.text = "WEEK SCORE:" + lerpScore;

		// FlxG.watch.addQuick('font', scoreText.font);
		if (VS.animation.curAnim.finished) VS.alpha = 0;

		if (!movedBack && !selectedWeek)
		{
			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;
			if (upP)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (downP)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeWeek(-FlxG.mouse.wheel);
				changeDifficulty();
			}

			if (controls.UI_DOWN)
				downArrow.animation.play('press');
			else
				downArrow.animation.play('idle');

			if (controls.UI_UP)
				upArrow.animation.play('press');
			else
				upArrow.animation.play('idle');

			if (controls.UI_RIGHT_P)
				changeDifficulty(1);
			else if (controls.UI_LEFT_P)
				changeDifficulty(-1);
			else if (upP || downP)
				changeDifficulty();

			if(FlxG.keys.justPressed.CONTROL)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				//FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}
		
		//.clipRect = calcFromRect(actualSpr, new FlxRect(rectSpr.x, rectSpr.y, rectSpr.width, rectSpr.height))
		
		for (item in grpWeekText.members)
		{
			item.clipRect = calcFromRect(item, new FlxRect(blackBottom.x, blackBottom.y, blackBottom.width, blackBottom.height));
		}
		
		super.update(elapsed);

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y * 1.1;
			lock.visible = curWeek == 1;
		});
	}
	
	//thx eyedalehim
	private function calcFromRect(s:FlxSprite, r:FlxRect)
    {
        return new FlxRect(r.x - s.x, r.y - s.y, r.width, r.height);
    }

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(loadedWeeks[curWeek].fileName) || loadedWeeks[curWeek].fileName != 'locked')
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();

				var bf:MenuCharacter = grpWeekCharacters.members[1];
				var dad:MenuCharacter = grpWeekCharacters.members[0];
				grpWeekCharacters.members[0].animation.play('confirm');
				//grpWeekCharacters.members[0].offset.x == 46;
				//grpWeekCharacters.members[0].offset.y == 51.5;
				grpWeekCharacters.members[0].offset.set(170, 151);
				VS.animation.play('confirm');
				VS.centerOffsets();
				VS.centerOrigin();
				FlxTween.tween(strikethrough, {'scale.x': 0}, 0.15);
				FlxTween.tween(oppName, {alpha: 0}, 0.15);
				FlxTween.tween(playerName, {alpha: 0}, 0.15);
				FlxTween.tween(bgCol, {alpha: 0}, 0.13);
				FlxTween.tween(black, {alpha: 0.66}, 0.15);
				FlxTween.color(grpWeekCharacters.members[1], 0.15, 0xffffff, 0xFF000000);
				stopspamming = true;
			}

			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
			if(diffic == null) diffic = '';

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
		} else {
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		WeekData.setDirectoryFromWeek(loadedWeeks[curWeek]);

		var diff:String = CoolUtil.difficulties[curDifficulty];
		var newImage:FlxGraphic = Paths.image('menudifficulties/' + Paths.formatToSongPath(diff));
		//trace(Paths.currentModDirectory + ', menudifficulties/' + Paths.formatToSongPath(diff));
		
		lastDifficultyName = diff;

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var firstTime = true;

	function changeWeek(change:Int = 0):Void
	{
		
		curWeek += change;

		if (curWeek >= loadedWeeks.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = loadedWeeks.length - 1;

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);
		
		var weekArray:Array<String> = leWeek.weekCharacters;
		
		if (weekArray[0] != grpWeekCharacters.members[0].character) {
			FlxTween.tween(bgCol, {alpha: 0}, 0.2, {onComplete: function(twn:FlxTween)
			{
				bgCol.makeGraphic(Std.int(636.05), FlxG.height, FlxColor.fromRGB(leWeek.overlayColor[0], leWeek.overlayColor[1], leWeek.overlayColor[3]));
				FlxTween.tween(bgCol, {alpha: 0.55}, 0.2);
			}});
		} else {
			bgCol.makeGraphic(Std.int(636.05), FlxG.height, FlxColor.fromRGB(leWeek.overlayColor[0], leWeek.overlayColor[1], leWeek.overlayColor[3]));
		}

		var leName:String = leWeek.description;
		FlxScrollingText.addText(txtWeekDesc, leName.toUpperCase(), true);

		var bullShit:Int = 0;

		var unlocked:Bool = !weekIsLocked(leWeek.fileName) || leWeek.fileName != 'locked';
		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && unlocked)
				item.alpha = 1;
			else
				item.alpha = 0;
			item.targetY = bullShit - curWeek;
			bullShit++;
		}
		PlayState.storyWeek = curWeek;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
		if (!firstTime) {
			updateText(); 
		} else {
			new FlxTimer().start(0.25, function(tmr:FlxTimer) {
				updateText();
			});
		}
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	var chrisTimer:FlxTimer = null;
	var charTween:FlxTween = null;
	function updateText()
	{
		var weekArray:Array<String> = loadedWeeks[curWeek].weekCharacters;
		for (i in 0...grpWeekCharacters.length) {
			if (!firstTime && weekArray[0] != grpWeekCharacters.members[0].character) {
				//grpWeekCharacters.members[0].y -= grpWeekCharacters.members[0].frameHeight;
				//charTween = 
				//FlxTween.color(grpWeekCharacters.members[0], 0.15, 0xffffff, 0xFF000000);
				FlxTween.tween(grpWeekCharacters.members[0], {y: grpWeekCharacters.members[0].y + grpWeekCharacters.members[0].frameHeight}, 0.23, {onComplete: function(twn:FlxTween)
				{
					grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
					FlxTween.tween(grpWeekCharacters.members[0], {y: 0 + 70}, 0.1, {
					onComplete: function(twn:FlxTween) {
					}});
					//FlxTween.color(grpWeekCharacters.members[0], 0.15, 0xFF000000, 0xffffff);
				}});
				
				FlxTween.tween(oppName, {x: oppName.x * -12}, 0.16, {onComplete: function(twn:FlxTween) {
					oppName.frames = Paths.getSparrowAtlas('storyassets/' + weekArray[0]);
					oppName.animation.addByPrefix('idle', weekArray[0] + ' name', 24, true);
					oppName.animation.play('idle', true);
					FlxTween.tween(oppName, {x: grpWeekCharacters.members[0].x / 3.5}, 0.15);
				}});	
			} else {
				grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
				oppName.frames = Paths.getSparrowAtlas('storyassets/' + weekArray[0]);
				oppName.animation.addByPrefix('idle', weekArray[0] + ' name', 24, true);
				oppName.animation.play('idle', true);
			}
			var bf:MenuCharacter = grpWeekCharacters.members[1];
			var dad:MenuCharacter = grpWeekCharacters.members[0];
			
			
			if (weekArray[0] == 'liquid') {
				if (chrisTimer != null) {
					chrisTimer.active = false;
					chrisTimer = null;
				}
				playerName.scale.x = 1;
				playerName.scale.y = 1;
				playerName.frames = Paths.getSparrowAtlas('storyassets/' + weekArray[1]);
				playerName.animation.addByPrefix('idle', weekArray[1] + ' name', 24, true);
				playerName.animation.play('idle', true);
			} else {
				playerName.centerOrigin();
				playerName.scale.x = 0.6;
				playerName.scale.y = 0.6;
				chrisTimer = new FlxTimer().start(0.085, function(tmr:FlxTimer) {
					playerName.frames = Paths.getSparrowAtlas('storyassets/chris');
					playerName.animation.addByPrefix('idle', 'chris name', 24, true);
					playerName.animation.play('idle', true);
					playerName.scale.x = 1.1;
					playerName.scale.y = 1.1;
					new FlxTimer().start(0.071, function(tmr:FlxTimer) {
						playerName.scale.x = 1;
						playerName.scale.y = 1;
					});
				});
				
			}
		}

		var leWeek:WeekData = loadedWeeks[curWeek];

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName, curDifficulty);
		#end
		firstTime = false;
	}
}
