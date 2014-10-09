
package enemies;

import flash.display.BitmapData;
import flash.media.Sound;
// #if flash
// import flash.media.Sound;
// #else
// import openfl.media.Sound;
// #end

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.util.FlxAngle;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxMath;


enum SpectreMind{
  Deciding;
  Searching;
  Hiding;
  Appearing;
  Armed;
  Attacking;
  Dying;
}


@:bitmap("assets/images/spectre.png") class Spectrebmp extends BitmapData {}

#if flash
@:sound("assets/sounds/sfx_spectre_appear.mp3") class SpectreSappear extends Sound {}
@:sound("assets/sounds/sfx_spectre_attack.mp3") class SpectreSattack extends Sound {}
@:sound("assets/sounds/sfx_spectre_charge.mp3") class SpectreScharge extends Sound {}
@:sound("assets/sounds/sfx_spectre_death.mp3") class SpectreSdeath extends Sound {}
@:sound("assets/sounds/sfx_spectre_disappear.mp3") class SpectreSdisappear extends Sound {}
#else
@:sound("assets/sounds/sfx_spectre_appear.ogg") class SpectreSappear extends Sound {}
@:sound("assets/sounds/sfx_spectre_attack.ogg") class SpectreSattack extends Sound {}
@:sound("assets/sounds/sfx_spectre_charge.ogg") class SpectreScharge extends Sound {}
@:sound("assets/sounds/sfx_spectre_death.ogg") class SpectreSdeath extends Sound {}
@:sound("assets/sounds/sfx_spectre_disappear.ogg") class SpectreSdisappear extends Sound {}
#end


class Spectre extends Enemy
{

  private function initSounds():Void
  {
    var s:FlxSound;


    s = new FlxSound();
    s.loadEmbedded(SpectreSappear);
    addSound("appear", s );

    s = new FlxSound();
    s.loadEmbedded(SpectreSattack);
    addSound("attack", s, 1.5 );

    s = new FlxSound();
    s.loadEmbedded(SpectreScharge);
    addSound("charge", s, 0.4 );

    s = new FlxSound();
    s.loadEmbedded(SpectreSdeath);
    addSound("death", s, 1.7 );

    s = new FlxSound();
    s.loadEmbedded(SpectreSdisappear);
    addSound("disappear", s );
  }

  private var _targetPos:FlxPoint = new FlxPoint();
  private var _targetAngle:Float = 0;
  private var _targetDirection:Int = 0x0000;
  private var _inRange:Bool = false;

  private var _shotMade:Bool = false;



  private var _armDistance:Int = 50;
  private var _attackDistance:Int = 32;

  // Randomize movement, 1,2,3
  private var _moveBy:Int = 16;


  override public function new(X:Float=0, Y:Float=0)
  {
    super(X,Y);

    loadGraphic(Spectrebmp, true, 16, 16);

    animation.add("appear", [0, 1, 2, 3, 4], 20, false);
    animation.add("hide",  [4, 3, 2, 1, 0], 20, false);
    animation.add("armed",  [5], 1, false);
    animation.add("attack",  [6, 7], 30, true);

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
  override public function update():Void
  {
    _elapsed = FlxG.elapsed;

    // what to do?
    if(alive)
    {
      switch (_state) {
        case Searching:
          lookForPlayer();
        case Armed:
          lookForPlayer();
      }
      updateCooldowns();
    }
    super.update();
  }

  private function updateCooldowns():Void
  {
    _currentTime -= _elapsed;

    // Change state when finished
    if(_currentTime <= 0){
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
      }
    }
    // Delayed attacking
    if(_state == Attacking && _currentTime <= _time.attacking*0.8){
      shoot();
    }
  }

  /**
   * Start searching for the player
   */
  private function startSearching():Void
  {
    _currentTime = _time.searching;
    _state = Searching;
    _shotMade = false;
  }

  private function startHiding():Void
  {
    if(getGraphicMidpoint().distanceTo(_targetPos) > _viewDistance){
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

  private function startAppearing():Void
  {
    // trace("Start Appearing");
    _currentTime = _time.appearing;
    _state = Appearing;
    animation.play("appear");
    playSound("appear");
  }

  private function startArming():Void
  {
    // trace("Start Arming!");
    _state = Armed;
    animation.play("armed");
    playSound("charge");
  }

  private function moveToNextTile():Void
  {
    // trace("Move to next tile");
    // Move to next available tile

    _moveBy = FlxRandom.intRanged(1,2);

    switch(_targetDirection){
      case FlxObject.UP:
        y -= 16*_moveBy;
      case FlxObject.DOWN:
        y += 16*_moveBy;
      case FlxObject.LEFT:
        x -= 16*_moveBy;
      case FlxObject.RIGHT:
        x += 16*_moveBy;
    }

    startAppearing();
  }
  /**
   * Spectre just stedded into the wall or something, he must get back
   */
  public function stepBack():Void
  {
    switch(_targetDirection){
      case FlxObject.UP:
        y += 16*_moveBy;
      case FlxObject.DOWN:
        y -= 16*_moveBy;
      case FlxObject.LEFT:
        x += 16*_moveBy;
      case FlxObject.RIGHT:
        x -= 16*_moveBy;
    }
    startAppearing();
  }

  private function lookForPlayer():Void
  {
    fetchTargetPosition();
    if(getGraphicMidpoint().distanceTo(_targetPos) < _armDistance)
    {
      // hold, hooold
      if(_state != Armed) startArming();

      if(getGraphicMidpoint().distanceTo(_targetPos) < _attackDistance)
      {
        // ATTACK!
        if(_state != Attacking) startAttacking();
      }
    }else{
      if(_state != Searching){
        // reset state when player leaves _armDistance
        startSearching();
      }
    }
  }

  private function startAttacking():Void
  {
    // trace("Start Attacking!");
    _state = Attacking;
    animation.play("attack");
    _currentTime = _time.attacking;
    playSound("attack");
  }

  private function shoot():Void
  {
    if(!_shotMade)
    {
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
  private function fetchTargetPosition():Void
  {
    _targetPos = cast(FlxG.state, PlayState).getPlayerPosition();
    _targetAngle = FlxAngle.angleBetweenPoint(this, _targetPos, true);

    // Just 4 directions
    if( FlxMath.inBounds(_targetAngle, -45, 45) ){
      _targetDirection = FlxObject.RIGHT;
    }else if( FlxMath.inBounds(_targetAngle, 45, 135) ){
      _targetDirection = FlxObject.DOWN;
    }else if( Math.abs(_targetAngle) > 135 ){
      _targetDirection = FlxObject.LEFT;
    }else{
      _targetDirection = FlxObject.UP;
    }

  }


  override public function kill():Void
  {
    stopSound("appear");
    stopSound("attack");
    stopSound("charge");
    stopSound("disappear");
    playSound("death");

    alive = false;

    var puff:PlayerTrail;
    puff = cast(FlxG.state, PlayState).puffSmoke(x,y);
    puff.velocity.x = 6;
    puff.velocity.y = -6;
    puff = cast(FlxG.state, PlayState).puffSmoke(x,y);
    puff.velocity.x = 6;
    puff.velocity.y = 6;
    puff = cast(FlxG.state, PlayState).puffSmoke(x,y);
    puff.velocity.x = -6;
    puff.velocity.y = 6;
    puff = cast(FlxG.state, PlayState).puffSmoke(x,y);
    puff.velocity.x = -6;
    puff.velocity.y = -6;

    exists = false;
  }

}
