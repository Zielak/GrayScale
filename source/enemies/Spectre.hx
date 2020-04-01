package enemies;

import AssetPaths.Images;
import AssetPaths.Sounds;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;

enum SpectreMind {
	Deciding;
	Searching;
	Hiding;
	Appearing;
	Armed;
	Attacking;
	Dying;
}

class Spectre extends Enemy {
	private function initSounds():Void {
		var s:FlxSound;

		s = new FlxSound();
		s.loadEmbedded(Sounds.sfx_spectre_appear__ogg);
		addSound("appear", s);

		s = new FlxSound();
		s.loadEmbedded(Sounds.sfx_spectre_attack__ogg);
		addSound("attack", s, 1.5);

		s = new FlxSound();
		s.loadEmbedded(Sounds.sfx_spectre_charge__ogg);
		addSound("charge", s, 0.4);

		s = new FlxSound();
		s.loadEmbedded(Sounds.sfx_spectre_death__ogg);
		addSound("death", s, 1.7);

		s = new FlxSound();
		s.loadEmbedded(Sounds.sfx_spectre_disappear__ogg);
		addSound("disappear", s);
	}

	private var _state:SpectreMind;
	private var _targetPos:FlxPoint = new FlxPoint();
	private var _targetAngle:Float = 0;
	private var _targetDirection:Int = 0x0000;
	private var _inRange:Bool = false;

	private var _shotMade:Bool = false;

	private var _armDistance:Int = 50;
	private var _attackDistance:Int = 32;

	// Randomize movement, 1,2,3
	private var _moveBy:Int = 16;

	override public function new(X:Float = 0, Y:Float = 0) {
		super(X, Y);

		loadGraphic(Images.spectre__png, true, 16, 16);

		animation.add("appear", [0, 1, 2, 3, 4], 20, false);
		animation.add("hide", [4, 3, 2, 1, 0], 20, false);
		animation.add("armed", [5], 1, false);
		animation.add("attack", [6, 7], 30, true);

		animation.play("appear");

		_time.searching = 0.7;
		_time.hiding = 0.85;
		_time.appearing = 0.5;
		_time.attacking = 1;

		x = Math.round(x);
		y = Math.round(y);

		initSounds();

		startSearching();
	}

	/**
	 * Update, where everything happens
	 */
	override public function update(elapsed:Float):Void {
		_elapsed = FlxG.elapsed;

		// what to do?
		if (alive) {
			switch (_state) {
				case Searching:
					lookForPlayer();
				case Armed:
					lookForPlayer();
				default:
			}
			updateCooldowns();
		}
		super.update(elapsed);
	}

	private function updateCooldowns():Void {
		_currentTime -= _elapsed;

		// Change state when finished
		if (_currentTime <= 0) {
			switch (_state) {
				case Searching:
					fetchTargetPosition();
					startHiding();
				case Hiding:
					moveToNextTile();
				case Appearing:
					startSearching();
				case Attacking:
					startSearching();
				default:
			}
		}
		// Delayed attacking
		if (_state == Attacking && _currentTime <= _time.attacking * 0.8) {
			shoot();
		}
	}

	/**
	 * Start searching for the player
	 */
	private function startSearching():Void {
		_currentTime = _time.searching;
		_state = Searching;
		_shotMade = false;
	}

	private function startHiding():Void {
		if (getGraphicMidpoint().distanceTo(_targetPos) > _viewDistance) {
			// I can't see him anymore, just stay idle.
			startSearching();
			return;
		}
		// on my way!
		animation.play("hide");
		_currentTime = _time.hiding;
		_state = Hiding;
		// _disappearS.play(true);
	}

	private function startAppearing():Void {
		// trace("Start Appearing");
		_currentTime = _time.appearing;
		_state = Appearing;
		animation.play("appear");
		playSound("appear");
	}

	private function startArming():Void {
		// trace("Start Arming!");
		_state = Armed;
		animation.play("armed");
		playSound("charge");
	}

	private function moveToNextTile():Void {
		// trace("Move to next tile");
		// Move to next available tile

		_moveBy = FlxG.random.int(1, 2);

		switch (_targetDirection) {
			case FlxObject.UP:
				y -= 16 * _moveBy;
			case FlxObject.DOWN:
				y += 16 * _moveBy;
			case FlxObject.LEFT:
				x -= 16 * _moveBy;
			case FlxObject.RIGHT:
				x += 16 * _moveBy;
		}

		startAppearing();
	}

	/**
	 * Spectre just stedded into the wall or something, he must get back
	 */
	public function stepBack():Void {
		switch (_targetDirection) {
			case FlxObject.UP:
				y += 16 * _moveBy;
			case FlxObject.DOWN:
				y -= 16 * _moveBy;
			case FlxObject.LEFT:
				x += 16 * _moveBy;
			case FlxObject.RIGHT:
				x -= 16 * _moveBy;
		}
		startAppearing();
	}

	private function lookForPlayer():Void {
		fetchTargetPosition();
		if (getGraphicMidpoint().distanceTo(_targetPos) < _armDistance) {
			// hold, hooold
			if (_state != Armed)
				startArming();

			if (getGraphicMidpoint().distanceTo(_targetPos) < _attackDistance) {
				// ATTACK!
				if (_state != Attacking)
					startAttacking();
			}
		} else {
			if (_state != Searching) {
				// reset state when player leaves _armDistance
				startSearching();
			}
		}
	}

	private function startAttacking():Void {
		// trace("Start Attacking!");
		_state = Attacking;
		animation.play("attack");
		_currentTime = _time.attacking;
		playSound("attack");
	}

	private function shoot():Void {
		if (!_shotMade) {
			_shotMade = true;
			cast(FlxG.state, PlayState).flashHUD(10);

			// Shoot!
			var spr:SpectreProjectile;
			var arr:Array<SpectreProjectile> = new Array<SpectreProjectile>();

			spr = new SpectreProjectile(x, y, FlxObject.RIGHT);
			arr.push(spr);

			spr = new SpectreProjectile(x, y, FlxObject.LEFT);
			arr.push(spr);

			spr = new SpectreProjectile(x, y, FlxObject.UP);
			arr.push(spr);

			spr = new SpectreProjectile(x, y, FlxObject.DOWN);
			arr.push(spr);

			cast(FlxG.state, PlayState).addProjectiles(arr);
		}
	}

	/**
	 * Gets player position from the outside
	 */
	private function fetchTargetPosition():Void {
		_targetPos = cast(FlxG.state, PlayState).getPlayerPosition();
		_targetAngle = FlxAngle.angleBetweenPoint(this, _targetPos, true);

		// Just 4 directions
		if (FlxMath.inBounds(_targetAngle, -45, 45)) {
			_targetDirection = FlxObject.RIGHT;
		} else if (FlxMath.inBounds(_targetAngle, 45, 135)) {
			_targetDirection = FlxObject.DOWN;
		} else if (Math.abs(_targetAngle) > 135) {
			_targetDirection = FlxObject.LEFT;
		} else {
			_targetDirection = FlxObject.UP;
		}
	}

	override public function kill():Void {
		stopSound("appear");
		stopSound("attack");
		stopSound("charge");
		stopSound("disappear");
		playSound("death");

		alive = false;

		var position = new FlxPoint(x, y);

		cast(FlxG.state, PlayState).spawnEffect('smoke', position, FlxPoint.weak(6, -6));
		cast(FlxG.state, PlayState).spawnEffect('smoke', position, FlxPoint.weak(6, 6));
		cast(FlxG.state, PlayState).spawnEffect('smoke', position, FlxPoint.weak(-6, 6));
		cast(FlxG.state, PlayState).spawnEffect('smoke', position, FlxPoint.weak(-6, -6));

		exists = false;
	}
}
