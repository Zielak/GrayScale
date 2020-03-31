package;

import flixel.effects.FlxFlicker;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class PlayerTrail extends FlxSprite {
	private var _lifeTime:Float;
	private var _dyingTime:Float;
	private var _deathCounter:FlxTween;
	private var _fps:Int;

	public function new(X:Float, Y:Float):Void {
		X = Math.round(X);
		Y = Math.round(Y);
		super(X, Y);

		_lifeTime = FlxG.random.float(0.1, 0.2);
		_dyingTime = FlxG.random.float(0.5, 0.8);
		_fps = Math.round(FlxG.random.int(10, 30) / 2);

		loadGraphic(AssetPaths.playertrails__png, true, 16, 16);

		animation.add("death", [0, 1, 2, 3, 4, 5], _fps, false, FlxG.random.bool(), FlxG.random.bool());
		// trace('fps: '+_fps);
		// trace('_dyingTime: '+ _dyingTime);
	}

	override public function update(elapsed:Float):Void {
		if (alive) {
			_lifeTime -= FlxG.elapsed;
			if (_lifeTime <= 0) {
				kill();
			}
		} else if (!alive && exists) {
			_dyingTime -= FlxG.elapsed;
			if (_dyingTime <= 0) {
				death();
			}
		}

		super.update(elapsed);
	}

	override public function kill():Void {
		alive = false;
		animation.play("death");
		FlxFlicker.flicker(this, 3, 0.05);
	}

	private function death():Void {
		exists = false;
	}
}
