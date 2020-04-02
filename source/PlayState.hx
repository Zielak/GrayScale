package;

import AssetPaths.Musics;
import AssetPaths.Images;
import enemies.Cruncher;
import enemies.Spectre;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.tile.FlxTilemap;

class PlayState extends FlxState implements IPlayState {
	private static inline var TILE_WIDTH:Int = 16;
	private static inline var TILE_HEIGHT:Int = 16;

	private var _map:FlxOgmoLoader;
	private var _tileMap:FlxTilemap;

	private var _collisions:Collisions;

	private var _hud:HUD;

	// TODO: Move this to HUD itself!
	public var _hudCoinsMap:HUDCoinMap;

	private var _flashDur:Int = 0;
	private var _flashing:Bool = false;
	private var _flashTileOffset:Int = 80;

	private var _player:Player;

	public var player(get, null):Player;

	function get_player() {
		return _player;
	}

	private var _playerPos:FlxPoint = new FlxPoint(0, 0);

	private var _maxCoins:Int = 0;

	public var coins = new FlxTypedGroup<FlxSprite>();
	public var decoration = new FlxTypedGroup<FlxSprite>();

	public var projectiles = new FlxTypedGroup<FlxSprite>();
	public var crunchers = new FlxTypedGroup<FlxSprite>();
	public var spectres = new FlxTypedGroup<FlxSprite>();

	// public var bouncyWalls = new FlxTypedGroup<FlxSprite>();
	public var effectsGroup = new FlxTypedGroup<FlxSprite>();

	private var _trailIterator:Int = 0;
	private var _trailGenerateAt:Int = 0;

	private var _lvlScore:Int = 0;

	private var _music:FlxSound;

	public function resumeMusic():Void {
		if (!_music.playing && !PlayList.instance.isLastLevel) {
			_music.resume();
		}
	}

	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void {
		super.create();
		// FlxG.debugger.drawDebug = true;

		FlxG.timeScale = 1;

		_music = new FlxSound();
		_music.loadEmbedded(Musics.music_grayscale_theme__ogg, true);

		if (!PlayList.instance.isLastLevel) {
			_music.play();
		}

		setupMap();

		_hudCoinsMap = new HUDCoinMap();

		_hudCoinsMap.updatePoints(coins.members);
		add(_hudCoinsMap);

		add(projectiles);
		add(effectsGroup);
		add(coins);
		add(spectres);
		add(_player);
		add(decoration);
		add(crunchers);

		// FlxG.camera.follow(_player, FlxCameraFollowStyle.LOCKON, 1);
		FlxG.camera.focusOn(new FlxPoint(_player.x, _player.y));
		FlxG.camera.follow(_player, FlxCameraFollowStyle.NO_DEAD_ZONE, 1);

		_hud = new HUD();
		_hud.maxCoins = _maxCoins;
		add(_hud);
	}

	/**
	 * Function that is called when this state is destroyed - you might want to
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void {
		super.destroy();
		_map = null;
		_tileMap = null;

		_hud = null;
		_hudCoinsMap = null;

		_player = null;
		_playerPos = null;

		coins = null;
		projectiles = null;
		crunchers = null;
		spectres = null;

		// bouncyWalls = null;

		effectsGroup = null;
		_music = null;
	}

	private function setupMap():Void {
		var UP:Int = FlxObject.UP;
		var DOWN:Int = FlxObject.DOWN;
		var LEFT:Int = FlxObject.LEFT;
		var RIGHT:Int = FlxObject.RIGHT;
		var NONE:Int = FlxObject.NONE;
		var ANY:Int = FlxObject.ANY;

		_collisions = new Collisions(this);

		var ROW_SIZE:Int = 16;

		_map = new FlxOgmoLoader(PlayList.instance.currentLevelName);
		_tileMap = _map.loadTilemap(Images.tilemap2__png, 16, 16, "walls");

		FlxG.worldBounds.set(_tileMap.x, _tileMap.y, _tileMap.width, _tileMap.height);

		_tileMap.setTileProperties(0, NONE);
		_tileMap.setTileProperties(1, NONE, _collisions.voidCallback);
		_tileMap.setTileProperties(0 + _flashTileOffset, NONE);
		_tileMap.setTileProperties(1 + _flashTileOffset, NONE);

		// Walkable, first row
		for (i in 2...16) {
			_tileMap.setTileProperties(i, NONE);
			_tileMap.setTileProperties(i + _flashTileOffset, NONE);
		}

		// Walkable, pretty tiles
		for (i in 27...32) {
			_tileMap.setTileProperties(i, NONE);
			_tileMap.setTileProperties(i + _flashTileOffset, NONE);

			_tileMap.setTileProperties(i + ROW_SIZE, NONE);
			_tileMap.setTileProperties(i + ROW_SIZE + _flashTileOffset, NONE);

			_tileMap.setTileProperties(i + ROW_SIZE * 2, NONE);
			_tileMap.setTileProperties(i + ROW_SIZE * 2 + _flashTileOffset, NONE);
		}

		// Bouncy walls
		for (i in 23...27) {
			_tileMap.setTileProperties(i, ANY, _collisions.bouncyCallback);
			_tileMap.setTileProperties(i + _flashTileOffset, ANY, _collisions.bouncyCallback);
			_tileMap.setTileProperties(i + ROW_SIZE, ANY, _collisions.bouncyCallback);
			_tileMap.setTileProperties(i + ROW_SIZE + _flashTileOffset, ANY, _collisions.bouncyCallback);
		}

		// One-way tiles
		_tileMap.setTileProperties(54, UP | DOWN | LEFT);
		_tileMap.setTileProperties(54 + _flashTileOffset, UP | DOWN | LEFT);
		_tileMap.setTileProperties(55, LEFT | DOWN | RIGHT);
		_tileMap.setTileProperties(55 + _flashTileOffset, LEFT | DOWN | RIGHT);
		_tileMap.setTileProperties(56, UP | DOWN | RIGHT);
		_tileMap.setTileProperties(56 + _flashTileOffset, UP | DOWN | RIGHT);
		_tileMap.setTileProperties(57, LEFT | UP | RIGHT);
		_tileMap.setTileProperties(57 + _flashTileOffset, LEFT | UP | RIGHT);

		add(_tileMap);
		_map.loadEntities(placeEntities, "entities");
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed:Float):Void {
		if (_player.reviving)
			return;
		// Change level for debuggin

		#if debug
		if (FlxG.keys.pressed.ONE)
			PlayList.instance.loadLevel(0);
		if (FlxG.keys.pressed.TWO)
			PlayList.instance.loadLevel(1);
		if (FlxG.keys.pressed.THREE)
			PlayList.instance.loadLevel(2);
		if (FlxG.keys.pressed.FOUR)
			PlayList.instance.loadLevel(3);
		if (FlxG.keys.pressed.FIVE)
			PlayList.instance.loadLevel(4);
		if (FlxG.keys.pressed.SIX)
			PlayList.instance.loadLevel(5);
		if (FlxG.keys.pressed.SEVEN)
			PlayList.instance.loadLevel(6);
		if (FlxG.keys.pressed.EIGHT)
			PlayList.instance.loadLevel(7);
		if (FlxG.keys.pressed.NINE)
			PlayList.instance.loadLevel(8);
		if (FlxG.keys.anyPressed([
			FlxKey.ONE,
			FlxKey.TWO,
			FlxKey.THREE,
			FlxKey.FOUR,
			FlxKey.FIVE,
			FlxKey.SIX,
			FlxKey.SEVEN,
			FlxKey.EIGHT,
			FlxKey.NINE
		]))
			_player.kill();
		#end

		// ============
		// COLLISIONS
		// ============

		FlxG.collide(_player, decoration, _collisions.playerCollidesTilemap);
		FlxG.collide(_player, _tileMap, _collisions.playerCollidesTilemap);
		FlxG.overlap(_player, coins, _collisions.playerOverlapsCoin);
		FlxG.overlap(_player, projectiles, _collisions.playerOverlapsProjectile);
		FlxG.overlap(_player, crunchers, _collisions.playerOverlapsCruncher);
		FlxG.overlap(_player, spectres, _collisions.playerOverlapsSpectre);

		FlxG.collide(crunchers, null, _collisions.CrunchersOverlapEachother);

		FlxG.overlap(spectres, null, _collisions.SpectresOverlapEachother);
		FlxG.collide(spectres, _tileMap);

		// ============
		// HUD STUFF
		// ============
		_hud.updateHUD(_player.dashCooldown, _player.dashing, coins.countLiving(), ScoreManager.instance.score);
		_hudCoinsMap.updateTarget(_player.x, _player.y);

		updateFlashings();

		// ============
		// DASHING - spam trails
		// ============
		if (_player.dashing) {
			_trailIterator++;
			if (_trailIterator >= _trailGenerateAt) {
				_trailIterator = 0;
				var newTrail = new PlayerTrail(_player.x - _player.offset.x, _player.y - _player.offset.y);
				effectsGroup.add(newTrail);
			}
		}

		// ============
		// ENEMY ATTACKS
		// ============
		// Slomo while cruncher is nearby and charging at you
		adjustTimescale();

		// Camera fix?
		FlxG.camera.x = Math.round(FlxG.camera.x);
		FlxG.camera.y = Math.round(FlxG.camera.y);

		// Attach HuD Coin map to HuD
		// _hudCoinsMap.x = FlxG.camera.x;
		// _hudCoinsMap.y = FlxG.camera.y;

		super.update(elapsed);
	}

	/**
	 * Place all entities from Ogmo project map
	 */
	private function placeEntities(entityName:String, entityData:Xml):Void {
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		x = Math.round(x);
		y = Math.round(y);

		if (entityName == "player") {
			_player = new Player(x, y);
		} else if (entityName == "coin") {
			// if(coins.length == 0){
			var coin = new Coin(x, y);
			coins.add(coin);
			_maxCoins++;
			// }
		} else if (entityName == "ECruncher") {
			var enemy = new Cruncher(x, y);
			crunchers.add(enemy);
		} else if (entityName == "ESpectre") {
			var enemy = new Spectre(x, y);
			spectres.add(enemy);
		} else if (entityName == "boulder") {
			var deco = new FlxSprite(Math.round(x), Math.round(y));
			deco.loadGraphic(Images.boulders__png, true, 32, 32);
			deco.animation.add("idle", [0, 1, 2, 3], 0);
			deco.animation.play("idle");
			deco.animation.frameIndex = FlxG.random.int(0, 3);

			deco.setSize(24, 24);

			deco.immovable = true;

			decoration.add(deco);
		}
	}

	/**
	 * Flash the screen by changing tiles
	 */
	public function flashHUD(?duration:Int = 9):Void {
		flashOn(duration);
	}

	private function updateFlashings():Void {
		if (_flashing) {
			_flashDur--;
			// trace(_flashDur);

			if (_flashDur <= 0) {
				flashOff();
			}
		}
	}

	private function flashOn(duration:Int):Void {
		// trace("Flash ON!");
		// Pathetic whole white screen flash
		// _hud.flash(duration);

		if (!_flashing) {
			// Swap tiles!
			var tiles = _tileMap.getData();
			for (i in 0...tiles.length) {
				_tileMap.setTileByIndex(i, tiles[i] + _flashTileOffset);
			}

			_flashing = true;
			_flashDur = duration;
		} else {
			if (duration > _flashDur) {
				_flashDur = duration;
			}
		}
	}

	private function flashOff():Void {
		// trace("Flash off!");
		_flashing = false;

		var tiles = _tileMap.getData();

		for (i in 0...tiles.length) {
			_tileMap.setTileByIndex(i, tiles[i] - _flashTileOffset);
		}
	}

	private function adjustTimescale() {
		if (player.dashing) {
			return;
		}

		var timeScale = 1.0;
		crunchers.forEachAlive(function(C) {
			var cruncher = cast(C, Cruncher);

			if (cruncher.state == Attacking) {
				var _distance = FlxMath.distanceBetween(cruncher, player);
				var _maxDist = 75;

				if (_distance < _maxDist) {
					var _minTimeScale = 0.25;
					var _distPerc = _distance / _maxDist;
					timeScale = Math.max(_minTimeScale, _minTimeScale + _distPerc * (1.0 - _minTimeScale));
				}
			}
		});
		if (timeScale <= 1) {
			FlxG.timeScale = timeScale;
		}
	}

	public function levelFinished():Void {
		if (_music.playing) {
			// trace("stopping music");
			_music.stop();
		}
		// trace("is last level? "+PlayList.instance.isLastLevel);
		if (!PlayList.instance.isLastLevel) {
			// trace("  nope");
			FlxG.switchState(new LevelComplete());
		} else {
			// trace("  yep");
			FlxG.switchState(new TheEnd());
		}
	}

	/**
	 * With this, enemies know where ther player is  in the world
	 * Used in their fetchTargetPosition()
	 * @return Player's position in world
	 */
	public function getPlayerPosition():FlxPoint {
		_playerPos.x = _player.x + 8;
		_playerPos.y = _player.y + 8;
		return _playerPos;
	}

	/**
	 * Kill player and optionally revive him into last known safe position
	 * @param  void if true, then player can go back to last known position
	 */
	public function hurtPlayer(?void:Bool = false):Void {
		if (void) {
			// trace("I'm trying to get you back at safe spot...");
			Achievements.instance.diedFromVoid();
			flashHUD(2);
			// if(_music.playing) _music.pause();
			_player.reviveAtSafeSpot();
		} else {
			_player.hurt(1);
			if (_player.health <= 0) {
				// Man, you're done!
				_music.stop();
				Achievements.instance.diedFromMonster();
			}
		}
	}

	public function spawnEffect(type:String, position:FlxPoint, velocity:FlxPoint):FlxSprite {
		var newEffect:FlxSprite = new FlxSprite(position.x, position.y);

		switch (type) {
			case 'ring':
				newEffect = new RingBlink(position.x, position.y);
			case 'smoke':
				newEffect = new PlayerTrail(position.x, position.y);
			default:
				newEffect = new PlayerTrail(position.x, position.y);
		}

		newEffect.velocity.copyFrom(velocity);

		effectsGroup.add(newEffect);

		return newEffect;
	}

	public function addProjectile(S:Dynamic):Void {
		projectiles.add(cast(S, FlxSprite));
	}

	public function addProjectiles(A:Array<Dynamic>):Void {
		for (s in A) {
			projectiles.add(cast(s, FlxSprite));
		}
	}
}
