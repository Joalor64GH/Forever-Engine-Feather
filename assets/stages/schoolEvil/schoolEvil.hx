function dadPosition(boyfriend:Character, gf:Character, dad:Character)
{
	var evilTrail:FlxTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
	evilTrail.changeValuesEnabled(false, false, false, false);
	add(evilTrail);
}
