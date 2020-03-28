package;

import flash.display.BitmapData;
import flixel.FlxSprite;

using flixel.util.FlxSpriteUtil;

@:bitmap("assets/images/ringBlink.png") class RingBlinkbmp extends BitmapData {}

class RingBlink extends FlxSprite {
	public function new(X:Float, Y:Float):Void {
		X = Math.round(X);
		Y = Math.round(Y);
		super(X, Y);

		loadGraphic(RingBlinkbmp, true, 16, 16);

		animation.add("death", [0, 1, 2, 3, 4, 5], 30, false);
	}

	override public function update():Void {
		if (animation.finished) {
			destroy();
		}

		super.update();
	}
}
