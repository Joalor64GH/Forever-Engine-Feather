package gameObjects;

import base.feather.ScriptHandler;
import dependency.FNFSprite;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import states.PlayState;

using StringTools;

typedef StageDataDef =
{
	var objects:Array<StageObject>;

	var spawnGirlfriend:Bool;
	var defaultZoom:Float;
	var camSpeed:Float;
	var dadPos:Array<Int>;
	var gfPos:Array<Int>;
	var bfPos:Array<Int>;
}

typedef StageObject =
{
	var name:Null<String>; // for getting the name of `this` object on a script;
	var image:Null<String>; // the image file name for `this` object;
	var imageDirectory:Null<String>; // the image file path for `this` object;
	var position:Null<Array<Float>>; // the position of `this` object;
	var scrollFactor:Null<Array<Float>>; // the scroll factor for `this` object;
	var scale:Null<Array<Float>>; // the scale for `this` object;
	var animations:Null<Array<Dynamic>>; // the animations available on `this` object;
	var defaultAnimation:Null<String>; // the object's default animation;
	var flipX:Null<Bool>; // whether `this` object is flipped horizontally;
	var flipY:Null<Bool>; // whether `this` object is flipped vertically;
	var size:Null<Float>; // the size for `this` object;
	var layer:String; // where should `this` object be spawned;
	var blend:String; // the blend mode for `this` object;
	var antialiasing:Bool; // whether `this` object has antialiasing enabled;
}

class Stage extends FlxTypedGroup<FlxBasic>
{
	//
	public var gfVersion:String = 'gf';

	public var curStage:String;

	var daPixelZoom = PlayState.daPixelZoom;

	public var foreground:FlxTypedGroup<FlxBasic>;
	public var layers:FlxTypedGroup<FlxBasic>;

	public var spawnGirlfriend:Bool = true;

	public var objectMap:Map<String, FNFSprite> = new Map<String, FNFSprite>();
	public var stageScript:ScriptHandler;
	public var stageJson:StageDataDef;

	public var sendMessage:Bool = false;
	public var messageText:String = '';

	public function new(curStage:String = 'unknown', stageDebug:Bool = false)
	{
		super();
		this.curStage = curStage;

		// to apply to foreground use foreground.add(); instead of add();
		foreground = new FlxTypedGroup<FlxBasic>();
		layers = new FlxTypedGroup<FlxBasic>();

		reloadJson();

		if (!stageDebug)
		{
			if (PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1)
				curStage = 'unknown';
			else
				curStage = PlayState.SONG.stage;
		}

		//
		switch (curStage)
		{
			default:
				curStage = 'unknown';
				PlayState.defaultCamZoom = 0.9;
		}

		try
		{
			//
			callStageScript();
		}
		catch (e)
		{
			sendMessage = true;
			messageText = '[GAME STAGE]: Uncaught Error: $e';
		}
	}

	public function reloadJson()
	{
		try
		{
			stageJson = haxe.Json.parse(Paths.getTextFile('stages/$curStage/$curStage.json'));
		}
		catch (e)
		{
			stageJson = haxe.Json.parse('{
			    "spawnGirlfriend": true,
			    "defaultZoom": 0.9,
			    "camSpeed": 1,
			    "dadPos": [100, 100],
			    "gfPos": [300, 100],
			    "bfPos": [770, 450]
			}');
		}

		if (stageJson != null)
		{
			spawnGirlfriend = stageJson.spawnGirlfriend;
			PlayState.cameraSpeed = stageJson.camSpeed;

			if (stageJson.objects != null)
			{
				for (object in stageJson.objects)
				{
					var createdSprite:FNFSprite = new FNFSprite(object.position[0], object.position[1]);

					var directory:String = object.imageDirectory != null ? object.imageDirectory : 'stages/$curStage/images';

					if (object.animations != null)
					{
						createdSprite.frames = Paths.getSparrowAtlas(object.image, directory);
						for (anim in object.animations)
							createdSprite.animation.addByPrefix(anim[0], anim[1], anim[2], anim[3]);
						if (object.defaultAnimation != null)
							createdSprite.playAnim(object.defaultAnimation);
					}
					else
						createdSprite.loadGraphic(Paths.image(object.image, directory));

					if (object.scrollFactor != null)
						createdSprite.scrollFactor.set(object.scrollFactor[0], object.scrollFactor[1]);
					if (object.size != null)
						createdSprite.setGraphicSize(Std.int(createdSprite.width * object.size));
					if (object.scale != null)
					{
						createdSprite.scale.x = object.scale[0];
						createdSprite.scale.y = object.scale[1];
					}

					createdSprite.flipX = object.flipX;
					createdSprite.flipY = object.flipY;
					createdSprite.antialiasing = object.antialiasing;

					if (object.blend != null)
						createdSprite.blend = ForeverTools.returnBlendMode(object.blend);

					if (object.name != null && createdSprite != null)
						objectMap.set(object.name, createdSprite);
					switch (object.layer)
					{
						case 'layers' | 'on layers' | 'gf' | 'above gf':
							layers.add(createdSprite);
						case 'foreground' | 'on foreground' | 'chars' | 'above chars':
							foreground.add(createdSprite);
						default:
							add(createdSprite);
					}
				}
			}
		}
	}

	// return the girlfriend's type
	public function returnGFtype(curStage)
	{
		switch (curStage)
		{
			case 'highway':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school' | 'schoolEvil':
				gfVersion = 'gf-pixel';
			case 'military':
				if (PlayState.SONG.song.toLowerCase() == 'stress')
					gfVersion = 'pico-speaker';
				else
					gfVersion = 'gf-tankmen';
			default:
				gfVersion = 'gf';
		}

		return gfVersion;
	}

	public function dadPosition(curStage:String, boyfriend:Character, gf:Character, dad:Character, camPos:FlxPoint):Void
	{
		callFunc('postCreate', [boyfriend, gf, dad]);
		callFunc('dadPosition', [boyfriend, gf, dad]);
	}

	public function repositionPlayers(curStage:String, boyfriend:Character, gf:Character, dad:Character)
	{
		boyfriend.setPosition(stageJson.bfPos[0], stageJson.bfPos[1]);
		dad.setPosition(stageJson.dadPos[0], stageJson.dadPos[1]);
		gf.setPosition(stageJson.gfPos[0], stageJson.gfPos[1]);
		callFunc('repositionPlayers', [boyfriend, gf, dad]);
	}

	public function stageUpdate(curBeat:Int, boyfriend:Character, gf:Character, dad:Character)
	{
		callFunc('beatHit', [curBeat, boyfriend, gf, dad]);
		callFunc('updateStage', [curBeat, boyfriend, gf, dad]);
	}

	public function stageUpdateSteps(curStep:Int, boyfriend:Character, gf:Character, dad:Character)
	{
		callFunc('stepHit', [curStep, boyfriend, gf, dad]);
		callFunc('updateStageSteps', [curStep, boyfriend, gf, dad]);
	}

	public function stageUpdateConstant(elapsed:Float, boyfriend:Character, gf:Character, dad:Character)
	{
		callFunc('update', [elapsed, boyfriend, gf, dad]);
		callFunc('updateStageConst', [elapsed, boyfriend, gf, dad]);
	}

	override public function add(Object:FlxBasic):FlxBasic
	{
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		return super.add(Object);
	}

	function callStageScript()
	{
		var modulePath = Paths.module('$curStage/$curStage', 'stages');

		if (!sys.FileSystem.exists(modulePath))
			return;

		stageScript = new ScriptHandler(modulePath);

		/* ===== SCRIPT VARIABLES ===== */

		setVar('add', add);
		setVar('remove', remove);
		setVar('foreground', foreground);
		setVar('layers', layers);
		setVar('gfVersion', gfVersion);
		setVar('game', PlayState.main);
		setVar('spawnGirlfriend', function(blah:Bool)
		{
			spawnGirlfriend = blah;
		});
		if (PlayState.SONG != null)
			setVar('songName', PlayState.SONG.song.toLowerCase());

		if (PlayState.boyfriend != null)
		{
			setVar('bf', PlayState.boyfriend);
			setVar('boyfriend', PlayState.boyfriend);
			setVar('player', PlayState.boyfriend);
			setVar('bfName', PlayState.boyfriend.curCharacter);
			setVar('boyfriendName', PlayState.boyfriend.curCharacter);
			setVar('playerName', PlayState.boyfriend.curCharacter);

			setVar('bfData', PlayState.boyfriend.characterData);
			setVar('boyfriendData', PlayState.boyfriend.characterData);
			setVar('playerData', PlayState.boyfriend.characterData);
		}

		if (PlayState.opponent != null)
		{
			setVar('dad', PlayState.opponent);
			setVar('dadOpponent', PlayState.opponent);
			setVar('opponent', PlayState.opponent);
			setVar('dadName', PlayState.opponent.curCharacter);
			setVar('dadOpponentName', PlayState.opponent.curCharacter);
			setVar('opponentName', PlayState.opponent.curCharacter);

			setVar('dadData', PlayState.opponent.characterData);
			setVar('dadOpponentData', PlayState.opponent.characterData);
			setVar('opponentData', PlayState.opponent.characterData);
		}

		if (PlayState.gf != null)
		{
			setVar('gf', PlayState.gf);
			setVar('girlfriend', PlayState.gf);
			setVar('spectator', PlayState.gf);
			setVar('gfName', PlayState.gf.curCharacter);
			setVar('girlfriendName', PlayState.gf.curCharacter);
			setVar('spectatorName', PlayState.gf.curCharacter);

			setVar('gfData', PlayState.gf.characterData);
			setVar('girlfriendData', PlayState.gf.characterData);
			setVar('spectatorData', PlayState.gf.characterData);
		}

		setVar('getObject', function(object:String)
		{
			var gottenObject:FNFSprite = objectMap.get(object);
			return gottenObject;
		});

		callFunc('create', []);
		callFunc('generateStage', []);
	}

	public function callFunc(key:String, args:Array<Dynamic>)
	{
		if (stageScript == null)
			return null;
		else
			return stageScript.call(key, args);
	}

	public function setVar(key:String, value:Dynamic)
	{
		if (stageScript == null)
			return null;
		else
			return stageScript.set(key, value);
	}
}
