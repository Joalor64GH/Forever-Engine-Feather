package modding;

import flixel.FlxG;
import polymod.*;
import polymod.Polymod.ModMetadata;
import polymod.Polymod.PolymodError;
import polymod.Polymod;
import polymod.format.ParseRules;
#if MODS_ALLOWED
import polymod.backends.OpenFLBackend;
import polymod.backends.PolymodAssets.PolymodAssetType;
import polymod.format.ParseRules.LinesParseFormat;
import polymod.format.ParseRules.TextFileFormat;
#end

/**
 * Class based off of Kade Engine, Enigma Engine, and ChainSaw Engine.
 * Credits: KadeDev, MasterEric, MAJigsaw77.
 */
class ModCore
{
	/**
	 * The current API version.
	 * Must be formatted in Semantic Versioning v2; <MAJOR>.<MINOR>.<PATCH>.
	 * 
	 * Remember to increment the major version if you make breaking changes to mods!
	 */
	static final API_VERSION:String = "1.6.0";

	static final MOD_DIRECTORY:String = "mods";

	static var loadedModList:Array<ModMetadata> = [];

	private static final modExtensions:Map<String, PolymodAssetType> = [
		'ogg' => AUDIO_SOUND, 'png' => IMAGE, 'xml' => TEXT, 'json' => TEXT, 'txt' => TEXT, 'hx' => TEXT, 'hxs' => TEXT, 'hxc' => TEXT, 'hscript' => TEXT,
		'ttf' => FONT, 'otf' => FONT
	];

	public static function loadAllMods()
	{
		#if MODS_ALLOWED
		trace("[INFO] Initializing ModCore (using all mods)...");
		loadModsById(ModUtil.getAllModIds());
		#else
		trace("[INFO] ModCore not initialized; not supported on this platform.");
		#end
	}

	public static function loadConfiguredMods()
	{
		#if MODS_ALLOWED
		trace("[INFO] Initializing ModCore (using user config)...");
		trace('  User mod config: ${FlxG.save.data.modConfig}');
		var userModConfig = ModUtil.getConfiguredMods();
		loadModsById(userModConfig);
		#else
		trace("[INFO] ModCore not initialized; not supported on this platform.");
		#end
	}

	public static function loadModsById(ids:Array<String>)
	{
		#if MODS_ALLOWED
		var modsToLoad:Array<String> = [];

		if (ids.length == 0)
		{
			trace('[WARN] You attempted to load zero mods.');
		}
		else
		{
			if (ids[0] != '' && ids != null)
			{
				trace('[INFO] Attempting to load ${ids.length} mods...');
				modsToLoad = ids;
			}
			else
			{
				modsToLoad = [];
			}
		}

		loadedModList = polymod.Polymod.init({
			modRoot: MOD_DIRECTORY,
			dirs: modsToLoad,
			framework: CUSTOM,
			apiVersion: API_VERSION,
			errorCallback: onPolymodError,
			extensionMap: modExtensions,
			frameworkParams: buildFrameworkParams(),

			// Use a custom backend so we can get a picture of what's going on,
			// or even override behavior ourselves.
			customBackend: ModCoreBackend,

			// List of filenames to ignore in mods. Use the default list to ignore the metadata file, etc.
			ignoredFiles: Polymod.getDefaultIgnoreList(),

			// Parsing rules for various data formats.
			parseRules: buildParseRules(),
		});

		if (loadedModList == null)
		{
			trace('[ERROR] Mod loading failed, check above for a message from Polymod explaining why.');
		}
		else
		{
			if (loadedModList.length == 0)
			{
				trace('[INFO] Mod loading complete. We loaded no mods / ${ids.length} mods.');
			}
			else
			{
				trace('[INFO] Mod loading complete. We loaded ${loadedModList.length} / ${ids.length} mods.');
			}
		}

		for (mod in loadedModList)
			trace('  * ${mod.title} v${mod.modVersion} [${mod.id}]');

		var fileList = Polymod.listModFiles("IMAGE");
		trace('[INFO] Installed mods have replaced ${fileList.length} images.');
		for (item in fileList)
			trace('  * $item');

		fileList = Polymod.listModFiles("TEXT");
		trace('[INFO] Installed mods have replaced ${fileList.length} text files.');
		for (item in fileList)
			trace('  * $item');

		fileList = Polymod.listModFiles("MUSIC");
		trace('[INFO] Installed mods have replaced ${fileList.length} music files.');
		for (item in fileList)
			trace('  * $item');

		fileList = Polymod.listModFiles("SOUND");
		trace('[INFO] Installed mods have replaced ${fileList.length} sound files.');
		for (item in fileList)
			trace('  * $item');
		#else
		trace("[WARN] Attempted to load mods when Polymod was not supported!");
		#end
	}

	#if MODS_ALLOWED
	static function buildParseRules():polymod.format.ParseRules
	{
		var output = polymod.format.ParseRules.getDefault();
		// Ensure TXT files have merge support.
		output.addType("txt", TextFileFormat.LINES);
		// Ensure script files have merge support.
		output.addType("hscript", TextFileFormat.PLAINTEXT);

		// You can specify the format of a specific file, with file extension.
		// output.addFile("data/introText.txt", TextFileFormat.LINES)
		return output;
	}

	static inline function buildFrameworkParams():polymod.FrameworkParams
	{
		return {
			assetLibraryPaths: [
				"songs" => "songs", "events" => "events", "fonts" => "fonts", "characters" => "characters", "scripts" => "scripts",
				"notetypes" => "notetypes", "weeks" => "weeks", "music" => "music", "sounds" => "sounds", "images" => "images", "stages" => "stages",
				"shaders" => "shaders"
			]
		}
	}

	public static function getParseRules():ParseRules
	{
		var output = ParseRules.getDefault();
		output.addType("txt", TextFileFormat.LINES);
		return output;
	}

	static function onPolymodError(error:PolymodError):Void
	{
		// Perform an action based on the error code.
		switch (error.code)
		{
			case MOD_LOAD_PREPARE:
				trace('[INFO] ' + error.message, null);
			case MOD_LOAD_DONE:
				trace('[INFO] ' + error.message, null);
			// case MOD_LOAD_FAILED:
			case MISSING_ICON:
				trace('[WARN] A mod is missing an icon, will just skip it but please add one: ${error.message}', null);
			// case "parse_mod_version":
			// case "parse_api_version":
			// case "parse_mod_api_version":
			// case "missing_mod":
			// case "missing_meta":
			// case "missing_icon":
			// case "version_conflict_mod":
			// case "version_conflict_api":
			// case "version_prerelease_api":
			// case "param_mod_version":
			// case "framework_autodetect":
			// case "framework_init":
			// case "undefined_custom_backend":
			// case "failed_create_backend":
			// case "merge_error":
			// case "append_error":
			default:
				// Log the message based on its severity.
				switch (error.severity)
				{
					case NOTICE:
						trace('[INFO] ' + error.message, null);
					case WARNING:
						trace('[WARN] ' + error.message, null);
					case ERROR:
						trace('[ERROR] ' + error.message, null);
				}
		}
	}
	#end
}

#if MODS_ALLOWED
class ModCoreBackend extends OpenFLBackend
{
	public function new()
	{
		super();
		trace('Initialized custom asset loader backend.');
	}

	public override function clearCache()
	{
		super.clearCache();
		trace('[WARN] Custom asset cache has been cleared.');
	}

	public override function exists(id:String):Bool
	{
		trace('Call to ModCoreBackend: exists($id)');
		return super.exists(id);
	}

	public override function getBytes(id:String):lime.utils.Bytes
	{
		trace('Call to ModCoreBackend: getBytes($id)');
		return super.getBytes(id);
	}

	public override function getText(id:String):String
	{
		trace('Call to ModCoreBackend: getText($id)');
		return super.getText(id);
	}

	public override function list(type:PolymodAssetType = null):Array<String>
	{
		trace('Listing assets in custom asset cache ($type).');
		return super.list(type);
	}
}
#end
