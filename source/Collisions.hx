package;

import flixel.FlxG;
import enemies.Spectre;
import flixel.FlxSprite;
import flixel.FlxObject;

class Collisions {
	private var _playState:PlayState;

	public function new(playState:PlayState) {
		_playState = playState;
	}

	/**
	 * Player colides Tilemap
	 */
	public function playerCollidesTilemap(P:FlxObject, TM:FlxObject):Void {
		var player = cast(P, Player);
		if (player.dashing) {
			player.bounce(bounceSprite(player, player.direction));
		}
	}

	/**
	 * Gets new direction for sprite based on current direction and which face of the tile it's touching
	 * @param  S   Sprite to be redirected
	 * @param  dir Current sprite's direction
	 * @return     New direction Enum, see FlxObject.DOWN etc
	 */
	public function bounceSprite(S:FlxSprite, dir:Int):Int {
		var DOWN = FlxObject.DOWN;
		var LEFT = FlxObject.LEFT;
		var UP = FlxObject.UP;
		var RIGHT = FlxObject.RIGHT;
		var newDirection = 0x0000;

		if (S.touching == DOWN | LEFT) {
			newDirection = UP | RIGHT;
		}
		if (S.touching == DOWN | RIGHT) {
			newDirection = UP | LEFT;
		}
		if (S.touching == UP | LEFT) {
			newDirection = DOWN | RIGHT;
		}
		if (S.touching == UP | RIGHT) {
			newDirection = DOWN | LEFT;
		}

		if (S.touching == UP) {
			if (dir == UP | RIGHT)
				newDirection = DOWN | RIGHT;
			if (dir == UP | LEFT)
				newDirection = DOWN | LEFT;
			if (dir == UP)
				newDirection = DOWN;
		}

		if (S.touching == DOWN) {
			if (dir == DOWN | RIGHT)
				newDirection = UP | RIGHT;
			if (dir == DOWN | LEFT)
				newDirection = UP | LEFT;
			if (dir == DOWN)
				newDirection = UP;
		}

		if (S.touching == LEFT) {
			if (dir == LEFT | UP)
				newDirection = RIGHT | UP;
			if (dir == LEFT | DOWN)
				newDirection = RIGHT | DOWN;
			if (dir == LEFT)
				newDirection = RIGHT;
		}

		if (S.touching == RIGHT) {
			if (dir == RIGHT | UP)
				newDirection = LEFT | UP;
			if (dir == RIGHT | DOWN)
				newDirection = LEFT | DOWN;
			if (dir == RIGHT)
				newDirection = LEFT;
		}
		return newDirection;
	}

	/**
	 * Player over Void!
	 */
	public function voidCallback(T:FlxObject, P:FlxObject):Void {
		var type = Type.getClassName(Type.getClass(P));

		// trace("Void collision with " + type);

		if (type == "Player") {
			var player = cast(P, Player);
			player.onVoid = true;
			if (!player.dashing && !player.reviving) {
				// Faulty below. Can land between 4 void tiles, right in the middle...
				if (T.overlapsPoint(player.getMidpoint())) {
					ScoreManager.instance.reducePointsFor("void");
					_playState.hurtPlayer(true);
				}
			}
		} else if (type == "enemies.Spectre") {
			var spectre = cast(P, Spectre);
			if (spectre.alive) {
				spectre.kill();
				ScoreManager.instance.addPointsFor("spectreVoid");
			}
		}
	}

	/**
	 * Player collides BouncyWall
	 */
	public function bouncyCallback(T:FlxObject, P:FlxObject):Void {
		var player = cast(P, Player);

		if (player.dashing) {
			player.bounce(bounceSprite(player, player.direction), true);

			if (T.touching == FlxObject.LEFT || T.touching == FlxObject.RIGHT) {
				FlxG.camera.shake(0.05, 0.13, null, true, flixel.util.FlxAxes.X);
			} else {
				FlxG.camera.shake(0.05, 0.13, null, true, flixel.util.FlxAxes.X);
			}
			Achievements.instance.thisIsHowIBounce();
			_playState.flashHUD(3);
		}
	}

	/**
	 * Player over Coin
	 */
	public function playerOverlapsCoin(P:FlxObject, C:FlxObject):Void {
		var player = cast(P, Player);

		if (player.dashing) {
			if (P.alive && P.exists && C.alive && C.exists) {
				player.collectedCoin();
				C.kill();
				ScoreManager.instance.addPointsFor("coin");
			}

			// trace("Coins left: "+_coins.countLiving());
			if (_playState.coins.countLiving() == 0) {
				// trace("pre-levelFinished");
				_playState.levelFinished();
			} else {
				var newCoins = new Array<FlxSprite>();
				_playState.coins.forEachAlive(function(spr) {
					newCoins.push(spr);
				});
				_playState._hudCoinsMap.updatePoints(newCoins);
			}
		} else if (!player.dashing && C.alive) {
			FlxObject.separate(P, C);
		}
	}

	public function playerOverlapsCruncher(P:FlxObject, E:FlxObject):Void {
		var player = cast(P, Player);

		if (player.dashing) {
			// Kill it! Points!
			if (E.alive) {
				E.kill();
				ScoreManager.instance.addPointsFor("cruncher");
				FlxG.camera.shake(0.02, 0.2);
			}
		} else {
			if (E.alive && player.alive) {
				// Well, you're dead
				_playState.hurtPlayer();
			}
		}
	}

	public function playerOverlapsSpectre(P:FlxObject, E:FlxObject):Void {
		// Can do nothing to kill spectre right now... or can you?
		// if(_player.dashing){
		//   // Kill it! Points!
		//   if(E.alive){
		//     E.kill();
		//     ScoreManager.instance.addPointsFor("spectre");
		//     FlxG.camera.shake(0.02, 0.2);
		//   }
		// }else{
		//   if(E.alive){
		//     // Well, you're dead
		//     _player.kill();
		//   }
		// }
	}

	public function playerOverlapsProjectile(P:FlxObject, E:FlxObject):Void {
		var player = cast(P, Player);

		if (!player.dashing) {
			if (E.alive && player.alive) {
				// Well, you're dead
				_playState.hurtPlayer();
			}
		}
	}

	public function SpectresOverlapEachother(A:FlxObject, B:FlxObject):Void {
		if (A.alive && B.alive) {
			// trace("Spectres collide");
			cast(A, Spectre).stepBack();
		}
	}

	public function SpectresOverlapTilemap(S:FlxObject, T:FlxObject):Void {
		// Didn't had time to do it well...
		// trace("Spectres collides wall");
		// trace(T);
		// cast(S, Spectre).stepBack();
	}

	public function CrunchersOverlapEachother(A:FlxObject, B:FlxObject):Void {
		if (A.alive && B.alive) {
			FlxObject.separate(A, B);
		}
	}
}
