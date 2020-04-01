package;

import AssetPaths.Images;
import flixel.FlxG;
import flixel.FlxSprite;

class RingBlink extends FlxSprite {
	public function new(X:Float, Y:Float):Void {
		X = Math.round(X);
		Y = Math.round(Y);
		super(X, Y);

		loadGraphic(Images.ringBlink__png, true, 16, 16);

		animation.add("death", [0, 1, 2, 3, 4, 5], 20, false, FlxG.random.bool(), FlxG.random.bool());

		animation.play("death");
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (animation.finished) {
			destroy();
		}
	}
}
