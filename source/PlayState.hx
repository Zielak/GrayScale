package ;

import flash.display.BitmapData;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxRandom;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.tile.FlxTile;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxSpriteUtil;

// import openfl.Assets;


#if !flash
@:sound("assets/music/music_grayscale_theme.ogg") class MainThememp3 extends flash.media.Sound {}
#else
@:sound("assets/music/music_grayscale_theme128.mp3") class MainThememp3 extends flash.media.Sound {}
#end


@:bitmap("assets/images/boulders.png") class Bouldersbmp extends BitmapData {}
@:bitmap("assets/images/tilemap2.png") class Tilemapbmp extends BitmapData {}

class PlayState extends FlxState implements IPlayState
{

  private static inline var TILE_WIDTH:Int = 16;
  private static inline var TILE_HEIGHT:Int = 16;

  private var _map:FlxOgmoLoader;
  private var _tileMap:FlxTilemap;

  private var _hud:HUD;
  private var _hudCoinsMap:HUDCoinMap;
  private var _flashDur:Int = 0;
  private var _flashing:Bool = false;
  private var _flashTileOffset:Int = 80;

  private var _player:Player;
  public var player(get, null):Player;
  function get_player() {
    return _player;
  }
  private var _playerPos:FlxPoint = new FlxPoint(0,0);




  private var _coins = new FlxTypedGroup<FlxSprite>();
  private var _maxCoins:Int = 0;

  private var _decoration = new FlxTypedGroup<FlxSprite>();

  private var _projectiles = new FlxTypedGroup<FlxSprite>();
  private var _Ecrunchers = new FlxTypedGroup<FlxSprite>();
  private var _Espectres = new FlxTypedGroup<FlxSprite>();

  private var _bouncyWalls = new FlxTypedGroup<FlxSprite>();


  private var _playerTrails = new FlxTypedGroup<FlxSprite>();
  private var _trailIterator:Int = 0;
  private var _trailGenerateAt:Int = 0;


  private var _lvlScore:Int = 0;



  private var _music:FlxSound;
  public function resumeMusic():Void
  {
    if(!_music.playing && !PlayList.instance.isLastLevel)
    {
      _music.resume();
    }
  }

  /**
   * Function that is called up when to state is created to set it up. 
   */
  override public function create():Void
  {
    super.create();
    // FlxG.debugger.drawDebug = true;

    FlxG.timeScale = 1;

    _music = new FlxSound();
    _music.loadEmbedded(MainThememp3, true);

    if(!PlayList.instance.isLastLevel)
    {
      _music.play();
    }


    setupMap();

    
    _hudCoinsMap = new HUDCoinMap();
    _hudCoinsMap.updatePoints(_coins.members);
    add(_hudCoinsMap);

    add(_projectiles);
    add(_playerTrails);
    add(_coins);
    add(_Espectres);
    add(_player);
    add(_decoration);
    add(_Ecrunchers);

    // FlxG.camera.follow(_player, FlxCamera.STYLE_LOCKON, 1);
    FlxG.camera.focusOn( new FlxPoint(_player.x, _player.y));
    FlxG.camera.follow(_player, FlxCamera.STYLE_LOCKON, 5);

    _hud = new HUD();
    _hud.maxCoins = _maxCoins;
    add(_hud);
  }
  
  /**
   * Function that is called when this state is destroyed - you might want to 
   * consider setting all objects this state uses to null to help garbage collection.
   */
  override public function destroy():Void
  {
    super.destroy();
    _map = null;
    _tileMap = null;

    _hud = null;
    _hudCoinsMap = null;

    _player = null;
    _playerPos = null;

    _coins = null;


    _projectiles = null;
    _Ecrunchers = null;
    _Espectres = null;

    _bouncyWalls = null;


    _playerTrails = null;
    _music = null;
  }


  private function setupMap():Void
  {
    var UP:Int = FlxObject.UP;
    var DOWN:Int = FlxObject.DOWN;
    var LEFT:Int = FlxObject.LEFT;
    var RIGHT:Int = FlxObject.RIGHT;
    var NONE:Int = FlxObject.NONE;
    var ANY:Int = FlxObject.ANY;

    _map = new FlxOgmoLoader(PlayList.instance.currentLevelName);
    _tileMap = _map.loadTilemap(Tilemapbmp, 16, 16, "walls");

    _tileMap.setTileProperties(0, NONE);
    _tileMap.setTileProperties(1, NONE, voidCallback);
    _tileMap.setTileProperties(0+_flashTileOffset, NONE);
    _tileMap.setTileProperties(1+_flashTileOffset, NONE);

    // Walkable, first row
    for(i in 2...16)
    {
      _tileMap.setTileProperties(i, NONE);
      _tileMap.setTileProperties(i+_flashTileOffset, NONE);
    }

    // Walkable, pretty tiles
    for(i in 27...32)
    {
      _tileMap.setTileProperties(i, NONE);
      _tileMap.setTileProperties(i+_flashTileOffset, NONE);

      _tileMap.setTileProperties(i+16, NONE);
      _tileMap.setTileProperties(i+16+_flashTileOffset, NONE);

      _tileMap.setTileProperties(i+32, NONE);
      _tileMap.setTileProperties(i+32+_flashTileOffset, NONE);
    }

    // Bouncy walls
    for(i in 23...27)
    {
      _tileMap.setTileProperties(i, ANY, bouncyCallback);
      _tileMap.setTileProperties(i+_flashTileOffset, ANY, bouncyCallback);
      _tileMap.setTileProperties(i+16, ANY, bouncyCallback);
      _tileMap.setTileProperties(i+16+_flashTileOffset, ANY, bouncyCallback);
    }

    // One-way tiles
    _tileMap.setTileProperties(54, UP|DOWN|LEFT);
    _tileMap.setTileProperties(54+_flashTileOffset, UP|DOWN|LEFT);
    _tileMap.setTileProperties(55, LEFT|DOWN|RIGHT);
    _tileMap.setTileProperties(55+_flashTileOffset, LEFT|DOWN|RIGHT);
    _tileMap.setTileProperties(56, UP|DOWN|RIGHT);
    _tileMap.setTileProperties(56+_flashTileOffset, UP|DOWN|RIGHT);
    _tileMap.setTileProperties(57, LEFT|UP|RIGHT);
    _tileMap.setTileProperties(57+_flashTileOffset, LEFT|UP|RIGHT);

    add(_tileMap);
    _map.loadEntities(placeEntities, "entities");
  }



  /**
   * Function that is called once every frame.
   */
  override public function update():Void
  {
    if(_player.reviving) return;
    // Change level for debuggin

#if debug
    if(FlxG.keys.anyPressed(["ONE"])) PlayList.instance.loadLevel(0);
    if(FlxG.keys.anyPressed(["TWO"])) PlayList.instance.loadLevel(1);
    if(FlxG.keys.anyPressed(["THREE"])) PlayList.instance.loadLevel(2);
    if(FlxG.keys.anyPressed(["FOUR"])) PlayList.instance.loadLevel(3);
    if(FlxG.keys.anyPressed(["FIVE"])) PlayList.instance.loadLevel(4);
    if(FlxG.keys.anyPressed(["SIX"])) PlayList.instance.loadLevel(5);
    if(FlxG.keys.anyPressed(["SEVEN"])) PlayList.instance.loadLevel(6);
    if(FlxG.keys.anyPressed(["EIGHT"])) PlayList.instance.loadLevel(7);
    if(FlxG.keys.anyPressed(["NINE"])) PlayList.instance.loadLevel(8);
    if(FlxG.keys.anyPressed(["ONE","TWO","THREE","FOUR","FIVE","SIX","SEVEN","EIGHT","NINE"]) ) killPlayer();
#end

    // ============
    // COLLISIONS
    // ============

    FlxG.collide(_player, _decoration);
    FlxG.collide(_player, _tileMap, playerCollidesTilemap);
    FlxG.overlap(_player, _coins, playerOverlapsCoin);
    FlxG.overlap(_player, _projectiles, playerOverlapsProjectile);
    FlxG.overlap(_player, _Ecrunchers, playerOverlapsCruncher);
    FlxG.overlap(_player, _Espectres, playerOverlapsSpectre);

    FlxG.collide(_Ecrunchers, null, ECrunchersOverlapEachother);

    FlxG.overlap(_Espectres, null, ESpectresOverlapEachother);
    FlxG.collide(_Espectres, _tileMap);


    // ============
    // HUD STUFF
    // ============
    _hud.updateHUD(
      _player.dashCooldown,
      _player.dashing,
      _coins.countLiving(),
      ScoreManager.instance.score
    );
    _hudCoinsMap.updateTarget(_player.x, _player.y);

    updateFlashings();


    // ============
    // DAShING - spam trails
    // ============
    if(_player.dashing)
    {
      _trailIterator ++;
      if(_trailIterator >= _trailGenerateAt)
      {
        _trailIterator = 0;
        var newTrail = new PlayerTrail(_player.x - _player.offset.x, _player.y - _player.offset.y);
        _playerTrails.add(newTrail);
      }
    }



    // Camera fix?
    FlxG.camera.x = Math.round( FlxG.camera.x );
    FlxG.camera.y = Math.round( FlxG.camera.y );

    // Attach HuD Coin map to HuD
    // _hudCoinsMap.x = FlxG.camera.x;
    // _hudCoinsMap.y = FlxG.camera.y;


    super.update();
  }







  /**
   * Place all entities from Ogmo project map
   */
  private function placeEntities(entityName:String, entityData:Xml):Void
  {
    var x:Int = Std.parseInt(entityData.get("x"));
    var y:Int = Std.parseInt(entityData.get("y"));
    x = Math.round(x);
    y = Math.round(y);

    if (entityName == "player")
    {
      _player = new Player(x, y);
    }
    else if (entityName == "coin")
    {
      // if(_coins.length == 0){
        var coin = new Coin(x, y);
        _coins.add(coin);
        _maxCoins ++;
      // }
    }
    else if (entityName == "ECruncher")
    {
      var enemy = new ECruncher(x, y);
      _Ecrunchers.add(enemy);
    }
    else if (entityName == "ESpectre")
    {
      // if(_Espectres.members.length <= 0){
        var enemy = new ESpectre(x, y);
        _Espectres.add(enemy);
      // }
    }
    else if(entityName == "boulder")
    {
      var deco = new FlxSprite( Math.round(x), Math.round(y));
      deco.loadGraphic(Bouldersbmp, true, 32, 32);
      deco.animation.add("idle", [0,1,2,3], 0);
      deco.animation.play("idle");
      deco.animation.frameIndex = FlxRandom.intRanged(0,3);

      deco.offset.x = 4;
      deco.offset.y = 4;
      deco.setSize(24, 24);

      deco.immovable = true;

      _decoration.add(deco);
    }
  }




  /**
   * Flash the screen by changing tiles
   */
  public function flashHUD(?duration:Int = 9):Void
  {
    flashOn(duration);
  }

  private function updateFlashings():Void
  {
    if(_flashing)
    {
      _flashDur--;
      // trace(_flashDur);

      if(_flashDur <= 0)
      {
        flashOff();
      }
    }
  }
  private function flashOn(duration:Int):Void
  {
    // trace("Flash ON!");
    // Pathetic whole white screen flash
    // _hud.flash(duration);

    if(!_flashing)
    {
      // Swap tiles!
      var tiles = _tileMap.getData();
      for(i in 0...tiles.length)
      {
        _tileMap.setTileByIndex(i, tiles[i] + _flashTileOffset);
      }

      _flashing = true;
      _flashDur = duration;
    }
    else
    {
      if(duration > _flashDur)
      {
        _flashDur = duration;
      }
    }
  }
  private function flashOff():Void
  {
    // trace("Flash off!");
    _flashing = false;

    var tiles = _tileMap.getData();

    for(i in 0...tiles.length)
    {
      _tileMap.setTileByIndex(i, tiles[i] - _flashTileOffset);
    }
  }








  /**
   * Player colides Tilemap
   */
  private function playerCollidesTilemap(P:FlxObject, T:FlxObject):Void
  {
    if(_player.dashing)
    {
      _player.bounce(bounceSprite(_player, _player.direction));
    }
  }

  /**
   * Gets new direction for sprite based on current direction and which face of the tile it's touching
   * @param  S   Sprite to be redirected
   * @param  dir Current sprite's direction
   * @return     New direction Enum, see FlxObject.DOWN etc
   */
  private function bounceSprite(S:FlxSprite, dir:Int):Int
  {
    var DOWN = FlxObject.DOWN;
    var LEFT = FlxObject.LEFT;
    var UP = FlxObject.UP;
    var RIGHT = FlxObject.RIGHT;
    var newDirection = 0x0000;

    if (S.touching == DOWN|LEFT){
      newDirection = UP|RIGHT;
    }
    if (S.touching == DOWN|RIGHT){
      newDirection = UP|LEFT;
    }
    if (S.touching == UP|LEFT){
      newDirection = DOWN|RIGHT;
    }
    if (S.touching == UP|RIGHT){
      newDirection = DOWN|LEFT;
    }

    if (S.touching == UP){
      if(dir == UP|RIGHT) newDirection = DOWN|RIGHT;
      if(dir == UP|LEFT) newDirection = DOWN|LEFT;
      if(dir == UP) newDirection = DOWN;
    }

    if (S.touching == DOWN){
      if(dir == DOWN|RIGHT) newDirection = UP|RIGHT;
      if(dir == DOWN|LEFT) newDirection = UP|LEFT;
      if(dir == DOWN) newDirection = UP;
    }

    if (S.touching == LEFT){
      if(dir == LEFT|UP) newDirection = RIGHT|UP;
      if(dir == LEFT|DOWN) newDirection = RIGHT|DOWN;
      if(dir == LEFT) newDirection = RIGHT;
    }

    if (S.touching == RIGHT){
      if(dir == RIGHT|UP) newDirection = LEFT|UP;
      if(dir == RIGHT|DOWN) newDirection = LEFT|DOWN;
      if(dir == RIGHT) newDirection = LEFT;
    }
    return newDirection;
  }


  /**
   * Player over Void!
   */
  private function voidCallback(T:FlxObject, P:FlxObject):Void
  {
    var type = Type.getClassName(Type.getClass(P));
    // trace(type);
    if(type == "Player")
    {
      _player.onVoid = true;
      if(!_player.dashing && !_player.reviving)
      {
        // Faulty below. Can land between 4 void tiles, right in the middle...
        if(T.overlapsPoint( _player.getMidpoint()))
        {
          ScoreManager.instance.reducePointsFor("void");
          killPlayer(true);
        }
      }
    }
    else if(type == "ECruncher")
    {
      if(cast(P, ECruncher).alive)
      {
        cast(P, ECruncher).kill();
        ScoreManager.instance.addPointsFor("spectreVoid");
      }
    }
    
  }

  /**
   * Player collides BouncyWall
   */
  private function bouncyCallback(T:FlxObject, P:FlxObject):Void
  {
    if(_player.dashing)
    {
      _player.bounce(bounceSprite(_player, _player.direction), true);

      if(T.touching == FlxObject.LEFT || T.touching == FlxObject.RIGHT)
      {
        FlxG.camera.shake(0.05, 0.13, null, true, FlxCamera.SHAKE_HORIZONTAL_ONLY);
      }
      else
      {
        FlxG.camera.shake(0.05, 0.13, null, true, FlxCamera.SHAKE_VERTICAL_ONLY);
      }
      Achievements.instance.thisIsHowIBounce();
      flashHUD(3);

      // var ringBlink = new RingBlink(_player.x,_player.y);
      // add(ringBlink);
    }
  }

  /**
   * Player over Coin
   */
  private function playerOverlapsCoin(P:FlxObject, C:FlxObject):Void
  {
    if(_player.dashing)
    {
      if (P.alive && P.exists && C.alive && C.exists)
      {
        _player.collectedCoin();
        C.kill();
        ScoreManager.instance.addPointsFor("coin");
      }
      // trace("Coins left: "+_coins.countLiving());
      if (_coins.countLiving() == 0)
      {
        // trace("pre-levelFinished");
        levelFinished();
      }
      else
      {
        var newCoins = new Array<FlxSprite>();
        _coins.forEachAlive(function(spr){
          newCoins.push(spr);
        });
        _hudCoinsMap.updatePoints(newCoins);
      }
    }
    else if(!_player.dashing && C.alive)
    {
      FlxObject.separate(P,C);
    }
  }


  private function playerOverlapsCruncher(P:FlxObject, E:FlxObject):Void
  {
    if(_player.dashing)
    {
      // Kill it! Points!
      if(E.alive)
      {
        E.kill();
        ScoreManager.instance.addPointsFor("cruncher");
        FlxG.camera.shake(0.02, 0.2);
      }
    }
    else
    {
      if(E.alive && _player.alive){
        // Well, you're dead
        killPlayer();
      }
    }
  }


  private function playerOverlapsSpectre(P:FlxObject, E:FlxObject):Void
  {
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

  private function playerOverlapsProjectile(P:FlxObject, E:FlxObject):Void
  {
    if(!_player.dashing)
    {
      if(E.alive && _player.alive)
      {
        // Well, you're dead
        killPlayer();
      }
    }
  }

  private function ESpectresOverlapEachother(A:FlxObject, B:FlxObject):Void
  {
    if(A.alive && B.alive)
    {
      // trace("Spectres collide");
      cast(A, ESpectre).stepBack();
    }
  }
  private function ESpectresOverlapTilemap(S:FlxObject, T:FlxObject):Void
  {
    // Didn't had time to do it well...
    // trace("Spectres collides wall");
    // trace(T);
    // cast(S, ESpectres).stepBack();
  }

  private function ECrunchersOverlapEachother(A:FlxObject, B:FlxObject):Void
  {
    if(A.alive && B.alive)
    {
      FlxObject.separate(A,B);
    }
  }





  private function levelFinished():Void
  {
    if(_music.playing)
    {
      // trace("stopping music");
      _music.stop();
    }
    // trace("is last level? "+PlayList.instance.isLastLevel);
    if(!PlayList.instance.isLastLevel)
    {
      // trace("  nope");
      FlxG.switchState(new LevelComplete());
    }
    else
    {
      // trace("  yep");
      FlxG.switchState(new TheEnd());
    }
  }



  /**
   * With this, enemies know where ther player is  in the world
   * Used in their fetchTargetPosition()
   * @return Player's position in world
   */
  public function getPlayerPosition():FlxPoint
  {
    _playerPos.x = _player.x + 8;
    _playerPos.y = _player.y + 8;
    return _playerPos;
  }

  /**
   * Kill player and optionally revive him into last known safe position
   * @param  void if true, then player can go back to last known position
   */
  private function killPlayer(?void:Bool = false):Void
  {
    if(void)
    {
      // trace("I'm trying to get you back at safe spot...");
      Achievements.instance.diedFromVoid();
      flashHUD(2);
      // if(_music.playing) _music.pause();
      _player.reviveAtSafeSpot();
    }
    else
    {
      // Man, you're done!
      _music.stop();
      Achievements.instance.diedFromMonster();
      _player.kill();
    }
  }

  /**
   * Adds puff one puff particle in the world. Used with player's dashing
   * @param  ?X [description]
   * @param  ?Y [description]
   * @return    [description]
   */
  public function puffSmoke(?X:Float = 0, ?Y:Float = 0):PlayerTrail
  {
    var newTrail = new PlayerTrail(X, Y);
    _playerTrails.add(newTrail);
    return newTrail;
  }


  public function addProjectile(S:Dynamic):Void
  {
    _projectiles.add(cast(S, FlxSprite));
  }


  public function addProjectiles(A:Array<Dynamic>):Void
  {
    for(s in A)
    {
      _projectiles.add(cast(s, FlxSprite));
    }
  }

}
