package;

import flixel.FlxSprite;

class RingBlink extends FlxSprite {
	public function new(X:Float, Y:Float):Void {
		X = Math.round(X);
		Y = Math.round(Y);
		super(X, Y);

		loadGraphic(AssetPaths.ringBlink__png, true, 16, 16);

		animation.add("death", [0, 1, 2, 3, 4, 5], 30, false);
	}

	override public function update(elapsed:Float):Void {
		if (animation.finished) {
			destroy();
		}

		super.update(elapsed);
	}
}
