package;

import AssetPaths.Images;
import AssetPaths.Sounds;
import flixel.effects.FlxFlicker;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import flixel.input.keyboard.FlxKeyboard;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class Player extends FlxSprite {
	private var sounds:Dynamic<FlxSound> = {
		bounce: new FlxSound(),
		bounceHard: new FlxSound(),
		collect: new FlxSound(),
		dash: new FlxSound(),
		death: new FlxSound(),
		foorsteps: new FlxSound(),
	}

	private function initSounds():Void {
		sounds.bounce.loadEmbedded(Sounds.sfx_player_bounce__ogg);
		sounds.bounceHard.loadEmbedded(Sounds.sfx_player_bounce_energy__ogg);
		sounds.collect.loadEmbedded(Sounds.sfx_player_collect__ogg);
		sounds.dash.loadEmbedded(Sounds.sfx_player_dash__ogg);
		sounds.death.loadEmbedded(Sounds.sfx_player_death__ogg);
		sounds.foorsteps.loadEmbedded(Sounds.sfx_player_footsteps__ogg);
	}

	/**
	 * Current speed, manipulated during play by eg. Dashing
	 */
	public var speed:Float = 82;

	private var _speedLerp:Float = 0.72;

	/**
	 * Maximum "walking" speed
	 */
	public var moveSpeed:Float = 80;

	private var _moveAngle:Float = 0;

	private var _deathCamTime:Float = 0.7;

	private var dash:Dynamic = {
		speed: 300, // How fast you go while dashing
		cooldown: 0, // Current cooldown of dashing
		time: 0.18, // How long can you dash
		timeMore: 0.01, // Added when you keep holding dash key
		// TODO: Make it a number and use :Dynamic<Float>
		addedMoreTime: false,
		timeLeft: 0, // How long can you dash?
		maxCD: 1,
		regenCD: 1,
		bounceCount: 0, // Prevent getting stuck by counting bounce times
		timeSpent: 0 // Time spent while dashing (in air), resets upon landing
	};
	private var dashLog:Array<FlxPoint>;

	// Just getter, cooldown is private
	@:isVar public var dashCooldown(get, null):Float;

	function get_dashCooldown() {
		return dash.cooldown;
	}

	// Direction
	private var _direction:Int = 0x0000;

	public var direction(get, set):Int;

	public function get_direction():Int {
		var dir:Int = 0x0000;
		switch (_moveAngle) {
			case 90:
				dir = FlxObject.DOWN;
			case 45:
				dir = FlxObject.DOWN | FlxObject.RIGHT;
			case 0:
				dir = FlxObject.RIGHT;
			case -45:
				dir = FlxObject.UP | FlxObject.RIGHT;
			case -90:
				dir = FlxObject.UP;
			case -135:
				dir = FlxObject.UP | FlxObject.LEFT;
			case 180:
				dir = FlxObject.LEFT;
			case 135:
				dir = FlxObject.DOWN | FlxObject.LEFT;
		}
		return dir;
	}

	public function set_direction(val:Int):Int {
		if (val == FlxObject.DOWN)
			_moveAngle = 90;
		if (val == FlxObject.DOWN | FlxObject.RIGHT)
			_moveAngle = 45;
		if (val == FlxObject.RIGHT)
			_moveAngle = 0;
		if (val == FlxObject.UP | FlxObject.RIGHT)
			_moveAngle = -45;
		if (val == FlxObject.UP)
			_moveAngle = -90;
		if (val == FlxObject.UP | FlxObject.LEFT)
			_moveAngle = -135;
		if (val == FlxObject.LEFT)
			_moveAngle = 180;
		if (val == FlxObject.DOWN | FlxObject.LEFT)
			_moveAngle = 135;

		_direction = val;
		// trace("new direction: "+val);
		// trace("_moveAngle   : "+_moveAngle);

		return _direction;
	}

	public function get_invincible():Bool {
		return dashing || justHurt;
	}

	public var maxHealth:Float = 1.8;
	public var justHurt:Bool = false;

	public var dashing:Bool = false;
	public var chargingDash:Bool = false;
	public var canDash:Bool = true;

	private var _inputGamepad:Bool;
	private var _gamepad:FlxGamepad;
	private var _keyboard:FlxKeyboard;
	private var _up:Bool = false;
	private var _down:Bool = false;
	private var _left:Bool = false;
	private var _right:Bool = false;
	private var _A:Bool = false;
	// private var _B:Bool = false; never used
	#if mobile
	private var _touches:Array<FlxTouch>;
	private var _dpadPoint:FlxPoint;
	private var _touchPoint:FlxPoint;
	private var _touchAngle:Float = 0;
	#end

	public var reviving:Bool = false;
	public var safeSpot:FlxPoint = new FlxPoint(0, 0);

	private var _tmpPoint:FlxPoint = new FlxPoint(0, 0);

	public var onVoid:Bool = false;

	public function new(X:Float = 0, Y:Float = 0) {
		super(X, Y);

		dashLog = new Array<FlxPoint>();

		loadGraphic(Images.player__png, true, 16, 16);

		var fps:Int = 4;
		animation.add("idle", [16], fps, true);
		animation.add("d", [0, 1], fps, true);
		animation.add("dr", [2, 3], fps, true);
		animation.add("r", [4, 5], fps, true);
		animation.add("ur", [6, 7], fps, true);
		animation.add("u", [8, 9], fps, true);
		animation.add("ul", [10, 11], fps, true);
		animation.add("l", [12, 13], fps, true);
		animation.add("dl", [14, 15], fps, true);
		animation.add("charging", [17, 18, 19, 18, 17, 20, 17, 18, 19, 20], 15, true);
		animation.add("dashing", [21], fps, true);
		animation.add("void", [22], fps, true);

		drag.x = drag.y = 1200;
		// elasticity = 1;

		setSize(8, 8);
		offset.set(4, 4);

		safeSpot.x = X;
		safeSpot.x = Y;

		_inputGamepad = false;

		#if mobile
		_dpadPoint = new FlxPoint(0, Std.int(FlxG.height / 4 * 3));
		_touches = new Array<FlxTouch>();
		_touchPoint = new FlxPoint(0, 0);
		#end

		health = 1.8;
		pixelPerfectRender = true;

		initSounds();
	}

	override public function update(elapsed:Float):Void {
		if (alive && !reviving) {
			updateTimers(elapsed);
			updateMovement();
			updateSafeSpot();
			updateDashing(elapsed);
			updateAchievements();
			spark();
		}

		if (!alive && !reviving) {
			_deathCamTime -= FlxG.elapsed;

			if (_deathCamTime <= 0) {
				ScoreManager.instance.resetLevelScore();
				FlxG.switchState(new PlayState());
			}
		}

		super.update(elapsed);

		// Reset this one every frame
		onVoid = false;
	}

	private function updateSafeSpot():Void {
		/**
		 * Remember
		 */
		if (!dashing && !onVoid) {
			_tmpPoint.x = x;
			_tmpPoint.y = y;
			// trace(" tmp point: "+_tmpPoint.toString());

			if (_tmpPoint.distanceTo(safeSpot) > 100) {
				safeSpot.x = Math.round(x);
				safeSpot.y = Math.round(y);
				// trace("Remembering: "+safeSpot.toString() );
			}
		}
	}

	private function updateTimers(elapsed:Float):Void {
		dash.timeSpent += elapsed;

		/**
		 * Dashing cooldowns
		 */
		if (dash.cooldown > 0) {
			dash.cooldown -= dash.regenCD * elapsed;
		} else if (dash.cooldown < 0) {
			dash.cooldown = 0;
			canDash = true;
		}

		if (alive && !justHurt && health < maxHealth) {
			health += elapsed / 10;
		}
	}

	/**
		Keeps dashing speed until duration is over
	**/
	private function updateDashing(elapsed:Float):Void {
		if (dashing) {
			if (dash.timeLeft > 0) {
				dash.timeLeft -= elapsed;

				if (dash.timeLeft <= 0 && _A && !dash.addedMoreTime) {
					dash.timeLeft += dash.timeMore;
					dash.addedMoreTime = true;
					// trace("added more time for dash");
				}
			} else {
				stopDashing();
			}
		}
	}

	private function updateMovement():Void {
		if (!dashing) {
			getKeys();
		}

		// Move player forward, when dashing and not
		move();

		// Dash if we can
		if (_A && !dashing && canDash) {
			if (_up || _down || _left || _right) {
				startDashing();
			} else if (!chargingDash && canDash) {
				startCharging();
			}
		}

		if (!_A && chargingDash) {
			stopCharging(true);
		}

		// Update animations
		decideAnimation();

		/**
		 * Sounds
		 */
		if (!dashing && (_up || _down || _left || _right)) {
			sounds.foorsteps.play();
		} else {
			sounds.foorsteps.stop();
		}

		/**
		 * Position fixer
		 */
		if (!dashing) {
			x = Math.round(x);
			y = Math.round(y);
		}
	}

	/**
	 * Update all input related variables
	 * TODO: Move out from player. Needed in menus and intro.
	 */
	private function getKeys():Void {
		#if mobile
		_touches = FlxG.touches.list;
		_up = false;
		_down = false;
		_left = false;
		_right = false;
		_A = false;

		for (t in _touches) {
			// Dash
			if (t.screenX > Std.int(FlxG.width / 2)) {
				_A = true;
			} else {
				// check for anything else
				_touchPoint.x = t.screenX;
				_touchPoint.y = t.screenY;

				// not too far from the DPAD
				if (_touchPoint.distanceTo(_dpadPoint) < 40 && _touchPoint.distanceTo(_dpadPoint) > 2) {
					_touchAngle = _dpadPoint.angleBetween(_touchPoint);

					// 45 deg + 22.5 deg so we can walk diagonally
					if (_touchAngle > -67.5 && _touchAngle < 67.5) {
						_up = true;
					}
					if (_touchAngle > 22.5 && _touchAngle < 157.5) {
						_right = true;
					}
					if (_touchAngle < -22.5 && _touchAngle > -157.5) {
						_left = true;
					}
					if (Math.abs(_touchAngle) > 112.5) {
						_down = true;
					}
				}
			}
		}
		#else
		_gamepad = FlxG.gamepads.lastActive;
		_keyboard = FlxG.keys;

		if (_gamepad != null) {
			if (!_inputGamepad && _gamepad.anyButton()) {
				trace('PLAYER: switched to gamepad input!');
				_inputGamepad = true;
			}
		} else {
			if (_inputGamepad && _keyboard.anyJustPressed(["UP", "W", "DOWN", "S", "LEFT", "A", "RIGHT", "D", "X", "NUMPADFOUR"])) {
				trace('PLAYER: switched to keyboard input!');
				_inputGamepad = false;
			}
		}

		if (_inputGamepad) {
			_up = _gamepad.pressed.DPAD_UP;
			_down = _gamepad.pressed.DPAD_DOWN;
			_left = _gamepad.pressed.DPAD_LEFT;
			_right = _gamepad.pressed.DPAD_RIGHT;
			// FlxGamepadInputID
			_A = _gamepad.pressed.A;
			// _B = FlxG.keys.anyPressed([FlxKey.Z, FlxKey.NUMPADFIVE]);
		} else {
			_up = _keyboard.anyPressed([FlxKey.UP, FlxKey.W]);
			_down = _keyboard.anyPressed([FlxKey.DOWN, FlxKey.S]);
			_left = _keyboard.anyPressed([FlxKey.LEFT, FlxKey.A]);
			_right = _keyboard.anyPressed([FlxKey.RIGHT, FlxKey.D]);

			_A = _keyboard.anyPressed([FlxKey.X, FlxKey.NUMPADFOUR]);
			// _B = FlxG.keys.anyPressed([FlxKey.Z, FlxKey.NUMPADFIVE]);
		}

		#if !FLX_NO_DEBUG
		if (_gamepad != null) {
			FlxG.watch.addQuick("pressed ID", _gamepad.firstPressedID());
			FlxG.watch.addQuick("released ID", _gamepad.firstJustReleasedID());
			FlxG.watch.addQuick("justPressed ID", _gamepad.firstJustPressedID());
			FlxG.watch.addQuick("_up", _gamepad.pressed.DPAD_UP);
			FlxG.watch.addQuick("_down", _gamepad.pressed.DPAD_DOWN);
			FlxG.watch.addQuick("_left", _gamepad.pressed.DPAD_LEFT);
			FlxG.watch.addQuick("_right", _gamepad.pressed.DPAD_RIGHT);
			// FlxG.watch.addQuick("_gamepad.anyButton()", _gamepad.anyButton() );
			// FlxG.watch.addQuick("_inputGamepad", _inputGamepad );
		}
		#end
		#end
	}

	/**
	 * Update movement, move forward even when dashing
	 */
	private function move():Void {
		if (!dashing) {
			if (_up && _down) {
				_up = _down = false;
			}
			if (_left && _right) {
				_left = _right = false;
			}

			if (_up || _down || _left || _right) {
				if (_up) {
					_moveAngle = -90;
					if (_left)
						_moveAngle -= 45;
					else if (_right)
						_moveAngle += 45;
				} else if (_down) {
					_moveAngle = 90;
					if (_left)
						_moveAngle += 45;
					else if (_right)
						_moveAngle -= 45;
				} else if (_left)
					_moveAngle = 180;
				else if (_right)
					_moveAngle = 0;

				// FlxAngle.rotatePoint(speed, 0, 0, 0, _moveAngle, velocity);
				velocity.set(speed, 0);
				velocity.rotate(FlxPoint.weak(0, 0), _moveAngle);
			}
		} else {
			// FlxAngle.rotatePoint(speed, 0, 0, 0, _moveAngle, velocity);
			velocity.set(speed, 0);
			velocity.rotate(FlxPoint.weak(0, 0), _moveAngle);
		}
	}

	private function decideAnimation():Void {
		if (dashing) {
			animation.play("dashing");
		} else if (chargingDash) {
			animation.play("charging");
		} else {
			if (velocity.x == 0 && velocity.y == 0) {
				animation.play("idle");
			} else {
				switch (_moveAngle) {
					case 90:
						animation.play("d");
					case 45:
						animation.play("dr");
					case 0:
						animation.play("r");
					case -45:
						animation.play("ur");
					case -90:
						animation.play("u");
					case -135:
						animation.play("ul");
					case 180:
						animation.play("l");
					case 135:
						animation.play("dl");
				}
			}
		}
	}

	private function startCharging():Void {
		chargingDash = true;
	}

	private function stopCharging(cancelled:Bool = false):Void {
		chargingDash = false;

		if (cancelled) {
			var velocity = FlxPoint.weak(14, 0).rotate(FlxPoint.weak(0, 0), FlxG.random.float(0, 360));
			var position = FlxPoint.weak(x - offset.x, y - offset.y);

			cast(FlxG.state, PlayState).spawnEffect('ring', position, velocity);
		}
	}

	private function startDashing():Void {
		stopCharging();
		dashing = true;
		canDash = false;
		dash.addedMoreTime = false;
		dash.cooldown = dash.maxCD;
		speed = dash.speed;
		dash.timeLeft = dash.time;

		sounds.dash.play();
		sounds.foorsteps.stop();

		cast(FlxG.state, PlayState).flashHUD();
		FlxG.camera.shake(0.01, 0.1);
	}

	private function stopDashing():Void {
		speed = moveSpeed;
		velocity.x *= 0.2;
		velocity.y *= 0.2;

		dashing = false;
		dash.bounceCount = 0;
		dash.timeSpent = 0;

		dashLog = new Array<FlxPoint>();
	}

	private function startHurting():Void {
		justHurt = true;

		sounds.death.play();

		var position = FlxPoint.weak(x - offset.x, y - offset.y);

		cast(FlxG.state, PlayState).spawnEffect('ring', position, FlxPoint.weak(40, 0));
		cast(FlxG.state, PlayState).spawnEffect('ring', position, FlxPoint.weak(-40, 0));
		cast(FlxG.state, PlayState).spawnEffect('ring', position, FlxPoint.weak(0, 40));
		cast(FlxG.state, PlayState).spawnEffect('ring', position, FlxPoint.weak(0, -40));

		FlxFlicker.flicker(this, 2, 0.05);
		new FlxTimer().start(3, stopHurting);
	}

	private function stopHurting(timer:FlxTimer):Void {
		justHurt = false;
		FlxFlicker.stopFlickering(this);
	}

	private function spark():Void {
		if (health < maxHealth && (health / maxHealth) * FlxG.random.float() < 0.12) {
			var position = FlxPoint.weak(x - offset.x, y - offset.y);
			var velocity = FlxPoint.weak(FlxG.random.float(15, 60), 0).rotate(FlxPoint.weak(0, 0), FlxG.random.float(0, 360));

			cast(FlxG.state, PlayState).spawnEffect('ring', position, velocity);
		}
	}

	/**
	 * Bounce off walls
	 * @param  newDirection new direction of movement
	 * @param  ?hard        did we hit Energy wall? Bounce HARDER
	 */
	public function bounce(newDirection:Int, ?hard:Bool = false):Void {
		direction = newDirection;
		if (hard) {
			sounds.bounceHard.play(true);
			resetDashingTimer(0.019);
		} else {
			sounds.bounce.play(true);
		}
	}

	/**
	 * Make player dasha little longer. Called when bouncing off Energy walls.
	 * Also prevents from getting stuck in dash loop (eg. stuck between 2 energy walls). Keeps a log of every last bounce position and checks for repetition.
	 * Breaks dashing state when repetition rate is too high.
	 * *fabolous!*
	 * @param  ?alsoAdd [description]
	 * @return          [description]
	 */
	private function resetDashingTimer(?alsoAdd:Float = 0):Void {
		dash.timeLeft = dash.time + alsoAdd;
		dash.bounceCount++;
		dashLog.push(new FlxPoint(x, y));

		// Check for repetition, prevent looping
		var repetition:Int = 0; // Stability?
		var A:FlxPoint;
		var B:FlxPoint;

		// Only check for repetition after a while
		if (dash.bounceCount > 10) {
			for (i in 0...dashLog.length) {
				A = dashLog[i];
				A.x = Math.round(A.x);
				A.y = Math.round(A.y);
				for (j in 0...dashLog.length) {
					B = dashLog[j];
					B.x = Math.round(B.x);
					B.y = Math.round(B.y);

					// trace("A: ["+A.x+", "+A.y+"]" );
					// trace("B: ["+B.x+", "+B.y+"]" );
					if (A.x == B.x && A.y == B.y) {
						repetition++;
						// trace(" ["+i+", "+ j+"]  A & B Are equal");
					}

					// trace("------------" );
				}
			}
		}
		if (repetition >= dash.bounceCount * 2) {
			// just in case, lower probability of stucking by 3 lol
			stopDashing();
		}
		// trace("Repetition: "+repetition);
		// trace("Bounce Count: "+dash.bounceCount);
	}

	/**
	 * Cha-ching for collected coin
	 */
	public function collectedCoin():Void {
		sounds.collect.play(true);
	}

	public function updateAchievements():Void {
		if (dashing) {
			Achievements.instance.spaceTimeTraveller();
		}
	}

	/**
	 * Fall back to last known safe position after getting soft-killed
	 */
	public function reviveAtSafeSpot():Void {
		if (alive && !reviving) {
			// trace("Reviving");

			alive = false;
			reviving = true;

			sounds.death.play();
			animation.play("void");

			FlxTween.tween(this, {
				x: safeSpot.x,
				y: safeSpot.y
			}, 1, {
				ease: FlxEase.quartInOut,
				onComplete: reviveComplete,
				type: FlxTweenType.ONESHOT
			});

			// alive = true; // One or the other?
			// reviving = false;

			// x = safeSpot.x;
			// y = safeSpot.y;
		}
	}

	/**
	 * Called after "reviving" animation is complete
	 * @param  tween I guess I had to put reference to the FlxTween object here.
	 */
	private function reviveComplete(tween:FlxTween):Void {
		x = safeSpot.x;
		y = safeSpot.y;
		// trace("Reviving complete");
		cast(FlxG.state, PlayState).resumeMusic();

		alive = true; // One or the other?
		reviving = false;
	}

	override public function hurt(Damage:Float) {
		if (get_invincible()) {
			return;
		}

		super.hurt(Damage);

		if (health > 0) {
			startHurting();
		}
	}

	override public function kill():Void {
		sounds.death.play();
		alive = false;

		#if debug
		FlxG.timeScale = 1;
		#else
		FlxG.timeScale = 0.2;
		#end

		visible = false;

		var position = FlxPoint.weak(x - offset.x, y - offset.y);

		cast(FlxG.state, PlayState).spawnEffect('smoke', position, FlxPoint.weak(11, -11));
		cast(FlxG.state, PlayState).spawnEffect('smoke', position, FlxPoint.weak(11, 11));
		cast(FlxG.state, PlayState).spawnEffect('smoke', position, FlxPoint.weak(-11, 11));
		cast(FlxG.state, PlayState).spawnEffect('smoke', position, FlxPoint.weak(-11, -11));

		// FlxG.switchState(new sounds.Deathtate());
	}

	// override public function revive():Void
	// {
	//   super.revive();
	//   x = safeSpot.x;
	//   y = safeSpot.y;
	// }
}
