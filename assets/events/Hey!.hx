function eventTrigger(params)
{
	var timer:Float = Std.parseFloat(params[1]);
	if (Math.isNaN(timer) || timer <= 0)
		timer = 0.6;

	switch (params[0])
	{
		case 'dad', 'dadOpponent', 'opponent', '1':
			if (PlayState.opponent.animOffsets.exists('hey'))
				PlayState.opponent.playAnim('hey', true);
			else if (PlayState.opponent.animOffsets.exists('cheer'))
				PlayState.opponent.playAnim('cheer', true);
			PlayState.opponent.specialAnim = true;
			PlayState.opponent.heyTimer = timer;
		case 'gf', 'girlfriend', 'spectator', '2':
			if (PlayState.gf.animOffsets.exists('hey'))
				PlayState.gf.playAnim('hey', true);
			else if (PlayState.gf.animOffsets.exists('cheer'))
				PlayState.gf.playAnim('cheer', true);
			PlayState.gf.specialAnim = true;
			PlayState.gf.heyTimer = timer;
		default:
			if (PlayState.boyfriend.animOffsets.exists('hey'))
				PlayState.boyfriend.playAnim('hey', true);
			else if (PlayState.boyfriend.animOffsets.exists('cheer'))
				PlayState.boyfriend.playAnim('cheer', true);
			PlayState.boyfriend.specialAnim = true;
			PlayState.boyfriend.heyTimer = timer;
	}
}

function returnDescription()
	return
		"Plays the \"Hey!\" animation from Bopeebo,\ncharacterValue 1: Character (bf, gf, dad, defaults to bf).\ncharacterValue 2: Custom animation duration,\nleave it blank for 0.6s";
