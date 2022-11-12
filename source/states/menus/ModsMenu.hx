package states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import openfl.display.BlendMode;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import base.input.Controls;
import flixel.group.FlxGroup.FlxTypedGroup;
import song.MusicBeat.MusicBeatState;
import gameObjects.gameFonts.Alphabet;

/*
    the Mods Menu, handles mod managment;
*/
class ModsMenu extends MusicBeatState
{
    public var background:FlxSprite;
    public var boyfriend:FlxSprite;
    public var itemGroup:FlxTypedGroup<Alphabet>;

    override public function create()
    {
        super.create();

        // create background
		generateBackground();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

		if (Controls.getPressEvent("back"))
            Main.switchState(this, new MainMenu());
    }

	function generateBackground():Void
	{
		background = cast new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(19, 21, 33));
		background.scrollFactor.set();
		background.screenCenter();
		add(background);

        // mario;
		boyfriend = new FlxSprite().loadGraphic(Paths.image('menus/chart/bg'));
		boyfriend.setGraphicSize(Std.int(FlxG.width));
		boyfriend.scrollFactor.set();
		boyfriend.blend = BlendMode.DIFFERENCE;
		boyfriend.screenCenter();
		boyfriend.alpha = 0;
		add(boyfriend);
		FlxTween.tween(boyfriend, {alpha: 0.07}, 0.4);
	}
}