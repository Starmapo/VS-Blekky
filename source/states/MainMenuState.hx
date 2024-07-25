package states;

import backend.Song;
import backend.Highscore;
import backend.WeekData;
import flixel.addons.display.FlxTiledSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import openfl.display.Sprite;
import options.OptionsState;
import states.editors.MasterEditorMenu;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = [
		'blekk',
		'nah',
		'intrude',
		'options'
	];

	var menuArt:FlxSprite;
	var scrollBlue:FlxTiledSprite;
	var scrollGreen:FlxTiledSprite;
	var greenCamera:FlxCamera;
	var mask:Sprite = new Sprite();

	override function create()
	{
		super.create();

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		updateMask();
		FlxG.game.addChild(mask);
		FlxG.game.mask = mask;

		var blueCamera = new FlxCamera();
		FlxG.cameras.add(blueCamera, false);

		scrollBlue = new FlxTiledSprite(Paths.image("mainmenu/scrollBlue"), blueCamera.width, blueCamera.height);
		scrollBlue.scrollFactor.set();
		scrollBlue.camera = blueCamera;
		add(scrollBlue);

		greenCamera = new FlxCamera(FlxG.width * 0.38, 0, Std.int(FlxG.width * 1.11), Std.int(FlxG.height * 1.47));
		greenCamera.bgColor.alpha = 0;
		greenCamera.angle = 24;
		FlxG.cameras.add(greenCamera, false);

		scrollGreen = new FlxTiledSprite(Paths.image("mainmenu/scrollGreen"), greenCamera.width, greenCamera.height);
		scrollGreen.scrollFactor.set();
		scrollGreen.camera = greenCamera;
		add(scrollGreen);

		var normalCamera = new FlxCamera();
		normalCamera.bgColor.alpha = 0;
		FlxG.cameras.add(normalCamera);
		FlxG.cameras.remove(FlxG.camera);
		FlxG.camera = normalCamera;

		menuArt = new FlxSprite();
		menuArt.antialiasing = ClientPrefs.data.antialiasing;
		menuArt.frames = Paths.getSparrowAtlas("mainmenu/art");
		for (option in optionShit)
			menuArt.animation.addByPrefix(option, option, 5);
		menuArt.scrollFactor.set();
		menuArt.screenCenter(Y);
		menuArt.x = 350 - (menuArt.width / 2);
		add(menuArt);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(900, 20 + (i * 180));
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.frames = Paths.getSparrowAtlas("mainmenu/items");
			menuItem.animation.addByPrefix('idle', "item_" + optionShit[i], 0);
			menuItem.animation.addByPrefix('selected', "itemSelected_" + optionShit[i], 0);
			menuItem.animation.play('idle');
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.updateHitbox();
			menuItem.x -= menuItem.width / 2;
		}

		var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);
		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

		/*FlxG.watch.add(this, "xScale");
		FlxG.watch.add(this, "widthScale");
		FlxG.watch.add(this, "heightScale");*/
	}

	var selectedSomethin:Bool = false;
	/*var xScale = 0.4;
	var widthScale = 1.3;
	var heightScale = 1.75;*/

	override function update(elapsed:Float)
	{
		/*if (FlxG.keys.justPressed.Q)
			greenCamera.x = FlxG.width * (xScale -= 0.01);
		if (FlxG.keys.justPressed.E)
			greenCamera.x = FlxG.width * (xScale += 0.01);
		if (FlxG.keys.justPressed.ONE)
			greenCamera.width = Std.int(FlxG.width * (widthScale -= 0.01));
		if (FlxG.keys.justPressed.TWO)
			greenCamera.width = Std.int(FlxG.width * (widthScale += 0.01));
		if (FlxG.keys.justPressed.THREE)
			greenCamera.height = Std.int(FlxG.height * (heightScale -= 0.01));
		if (FlxG.keys.justPressed.FOUR)
			greenCamera.height = Std.int(FlxG.height * (heightScale += 0.01));*/

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
				changeItem(-1);

			if (controls.UI_DOWN_P)
				changeItem(1);

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				selectedSomethin = true;

				FlxFlicker.flicker(menuItems.members[curSelected], 1, 0.06, false, false, function(flick:FlxFlicker)
				{
					switch (optionShit[curSelected])
					{
						case 'options':
							MusicBeatState.switchState(new OptionsState());
							OptionsState.onPlayState = false;
							if (PlayState.SONG != null)
							{
								PlayState.SONG.arrowSkin = null;
								PlayState.SONG.splashSkin = null;
								PlayState.stageUI = 'normal';
							}
						default:
							persistentUpdate = false;
							Difficulty.resetList();
							
							// var songLowercase:String = Paths.formatToSongPath(optionShit[curSelected]);
							var songLowercase:String = "tutorial";
							var poop:String = Highscore.formatSong(songLowercase, 0);
							PlayState.SONG = Song.loadFromJson(poop, songLowercase);

							LoadingState.loadAndSwitchState(new PlayState());

							FlxG.sound.music.volume = 0;
					}
				});

				for (i in 0...menuItems.members.length)
				{
					if (i == curSelected)
						continue;
					FlxTween.tween(menuItems.members[i], {alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							menuItems.members[i].kill();
						}
					});
				}
			}
			#if desktop
			if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		scrollBlue.scrollY = scrollBlue.scrollX = scrollGreen.scrollY = scrollGreen.scrollX += elapsed * 120;

		super.update(elapsed);
	}

	override function destroy()
	{
		FlxG.game.removeChild(mask);
		FlxG.game.mask = null;
		mask = null;

		super.destroy();
	}

	override function onResize(width:Int, height:Int)
	{
		updateMask();
		super.onResize(width, height);
	}

	function changeItem(huh:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		menuItems.members[curSelected].animation.play('idle');
		menuItems.members[curSelected].updateHitbox();

		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.members[curSelected].animation.play('selected');
		menuItems.members[curSelected].centerOffsets();

		menuArt.animation.play(optionShit[curSelected]);
		menuArt.updateHitbox();
	}

	function updateMask()
	{
		mask.graphics.clear();
		mask.graphics.beginFill(FlxColor.BLACK);
		mask.graphics.drawRect(0, 0, FlxG.width * FlxG.scaleMode.scale.x, FlxG.height * FlxG.scaleMode.scale.y);
		mask.graphics.endFill();
	}
}
