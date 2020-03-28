package;

import flash.display.BitmapData;
import flash.media.Sound;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.input.touch.FlxTouch;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.XboxButtonID;
import flixel.input.keyboard.FlxKeyboard;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxAngle;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;

@:bitmap("assets/images/player.png") class Playerbmp extends BitmapData {}
#if flash
@:sound("assets/sounds/sfx_player_bounce.mp3") class Sbounce extends Sound {}
@:sound("assets/sounds/sfx_player_bounce_energy.mp3") class SbounceHard extends Sound {}
@:sound("assets/sounds/sfx_player_collect.mp3") class Scollect extends Sound {}
@:sound("assets/sounds/sfx_player_dash.mp3") class Sdash extends Sound {}
@:sound("assets/sounds/sfx_player_death.mp3") class Sdeath extends Sound {}
@:sound("assets/sounds/sfx_player_footsteps.mp3") class Sfootsteps extends Sound {}
#else
@:sound("assets/sounds/sfx_player_bounce.ogg") class Sbounce extends Sound {}
@:sound("assets/sounds/sfx_player_bounce_energy.ogg") class SbounceHard extends Sound {}
@:sound("assets/sounds/sfx_player_collect.ogg") class Scollect extends Sound {}
@:sound("assets/sounds/sfx_player_dash.ogg") class Sdash extends Sound {}
@:sound("assets/sounds/sfx_player_death.ogg") class Sdeath extends Sound {}
@:sound("assets/sounds/sfx_player_footsteps.ogg") class Sfootsteps extends Sound {}
#end

class Player extends FlxSprite {
	private var bounceS:FlxSound;
	private var bounceHardS:FlxSound;
	private var collectS:FlxSound;
	private var dashS:FlxSound;
	private var deathS:FlxSound;
	private var foorstepsS:FlxSound;

	private function initSounds():Void {
		bounceS = new FlxSound();
		bounceS.loadEmbedded(Sbounce);

		bounceHardS = new FlxSound();
		bounceHardS.loadEmbedded(SbounceHard);

		collectS = new FlxSound();
		collectS.loadEmbedded(Scollect);

		dashS = new FlxSound();
		dashS.loadEmbedded(Sdash);

		deathS = new FlxSound();
		deathS.loadEmbedded(Sdeath);

		foorstepsS = new FlxSound();
		foorstepsS.loadEmbedded(Sfootsteps);
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

	private var _elapsed:Float;

	public var dashing:Bool = false;
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

		loadGraphic(Playerbmp, true, 16, 16);

		var fps:Int = 4;
		animation.add("idle", [0], fps, true);
		animation.add("d", [1, 2], fps, true);
		animation.add("dr", [3, 4], fps, true);
		animation.add("r", [5, 6], fps, true);
		animation.add("ur", [7, 8], fps, true);
		animation.add("u", [9, 10], fps, true);
		animation.add("ul", [11, 12], fps, true);
		animation.add("l", [13, 14], fps, true);
		animation.add("dl", [15, 16], fps, true);
		animation.add("dash", [17], fps, true);

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

		initSounds();
	}

	override public function update():Void {
		if (alive && !reviving) {
			updateTimers();
			updateMovement();
			updateSafeSpot();
			updateDashing();
			updateAchievements();
		}

		if (!alive && !reviving) {
			_deathCamTime -= FlxG.elapsed;

			if (_deathCamTime <= 0) {
				ScoreManager.instance.resetLevelScore();
				FlxG.switchState(new PlayState());
			}
		}

		super.update();

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

			if (FlxMath.getDistance(_tmpPoint, safeSpot) > 100) {
				safeSpot.x = Math.round(x);
				safeSpot.y = Math.round(y);
				// trace("Remembering: "+safeSpot.toString() );
			}
		}
	}

	private function updateTimers():Void {
		_elapsed = FlxG.elapsed;

		dash.timeSpent += _elapsed;

		/**
		 * Dashing cooldowns
		 */
		if (dash.cooldown > 0) {
			dash.cooldown -= dash.regenCD * _elapsed;
		} else if (dash.cooldown < 0) {
			dash.cooldown = 0;
			canDash = true;
		}
	}

	private function updateDashing():Void {
		// Keeps dashing speed until duration is over
		if (dashing) {
			if (dash.timeLeft > 0) {
				dash.timeLeft -= _elapsed;

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
		if (_A && !dashing && canDash && (_up || _down || _left || _right)) {
			startDashing();
		}

		// Update animations
		updateAnimation();

		/**
		 * Sounds
		 */
		if (!dashing && (_up || _down || _left || _right)) {
			foorstepsS.play();
		} else {
			foorstepsS.stop();
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
					_touchAngle = FlxAngle.getAngle(_dpadPoint, _touchPoint);

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
			if (_gamepad.anyButton()) {
				_inputGamepad = true;
			}
		} else {
			if (_keyboard.anyJustPressed(["UP", "W", "DOWN", "S", "LEFT", "A", "RIGHT", "D", "X", "NUMPADFOUR"])) {
				_inputGamepad = false;
			}
		}

		if (_inputGamepad) {
			_up = _gamepad.pressed(XboxButtonID.DPAD_UP);
			_down = _gamepad.pressed(XboxButtonID.DPAD_DOWN);
			_left = _gamepad.pressed(XboxButtonID.DPAD_LEFT);
			_right = _gamepad.pressed(XboxButtonID.DPAD_RIGHT);

			_A = _gamepad.pressed(GamepadIDs.A);
			// _B = FlxG.keys.pressed.anyPressed(["Z", "NUMPADFIVE"]);
		} else {
			_up = _keyboard.anyPressed(["UP", "W"]);
			_down = _keyboard.anyPressed(["DOWN", "S"]);
			_left = _keyboard.anyPressed(["LEFT", "A"]);
			_right = _keyboard.anyPressed(["RIGHT", "D"]);

			_A = _keyboard.anyPressed(["X", "NUMPADFOUR"]);
			// _B = FlxG.keys.pressed.anyPressed(["Z", "NUMPADFIVE"]);
		}

		#if !FLX_NO_DEBUG
		if (_gamepad != null) {
			FlxG.watch.add.addQuick("pressed ID", _gamepad.firstPressedButtonID());
			FlxG.watch.add.addQuick("released ID", _gamepad.firstJustReleasedButtonID());
			FlxG.watch.add.addQuick("justPressed ID", _gamepad.firstJustPressedButtonID());
			FlxG.watch.add.addQuick("_up", _gamepad.pressed(XboxButtonID.DPAD_UP));
			FlxG.watch.add.addQuick("_down", _gamepad.pressed(XboxButtonID.DPAD_DOWN));
			FlxG.watch.add.addQuick("_left", _gamepad.pressed(XboxButtonID.DPAD_LEFT));
			FlxG.watch.add.addQuick("_right", _gamepad.pressed(XboxButtonID.DPAD_RIGHT));
			// FlxG.watch.add.addQuick("_gamepad.anyButton()", _gamepad.anyButton() );
			// FlxG.watch.add.addQuick("_inputGamepad", _inputGamepad );
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

				FlxAngle.rotatePoint(speed, 0, 0, 0, _moveAngle, velocity);
			}
		} else {
			FlxAngle.rotatePoint(speed, 0, 0, 0, _moveAngle, velocity);
		}
	}

	private function updateAnimation():Void {
		if (dashing) {
			animation.play("dash");
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

	private function startDashing():Void {
		dashing = true;
		canDash = false;
		dash.addedMoreTime = false;
		dash.cooldown = dash.maxCD;
		speed = dash.speed;
		dash.timeLeft = dash.time;

		dashS.play();
		foorstepsS.stop();

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

	/**
	 * Bounce off walls
	 * @param  newDirection new direction of movement
	 * @param  ?hard        did we hit Energy wall? Bounce HARDER
	 */
	public function bounce(newDirection:Int, ?hard:Bool = false):Void {
		direction = newDirection;
		if (hard) {
			bounceHardS.play(true);
			resetDashingTimer(0.019);
		} else {
			bounceS.play(true);
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
		collectS.play(true);
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

			deathS.play();
			animation.play("dash");

			FlxTween.tween(this, {x: safeSpot.x, y: safeSpot.y}, 1, {ease: FlxEase.quartInOut, complete: reviveComplete, type: FlxTween.ONESHOT});

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

	override public function kill():Void {
		deathS.play();
		alive = false;

		#if debug
		FlxG.timeScale = 1;
		#else
		FlxG.timeScale = 0.2;
		#end

		visible = false;

		var puff:PlayerTrail;
		puff = cast(FlxG.state, PlayState).puffSmoke(x, y);
		puff.velocity.x = 9;
		puff.velocity.y = -9;
		puff = cast(FlxG.state, PlayState).puffSmoke(x, y);
		puff.velocity.x = 9;
		puff.velocity.y = 9;
		puff = cast(FlxG.state, PlayState).puffSmoke(x, y);
		puff.velocity.x = -9;
		puff.velocity.y = 9;
		puff = cast(FlxG.state, PlayState).puffSmoke(x, y);
		puff.velocity.x = -9;
		puff.velocity.y = -9;

		// FlxG.switchState(new DeathState());
	}

	// override public function revive():Void
	// {
	//   super.revive();
	//   x = safeSpot.x;
	//   y = safeSpot.y;
	// }
}
