package gameObjects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import song.Conductor;
import states.PlayState;

using StringTools;

class Receptor extends FlxSprite
{
	/*  Oh hey, just gonna port this code from the previous Skater engine 
		(depending on the release of this you might not have it cus I might rewrite skater to use this engine instead)
		It's basically just code from the game itself but
		it's in a separate class and I also added the ability to set offsets for the arrows.

		uh hey you're cute ;)
	 */
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var strumData:Int = 0;
	public var canFinishAnimation:Bool = true;

	public var initialX:Int;
	public var initialY:Int;

	public var xTo:Float;
	public var yTo:Float;
	public var angleTo:Float;

	public var overrideAlpha:Bool = false;

	public var setAlpha:Float = Init.trueSettings.get('Arrow Opacity') * 0.01;

	public static var actions:Array<String> = ['left', 'down', 'up', 'right'];
	public static var colors:Array<String> = ['purple', 'blue', 'green', 'red'];

	public function new(x:Float, y:Float, ?strumData:Int = 0)
	{
		// this extension is just going to rely a lot on preexisting code as I wanna try to write an extension before I do options and stuff
		super(x, y);
		animOffsets = new Map<String, Array<Dynamic>>();

		this.strumData = strumData;

		updateHitbox();
		scrollFactor.set();
		antialiasing = !Init.trueSettings.get('Disable Antialiasing');
	}

	// literally just character code
	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (!overrideAlpha)
			alpha = AnimName == 'confirm' ? 1 : setAlpha;

		animation.play(AnimName, Force, Reversed, Frame);
		updateHitbox();

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
		animOffsets[name] = [x, y];
}

class Strumline extends FlxSpriteGroup
{
	//
	public var receptors:FlxTypedSpriteGroup<Receptor>;
	public var splashNotes:FlxTypedSpriteGroup<NoteSplash>;
	public var notesGroup:FlxTypedSpriteGroup<Note>;
	public var holdsGroup:FlxTypedSpriteGroup<Note>;
	public var allNotes:FlxTypedGroup<Note>;

	public var characters:Array<Character>;

	public var doTween:Bool = true;
	public var autoplay:Bool = true;
	public var displayJudges:Bool = false;
	public var downscroll:Bool = false;

	public var keyAmount:Int = 4;
	public var xPos:Float = 0;
	public var yPos:Float = 0;

	public var receptorFrames:String = "NOTE_assets";
	public var assetModifier:String = "base";

	public function new(xPos:Float = 0, yPos:Float = 0, receptorFrames:String = 'NOTE_assets', assetModifier:String = 'base', characters:Array<Character>,
			?downscroll:Bool = false, ?displayJudges:Bool = true, ?autoplay:Bool = true, ?doTween:Bool = true, ?keyAmount:Int = 4)
	{
		super();

		receptors = new FlxTypedSpriteGroup<Receptor>();
		splashNotes = new FlxTypedSpriteGroup<NoteSplash>();
		notesGroup = new FlxTypedSpriteGroup<Note>();
		holdsGroup = new FlxTypedSpriteGroup<Note>();

		allNotes = new FlxTypedGroup<Note>();

		this.autoplay = autoplay;
		this.characters = characters;
		this.doTween = doTween;

		this.displayJudges = displayJudges;
		this.receptorFrames = receptorFrames;
		this.assetModifier = assetModifier;
		this.downscroll = downscroll;

		this.xPos = xPos;
		this.keyAmount = keyAmount;
		this.yPos = yPos;

		reloadReceptors(assetModifier);
	}

	public function reloadReceptors(?modifier:String = "base", ?xNew:Float, ?yNew:Float, ?skipTween:Bool = false)
	{
		receptors.forEachAlive(function(receptor:Receptor)
		{
			receptor.destroy();
		});
		receptors.clear();

		splashNotes.forEachAlive(function(noteSplash:NoteSplash)
		{
			noteSplash.destroy();
		});
		splashNotes.clear();

		doTween = !skipTween;

		for (i in 0...keyAmount)
		{
			var addX:Int = modifier == 'pixel' ? -35 : -20;
			var addY:Int = modifier == 'pixel' ? 40 : 25;

			var receptor:Receptor = ForeverAssets.generateUIArrows(addX + (xNew == null ? xPos : xNew), addY + (yNew == null ? yPos : yNew), i,
				receptorFrames, modifier);
			receptor.ID = i;

			receptor.x -= ((keyAmount / 2) * Note.swagWidth);
			receptor.x += (Note.swagWidth * i);
			receptors.add(receptor);

			receptor.initialX = Math.floor(receptor.x);
			receptor.initialY = Math.floor(receptor.y);
			receptor.angleTo = 0;
			receptor.y -= 10;
			receptor.playAnim('static');

			if (doTween)
			{
				receptor.alpha = 0;
				FlxTween.tween(receptor, {y: receptor.initialY, alpha: receptor.setAlpha}, (Conductor.crochet * 4) / 1000,
					{ease: FlxEase.circOut, startDelay: (Conductor.crochet / 1000) + ((Conductor.stepCrochet / 1000) * i)});
			}
			else
			{
				receptor.y = receptor.initialY;
				receptor.alpha = receptor.setAlpha;
			}

			if (displayJudges)
			{
				var noteSplash:NoteSplash = null;
				for (character in this.characters)
				{
					var splashSkin:String = character.characterData.splashSkin;
					noteSplash = ForeverAssets.generateNoteSplashes(splashSkin, splashNotes, modifier, PlayState.changeableSkin, 'default/skins', i);
				}
				splashNotes.add(noteSplash);
			}
		}

		if (Init.trueSettings.get("Clip Style").toLowerCase() == 'stepmania')
			add(holdsGroup);
		add(receptors);
		if (Init.trueSettings.get("Clip Style").toLowerCase() == 'fnf')
			add(holdsGroup);
		add(notesGroup);
		if (splashNotes != null)
			add(splashNotes);
	}

	public function createSplash(coolNote:Note)
	{
		// play animation in existing notesplashes
		var noteSplashRandom:String = (Std.string((FlxG.random.int(0, 1) + 1)));
		splashNotes.members[coolNote.noteData].playAnim('anim' + noteSplashRandom);
	}

	public function push(newNote:Note)
	{
		//
		var chosenGroup = (newNote.isSustainNote ? holdsGroup : notesGroup);
		chosenGroup.add(newNote);
		allNotes.add(newNote);
		chosenGroup.sort(FlxSort.byY, (!Init.trueSettings.get('Downscroll')) ? FlxSort.DESCENDING : FlxSort.ASCENDING);
	}
}
