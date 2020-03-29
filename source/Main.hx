package;

import openfl.display.Sprite;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.FlxG;

class Main extends Sprite {
	var gameWidth:Int = 160; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 144; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = MenuState; // The FlxState the game starts with.
	var zoom:Float = 4; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	var mouseVisible:Bool = false;

	public function new() {
		super();

		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		FlxG.mouse.visible = mouseVisible;
	}
}
