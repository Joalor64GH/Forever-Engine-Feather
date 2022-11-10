package gameObjects;

import dependency.FNFSprite;

/**
	Create the note splashes in week 7 whenever you get a sick!
**/
class NoteSplash extends FNFSprite
{
	public var noteData:Int = 0;

	public function new(noteData:Int)
	{
		super(x, y);
		alpha = 0.000001;
		this.noteData = noteData;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// kill the note splash if it's done
		if (animation.finished)
		{
			// set the splash to invisible
			if (alpha != 0.000001)
				alpha = 0.000001;
		}
		//
	}

	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0)
	{
		// make sure the animation is visible
		if (!Init.trueSettings.get('Disable Note Splashes'))
			alpha = 0.6;

		super.playAnim(AnimName, Force, Reversed, Frame);
	}
}
