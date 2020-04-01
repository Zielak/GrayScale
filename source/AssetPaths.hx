package;

@:build(flixel.system.FlxAssets.buildFileReferences("assets/images", true, ["png"]))
class Images {}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/sounds", true, ["mp3", "ogg"]))
class Sounds {}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/music", true, ["mp3", "ogg"]))
class Musics {}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/maps", true, ["oel", "json"]))
class Levels {}
