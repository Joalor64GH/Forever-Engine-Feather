var lightningStrikeBeat:Int = 0;
var lightningOffset:Int = 8;

function updateStage(curBeat:Int, boyfriend:Character, gf:Character, dad:Character)
{
	if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
	{
		lightningStrikeBeat = curBeat;

		FlxG.sound.play(Paths.soundRandom('events/week2/thunder', 1, 2));

		if (!Init.trueSettings.get('Disable Flashing Lights'))
			getObject("hallowBack").playAnim('lightning');

		lightningOffset = FlxG.random.int(8, 24);

		if (boyfriend.animOffsets.exists('scared'))
		{
			boyfriend.playAnim('scared', true);
			boyfriend.specialAnim = true;
			boyfriend.heyTimer = 0.6;
		}

		if (gf.animOffsets.exists('scared'))
		{
			gf.playAnim('scared', true);
			gf.specialAnim = true;
			gf.heyTimer = 0.6;
		}
	}
}
