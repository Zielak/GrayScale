import flixel.FlxSprite;

class SpinningPlayer extends FlxSprite {
	private var _YRate:Float = 0;

	private var _timer:Float = 0;

	public function new(X:Float = 0, Y:Float = 0) {
		super(X, Y);

		loadGraphic(AssetPaths.player__png, true, 16, 16);

		animation.add("spin", [1, 3, 5, 7, 9, 11, 13, 15], 1, true);
		animation.play("spin");
	}

	override public function update(elapsed:Float):Void {
		if (_timer <= 20) {
			_timer++;
		}

		if (_timer > 20 && y > -20) {
			_YRate += 0.08;
			y -= Std.int(_YRate);
		}

		if (animation.curAnim != null && animation.curAnim.frameRate < 60) {
			animation.curAnim.frameRate += 1;
		}
		super.update(elapsed);
	}
}
