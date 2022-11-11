function eventTrigger(params)
{
	var timer:Float = Std.parseFloat(params[1]);
	if (Math.isNaN(timer) || timer <= 0)
		timer = 0.6;
	if (params[0] == null)
		params[0] = 'white';
	FlxG.camera.flash(ForeverTools.returnColor(params[0]), timer);
}

function returnDescription()
	return
		"Sets GF head bopping speed,\nValue 1: 1 = Normal speed,\n2 = 1/2 speed, 4 = 1/4 speed etc.\nUsed on Fresh during the beatbox parts.\nWarning: Value must be integer!";
