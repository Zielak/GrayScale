
package ;

import flixel.addons.api.FlxGameJolt;
import flash.utils.ByteArray;

#if flash
@:file("zielak.private") class MyKey extends ByteArray { }
#end

class Achievements 
{

  /**
   * Complete whole game without dying from the void.
   */
  private var _diedFromVoid:Bool;
  public function diedFromVoid():Void{
    // trace("diedFromVoid");
    if(!_diedFromVoid){
      _diedFromVoid = false;
    }
  }


  /**
   * Complete whole game without dying from any monster.
   */
  private var _diedFromMonster:Bool;
  public function diedFromMonster():Void{
    // trace("diedFromMonster");
    if(!_diedFromMonster){
      _diedFromMonster = false;
    }
  }


  /**
   * Dash 10 times into the void and die. I'm sorry.
   */
  private var _shamelessDiver:Int;
  public function shamelessDiver():Void{
    // trace("shamelessDiver");
    if(_shamelessDiver < 10){
      _shamelessDiver ++;
      if(_shamelessDiver >= 10){
#if flash
        FlxGameJolt.addTrophy(10177);
#end
      }
    }
  }


  /**
   * Prolong your dash 30 times while bouncing off Energy walls during one game session.
   */
  private var _thisIsHowIBounce:Int;
  public function thisIsHowIBounce():Void{
    // trace("thisIsHowIBounce");
    if(_thisIsHowIBounce < 30){
      _thisIsHowIBounce ++;
      if(_thisIsHowIBounce >= 30){
#if flash
        FlxGameJolt.addTrophy(10180);
#end
      }
    }
  }

  /**
   * Accumulate 10 000 pixels while dashing, in one game-play session.
   */
  private var _spaceTimeTraveller:Int;
  public function spaceTimeTraveller():Void{
    // trace("spaceTimeTraveller");
    if(_spaceTimeTraveller < 10000){
      _spaceTimeTraveller ++;
      if(_spaceTimeTraveller >= 10000){
#if flash
        FlxGameJolt.addTrophy(10174);
#end
      }
    }
  }



  /**
   * Finish game
   */
  public function finishedGame():Void{
#if flash
    FlxGameJolt.addTrophy(10293);
#end
  }









  public function sendScore():Void
  {
    // trace("Achievements Sending Score");
#if flash
    var score = ScoreManager.instance.mainScore;
    FlxGameJolt.addScore(Std.string(score), score, 33097, true);
#end
  }




  /**
   * Singleton stuff
   * Determines whether an instance of this class can be created.
   */
  private static var canInstanciate:Bool;
  /**
   * The only instance of this class.
   */
  public static var instance(get, null):Achievements;
  
  public function new():Void {
    if (false == canInstanciate) {
      throw "Invalid Singleton access. Use Achievements.instance.";
    }
  }

  private static function get_instance():Achievements {
    if (null == instance) {
      // Set the flag to true, so the instance can be created.
      canInstanciate = true;
      // Create the only instance.
      instance = new Achievements();
      // Set the flag back to false, so no further instances can be created.
      canInstanciate = false;
    }
    return instance;
  }









  public function resetGlobalTrophies():Void
  {
    _diedFromVoid = false;
    _diedFromMonster = false;

    _shamelessDiver = 0;
    _thisIsHowIBounce = 0;
  }

  public function resetLevelTrophies():Void
  {
      
  }
  public function initAchievements():Void
  {
    // trace("initAchievements");
    resetGlobalTrophies();
    resetLevelTrophies();

#if flash
    // trace("check FlxGameJolt.initialized");
    if(!FlxGameJolt.initialized){
      // trace("FlxGameJolt.initialized = true");
      var bytearray = new MyKey(); // This will load your private key data as a ByteArray.
      var keystring = bytearray.readUTFBytes( bytearray.length ); // This converts the ByteArray to a string.

      // trace("FlxGameJolt.init");
      FlxGameJolt.init(30964, keystring);

      // FlxGameJolt.authUser("Zielak", "0471f3" );
      // trace("FlxGameJolt.authUser");
      FlxGameJolt.authUser();
    }
#end
  }

  public function sendGlobalTrophies():Void
  {
    if(!_diedFromMonster){

#if flash
      FlxGameJolt.addTrophy(10281);
#end
    }

    if(!_diedFromVoid){

#if flash
      FlxGameJolt.addTrophy(10182);
#end
    }
  }

}
