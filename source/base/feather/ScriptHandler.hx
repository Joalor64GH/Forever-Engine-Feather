package base.feather;

using StringTools;

class ScriptHandler extends SScript
{
	// this just kinda sets up script variables and such;
	// probably gonna clean it up later;
	public function new(file:String, ?preset:Bool = true)
	{
		super(file, preset);
		traces = false;
	}

	override public function preset():Void
	{
		super.preset();

		// here we set up the built-in imports
		// these should work on *any* script;

		// CLASSES (FLIXEL);
		set('FlxG', flixel.FlxG);
		set('FlxBasic', flixel.FlxBasic);
		set('FlxObject', flixel.FlxObject);
		set('FlxSprite', flixel.FlxSprite);
		set('FlxSound', flixel.system.FlxSound);
		set('FlxText', flixel.text.FlxText);
		set('FlxTimer', flixel.util.FlxTimer);
		set('FlxTween', flixel.tweens.FlxTween);
		set('FlxEase', flixel.tweens.FlxEase);
		set('FlxTrail', flixel.addons.effects.FlxTrail);

		// CLASSES (FUNKIN);
		set('Alphabet', gameObjects.gameFonts.Alphabet);
		set('Boyfriend', gameObjects.Boyfriend);
		set('CoolUtil', base.CoolUtil);
		set('Character', gameObjects.Character);
		set('Conductor', song.Conductor);
		set('HealthIcon', gameObjects.userInterface.HealthIcon);
		set('game', states.PlayState.main);
		set('PlayState', states.PlayState);
		set('Paths', Paths);

		// CLASSES (FOREVER);
		set('Init', Init);
		set('Main', Main);
		set('Stage', gameObjects.Stage);
		set('FNFSprite', dependency.FNFSprite);
		set('ForeverAssets', ForeverAssets);
		set('ForeverTools', ForeverTools);

		// CLASSES (FEATHER);
		set('ScriptableState', states.ScriptableState);
		set('ScriptableSubstate', states.ScriptableState.ScriptableSubstate);
		set('FeatherSprite', dependency.FeatherSprite);
		set('Controls', base.Controls);

		// OTHER
		set('GraphicsShader', openfl.display.GraphicsShader);
		set('ShaderFilter', openfl.filters.ShaderFilter);
	}

	public static function callScripts(moduleArray:Array<ScriptHandler>):Array<ScriptHandler>
	{
		var dirs:Array<Array<String>> = [
			CoolUtil.absoluteDirectory('scripts'),
			CoolUtil.absoluteDirectory('songs/${CoolUtil.swapSpaceDash(states.PlayState.SONG.song.toLowerCase())}')
		];

		var pushedModules:Array<String> = [];

		for (directory in dirs)
		{
			for (script in directory)
			{
				if (directory != null && directory.length > 0)
				{
					for (ext in Paths.scriptExts)
					{
						if (!pushedModules.contains(script) && script != null && script.endsWith('.$ext'))
						{
							try
							{
								moduleArray.push(new ScriptHandler(script));
								trace('new module loaded: ' + script);
								pushedModules.push(script);
							}
							catch (e)
							{
								//
								flixel.FlxG.switchState(new states.menus.MainMenu('[MAIN GAME]: $e'));
							}
						}
					}
				}
			}
		}

		if (moduleArray != null)
		{
			for (i in moduleArray)
				i.call('create', []);
		}

		return moduleArray;
	}
}
