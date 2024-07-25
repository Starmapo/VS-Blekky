package substates;

import flixel.addons.display.FlxTiledSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.transition.FlxTransitionableState;

import states.StoryMenuState;
import states.FreeplayState;
import options.OptionsState;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<FlxSprite>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['resume', 'restart', 'options', 'exit'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;

	public static var songName:String = null;

	var sheet:FlxAtlasFrames;
	var bgCamera:FlxCamera;
	var greenCamera:FlxCamera;
	var scrollGreen:FlxTiledSprite;

	override function create()
	{
		/*if(PlayState.chartingMode)
		{
			menuItemsOG.insert(2, 'Leave Charting Mode');
			
			var num:Int = 0;
			if(!PlayState.instance.startingSong)
			{
				num = 1;
				menuItemsOG.insert(3, 'Skip Time');
			}
			menuItemsOG.insert(3 + num, 'End Song');
			menuItemsOG.insert(4 + num, 'Toggle Practice Mode');
			menuItemsOG.insert(5 + num, 'Toggle Botplay');
		}*/
		menuItems = menuItemsOG;
		sheet = Paths.getSparrowAtlas('pausemenu/sheet');

		pauseMusic = new FlxSound();
		try
		{
			var pauseSong:String = getPauseSong();
			if(pauseSong != null) pauseMusic.loadEmbedded(Paths.music(pauseSong), true, true);
		}
		catch(e:Dynamic) {}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		bgCamera = new FlxCamera();
		bgCamera.bgColor.alpha = 0;
		FlxG.cameras.add(bgCamera, false);

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0;
		bg.scrollFactor.set();
		bg.camera = bgCamera;
		add(bg);

		greenCamera = new FlxCamera(0, 0, Std.int(FlxG.width * 0.25));
		greenCamera.bgColor.alpha = 0;
		FlxG.cameras.add(greenCamera, false);

		scrollGreen = new FlxTiledSprite(Paths.image("mainmenu/scrollGreen"), greenCamera.width, greenCamera.height);
		scrollGreen.scrollFactor.set();
		scrollGreen.camera = greenCamera;
		scrollGreen.alpha = 0.5;
		add(scrollGreen);

		FlxG.cameras.remove(PlayState.instance.camOther, false);
		FlxG.cameras.add(PlayState.instance.camOther, false);

		var levelInfoBG = new FlxSprite(20, 15 - 86 - 15);
		levelInfoBG.scrollFactor.set();
		levelInfoBG.frames = sheet;
		levelInfoBG.animation.addByPrefix('idle', 'songName', 0);
		levelInfoBG.animation.play('idle');
		levelInfoBG.updateHitbox();
		add(levelInfoBG);

		var levelInfo:FlxText = new FlxText(20, 15, 0, PlayState.SONG.song, 64);
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("AnnyantRoman.ttf"), 64);
		levelInfo.updateHitbox();
		add(levelInfo);

		var blueballedY = 15 + 105;
		var blueballedBG = new FlxSprite(20, blueballedY - (85 + 25) * 0.75);
		blueballedBG.scrollFactor.set();
		blueballedBG.frames = sheet;
		blueballedBG.animation.addByPrefix('idle', 'deathCounter', 0);
		blueballedBG.animation.play('idle');
		blueballedBG.scale.y = 0.75;
		blueballedBG.updateHitbox();
		add(blueballedBG);

		var blueballedTxt:FlxText = new FlxText(20, blueballedY, 0, "Blueballed: " + PlayState.deathCounter, 32);
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('AnnyantRoman.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 101, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('AnnyantRoman.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font('AnnyantRoman.ttf'), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		blueballedBG.alpha = blueballedTxt.alpha = 0;
		levelInfoBG.alpha = levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelInfoBG.x = levelInfo.x - 91 - 68;
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);
		blueballedBG.x = blueballedTxt.x - 128 - 20;

		var diff = FlxG.width - (levelInfoBG.x + 91 + 412);
		if (diff > 0) {
			levelInfoBG.setGraphicSize(levelInfoBG.width + diff, levelInfoBG.height);
			levelInfoBG.updateHitbox();
		}

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelInfoBG, {alpha: 1, y: levelInfoBG.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(blueballedBG, {alpha: 1, y: blueballedBG.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<FlxSprite>();
		add(grpMenuShit);

		regenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		super.create();
	}
	
	function getPauseSong()
	{
		var formattedSongName:String = (songName != null ? Paths.formatToSongPath(songName) : '');
		var formattedPauseMusic:String = Paths.formatToSongPath(ClientPrefs.data.pauseMusic);
		if(formattedSongName == 'none' || (formattedSongName != 'none' && formattedPauseMusic == 'none')) return null;

		return (formattedSongName != '') ? formattedSongName : formattedPauseMusic;
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		if(controls.BACK)
		{
			close();
			return;
		}

		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		var daSelected:String = menuItems[curSelected];

		if (controls.ACCEPT && (cantUnpause <= 0 || !controls.controllerMode))
		{
			switch (daSelected)
			{
				case "resume":
					close();
				case "restart":
					restartSong();
				case 'options':
					PlayState.instance.paused = true; // For lua
					PlayState.instance.vocals.volume = 0;
					MusicBeatState.switchState(new OptionsState());
					if(ClientPrefs.data.pauseMusic != 'None')
					{
						FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), pauseMusic.volume);
						FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
						FlxG.sound.music.time = pauseMusic.time;
					}
					OptionsState.onPlayState = true;
				case "exit":
					#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					Mods.loadTopMod();
					if(PlayState.isStoryMode)
						MusicBeatState.switchState(new StoryMenuState());
					else 
						MusicBeatState.switchState(new FreeplayState());

					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
					FlxG.camera.followLerp = 0;
			}
		}

		scrollGreen.scrollY = scrollGreen.scrollX += elapsed * 120;
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
		}
		MusicBeatState.resetState();
	}

	override function destroy()
	{
		pauseMusic.destroy();
		FlxG.cameras.remove(bgCamera);
		FlxG.cameras.remove(greenCamera);

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			if (bullShit == curSelected) {
				item.animation.play('selected');
			} else {
				item.animation.play('idle');
			}

			bullShit++;
		}
	}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length) {
			var item = new FlxSprite(0, -33 + (i * 164));
			item.frames = sheet;
			item.animation.addByPrefix('idle', 'item_' + menuItems[i], 0);
			item.animation.addByPrefix('selected', 'itemSelected_' + menuItems[i], 0);
			item.animation.play('idle');
			item.updateHitbox();
			grpMenuShit.add(item);
		}
		curSelected = 0;
		changeSelection();
	}
}
