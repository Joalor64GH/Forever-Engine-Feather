package;

import base.feather.ScriptHandler;
import dependency.FNFSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import gameObjects.Note;
import gameObjects.NoteSplash;
import gameObjects.Strumline.Receptor;
import gameObjects.userInterface.menu.Checkmark;
import playerData.Timings;
import song.Conductor;
import states.PlayState;

using StringTools;

/**
	Forever Assets is a class that manages the different asset types, basically a compilation of switch statements that are
	easy to edit for your own needs. Most of these are just static functions that return information
**/
class ForeverAssets
{
	//
	public static function generateCombo(asset:String, assetGroup:FlxTypedGroup<FNFSprite>, number:String, allSicks:Bool, assetModifier:String = 'base',
			changeableSkin:String = 'default', baseLibrary:String, negative:Bool, createdColor:FlxColor, scoreInt:Int):FNFSprite
	{
		var width = 100;
		var height = 140;

		if (assetModifier == 'pixel')
		{
			width = 10;
			height = 12;
		}
		var comboNumbers:FNFSprite;

		if (assetGroup != null && Init.trueSettings.get('Judgement Recycling'))
			comboNumbers = assetGroup.recycle(FNFSprite);
		else
			comboNumbers = new FNFSprite();
		comboNumbers.loadGraphic(Paths.image(ForeverTools.returnSkinAsset(asset, assetModifier, changeableSkin, baseLibrary)), true, width, height);
		comboNumbers.alpha = 1;
		comboNumbers.screenCenter();
		comboNumbers.x += (43 * scoreInt) + 20;
		comboNumbers.y += 60;

		comboNumbers.color = FlxColor.WHITE;
		if (negative)
			comboNumbers.color = createdColor;

		comboNumbers.animation.add('base', [
			(Std.parseInt(number) != null ? Std.parseInt(number) + 1 : 0) + (!allSicks ? 0 : 11)
		], 0, false);
		comboNumbers.animation.play('base');
		comboNumbers.zDepth = -Conductor.songPosition;

		if (assetModifier == 'pixel')
		{
			comboNumbers.antialiasing = false;
			comboNumbers.setGraphicSize(Std.int(comboNumbers.width * PlayState.daPixelZoom));
		}
		else
		{
			comboNumbers.antialiasing = true;
			comboNumbers.setGraphicSize(Std.int(comboNumbers.width * 0.5));
		}
		comboNumbers.updateHitbox();
		if (!Init.trueSettings.get('Simply Judgements'))
		{
			comboNumbers.acceleration.y = FlxG.random.int(200, 300);
			comboNumbers.velocity.y = -FlxG.random.int(140, 160);
			comboNumbers.velocity.x = FlxG.random.float(-5, 5);
		}

		return comboNumbers;
	}

	public static function generateRating(asset:String, assetGroup:FlxTypedGroup<FNFSprite>, perfectSick:Bool, timing:String, assetModifier:String = 'base',
			changeableSkin:String = 'default', baseLibrary:String):FNFSprite
	{
		var width = 500;
		var height = 163;
		if (assetModifier == 'pixel')
		{
			width = 72;
			height = 32;
		}
		var judgement:FNFSprite;
		if (assetGroup != null && Init.trueSettings.get('Judgement Recycling'))
			judgement = assetGroup.recycle(FNFSprite);
		else
			judgement = new FNFSprite();

		judgement.loadGraphic(Paths.image(ForeverTools.returnSkinAsset('judgements', assetModifier, changeableSkin, baseLibrary)), true, width, height);
		judgement.alpha = 1;
		judgement.screenCenter();
		judgement.x = (FlxG.width * 0.55) - 40;
		judgement.y -= 60;
		if (!Init.trueSettings.get('Simply Judgements'))
		{
			judgement.acceleration.y = 550;
			judgement.velocity.y = -FlxG.random.int(140, 175);
			judgement.velocity.x = -FlxG.random.int(0, 10);
		}
		judgement.animation.add('base', [
			Std.int((Timings.judgementsMap.get(asset)[0] * 2) + (perfectSick ? 0 : 2) + (timing == 'late' ? 1 : 0))
		], 24, false);
		judgement.animation.play('base');
		judgement.zDepth = -Conductor.songPosition;

		if (assetModifier == 'pixel')
		{
			judgement.antialiasing = false;
			judgement.setGraphicSize(Std.int(judgement.width * PlayState.daPixelZoom * 0.7));
		}
		else
		{
			judgement.antialiasing = true;
			judgement.setGraphicSize(Std.int(judgement.width * 0.7));
		}

		return judgement;
	}

	public static function generateNoteSplashes(asset:String, group:FlxTypedSpriteGroup<NoteSplash>, assetModifier:String = 'base',
			changeableSkin:String = 'default', baseLibrary:String, noteType:String = 'default', noteData:Int):NoteSplash
	{
		//
		var tempSplash:NoteSplash = group.recycle(NoteSplash);
		tempSplash.noteData = noteData;
		tempSplash.zDepth = -Conductor.songPosition;

		switch (assetModifier)
		{
			case 'pixel':
				tempSplash.loadGraphic(Paths.image(ForeverTools.returnSkinAsset('splash-pixel', assetModifier, changeableSkin, baseLibrary, 'notetypes'),
					'notetypes'), true, 34,
					34);
				tempSplash.animation.add('anim1', [noteData, 4 + noteData, 8 + noteData, 12 + noteData], 24, false);
				tempSplash.animation.add('anim2', [16 + noteData, 20 + noteData, 24 + noteData, 28 + noteData], 24, false);
				tempSplash.animation.play('anim1');
				tempSplash.addOffset('anim1', -120, -90);
				tempSplash.addOffset('anim2', -120, -90);
				tempSplash.setGraphicSize(Std.int(tempSplash.width * PlayState.daPixelZoom));

			default:
				tempSplash.loadGraphic(Paths.image(ForeverTools.returnSkinAsset(asset, assetModifier, changeableSkin, baseLibrary, 'notetypes'), 'notetypes'),
					true, 210, 210);
				tempSplash.animation.add('anim1', [
					(noteData * 2 + 1),
					8 + (noteData * 2 + 1),
					16 + (noteData * 2 + 1),
					24 + (noteData * 2 + 1),
					32 + (noteData * 2 + 1)
				], 24, false);
				tempSplash.animation.add('anim2', [
					(noteData * 2),
					8 + (noteData * 2),
					16 + (noteData * 2),
					24 + (noteData * 2),
					32 + (noteData * 2)
				], 24, false);
				tempSplash.animation.play('anim1');
				tempSplash.addOffset('anim1', -20, -10);
				tempSplash.addOffset('anim2', -20, -10);
		}

		return tempSplash;
	}

	public static function generateUIArrows(x:Float, y:Float, ?receptorData:Int = 0, framesArg:String, assetModifier:String,
			noteType:String = 'default'):Receptor
	{
		var uiReceptor:Receptor = new Receptor(x, y, receptorData);
		switch (assetModifier)
		{
			case 'pixel':
				// look man you know me I fucking hate repeating code
				// not even just a cleanliness thing it's just so annoying to tweak if something goes wrong like
				// genuinely more programmers should make their code more modular
				uiReceptor.loadGraphic(Paths.image(ForeverTools.returnSkinAsset('arrows-pixels', assetModifier, Init.trueSettings.get("Note Skin"),
					'$noteType/skins', 'notetypes'),
					'notetypes'),
					true, 17, 17);
				uiReceptor.animation.add('static', [receptorData]);
				uiReceptor.animation.add('pressed', [4 + receptorData, 8 + receptorData], 12, false);
				uiReceptor.animation.add('confirm', [12 + receptorData, 16 + receptorData], 24, false);

				uiReceptor.setGraphicSize(Std.int(uiReceptor.width * PlayState.daPixelZoom));
				uiReceptor.updateHitbox();
				uiReceptor.antialiasing = false;

				uiReceptor.addOffset('static', -67, -50);
				uiReceptor.addOffset('pressed', -67, -50);
				uiReceptor.addOffset('confirm', -67, -50);

			case 'chart editor':
				uiReceptor.loadGraphic(Paths.image('UI/forever/base/chart editor/note_array'), true, 157, 156);
				uiReceptor.animation.add('static', [receptorData]);
				uiReceptor.animation.add('pressed', [16 + receptorData], 12, false);
				uiReceptor.animation.add('confirm', [4 + receptorData, 8 + receptorData, 16 + receptorData], 24, false);

				uiReceptor.addOffset('static');
				uiReceptor.addOffset('pressed');
				uiReceptor.addOffset('confirm');

			default:
				// probably gonna revise this and make it possible to add other arrow types but for now it's just pixel and normal
				var stringSect:String = '';
				// call arrow type I think
				stringSect = Receptor.actions[receptorData];

				uiReceptor.frames = Paths.getSparrowAtlas(ForeverTools.returnSkinAsset('$framesArg', assetModifier, Init.trueSettings.get("Note Skin"),
					'$noteType/skins', 'notetypes'),
					'notetypes');

				uiReceptor.animation.addByPrefix('static', 'arrow' + stringSect.toUpperCase());
				uiReceptor.animation.addByPrefix('pressed', stringSect + ' press', 24, false);
				uiReceptor.animation.addByPrefix('confirm', stringSect + ' confirm', 24, false);

				uiReceptor.antialiasing = true;
				uiReceptor.setGraphicSize(Std.int(uiReceptor.width * 0.7));

				// set little offsets per note!
				// so these had a little problem honestly and they make me wanna off(set) myself so the middle notes basically
				// have slightly different offsets than the side notes (which have the same offset)

				var offsetMiddleX = 0;
				var offsetMiddleY = 0;
				if (receptorData > 0 && receptorData < 3)
				{
					offsetMiddleX = 2;
					offsetMiddleY = 2;
					if (receptorData == 1)
					{
						offsetMiddleX -= 1;
						offsetMiddleY += 2;
					}
				}

				uiReceptor.addOffset('static');
				uiReceptor.addOffset('pressed', -2, -2);
				uiReceptor.addOffset('confirm', 36 + offsetMiddleX, 36 + offsetMiddleY);
		}

		return uiReceptor;
	}

	/**
		Notes!
	**/
	public static function generateArrow(framesArg, assetModifier, strumTime, noteData, noteAlt, noteType, ?isSustainNote:Bool = false,
			?prevNote:Note = null):Note
	{
		if (framesArg == null || framesArg.length < 1)
			framesArg = 'NOTE_assets';
		var changeableSkin:String = Init.trueSettings.get("Note Skin");

		var newNote:Note;

		// gonna improve the system eventually
		if (changeableSkin.startsWith('quant'))
			newNote = Note.returnQuantNote(assetModifier, strumTime, noteData, noteAlt, noteType, isSustainNote, prevNote);
		else
		{
			newNote = new Note(strumTime, noteData, noteAlt, noteType, prevNote, isSustainNote);

			// newNote.holdHeight = 0.72;

			// frames originally go here
			switch (assetModifier)
			{
				case 'pixel': // pixel arrows default
					switch (noteType)
					{
						default:
							if (isSustainNote)
								Note.resetNote('arrowEnds', changeableSkin, assetModifier, newNote);
							else
								Note.resetNote('arrows-pixels', changeableSkin, assetModifier, newNote);
							newNote.antialiasing = false;
							newNote.setGraphicSize(Std.int(newNote.width * PlayState.daPixelZoom));
							newNote.updateHitbox();
					}
				default: // base game arrows for no reason whatsoever
					switch (noteType)
					{
						default:
							Note.resetNote(framesArg, changeableSkin, assetModifier, newNote);

							newNote.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
							newNote.setGraphicSize(Std.int(newNote.width * 0.7));
							newNote.updateHitbox();
					}
			}

			if (!isSustainNote)
				newNote.animation.play(Receptor.colors[noteData] + 'Scroll');

			if (isSustainNote && prevNote != null)
			{
				newNote.noteSpeed = prevNote.noteSpeed;
				newNote.alpha = (Init.trueSettings.get('Opaque Holds')) ? 1 : 0.6;
				newNote.animation.play(Receptor.colors[noteData] + 'holdend');
				newNote.updateHitbox();
				if (prevNote.isSustainNote)
				{
					prevNote.animation.play(Receptor.colors[prevNote.noteData] + 'hold');
					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * prevNote.noteSpeed;
					prevNote.updateHitbox();
				}
			}
		}

		// hold note shit
		if (isSustainNote && prevNote != null)
		{
			// set note offset
			if (prevNote.isSustainNote)
				newNote.noteVisualOffset = prevNote.noteVisualOffset;
			else // calculate a new visual offset based on that note's width and newnote's width
				newNote.noteVisualOffset = ((prevNote.width / 2) - (newNote.width / 2));
		}

		return newNote;
	}

	/**
		Checkmarks!
	**/
	public static function generateCheckmark(x:Float, y:Float, asset:String, assetModifier:String = 'base', changeableSkin:String = 'default',
			baseLibrary:String)
	{
		var newCheckmark:Checkmark = new Checkmark(x, y);
		switch (assetModifier)
		{
			default:
				newCheckmark.frames = Paths.getSparrowAtlas(ForeverTools.returnSkinAsset(asset, assetModifier, changeableSkin, baseLibrary));
				newCheckmark.antialiasing = true;

				newCheckmark.animation.addByPrefix('false finished', 'uncheckFinished');
				newCheckmark.animation.addByPrefix('false', 'uncheck', 12, false);
				newCheckmark.animation.addByPrefix('true finished', 'checkFinished');
				newCheckmark.animation.addByPrefix('true', 'check', 12, false);

				// for week 7 assets when they decide to exist
				// animation.addByPrefix('false', 'Check Box unselected', 24, true);
				// animation.addByPrefix('false finished', 'Check Box unselected', 24, true);
				// animation.addByPrefix('true finished', 'Check Box Selected Static', 24, true);
				// animation.addByPrefix('true', 'Check Box selecting animation', 24, false);
				newCheckmark.setGraphicSize(Std.int(newCheckmark.width * 0.7));
				newCheckmark.updateHitbox();

				///*
				var offsetByX = 45;
				var offsetByY = 5;
				newCheckmark.addOffset('false', offsetByX, offsetByY);
				newCheckmark.addOffset('true', offsetByX, offsetByY);
				newCheckmark.addOffset('true finished', offsetByX, offsetByY);
				newCheckmark.addOffset('false finished', offsetByX, offsetByY);
				// */

				// addOffset('true finished', 17, 37);
				// addOffset('true', 25, 57);
				// addOffset('false', 2, -30);
		}
		return newCheckmark;
	}
}
