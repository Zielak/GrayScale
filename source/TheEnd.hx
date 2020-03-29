package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.math.FlxPoint;

// import openfl.Assets;
class TheEnd extends FlxState {
	private var _music:FlxSound;

	private var _complete:FlxText;
	private var _thanks:FlxText;

	override public function create():Void {
		_music = new FlxSound();
		_music.loadEmbedded(AssetPaths.music_grayscale_theme__ogg, false);
		_music.play();

		var halfWidth:Int = Std.int(FlxG.width / 2);
		var halfHeight:Int = Std.int(FlxG.height / 2);

		var shadow:FlxPoint = new FlxPoint(0, 1);
		var shadowBig:FlxPoint = new FlxPoint(0, 3);

		_complete = new FlxText(halfWidth - 60, 42, 120, "THE END", 16);
		_complete.color = GBPalette.C4;
		_complete.alignment = "center";
		_complete.bold = true;
		_complete.shadowOffset.x = shadow.x;
		_complete.shadowOffset.y = shadow.y;
		_complete.setBorderStyle(FlxTextBorderStyle.SHADOW, GBPalette.C2, 1);

		_thanks = new FlxText(halfWidth - 60, 70, 120, "THANKS FOR PLAYING!", 8);
		_thanks.color = GBPalette.C4;
		_thanks.alignment = "center";
		_thanks.setBorderStyle(FlxTextBorderStyle.SHADOW, GBPalette.C2, 1);
		_thanks.shadowOffset.x = shadow.x;
		_thanks.shadowOffset.y = shadow.y;

		add(_complete);
		add(_thanks);

		ScoreManager.instance.rememberLevelScore();
		Achievements.instance.finishedGame();
		Achievements.instance.sendScore();
		Achievements.instance.sendGlobalTrophies();

		super.create();
	}

	override public function update(elapsed:Float):Void {
		if (!_music.playing || FlxG.keys.pressed.ENTER || FlxG.touches.list.length > 0) {
			ScoreManager.instance.resetAllScores();
			Achievements.instance.resetGlobalTrophies();
			Achievements.instance.resetLevelTrophies();
			PlayList.instance.nextLevel();
			FlxG.switchState(new MenuState());
		}

		super.update(elapsed);
	}

	override function destroy():Void {
		_music.stop();
		_music = null;
		_complete = null;
		_thanks = null;

		super.destroy();
	}
}
