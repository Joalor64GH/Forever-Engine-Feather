function loadedEventAction(params)
{
	var newStage:Stage = new Stage(params[0]);
	PlayState.stageGroup.add(newStage);

	new FlxTimer().start(0.005, function(tmr:FlxTimer)
	{
		newStage.visible = false;
	});
}

function eventTrigger(params)
{
	var changeTimer:FlxTimer;
	var timer:Float = Std.parseFloat(params[1]);
	if (Math.isNaN(timer))
		timer = 0.0001;

	changeTimer = new FlxTimer().start(timer, function(tmr:FlxTimer)
	{
		PlayState.stageBuild.destroy();
		PlayState.stageBuild.layers.destroy();
		PlayState.stageBuild.foreground.destroy();

		PlayState.stageGroup.remove(PlayState.stageBuild);

		PlayState.stageBuild = new Stage(params[0]);
		PlayState.stageGroup.add(PlayState.stageBuild);

		game.regenerateCharacters();

		PlayState.curStage = params[0];
	});
}

function returnDescription()
	return "Sets the current Stage to a new one\nValue 1: New Stage\nValue 2: Delay to Change Stages (in Milliseconds)";
