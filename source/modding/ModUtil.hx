package modding;

#if MODS_ALLOWED
import polymod.Polymod;
import flixel.FlxG;

@:access(modding.ModCore)
class ModUtil
{
	public static var modList:Map<String, Bool> = new Map<String, Bool>();

	public static var modMetadatas:Map<String, ModMetadata> = new Map();

	public static function reloadSavedMods():Void
	{
		var loadedMods:Array<String> = getConfiguredMods();
		var allMods:Array<String> = getAllModIds();
		for (mod in allMods)
		{
			if (loadedMods.contains(mod))
				modList.set(mod, true);
			else
				modList.set(mod, false);
		}
	}

	public static function setModEnabled(mod:String, enabled:Bool):Void
	{
		modList.set(mod, enabled);
		FlxG.save.data.modList = modList;
		FlxG.save.flush();
	}

	public static function getModEnabled(mod:String):Bool
	{
		if (!modList.exists(mod))
			setModEnabled(mod, false);

		return modList.get(mod);
	}

	public static function getActiveMods(modsToCheck:Array<String>):Array<String>
	{
		var activeMods:Array<String> = [];

		for (modName in modsToCheck)
		{
			if (getModEnabled(modName))
				activeMods.push(modName);
		}

		return activeMods;
	}

	public static function getAllModsMetadatasMap():Map<String, ModMetadata>
	{
		var modDatas:Array<ModMetadata> = getAllMods();
		if (modDatas.length > 0)
		{
			for (mod in modDatas)
			{
				modMetadatas.set(mod.title, mod);
			}
		}
		return modMetadatas;
	}

	public static function getAllLoadedMods(?returnModData:Bool = false):Array<Dynamic>
	{
		var returnArray:Array<Dynamic> = [];
		if (returnModData)
		{
			returnArray = modding.ModCore.loadedModList.copy();
			return returnArray;
		}
		else
		{
			var modList:Array<ModMetadata> = modding.ModCore.loadedModList.copy();
			if (modList.length > 0)
			{
				for (mod in modList)
				{
					returnArray.push(mod.title);
				}
			}
			return returnArray;
		}
	}

	/**
	 * If the user has configured an order of mods to load, returns the list of mod IDs in order.
	 * Otherwise, returns a list of ALL installed mods in alphabetical order.
	 * @return The mod order to load.
	 */
	public static function getConfiguredMods():Array<String>
	{
		var rawSaveData = FlxG.save.data.modConfig;

		if (rawSaveData != null)
		{
			var modEntries = rawSaveData.split('~');
			return modEntries;
		}
		else
		{
			// Mod list not in save!
			return null;
		}
	}

	public static function saveModList(loadedMods:Array<String>)
	{
		trace('[INFO] Saving mod configuration...');
		var rawSaveData = loadedMods.join('~');
		trace(rawSaveData);
		FlxG.save.data.modConfig = rawSaveData;
		var result = FlxG.save.flush();
		if (result)
			trace('[INFO] Mod configuration saved successfully.');
		else
			trace('[WARN] Failed to save mod configuration.');
	}

	/**
	 * Returns true if there are mods to load in the mod folder,
	 * and false if there aren't (or mods aren't supported).
	 * @return A boolean value.
	 */
	public static function hasMods():Bool
	{
		#if MODS_ALLOWED
		return getAllMods().length > 0;
		#else
		return false;
		#end
	}

	public static function getAllMods():Array<ModMetadata>
	{
		trace('[INFO] Scanning the mods folder...');
		var modMetadata = Polymod.scan(ModCore.MOD_DIRECTORY);
		trace('[INFO] Found ${modMetadata.length} mods when scanning.');
		return modMetadata;
	}

	public static function getAllModIds():Array<String>
	{
		var modIds = [for (i in getAllMods()) i.id];
		return modIds;
	}
}
#end
