package enemies;

import flixel.FlxSprite;
import flixel.system.FlxSound;

class Enemy extends FlxSprite {
	// TODO: Split to view and hearing distance?
	private var _viewDistance:Int = 100;

	private var _time:Dynamic<Float>;
	private var _elapsed:Float;
	private var _currentTime:Float = 0;

	/**
	 * Holds every playable sound of this enemy
	 */
	public var sounds(default, null):Map<String, FlxSound>;

	public function get_sounds():Map<String, FlxSound> {
		return _sounds;
	}

	private var _sounds:Map<String, FlxSound>;

	// Temp stuff
	private var _vol:Float;
	private var _svol:Float;

	/**
	 * Manipulate desired volume of sound with this array
	 */
	private var _soundsVolumes:Map<String, Float>;

	/**
	 * Change volume of this enemy based on the distance to player
	 */
	private function setVolumeByDistance(distance:Float):Void {
		if (distance > _viewDistance)
			return;

		_vol = -(distance / (_viewDistance * 1.5)) + 1;

		for (k in _sounds.keys()) {
			// get volume
			_svol = _soundsVolumes.get(k);

			// set volume
			_sounds.get(k).volume = _vol * _svol;
		}
	}

	/**
	 * Add new sound to the enemy
	 * @param id      Unique ID for the sound
	 * @param sound
	 * @param ?volume used in setVolumeByDistance()
	 */
	private function addSound(id:String, sound:FlxSound, ?volume:Float = 1.0):Void {
		if (!_sounds.exists(id)) {
			_sounds.set(id, sound);
			_soundsVolumes.set(id, volume);
		} else {
			trace("Enemy already has this sound. Now find me, lol.");
		}
	}

	/**
	 * Plays given sound
	 * @param  id
	 */
	private function playSound(id:String):Void {
		if (_sounds.exists(id)) {
			_sounds.get(id).play(true);
		}
	}

	private function stopSound(id:String):Void {
		if (_sounds.exists(id)) {
			_sounds.get(id).stop();
		}
	}

	public function new(X:Float = 0, Y:Float = 0) {
		super(X, Y);

		_sounds = new Map<String, FlxSound>();
		_soundsVolumes = new Map<String, Float>();

		_time = {};
	}
}
