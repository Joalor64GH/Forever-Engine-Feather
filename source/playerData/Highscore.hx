package playerData;

import flixel.FlxG;

using StringTools;

class Highscore
{
	#if (haxe >= "4.0.0")
	public static var songScores:Map<String, Int> = new Map();
	public static var weekScores:Map<String, Int> = new Map();
	#else
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var weekScores:Map<String, Int> = new Map<String, Int>();
	#end

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);

		FlxG.save.bind("HighScores", "Feather");
		if (songScores.exists(daSong))
		{
			if (songScores.get(daSong) < score)
				setScore(daSong, score);
		}
		else
			setScore(daSong, score);
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:Int = 0):Void
	{
		var daWeek:String = formatSong('week' + week, diff);

		FlxG.save.bind("WeekScores", "Feather");
		if (weekScores.exists(daWeek))
		{
			if (weekScores.get(daWeek) < score)
				setWeekScore(daWeek, score);
		}
		else
			setWeekScore(daWeek, score);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		FlxG.save.bind("HighScores", "Feather");
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	static function setWeekScore(song:String, score:Int):Void
	{
		FlxG.save.bind("WeekScores", "Feather");
		// Reminder that I don't need to format this song, it should come formatted!
		weekScores.set(song, score);
		FlxG.save.data.setWeekScore = weekScores;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		var daSong:String = song;

		var difficulty:String = '-' + CoolUtil.difficultyFromNumber(diff).toLowerCase();
		difficulty = difficulty.replace('-normal', '');

		daSong += difficulty;

		return daSong;
	}

	public static function getScore(song:String, diff:Int):Int
	{
		FlxG.save.bind("HighScores", "Feather");
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff));
	}

	public static function getWeekScore(week:Int, diff:Int):Int
	{
		FlxG.save.bind("WeekScores", "Feather");
		if (!weekScores.exists(formatSong('week' + week, diff)))
			setWeekScore(formatSong('week' + week, diff), 0);

		return weekScores.get(formatSong('week' + week, diff));
	}

	public static function load():Void
	{
		FlxG.save.bind("HighScores", "Feather");
		if (FlxG.save.data.songScores != null)
			songScores = FlxG.save.data.songScores;

		FlxG.save.bind("WeekScores", "Feather");
		if (FlxG.save.data.weekScores != null)
			weekScores = FlxG.save.data.weekScores;
	}
}
