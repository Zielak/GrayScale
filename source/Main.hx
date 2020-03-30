package;

import openfl.display.Sprite;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.FlxG;

class Main extends Sprite {
	// Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameWidth:Int = 160;

	// Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 144;

	// The FlxState the game starts with.
	var initialState:Class<FlxState>;

	// If -1, zoom is automatically calculated to fit the window dimensions.
	var zoom:Float = 4;

	// How many frames per second the game should run at.
	var framerate:Int = 60;

	// Whether to skip the flixel splash screen that appears in release mode.
	var skipSplash:Bool = true;

	// Whether to start the game in fullscreen on desktop targets
	var startFullscreen:Bool = false;
	var mouseVisible:Bool = false;

	public function new() {
		super();

		#if debug
		initialState = PlayState;
		#else
		initialState = MenuState;
		#end

		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		FlxG.mouse.visible = mouseVisible;
	}
}
