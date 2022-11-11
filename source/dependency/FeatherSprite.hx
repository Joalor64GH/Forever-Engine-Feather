package dependency;

import flixel.FlxSprite;

class FeatherSprite extends FlxSprite
{
	public var parentSprite:FlxSprite;

	public var addX:Float = 0;
	public var addY:Float = 0;
	public var addAngle:Float = 0;
	public var addAlpha:Float = 0;

	public var copyParentAngle:Bool = false;
	public var copyParentAlpha:Bool = false;
	public var copyParentVisib:Bool = false;

	public function new(fileName:String, ?fileFolder:String, ?fileAnim:String, ?looped:Bool = false)
	{
		super();

		if (fileName != null)
		{
			if (fileAnim != null)
			{
				frames = Paths.getSparrowAtlas(fileName, fileFolder);
				animation.addByPrefix('static', fileAnim, 24, looped);
				animation.play('static');
			}
			else
			{
				loadGraphic(Paths.image(fileName, fileFolder));
			}
			antialiasing = !Init.trueSettings.get('Disable Antialiasing');
			scrollFactor.set();
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// set parent sprite stuffs;
		if (parentSprite != null)
		{
			setPosition(parentSprite.x + addX, parentSprite.y + addY);
			scrollFactor.set(parentSprite.scrollFactor.x, parentSprite.scrollFactor.y);

			if (copyParentAngle)
				angle = parentSprite.angle + addAngle;

			if (copyParentAlpha)
				alpha = parentSprite.alpha * addAlpha;

			if (copyParentVisib)
				visible = parentSprite.visible;
		}
	}
}
