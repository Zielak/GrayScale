package;

import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxPoint;

interface IPlayState {
	public var player(get, null):Player;

	public function addProjectile(S:Dynamic):Void;
	public function addProjectiles(A:Array<Dynamic>):Void;

	public function flashHUD(?duration:Int):Void;
	public function puffSmoke(?X:Float, ?Y:Float):PlayerTrail;

	public function getPlayerPosition():FlxPoint;
}
