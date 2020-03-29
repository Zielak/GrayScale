package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;

using flixel.util.FlxSpriteUtil;

class HUD extends FlxTypedGroup<FlxSprite> {
	// private var _sprBack:FlxSprite;
	// private var _txtHealth:FlxText;
	// private var _txtMoney:FlxText;
	// private var _sprHealth:FlxSprite;
	// private var _sprMoney:FlxSprite;
	private var _dashCooldown:FlxSprite;
	private var _dashWidth:Int;
	private var _dashMaxWidth:Int;
	private var _dashing:FlxText;

	private var _flash:FlxSprite;
	private var _flashDur:Int;

	private var _coinsTxt:FlxText;

	public var maxCoins:Int = 0;

	private var _levelTxt:FlxText;

	private var _scoreTxt:FlxText;

	public function new() {
		super();

		var px = Std.int(FlxG.width * 0.5) - 16;
		var py = Std.int(FlxG.height * 0.5) - 16;

		_dashCooldown = new FlxSprite().loadGraphic(AssetPaths.dashhud__png, true, 32, 32);
		_dashCooldown.animation.add("idle", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], 20, false);
		// _dashCooldown.drawRect(0, 0, h, w, GBPalette.C4);
		// _dashCooldown.drawRect(1, 1, h-2, w-2, GBPalette.C4);
		// _dashMaxWidth = w;

		_dashCooldown.x = Std.int(px);
		_dashCooldown.y = Std.int(py);

		_flash = new FlxSprite().makeGraphic(FlxG.width + 20, FlxG.height + 20);
		_flash.drawRect(0, 0, FlxG.width + 20, FlxG.height + 20, GBPalette.C4);
		_flash.x = _flash.y = -10;
		_flash.visible = false;

		// _sprBack = new FlxSprite().makeGraphic(FlxG.width, 20, FlxColor.BLACK);
		// _sprBack.drawRect(0, 19, FlxG.width, 1, FlxColor.WHITE);

		_coinsTxt = new FlxText(FlxG.width - 82, 2, 80, "COLORS: 0/0", 8);
		_coinsTxt.alignment = "right";
		_coinsTxt.borderColor = GBPalette.C1;
		_coinsTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, GBPalette.C1, 1, 1);

		_levelTxt = new FlxText(FlxG.width - 82, 12, 80, "LEVEL: 0", 8);
		_levelTxt.alignment = "right";
		_levelTxt.borderColor = GBPalette.C1;
		_levelTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, GBPalette.C1, 1, 1);

		_scoreTxt = new FlxText(2, 2, 0, "SCORE: 0", 8);
		_scoreTxt.borderColor = GBPalette.C1;
		_scoreTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, GBPalette.C1, 1, 1);

		// _sprHealth = new FlxSprite(4, _txtHealth.y + (_txtHealth.height/2)  - 4, AssetPaths.health<strong>png);

		// _sprMoney = new FlxSprite(FlxG.width - 12, _txtMoney.y + (_txtMoney.height/2)  - 4, AssetPaths.coin__png);

		// _txtMoney.alignment = "right";
		// _txtMoney.x = _sprMoney.x - _txtMoney.width - 4;

		add(_dashCooldown);
		add(_flash);
		// add(_dashing);
		add(_coinsTxt);
		add(_scoreTxt);
		add(_levelTxt);
		// add(new FlxText(2, 2, 100, "The game is ON!"));

		// add(_sprBack);
		// add(_sprHealth);
		// add(_sprMoney);
		// add(_txtHealth);
		// add(_txtMoney);

		forEach(function(spr:FlxSprite) {
			spr.scrollFactor.set();
		});
	}

	public function updateHUD(DashCooldown:Float, Dashing:Bool, CoinsLeft:Int, Score:Int):Void {
		_dashCooldown.animation.frameIndex = Std.int(13 * DashCooldown);
		// _dashCooldown.scale.x = DashCooldown;
		// _txtHealth.text = Std.string(Health) + " / 3";
		// _txtMoney.text = Std.string(Money);
		// _txtMoney.x = _sprMoney.x - _txtMoney.width - 4;

		if (_flashDur > 0) {
			_flashDur--;
		} else if (_flashDur == 0 && _flash.visible) {
			_flash.visible = false;
		}

		// _dashing.visible = Dashing;

		_coinsTxt.text = "COLORS: " + (maxCoins - CoinsLeft) + "/" + maxCoins;
		_scoreTxt.text = "SCORE: " + Score;
		_levelTxt.text = "LEVEL: " + PlayList.instance.currentLevel;
	}

	public function flash(duration:Int = 3):Void {
		_flashDur = duration;
		_flash.visible = true;
	}
}
