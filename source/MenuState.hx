package;

import AssetPaths.Images;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.ui.FlxButton;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState {
	private var _btnPlay:FlxButton;

	private var _gameLogo:FlxSprite;
	private var _gbjam:FlxSprite;
	private var _darek:FlxSprite;
	private var _chris:FlxSprite;

	private var _fader:FlxSprite;

	private var _timer:Float;
	private var _times:Dynamic = {
		#if debug
		// Fasten up credits just for testing
		gbjam: 0, darek: 0, chris: 0
		#else
		gbjam: 1.5, darek: 2.5, chris: 2.5
		#end
	};

	private var _currentScreen:String = "";

	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void {
		// _btnPlay = new FlxButton(20, 20, "Play", clickPlay);
		// _btnPlay.screenCenter();
		// add(_btnPlay);

		_fader = new FlxSprite();
		_fader.loadGraphic(Images.blackFade__png, true, 160, 144);
		_fader.animation.add("fadeIn", [0, 1, 2, 3, 4, 5], 30, false);
		_fader.animation.add("fadeOut", [4, 3, 2, 1, 0], 30, false);

		_gbjam = new FlxSprite();
		_gbjam.loadGraphic(Images.gbjam3__png, 160, 144);

		_darek = new FlxSprite();
		_darek.loadGraphic(Images.intro_darekLogo__png, false, 160, 144);

		_chris = new FlxSprite();
		_chris.loadGraphic(Images.intro_chris__png, false, 160, 144);

		_gameLogo = new FlxSprite();
		_gameLogo.loadGraphic(Images.logo_game_ani__png, true, 160, 144);
		_gameLogo.animation.add("idle", [0, 0, 0, 0, 1, 2, 3, 3, 3], 5, false);
		_gameLogo.animation.add("showLogo", [4, 5, 6, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9], 14, false);
		_gameLogo.animation.add("hideLogo", [10, 11, 12, 13], 40, false);

		if (PlayList.instance.currentLevel == 0) {
			_gameLogo.animation.play("idle");
		} else {
			_gameLogo.animation.play("hideLogo");
		}

		_gbjam.visible = false;
		_darek.visible = false;
		_chris.visible = false;
		_gameLogo.visible = false;
		_fader.visible = true;

		// if(PlayList.instance.firstEntry){
		add(_gbjam);
		add(_darek);
		add(_chris);
		add(_gameLogo);
		add(_fader);
		showScreen("gbjam");
		// }else{
		//   add(_gameLogo);
		//   showScreen("gameLogo", "hideLogo");
		// }

		Achievements.instance.initAchievements();

		super.create();
	}

	private function showScreen(screen:String, ?aniFrame:String = "idle"):Void {
		// trace("showScreen("+screen+")");
		if (screen == "gbjam") {
			_currentScreen = "gbjam";
			_gbjam.visible = true;
			_fader.animation.play("fadeIn");
			_timer = _times.gbjam;
		} else if (screen == "darek") {
			_currentScreen = "darek";
			_darek.visible = true;
			_fader.animation.play("fadeIn");
			_timer = _times.darek;
		} else if (screen == "chris") {
			_currentScreen = "chris";
			_chris.visible = true;
			_fader.animation.play("fadeIn");
			_timer = _times.chris;
		} else if (screen == "gameLogo") {
			_currentScreen = "gameLogo";
			_fader.visible = false;
			_gameLogo.visible = true;
			_gameLogo.animation.play(aniFrame);
		}
	}

	private function hideScreen(screen:String):Void {
		// trace("hideScreen("+screen+")");
		if (screen == "gbjam") {
			_gbjam.visible = false;
			showScreen("darek");
		} else if (screen == "darek") {
			// _darek.visible = false;
			_darek.destroy();
			showScreen("chris");
		} else if (screen == "chris") {
			_chris.visible = false;
			showScreen("gameLogo");
		}
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed:Float):Void {
		if (_timer > 0) {
			_timer -= FlxG.elapsed;
		} else if (_timer <= 0 && _fader.animation.name != "fadeOut") {
			// trace("fadeOut");
			_fader.animation.play("fadeOut");
		}

		if (_fader.animation.finished && _currentScreen != "gameLogo") {
			if (_fader.animation.name == "fadeOut") {
				// trace("  - fadeOut finished!");
				hideScreen(_currentScreen);
			}
		}

		if (_gameLogo.animation.finished) {
			if (_gameLogo.animation.name == "idle") {
				_gameLogo.animation.play("showLogo");
			} else if (_gameLogo.animation.name == "showLogo") {
				if (FlxG.keys.anyPressed([FlxKey.ENTER]) || FlxG.touches.list.length > 0) {
					_gameLogo.animation.play("hideLogo");
				}
			} else if (_gameLogo.animation.name == "hideLogo") {
				FlxG.switchState(new PlayState());
			}
		}

		super.update(elapsed);
	}

	override public function destroy():Void {
		_gameLogo = null;
		_darek = null;
		_chris = null;
		_fader = null;

		super.destroy();

		// _btnPlay = FlxDestroyUtil.destroy(_btnPlay);
	}
}
