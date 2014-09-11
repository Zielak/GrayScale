
package ;

class ScoreManager
{

  private var _mainScore:Int;
  public var mainScore(get, null):Int;
  public function get_mainScore():Int{
    return _mainScore;
  }


  private var _score:Int;
  public var score(get, null):Int;
  public function get_score():Int{
    return _score;
  }
  public function addPoints(val:Int):Void
  {
    if(val > 0){
      _score += val;
    }
  }
  public function addPointsFor(str:String):Void
  {
    switch(str){
      case "cruncher":   // ghost - Gray Cruncher
        _score += 150;
      case "spectre":    // spy - Tile Spectre
        _score += 200;
      case "spectreVoid":
        _score += 350;
      case "coin":
        _score += 100;
      default:
        _score += 1;
    }
  }
  public function reducePointsFor(str:String):Void
  {
    switch (str) {
      case "void":
        _score -= 50;
        Achievements.instance.shamelessDiver();
    }
    if(_score < 0) _score = 0;
    // trace("reduced points, new it: "+_score);
  }
  public function rememberLevelScore():Void
  {
    _mainScore += _score;
  }
  public function resetAllScores():Void
  {
    resetMainScore();
    resetLevelScore();
  }
  public function resetMainScore():Void
  {
    _mainScore = 0;
  }
  public function resetLevelScore():Void
  {
    _score = 0;
  }




  /**
   * Singleton stuff
   * Determines whether an instance of this class can be created.
   */
  private static var canInstanciate:Bool;
  /**
   * The only instance of this class.
   */
  public static var instance(get, null):ScoreManager;
  
  public function new():Void {
    if (false == canInstanciate) {
      throw "Invalid Singleton access. Use ScoreManager.instance.";
    }
    // Init ?
    resetAllScores();
  }

  private static function get_instance():ScoreManager {
    if (null == instance) {
      // Set the flag to true, so the instance can be created.
      canInstanciate = true;
      // Create the only instance.
      instance = new ScoreManager();
      // Set the flag back to false, so no further instances can be created.
      canInstanciate = false;
    }
    return instance;
  }

}
