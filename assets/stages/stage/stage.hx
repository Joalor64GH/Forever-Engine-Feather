function dadPosition(boyfriend:Character, gf:Character, dad:Character)
{
	if (StringTools.startsWith('gf', dad.curCharacter))
	{
		dad.setPosition(gf.x, gf.y);
		gf.visible = false;
		if (PlayState.isStoryMode)
			camPos.x += 600;
	}
}
