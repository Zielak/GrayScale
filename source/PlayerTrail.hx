
package ;

import flash.display.BitmapData;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxRandom;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

using flixel.util.FlxSpriteUtil;


@:bitmap("assets/images/playertrails.png") class PlayerTrailsbmp extends BitmapData {}

class PlayerTrail extends FlxSprite
{

  private var _lifeTime:Float;
  private var _dyingTime:Float;
  private var _deathCounter:FlxTween;
  private var _fps:Int;

  public function new(X:Float, Y:Float):Void
  {
    X = Math.round( X );
    Y = Math.round( Y );
    super(X,Y);

    _lifeTime = FlxRandom.floatRanged(0.1, 0.2);
    _dyingTime = FlxRandom.floatRanged(0.5, 0.8);
    _fps = Math.round(FlxRandom.intRanged(10, 30)/2);

    loadGraphic(PlayerTrailsbmp, true, 16, 16);

    animation.add("death", [0, 1, 2, 3, 4, 5], _fps, false);
    // trace('fps: '+_fps);
    // trace('_dyingTime: '+ _dyingTime);
  }





  override public function update():Void
  {
    if(alive)
    {
      _lifeTime -= FlxG.elapsed;
      if(_lifeTime <= 0)
      {
        kill();
      }
    }
    else if(!alive && exists)
    {
      _dyingTime -= FlxG.elapsed;
      if(_dyingTime <= 0)
      {
        death();
      }
    }

    super.update();
  }

  override public function kill():Void
  {
    alive = false;
    animation.play("death");
    flicker(3, 0.05);
  }
  private function death():Void
  {
    exists = false;
  }

}
