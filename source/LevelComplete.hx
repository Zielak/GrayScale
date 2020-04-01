package;

import AssetPaths.Sounds;
import AssetPaths.Images;
import AssetPaths.Musics;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;

using flixel.util.FlxSpriteUtil;

class LevelComplete extends FlxState {
	private var _music:FlxSound;
	private var _bam:FlxSound;
	private var _dash:FlxSound;
	private var _dashed:Bool = false;

	private var _bg:FlxSprite;

	private var _whiteFace:FlxSprite;

	private var _player:SpinningPlayer;

	private var _theTimer:Int = -30;

	private var _levelNum:FlxText;
	private var _complete:FlxText;
	private var _levelscore1:FlxText;
	private var _levelscore2:FlxText;
	private var _mainscore1:FlxText;
	private var _mainscore2:FlxText;
	private var _footer:FlxText;

	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void {
		ScoreManager.instance.rememberLevelScore();
		Achievements.instance.sendScore();

		_music = new FlxSound();
		_music.loadEmbedded(Musics.music_victory_loop__ogg, true);

		_bam = new FlxSound();
		_bam.loadEmbedded(Sounds.sfx_player_bounce__ogg);

		_dash = new FlxSound();
		_dash.loadEmbedded(Sounds.sfx_player_dash__ogg);

		var halfWidth:Int = Std.int(FlxG.width / 2);
		var halfHeight:Int = Std.int(FlxG.height / 2);

		var shadow:FlxPoint = new FlxPoint(0, 1);
		var shadowBig:FlxPoint = new FlxPoint(0, 3);

		_bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height);
		_bg.drawRect(0, 0, FlxG.width, FlxG.height, GBPalette.C2);
		_bg.x = _bg.y = 0;

		_whiteFace = new FlxSprite();
		_whiteFace.loadGraphic(Images.whiteFade__png, false, 160, 288);
		_whiteFace.x = 0;
		_whiteFace.y = -144;

		_player = new SpinningPlayer(halfWidth - 8, halfHeight - 8);

		_levelNum = new FlxText(halfWidth - 40, 20, 80, "LEVEL " + PlayList.instance.currentLevel, 8);
		_levelNum.color = GBPalette.C4;
		_levelNum.alignment = "center";
		_levelNum.setBorderStyle(FlxTextBorderStyle.SHADOW, GBPalette.C1, 1);
		_levelNum.shadowOffset.x = shadow.x;
		_levelNum.shadowOffset.y = shadow.y;
		_levelNum.visible = false;

		_complete = new FlxText(halfWidth - 60, 42, 120, "COMPLETE!", 16);
		_complete.color = GBPalette.C4;
		_complete.alignment = "center";
		_complete.bold = true;
		_complete.shadowOffset.x = shadow.x;
		_complete.shadowOffset.y = shadow.y;
		_complete.setBorderStyle(FlxTextBorderStyle.SHADOW, GBPalette.C1, 1);
		_complete.visible = false;

		_levelscore1 = new FlxText(20, 73, 120, "LEVEL SCORE: " + ScoreManager.instance.score, 8);
		_levelscore1.color = GBPalette.C3;
		_levelscore1.shadowOffset.x = shadow.x;
		_levelscore1.shadowOffset.y = shadow.y;
		_levelscore1.setBorderStyle(FlxTextBorderStyle.SHADOW, GBPalette.C1, 1);
		_levelscore1.visible = false;

		_mainscore1 = new FlxText(20, 88, 120, "GAME SCORE: " + ScoreManager.instance.mainScore, 8);
		_mainscore1.color = GBPalette.C3;
		_mainscore1.shadowOffset.x = shadow.x;
		_mainscore1.shadowOffset.y = shadow.y;
		_mainscore1.setBorderStyle(FlxTextBorderStyle.SHADOW, GBPalette.C1, 1);
		_mainscore1.visible = false;

		_footer = new FlxText(halfWidth - 70, 115, 140, "[START] NEXT", 8);
		_footer.color = GBPalette.C3;
		_footer.alignment = "center";
		_footer.visible = false;

		add(_bg);

		add(_whiteFace);
		add(_player);

		add(_levelNum);
		add(_complete);
		add(_levelscore1);
		add(_mainscore1);
		add(_footer);

		super.create();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed:Float):Void {
		if (_theTimer < 400) {
			_theTimer++;
		}

		if (_theTimer > 30 && !_dashed) {
			_dashed = true;
			_dash.play();
		}

		if (_theTimer > 45 && _whiteFace.y < 144) {
			_whiteFace.y += 10;
		}

		// Show scores when player flies away
		if (_player.y < 0) {
			if (!_music.playing)
				_music.play();

			if (_theTimer > 50 && !_levelNum.visible) {
				_levelNum.visible = true;
			}
			if (_theTimer > 120 && !_complete.visible) {
				_complete.visible = true;
				FlxG.camera.shake(0.03, 0.15, null, true, flixel.util.FlxAxes.Y);
				_bam.play(true);
			}
			if (_theTimer > 180 && !_levelscore1.visible) {
				_levelscore1.visible = true;
				FlxG.camera.shake(0.01, 0.1, null, true, flixel.util.FlxAxes.Y);
				_bam.play(true);
			}
			if (_theTimer > 220 && !_mainscore1.visible) {
				_mainscore1.visible = true;
				FlxG.camera.shake(0.01, 0.1, null, true, flixel.util.FlxAxes.Y);
				_bam.play(true);
			}
			if (_theTimer > 280 && !_footer.visible) {
				_footer.visible = true;
			}

			if (FlxG.keys.pressed.ENTER || FlxG.touches.list.length > 0) {
				_music.stop();
				ScoreManager.instance.resetLevelScore();
				PlayList.instance.nextLevel();
				FlxG.switchState(new PlayState());
			}
		}

		// else if(_gameLogo.animation.name == "showLogo")
		//   {
		//     if(FlxG.keys.pressed.ENTER){
		//       PlayList.instance.nextLevel();
		//     FlxG.switchState(new PlayState());
		//     }
		//   }
		//   else if(_gameLogo.animation.name == "hideLogo")
		//   {
		//
		//   }

		super.update(elapsed);
	}
}
