package ;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxAngle;
import flixel.util.FlxPoint;
import flixel.group.FlxTypedGroup;

using flixel.util.FlxSpriteUtil;

class HUDCoinMap extends FlxTypedGroup<FlxSprite>
{

  private var _points:Array<FlxPoint>;
  private var _angles:Array<Float>;
  private var _distances:Array<Float>;

  private var _targetPoint:FlxPoint;

  private var _halfWidth:Int;
  private var _halfHeight:Int;

  private var _r:Int = 45;
  private var _visibilityDistance:Float = 80;

  public function new() 
  {
    super();

    _halfWidth = Std.int(FlxG.width*0.5);
    _halfHeight = Std.int(FlxG.height*0.5);

    _targetPoint = new FlxPoint(_halfWidth, _halfHeight);

  }

  override public function update():Void
  {
    if(members.length > 0)
    {
      for(i in 0..._points.length)
      {
        _angles[i] = FlxAngle.getAngle( _targetPoint , _points[i]) - 90;
        _distances[i] = _points[i].distanceTo(_targetPoint);

        if(_distances[i] < _visibilityDistance)
        {
          members[i].visible = false;
        }
        else
        {
          members[i].visible = true;
        }
      }
      for(i in 0..._points.length)
      {
        // trace("_angles[i]: "+_angles[i]);
        // trace(_halfWidth + Std.int( Math.cos( FlxAngle.asRadians(_angles[i]) ) * _r));
        members[i].x = _halfWidth + Std.int( Math.cos( FlxAngle.asRadians(_angles[i]) ) * _r);
        members[i].y = _halfHeight + Std.int( Math.sin( FlxAngle.asRadians(_angles[i]) ) * _r);
      }
    }
  }

  /**
   * Updates position of every point in the circle. 
   * @param  arr<FlxSprite> Array of coins FlxSprite objects from the level
   */
  public function updatePoints(arr:Array<FlxSprite>):Void
  {
    var sprite:FlxSprite;
    _points = new Array<FlxPoint>();
    _angles = new Array<Float>();
    _distances = new Array<Float>();
    members = new Array<FlxSprite>();

    for(s in arr)
    {
      _points.push( new FlxPoint(s.x, s.y) );
      _angles.push( 0 );
      _distances.push( 0 );

      sprite = new FlxSprite().makeGraphic(3, 3);
      sprite.drawRect(0, 0, 3, 3, GBPalette.C4);
      sprite.scrollFactor.set();
      add(sprite);
    }
  }

  /**
   * Target is our player, point of view to generate coin-pointers positions on the HUD
   * @param  X target X position in the world
   * @param  Y target Y position in the world
   */
  public function updateTarget(X:Float, Y:Float):Void
  {
    _targetPoint.x = X;
    _targetPoint.y = Y;
  }

}
