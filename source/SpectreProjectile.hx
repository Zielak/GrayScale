package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flash.display.BitmapData;

using flixel.util.FlxSpriteUtil;

@:bitmap("assets/images/spectreProjectile.png") class SpectreProjectilebmp extends BitmapData {}

class SpectreProjectile extends FlxSprite {
	private var _lifeTime:Float = 0.25;
	private var _speed:Int = 150;

	public function new(X:Float, Y:Float, D:Int):Void {
		X = Math.round(X);
		Y = Math.round(Y);
		super(X, Y);

		loadGraphic(SpectreProjectilebmp, true, 16, 16);

		animation.add("idle", [0, 1, 2, 3], 1, false);

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

	override public function update():Void {
		super.update();
		if (alive) {
			_lifeTime -= FlxG.elapsed;
			if (_lifeTime <= 0) {
				destroy();
			}
		}
	}
}
