package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;

using flixel.util.FlxSpriteUtil;

class StageClear extends FlxState {
	private var _bg:FlxSprite;

	public function new():Void {
		super();

		_bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height);
		_bg.drawRect(0, 0, FlxG.width, FlxG.height, GBPalette.C3);

		add(_bg);
	}
}
