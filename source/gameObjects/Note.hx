package gameObjects;

import base.feather.ScriptHandler;
import dependency.FNFSprite;
import flixel.FlxSprite;
import gameObjects.Strumline.Receptor;
import playerData.Timings;
import song.Conductor;
import states.PlayState;

using StringTools;

class Note extends FNFSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var noteAlt:Float = 0;
	public var noteType:String = 'default';
	public var noteString:String = "";

	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var ignoreNote:Bool = false;
	public var noteSplash:Bool = false;
	public var isMine:Bool = false;

	// only useful for charting stuffs
	public var chartSustain:FlxSprite = null;
	public var rawNoteData:Int;

	// not set initially
	public var noteQuant:Int = -1;
	public var noteVisualOffset:Float = 0;
	public var noteSpeed:Float = 0;
	public var noteDirection:Float = 0;

	public var parentNote:Note;
	public var childrenNotes:Array<Note> = [];

	public static var swagWidth:Float = 160 * 0.7;

	// it has come to this.
	public var endHoldOffset:Float = Math.NEGATIVE_INFINITY;

	public static var storedModules:Array<ScriptHandler>;
	private static var pushedNotes:Array<String> = [];

	public static var noteScript:ScriptHandler;

	public function new(strumTime:Float, noteData:Int, noteAlt:Float, noteType:String, ?prevNote:Note, ?isSustainNote:Bool = false)
	{
		this.prevNote = prevNote;
		this.isSustainNote = isSustainNote;
		this.strumTime = strumTime;
		this.noteData = noteData;
		this.noteAlt = noteAlt;

		if (prevNote == null)
			prevNote = this;

		if (noteType == null)
			noteType = 'default';

		super(x, y);

		// oh okay I know why this exists now
		y -= 2000;

		// determine parent note
		if (isSustainNote && prevNote != null)
		{
			parentNote = prevNote;
			while (parentNote.parentNote != null)
				parentNote = parentNote.parentNote;
			parentNote.childrenNotes.push(this);
		}
		else if (!isSustainNote)
			parentNote = null;

		antialiasing = !Init.trueSettings.get('Disable Antialiasing');

		// generateNote(noteType);
	}

	function getNoteColor(noteData)
		return Receptor.colors[noteData];

	function getNoteAction(noteData)
		return Receptor.actions[noteData];

	public function generateNote(noteType:String)
	{
		this.noteType = noteType;
		noteScript = getNoteScript(noteType);

		noteScript.set('getNoteColor', getNoteColor);
		noteScript.set('getNoteAction', getNoteAction);
		noteScript.set('noteSkin', Init.trueSettings.get('Note Skin'));
		// noteScript.set('playerNote', framesArg);

		var noteFunc:String = isSustainNote ? 'generateSustain' : 'generateNote';

		try
		{
			noteScript.call(noteFunc, [this]);
			trace('new note module loaded: ' + noteType);
		}
		catch (e)
		{
			trace('[NOTE ERROR] Script: $noteType is null');
			this.destroy();
			return;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			if (strumTime > Conductor.songPosition - (Timings.msThreshold) && strumTime < Conductor.songPosition + (Timings.msThreshold))
				canBeHit = true;
			else
				canBeHit = false;
		}
		else // make sure the note can't be hit if it's the dad's I guess
			canBeHit = false;

		if (tooLate || (parentNote != null && parentNote.tooLate))
			alpha = 0.3;

		if (noteScript != null)
			noteScript.call('update', [elapsed]);
	}

	public static function resetNote(framesArg:String, changeable:String = '', assetModifier:String, newNote:Note)
	{
		var pixelData:Array<Int> = [4, 5, 6, 7];

		if (framesArg.length < 2 || framesArg == null)
		{
			if (assetModifier == 'pixel')
			{
				if (newNote.isSustainNote)
					framesArg = 'arrowEnds';
				else
					framesArg = 'arrows-pixels';
			}
			else
				framesArg = 'NOTE_assets';
		}

		if (assetModifier != 'pixel')
		{
			var skinAssetPath:String = ForeverTools.returnSkinAsset(framesArg, assetModifier, changeable, '${newNote.noteType}/skins', 'notetypes');
			newNote.frames = Paths.getSparrowAtlas(skinAssetPath, 'notetypes');

			newNote.animation.addByPrefix(Receptor.colors[newNote.noteData] + 'Scroll', Receptor.colors[newNote.noteData] + '0');
			newNote.animation.addByPrefix(Receptor.colors[newNote.noteData] + 'holdend', Receptor.colors[newNote.noteData] + ' hold end');
			newNote.animation.addByPrefix(Receptor.colors[newNote.noteData] + 'hold', Receptor.colors[newNote.noteData] + ' hold piece');

			newNote.animation.addByPrefix('purpleholdend', 'pruple end hold'); // PA god dammit.
		}
		else
		{
			if (newNote.isSustainNote)
			{
				var skinAssetPath:String = ForeverTools.returnSkinAsset(framesArg, assetModifier, changeable, '${newNote.noteType}/skins', 'notetypes');
				newNote.loadGraphic(Paths.image(skinAssetPath, 'notetypes'), true, 7, 6);

				newNote.animation.add(Receptor.colors[newNote.noteData] + 'holdend', [pixelData[newNote.noteData]]);
				newNote.animation.add(Receptor.colors[newNote.noteData] + 'hold', [pixelData[newNote.noteData] - 4]);
			}
			else
			{
				var skinAssetPath:String = ForeverTools.returnSkinAsset(framesArg, assetModifier, changeable, '${newNote.noteType}/skins', 'notetypes');
				newNote.loadGraphic(Paths.image(skinAssetPath, 'notetypes'), true, 17, 17);
				newNote.animation.add(Receptor.colors[newNote.noteData] + 'Scroll', [pixelData[newNote.noteData]], 12);
			}
		}
	}

	public static function returnQuantNote(assetModifier, strumTime, noteData, noteAlt, noteType, ?isSustainNote:Bool = false, ?prevNote:Note = null):Note
	{
		var newNote:Note = new Note(strumTime, noteData, noteAlt, noteType, prevNote, isSustainNote);

		// actually determine the quant of the note
		if (newNote.noteQuant == -1)
		{
			/*
				I have to credit like 3 different people for these LOL they were a hassle
				but its gede pixl and scarlett, thank you SO MUCH for baring with me
			 */
			final quantArray:Array<Int> = [4, 8, 12, 16, 20, 24, 32, 48, 64, 192]; // different quants

			var curBPM:Float = Conductor.bpm;
			var newTime = strumTime;
			for (i in 0...Conductor.bpmChangeMap.length)
			{
				if (strumTime > Conductor.bpmChangeMap[i].songTime)
				{
					curBPM = Conductor.bpmChangeMap[i].bpm;
					newTime = strumTime - Conductor.bpmChangeMap[i].songTime;
				}
			}

			final beatTimeSeconds:Float = (60 / curBPM); // beat in seconds
			final beatTime:Float = beatTimeSeconds * 1000; // beat in milliseconds
			// assumed 4 beats per measure?
			final measureTime:Float = beatTime * 4;

			final smallestDeviation:Float = measureTime / quantArray[quantArray.length - 1];

			for (quant in 0...quantArray.length)
			{
				// please generate this ahead of time and put into array :)
				// I dont think I will im scared of those
				final quantTime = (measureTime / quantArray[quant]);
				if ((newTime #if !neko + Init.trueSettings['Offset'] #end + smallestDeviation) % quantTime < smallestDeviation * 2)
				{
					// here it is, the quant, finally!
					newNote.noteQuant = quant;
					break;
				}
			}
		}

		// note quants
		switch (assetModifier)
		{
			default:
				// inherit last quant if hold note
				if (isSustainNote && prevNote != null)
					newNote.noteQuant = prevNote.noteQuant;
				// base quant notes
				if (!isSustainNote)
				{
					// in case you're unfamiliar with these, they're ternary operators, I just dont wanna check for pixel notes using a separate statement
					var newNoteSize:Int = (assetModifier == 'pixel') ? 17 : 157;
					var skinAssetPath:String = ForeverTools.returnSkinAsset('NOTE_quants', assetModifier, Init.trueSettings.get("Note Skin"), 'default/skins',
						'notetypes');
					newNote.loadGraphic(Paths.image(skinAssetPath, 'notetypes'), true, newNoteSize, newNoteSize);

					newNote.animation.add('leftScroll', [0 + (newNote.noteQuant * 4)]);
					// LOL downscroll thats so funny to me
					newNote.animation.add('downScroll', [1 + (newNote.noteQuant * 4)]);
					newNote.animation.add('upScroll', [2 + (newNote.noteQuant * 4)]);
					newNote.animation.add('rightScroll', [3 + (newNote.noteQuant * 4)]);
				}
				else
				{
					// quant holds
					var skinAssetPath:String = ForeverTools.returnSkinAsset('HOLD_quants', assetModifier, Init.trueSettings.get("Note Skin"), 'default/skins',
						'notetypes');
					newNote.loadGraphic(Paths.image(skinAssetPath, 'notetypes'), true, (assetModifier == 'pixel') ? 17 : 109,
						(assetModifier == 'pixel') ? 6 : 52);
					newNote.animation.add('hold', [0 + (newNote.noteQuant * 4)]);
					newNote.animation.add('holdend', [1 + (newNote.noteQuant * 4)]);
					newNote.animation.add('rollhold', [2 + (newNote.noteQuant * 4)]);
					newNote.animation.add('rollend', [3 + (newNote.noteQuant * 4)]);
				}

				if (assetModifier == 'pixel')
				{
					newNote.antialiasing = false;
					newNote.setGraphicSize(Std.int(newNote.width * PlayState.daPixelZoom));
					newNote.updateHitbox();
				}
				else
				{
					newNote.setGraphicSize(Std.int(newNote.width * 0.7));
					newNote.updateHitbox();
					newNote.antialiasing = true;
				}
		}

		//
		if (!isSustainNote)
			newNote.animation.play(Receptor.actions[noteData] + 'Scroll');

		if (isSustainNote && prevNote != null)
		{
			newNote.noteSpeed = prevNote.noteSpeed;
			newNote.alpha = Init.trueSettings.get('Hold Opacity') * 0.01;
			newNote.animation.play('holdend');
			newNote.updateHitbox();

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play('hold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * (43 / 52) * 1.5 * prevNote.noteSpeed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}

		return newNote;
	}

	public function noteHit()
	{
		if (noteScript != null)
			noteScript.call('onHit', [this]);
	}

	public function noteMiss()
	{
		if (noteScript != null)
			noteScript.call('onMiss', [this]);
	}

	public function stepHit()
	{
		if (noteScript != null)
			noteScript.call('stepHit', [this]);
	}

	public function beatHit()
	{
		if (noteScript != null)
			noteScript.call('beatHit', [this]);
	}

	public static function getNoteScript(noteType:String):ScriptHandler
	{
		if (noteType == null)
			noteType = 'default';

		if (!pushedNotes.contains(noteType))
		{
			var module:String = Paths.module('$noteType', 'notetypes/$noteType');

			if (openfl.Assets.exists(module))
				noteScript = new ScriptHandler(module);

			if (noteScript != null)
				pushedNotes.push(noteType);

			return noteScript;
		}
		return null;
	}
}
