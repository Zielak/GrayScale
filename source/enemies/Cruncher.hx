package enemies;

import AssetPaths.Images;
import AssetPaths.Sounds;
import flixel.effects.FlxFlicker;
import flixel.FlxG;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;

enum CruncherMind {
	Deciding;
	Searching;
	Flying;
	Attacking;
	Dying;
}

class Cruncher extends Enemy {
	private function initSounds():Void {
		var s:FlxSound;

		s = new FlxSound();
		s.loadEmbedded(Sounds.sfx_cruncher_alert__ogg);
		addSound("alert", s, 0.8);

		s = new FlxSound();
		s.loadEmbedded(Sounds.sfx_cruncher_attack__ogg);
		addSound("attack", s);

		s = new FlxSound();
		s.loadEmbedded(Sounds.sfx_cruncher_death__ogg);
		addSound("death", s);
	}

	private var _state:CruncherMind;

	public var state(get, null):CruncherMind;

	public function get_state():CruncherMind {
		return _state;
	}

	private var _targetPos:FlxPoint = new FlxPoint();
	private var _targetAngle:Float = 0;
	private var _inRange:Bool = false;

	private var _flickering:Bool = false;

	private var _attackDistance:Int = 40;

	public var _flySpeed:Float = 36;
	public var _attackSpeed:Float = 150;
	public var speed:Float = 36;

	public function new(X:Float = 0, Y:Float = 0) {
		super(X, Y);

		/**
		 * Graphics
		 */
		loadGraphic(Images.cruncher__png, true, 16, 16);

		var _fps:Int = FlxG.random.int(3, 8);
		animation.add("flying", [0, 1], _fps, true);
		animation.add("attack", [2], 1, false);
		animation.add("death", [3, 4], 15, true);

		animation.play("flying");

		// setFacingFlip(FlxObject.RIGHT | FlxObject.DOWN, true, false);

		/**
		 * Properties
		 */
		drag.x = drag.y = 600;

		setSize(10, 10);
		offset.set(3, 3);

		_time.searching = 0.75;
		_time.flying = 1.35;
		_time.attacking = 0.28;
		_time.dying = 2.2;

		_state = Deciding;

		/**
		 * Sounds
		 */
		initSounds();
	}

	override public function update(elapsed:Float):Void {
		_elapsed = FlxG.elapsed;

		// what to do?
		if (alive) {
			switch (_state) {
				case Deciding:
					startSearching();
				case Flying:
					flyToPlayer();
				case Attacking:
					attackPlayer();
				default:
			}
			updateCooldowns();
		}

		// Not cool, should be refreshed only a moment before
		// we want to play sound
		setVolumeByDistance(getGraphicMidpoint().distanceTo(_targetPos));

		// Are we dying?
		if (!alive && exists) {
			_time.dying -= _elapsed;
			if (_time.dying <= 0) {
				death();
			} else if (_time.dying < 1 && !_flickering) {
				_flickering = true;
				FlxFlicker.flicker(this, 3, 0.05);
			}
		}

		super.update(elapsed);
	}

	private function updateCooldowns():Void {
		_currentTime -= _elapsed;
		// trace('curTime: '+_currentTime);
		// trace('elapsed: '+_elapsed);

		if (_currentTime <= 0) {
			// trace('current time = '+_currentTime+' and switching action');
			switch (_state) {
				case Searching:
					fetchTargetPosition();
					startFlying();
				case Flying:
					startSearching();
				case Attacking:
					startSearching();
				default:
			}
		}
	}

	private function startSearching():Void {
		_currentTime = _time.searching + FlxG.random.float(-0.03, 0.03);
		_state = Searching;
		speed = 0;

		animation.play("flying");
	}

	private function startFlying():Void {
		if (getGraphicMidpoint().distanceTo(_targetPos) > _viewDistance) {
			startSearching();
			return;
		}

		_currentTime = _time.flying;
		_state = Flying;

		speed = _flySpeed;
		playSound("alert");
	}

	private function startAttacking():Void {
		_currentTime = _time.attacking;
		_state = Attacking;

		speed = _attackSpeed;

		fetchTargetPosition();

		animation.play("attack");
		stopSound("alert");
		playSound("attack");
	}

	/**
	 * Gets player position from the outside
	 */
	private function fetchTargetPosition():Void {
		_targetPos = cast(FlxG.state, PlayState).getPlayerPosition();
		_targetAngle = FlxAngle.angleBetweenPoint(this, _targetPos, true);

		// Randomize a bit
		_targetAngle += FlxG.random.float(-20, 20);
	}

	private function flyToPlayer():Void {
		// FlxAngle.rotatePoint(speed, 0, 0, 0, _targetAngle, velocity);
		velocity.set(speed, 0);
		velocity.rotate(FlxPoint.weak(0, 0), _targetAngle);

		// fetchTargetPosition();
		if (getGraphicMidpoint().distanceTo(_targetPos) < _attackDistance) {
			startAttacking();
		}
	}

	private function attackPlayer():Void {
		// FlxAngle.rotatePoint(speed, 0, 0, 0, _targetAngle, velocity);
		velocity.set(speed, 0);
		velocity.rotate(FlxPoint.weak(0, 0), _targetAngle);
	}

	override public function kill():Void {
		alive = false;
		animation.play("death");
		playSound("death");
	}

	private function death():Void {
		exists = false;
	}
}
