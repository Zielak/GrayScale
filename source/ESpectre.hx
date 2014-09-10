
package ;

import flash.display.BitmapData;
import flash.media.Sound;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.util.FlxAngle;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;

using flixel.util.FlxSpriteUtil;

enum SpectreMind{
  Deciding;
  Searching;
  Flying;
  Attacking;
  Dying;
}

@:bitmap("assets/images/spectre.png") class ESpectrebmp extends BitmapData {}

#if flash
@:sound("assets/sounds/sfx_spectre_alert.mp3") class SpectreSalert extends Sound {}
@:sound("assets/sounds/sfx_spectre_attack.mp3") class SpectreSattack extends Sound {}
@:sound("assets/sounds/sfx_spectre_death.mp3") class SpectreSdeath extends Sound {}
#else
@:sound("assets/sounds/sfx_spectre_alert.ogg") class SpectreSalert extends Sound {}
@:sound("assets/sounds/sfx_spectre_attack.ogg") class SpectreSattack extends Sound {}
@:sound("assets/sounds/sfx_spectre_death.ogg") class SpectreSdeath extends Sound {}
#end

class ESpectre extends FlxSprite
{
  private var alertS:FlxSound;
  private var attackS:FlxSound;
  private var deathS:FlxSound;

  private function initSounds():Void
  {
    alertS = new FlxSound();
    alertS.loadEmbedded(SpectreSalert);

    attackS = new FlxSound();
    attackS.loadEmbedded(SpectreSattack);

    deathS = new FlxSound();
    deathS.loadEmbedded(SpectreSdeath);
  }
  private function setVolumeByDistance(distance:Float):Void
  {
    if(distance > _viewDistance) return;
    var vol:Float = -(distance / _viewDistance) + 1;

    // trace("dist:   "+distance);
    // trace("volume: "+vol);

    alertS.volume = vol*0.8;
  }



  private var _targetPos:FlxPoint = new FlxPoint();
  private var _targetAngle:Float = 0;
  private var _inRange:Bool = false;

  private var _state:EnumValue = Deciding;
  private var _searchingTime:Float = 0.75;
  private var _flyingTime:Float = 1.35;
  private var _attackingTime:Float = 0.28;

  private var _currentTime:Float = 0;

  private var _elapsed:Float;


  private var _dyingTime:Float = 2.2;
  private var _flickering:Bool = false;


  private var _viewDistance:Int = 100;
  private var _attackDistance:Int = 40;



  
  public var _flySpeed:Float = 36;
  public var _attackSpeed:Float = 150;
  public var speed:Float = 36;  

  public function new(X:Float=0, Y:Float=0)
  {
    super(X,Y);

    loadGraphic(ESpectrebmp, true, 16, 16);

    var _fps:Int = FlxRandom.intRanged(3, 8);
    animation.add("flying", [0, 1], _fps, true);
    animation.add("attack", [2], 1, false);
    animation.add("death",  [3, 4], 15, true);

    animation.play("flying");
    
    // setFacingFlip(FlxObject.RIGHT | FlxObject.DOWN, true, false);

    drag.x = drag.y = 600;

    setSize(10, 10);
    offset.set(3, 3);

    initSounds();

    // velocity.x = velocity.y = 120;
  }




  override public function update():Void
  {
    _elapsed = FlxG.elapsed;

    // what to do?
    if(alive)
    {
      switch (_state) {
        case Deciding:
          startSearching();
        case Flying:
          flyToPlayer();
        case Attacking:
          attackPlayer();
      }
      updateCooldowns();
    }


    setVolumeByDistance(getGraphicMidpoint().distanceTo(_targetPos));


    // Are we dying?
    if(!alive && exists)
    {
      _dyingTime -= _elapsed;
      if(_dyingTime <= 0)
      {
        death();
      }else if( _dyingTime < 1 && !_flickering){
        _flickering = true;
        flicker(3, 0.05);
      }
    }

    super.update();
  }



  private function updateCooldowns():Void
  {
    _currentTime -=_elapsed;
    // trace('curTime: '+_currentTime);
    // trace('elapsed: '+_elapsed);

    if(_currentTime <= 0){
      // trace('current time = '+_currentTime+' and switching action');
      switch (_state) {
        case Searching:
          fetchTargetPosition();
          startFlying();
        case Flying:
          startSearching();
        case Attacking:
          startSearching();
      }
    }
  }



  private function startSearching():Void
  {
    // trace('ESpectre: searching');
    _currentTime = _searchingTime + FlxRandom.floatRanged(-0.03, 0.03);
    _state = Searching;

    // trace("Tardet pos: "+_targetPos.toString() );
    // trace("Tardet ang: "+_targetAngle );

    speed = 0;

    animation.play("flying");
  }

  private function startFlying():Void
  {
    if(getGraphicMidpoint().distanceTo(_targetPos) > _viewDistance){
      startSearching();
      return;
    }

    _currentTime = _flyingTime;
    _state = Flying;

    speed = _flySpeed;
    alertS.play();
  }

  private function startAttacking():Void
  {
    // trace('ESpectre: ATTACK');
    _currentTime = _attackingTime;
    _state = Attacking;

    speed = _attackSpeed;

    fetchTargetPosition();

    animation.play("attack");
    alertS.stop();
    attackS.play(true);
  }


  /**
   * Gets player position from the outside
   */
  private function fetchTargetPosition():Void
  {
    _targetPos = cast(FlxG.state, PlayState).getPlayerPosition();
    _targetAngle = FlxAngle.angleBetweenPoint(this, _targetPos, true);

    // Randomize a bit
    _targetAngle += FlxRandom.floatRanged(-20, 20);
  }

  private function flyToPlayer():Void
  {
    FlxAngle.rotatePoint(speed, 0, 0, 0, _targetAngle, velocity);

    // fetchTargetPosition();
    if(getGraphicMidpoint().distanceTo(_targetPos) < _attackDistance){
      startAttacking();
    }
  }

  private function attackPlayer():Void
  {
    FlxAngle.rotatePoint(speed, 0, 0, 0, _targetAngle, velocity);
  }



  override public function kill():Void
  {
    alive = false;
    animation.play("death");
    deathS.play();
  }
  private function death():Void
  {
    exists = false;
  }
}
