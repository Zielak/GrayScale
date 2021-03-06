package;

import AssetPaths.Images;
import flixel.FlxSprite;
import flixel.FlxG;

class SpectreProjectile extends FlxSprite {
	private var _lifeTime:Float = 0.4;
	private var _speed:Int = 110;

	public function new(X:Float, Y:Float, D:Int):Void {
		X = Math.round(X + 3);
		Y = Math.round(Y + 3);
		super(X, Y);

		loadGraphic(Images.spectreProjectile__png, true, 16, 16);
		animation.add("idle", [0, 1, 2, 3], 1, false);

		setSize(10, 10);
		offset.set(3, 3);

		switch (D) {
			case 0x0001: // LEFT
				animation.frameIndex = 3;
				velocity.x = -_speed;
				x -= -4;
			case 0x0010: // RIOGHT
				animation.frameIndex = 1;
				velocity.x = _speed;
				x += -4;
			case 0x0100: // UP
				animation.frameIndex = 0;
				velocity.y = -_speed;
				y -= -4;
			case 0x1000: // DOWN
				animation.frameIndex = 2;
				velocity.y = _speed;
				y += -4;
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (alive) {
			_lifeTime -= FlxG.elapsed;
			if (_lifeTime <= 0) {
				destroy();
			}
		}
	}
}
