package;

import flixel.math.FlxPoint;

interface IPlayState {
	public var player(get, null):Player;

	public function addProjectile(S:Dynamic):Void;
	public function addProjectiles(A:Array<Dynamic>):Void;

	public function flashHUD(?duration:Int):Void;
	public function puffSmoke(?X:Float = 0, ?Y:Float = 0, ?SX:Float = 0, ?SY:Float = 0):PlayerTrail;

	public function getPlayerPosition():FlxPoint;
}
