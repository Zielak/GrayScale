package;

@:build(flixel.system.FlxAssets.buildFileReferences("assets/images", true))
class Images {}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/sounds", true))
class Sounds {}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/music", true))
class Musics {}

@:build(flixel.system.FlxAssets.buildFileReferences("assets/maps", true, ["oel", "json"]))
class Levels {}
