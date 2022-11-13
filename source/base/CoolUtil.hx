package base;

import lime.utils.Assets;
import openfl.Assets as OpenFlAssets;
import openfl.utils.AssetType;

using StringTools;
using hx.strings.Strings;

#if sys
import sys.FileSystem;
#end

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];
	public static var difficultyLength:Int = difficultyArray.length;
	public static var difficultyString:String = 'NORMAL';

	public static function difficultyFromNumber(number:Int):String
	{
		return difficultyArray[number];
	}

	public static function boundTo(value:Float, minValue:Float, maxValue:Float):Float
	{
		return Math.max(minValue, Math.min(maxValue, value));
	}

	public static function dashToSpace(string:String):String
	{
		return string.replace("-", " ");
	}

	public static function spaceToDash(string:String):String
	{
		return string.replace(" ", "-");
	}

	public static function swapSpaceDash(string:String):String
	{
		return StringTools.contains(string, '-') ? dashToSpace(string) : spaceToDash(string);
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function getOffsetsFromTxt(path:String):Array<Array<String>>
	{
		var fullText:String = Assets.getText(path);

		var firstArray:Array<String> = fullText.split('\n');
		var swagOffsets:Array<Array<String>> = [];

		for (i in firstArray)
			swagOffsets.push(i.split(' '));

		return swagOffsets;
	}

	public static function returnAssetsLibrary(library:String, ?subDir:String = 'assets/images'):Array<String>
	{
		var libraryArray:Array<String> = [];

		try
		{
			var unfilteredLibrary = listFoldersInPath('$subDir/$library' + (library.endsWith('/') ? '' : '/'));

			for (folder in unfilteredLibrary)
			{
				if (!folder.contains('.'))
					libraryArray.push(folder);
			}
		}
		catch (e)
		{
			trace('$subDir/$library is returning null');
			libraryArray = [];
		}

		return libraryArray;
	}

	public static function getAnimsFromTxt(path:String):Array<Array<String>>
	{
		var fullText:String = Assets.getText(path);

		var firstArray:Array<String> = fullText.split('\n');
		var swagOffsets:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagOffsets.push(i.split('--'));
		}

		return swagOffsets;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	/**
		Returns an array with the files of the specified directory.
		Example usage:
		var fileArray:Array<String> = CoolUtil.absoluteDirectory('scripts');
		trace(fileArray); -> ['mods/scripts/modchart.hx', 'assets/scripts/script.hx']
	**/
	public static function absoluteDirectory(file:String):Array<String>
	{
		if (!file.endsWith('/'))
			file = '$file/';

		var path:String = Paths.getPath(file);

		var absolutePath:String = Assets.getPath(path);
		var directory:Array<String> = listFilesInPath(absolutePath, null, ''); // I don't know if this will work as well as it should. @AltronMaxX

		if (directory != null)
		{
			var dirCopy:Array<String> = directory.copy();

			for (i in dirCopy)
			{
				var index:Int = dirCopy.indexOf(i);
				var file:String = '$path$i';
				dirCopy.remove(i);
				dirCopy.insert(index, file);
			}

			directory = dirCopy;
		}

		return if (directory != null) directory else [];
	}

	/**
	 * List all the files under a given subdirectory.
	 * @param path The path to look under.
	 * @return The list of paths to files under that path.
	 */
	public static function listFilesPathsInPath(path:String)
	{
		var dataAssets = OpenFlAssets.list();

		var queryPath = '${path}';

		var results:Array<String> = [];

		for (data in dataAssets)
		{
			if (data.indexOf(queryPath) != -1 && !results.contains(data))
			{
				results.push(data);
			}
		}

		return results;
	}

	/**
	 * List all the files under a given subdirectory.
	 * @param path The path to look under.
	 * @param fileType The openfl asset type. Default - null.
	 * @param fileEnd The file end to match file type.
	 * @return The list of files under that path.
	 */
	public static function listFilesInPath(path:String, fileType:AssetType = null, fileEnd:String = '.txt')
	{
		var dataAssets = OpenFlAssets.list(fileType);

		var queryPath = '${path}';

		var results:Array<String> = [];

		for (data in dataAssets)
		{
			if (data.indexOf(queryPath) != -1
				&& data.endsWith(fileEnd)
				&& !results.contains(data.substr(data.indexOf(queryPath) + queryPath.length).replaceAll(fileEnd, '')))
			{
				var suffixPos = data.indexOf(queryPath) + queryPath.length;
				results.push(data.substr(suffixPos).replaceAll(fileEnd, ''));
			}
		}

		return results;
	}

	/**
	 * List all the folders under a given subdirectory.
	 * @param path The path to look under.
	 * @return The list of folders under that path.
	 */
	public static function listFoldersInPath(path:String)
	{
		var dataAssets = OpenFlAssets.list();

		var queryPath = '${path}';

		var results:Array<String> = [];

		for (data in dataAssets)
		{
			if (data.indexOf(queryPath) != -1
				&& !results.contains(data.substr(data.indexOf(queryPath) + queryPath.length).replace(queryPath, '').removeAfter('/')))
			{
				var suffixPos = data.indexOf(queryPath) + queryPath.length;
				results.push(data.substr(suffixPos).replace(queryPath, '').removeAfter('/'));
			}
		}
		return results;
	}
}
