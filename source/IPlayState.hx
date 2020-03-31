package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;

interface IPlayState {
	public var player(get, null):Player;

	public function addProjectile(S:Dynamic):Void;
	public function addProjectiles(A:Array<Dynamic>):Void;

	public function flashHUD(?duration:Int):Void;
	public function spawnEffect(type:String, position:FlxPoint, velocity:FlxPoint):FlxSprite;

	public function getPlayerPosition():FlxPoint;
}
