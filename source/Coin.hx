package;

import flash.display.BitmapData;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using flixel.util.FlxSpriteUtil;

@:bitmap("assets/images/colorcoin.png") class ColorCoinbmp extends BitmapData {}

class Coin extends FlxSprite {
	private var _deathCounter:FlxTween;

	public function new(X:Float = 0, Y:Float = 0):Void {
		super(X + 2, Y + 2);

		loadGraphic(ColorCoinbmp, true, 16, 16);

		animation.add("idle", [0, 1, 2, 3], 6, true);
		animation.add("death", [4, 4, 4, 4, 4, 4, 4, 4, 5, 6, 7], 12, false);

		animation.play("idle");

		setSize(10, 10);
		offset.set(3, 3);

		// Can't move this
		immovable = true;
	}

	override public function kill():Void {
		alive = false;
		animation.play("death");
		_deathCounter = FlxTween.num(0, 1, 3, null, deathTween);
	}

	/**
	 * Helps animate disappereance of the coin. There are 3 phazes:
	 * 1. "death" animation from the sprite
	 * 2. add flickering effect of FlxSprite
	 * 3. remove
	 * @param  value current value of FlxTween
	 */
	private function deathTween(value:Float):Void {
		if (value < 0.5) {
			flicker(3, 0.05);
		}
		if (value == 1) {
			exists = false;
		}
	}
}
