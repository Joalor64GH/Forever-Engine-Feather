package gameObjects.userInterface;

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.tweens.FlxTween;
import sys.FileSystem;

using StringTools;

class HealthIcon extends FlxSprite
{
	// rewrite using da new icon system as ninjamuffin would say it
	public var sprTracker:FlxSprite;
	public var initialWidth:Float = 0;
	public var initialHeight:Float = 0;

	// script values;
	public var canBounce:Bool = true;
	public var scaleFactorX:Float = 1.2;
	public var scaleFactorY:Float = 1.2;
	public var easeValue:String = 'expoOut';

	public var suffix:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		updateIcon(char, isPlayer);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	// dynamic, to avoid having 31 billion if statements;
	public dynamic function updateAnim(health:Float)
	{
		if (health < 20)
			animation.curAnim.curFrame = 1;
		else
			animation.curAnim.curFrame = 0;
	}

	var bounceTween:FlxTween;

	public function bop(time:Float)
	{
		if (!canBounce)
			return;

		scale.set(scaleFactorX, scaleFactorY);
		if (bounceTween != null)
			bounceTween.cancel();
		bounceTween = FlxTween.tween(this.scale, {x: 1, y: 1}, time, {ease: ForeverTools.returnTweenEase(easeValue)});
	}

	public function updateIcon(char:String = 'bf', isPlayer:Bool = false)
	{
		var trimmedCharacter:String = char;
		if (trimmedCharacter.contains('-'))
			trimmedCharacter = trimmedCharacter.substring(0, trimmedCharacter.indexOf('-'));

		var iconPath = char;
		if (!openfl.Assets.exists(Paths.getPath('characters/$iconPath/icon$suffix.png', IMAGE)))
		{
			if (iconPath != trimmedCharacter)
				iconPath = trimmedCharacter;
			else
				iconPath = 'placeholder';
		}

		antialiasing = true;

		var iconGraphic:FlxGraphic = Paths.image('$iconPath/icon$suffix', 'characters');
		var iconWidth:Int = 1;

		// icons with endless frames;
		iconWidth = Std.int(iconGraphic.width / 150) - 1;
		iconWidth = iconWidth + 1;

		loadGraphic(iconGraphic); // get file size;
		loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / iconWidth), iconGraphic.height); // then load it;

		initialWidth = width;
		initialHeight = height;

		animation.add('icon', [0, 1], 0, false, isPlayer);
		animation.play('icon');
		scrollFactor.set();
	}
}
