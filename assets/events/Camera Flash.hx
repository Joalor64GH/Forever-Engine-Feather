function eventTrigger(value1, value2, value3)
{
	var timer:Float = Std.parseFloat(value2);
	if (Math.isNaN(timer) || timer <= 0)
		timer = 0.6;
	if (value1 == null)
		value1 = 'white';
	FlxG.camera.flash(ForeverTools.returnColor('$value1'), timer);
}

function returnDescription()
	return
		"Sets GF head bopping speed,\nValue 1: 1 = Normal speed,\n2 = 1/2 speed, 4 = 1/4 speed etc.\nUsed on Fresh during the beatbox parts.\nWarning: Value must be integer!";
