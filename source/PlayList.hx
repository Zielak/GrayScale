package;

class PlayList {
	private var _firstEntry:Bool;

	public var firstEntry(get, set):Bool;

	public function get_firstEntry():Bool {
		return _firstEntry;
	}

	public function set_firstEntry(val:Bool):Bool {
		_firstEntry = true;
		return _firstEntry;
	}

	private var _levelList:Array<String>;

	public var levelList(get, null):Array<String>;

	public function get_levelList():Array<String> {
		return _levelList;
	}

	private var _currentLevel:Int;

	public var currentLevel(get, null):Int;

	public function get_currentLevel():Int {
		return _currentLevel;
	}

	public var currentLevelName(get, null):String;

	public function get_currentLevelName():String {
		return _levelList[_currentLevel];
	}

	public var isLastLevel(get, null):Bool;

	public function get_isLastLevel():Bool {
		return (_currentLevel >= _levelList.length - 1);
	}

	private var _lastIntroLevel:Int;

	/**
	 * Sets the next level to be loaded
	 */
	public function nextLevel():Void {
		_currentLevel++;
		if (_currentLevel >= _levelList.length) {
			_currentLevel = 0;
		}
	}

	/**
	 * Forces the i'th level to be loaded
	 * @param  i Index of level
	 */
	public function loadLevel(i:Int):Void {
		_currentLevel = i;

		if (_currentLevel >= _levelList.length) {
			_currentLevel = _levelList.length - 1;
		}
	}

	/**
	 * Determines whether an instance of this class can be created.
	 */
	private static var canInstanciate:Bool;

	/**
	 * The only instance of this class.
	 */
	public static var instance(get, null):PlayList;

	public function new():Void {
		if (false == canInstanciate) {
			throw "Invalid Singleton access. Use PlayList.instance.";
		}
		// Init ?
		_firstEntry = true;
		_levelList = [
			"assets/maps/intro1.json",
			"assets/maps/intro2.json",
			"assets/maps/level1.json",
			"assets/maps/level2.json",
			"assets/maps/level3.json",
			"assets/maps/level4.json",
			"assets/maps/level6.json",
			"assets/maps/theend.json"
		];
		_lastIntroLevel = 1;
		_currentLevel = 0;
	}

	private static function get_instance():PlayList {
		if (null == instance) {
			// Set the flag to true, so the instance can be created.
			canInstanciate = true;
			// Create the only instance.
			instance = new PlayList();
			// Set the flag back to false, so no further instances can be created.
			canInstanciate = false;
		}
		return instance;
	}
}
