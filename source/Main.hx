package;

import base.*;
import base.Overlay.Console;
import base.input.Controls;
import dependency.Discord;
import dependency.FNFTransition;
import dependency.FNFUIState;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxColor;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.Json;
import haxe.io.Path;
import lime.app.Application;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.UncaughtErrorEvent;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

typedef GameWeek =
{
	var songs:Array<WeekSong>;
	var characters:Array<String>;
	var ?difficulties:Array<String>;
	var attachedImage:String;
	var storyName:String;
	var startsLocked:Bool;
	var hideOnStory:Bool;
	var hideOnFreeplay:Bool;
	var hideUntilUnlocked:Bool;
}

typedef WeekSong =
{
	var name:String;
	var opponent:String;
	var ?player:String; // wanna do something with this later haha;
	var colors:Array<Int>;
}

// Here we actually import the states and metadata, and just the metadata.
// It's nice to have modularity so that we don't have ALL elements loaded at the same time.
// at least that's how I think it works. I could be stupid!
class Main extends Sprite
{
	// class action variables
	public static var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public static var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).

	public static var mainClassState:Class<FlxState> = states.TitleState; // Determine the main class state of the game
	public static var framerate:Int = 120; // How many frames per second the game should run at.

	public static var gameVersion:String = '0.3.1';
	public static var featherVersion:String = '0.1';

	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var infoCounter:Overlay; // initialize the heads up display that shows information before creating it.
	var infoConsole:Console; // intiialize the on-screen console for script debug traces before creating it.

	public static var gameWeeksMap:Map<String, GameWeek> = [];
	public static var gameWeeks:Array<String> = [];

	// heres gameweeks set up!
	// in case you wanna hardcode weeks

	public static function loadHardcodedWeeks()
	{
		gameWeeksMap = [
			"myWeek" => {
				songs: [
					{
						"name": "Bopeebo",
						"opponent": "dad",
						"colors": [129, 100, 223]
					}
				],

				attachedImage: "week1",
				storyName: "vs. DADDY DEAREST",
				characters: ["dad", "bf", "gf"],

				startsLocked: false,
				hideOnStory: false,
				hideOnFreeplay: false,
				hideUntilUnlocked: false
			}
		];
		gameWeeks.push('myWeek');
	}

	public static function loadGameWeeks(isStory:Bool = false)
	{
		gameWeeksMap.clear();
		gameWeeks = [];

		var weekList:Array<String> = CoolUtil.coolTextFile(Paths.txt('weeks/weekList'));
		for (i in 0...weekList.length)
		{
			if (!gameWeeksMap.exists(weekList[i]))
			{
				var week:GameWeek = parseGameWeeks(Paths.file('weeks/' + weekList[i] + '.json'));
				if (week != null)
				{
					if ((isStory && (!week.hideOnStory || !week.hideUntilUnlocked))
						|| (!isStory && (!week.hideOnFreeplay || !week.hideUntilUnlocked)))
					{
						gameWeeksMap.set(weekList[i], week);
						gameWeeks.push(weekList[i]);
					}
				}
			}
		}
	}

	public static function parseGameWeeks(path:String):GameWeek
	{
		var rawJson:String = null;

		if (openfl.Assets.exists(path))
			rawJson = openfl.Assets.getText(path);

		return Json.parse(rawJson);
	}

	// most of these variables are just from the base game!
	// be sure to mess around with these if you'd like.

	public static function main():Void
		Lib.current.addChild(new Main());

	// calls a function to set the game up
	public function new()
	{
		super();

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);

		/**
		 * locking neko platforms on 60 because similar to html5 it cannot go over that
		 * avoids note stutters and stuff
		**/
		#if neko
		framerate = 60;
		#end

		// simply said, a state is like the 'surface' area of the window where everything is drawn.
		// if you've used gamemaker you'll probably understand the term surface better
		// this defines the surface bounds

		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
			// this just kind of sets up the camera zoom in accordance to the surface width and camera zoom.
			// if set to negative one, it is done so automatically, which is the default.
		}

		FlxTransitionableState.skipNextTransIn = true;

		// here we set up the base game
		var gameCreate:FlxGame;
		gameCreate = new FlxGame(gameWidth, gameHeight, Init, #if (flixel < "5.0.0") zoom, #end framerate, framerate, skipSplash);
		addChild(gameCreate); // and create it afterwards

		// initialize the game controls;
		Controls.init();

		// begin the discord rich presence
		#if DISCORD_RPC
		Discord.initializeRPC();
		Discord.changePresence('');
		#end

		#if !mobile
		infoCounter = new Overlay(0, 0);
		addChild(infoCounter);
		#end

		#if SHOW_CONSOLE
		infoConsole = new Console();
		addChild(infoConsole);
		#end

		FlxG.stage.application.window.onClose.add(function()
		{
			#if DISCORD_RPC
			Discord.shutdownRPC();
			#end
			Sys.exit(1);
			base.input.Controls.destroy();
		});
	}

	public static function framerateAdjust(input:Float)
	{
		return input * (60 / FlxG.drawFramerate);
	}

	/*  This is used to switch "rooms," to put it basically. Imagine you are in the main menu, and press the freeplay button.
		That would change the game's main class to freeplay, as it is the active class at the moment.
	 */
	public static var lastState:FlxState;

	public static function switchState(curState:FlxState, target:FlxState)
	{
		// Custom made Trans in
		mainClassState = Type.getClass(target);
		if (!FlxTransitionableState.skipNextTransIn)
		{
			curState.openSubState(new FNFTransition(0.35, false));
			FNFTransition.finishCallback = function()
			{
				FlxG.switchState(target);
			};
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		// load the state
		FlxG.switchState(target);
	}

	public static function updateFramerate(newFramerate:Int)
	{
		// flixel will literally throw errors at me if I dont separate the orders
		if (newFramerate > FlxG.updateFramerate)
		{
			FlxG.updateFramerate = newFramerate;
			FlxG.drawFramerate = newFramerate;
		}
		else
		{
			FlxG.drawFramerate = newFramerate;
			FlxG.updateFramerate = newFramerate;
		}
	}

	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var errMsgPrint:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");

		path = "crash/" + "FE_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
					errMsgPrint += file + ":" + line + "\n"; // if you Ctrl+Mouse Click its go to the line.
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/BeastlyGhost/Forever-Engine-Feather";

		if (!openfl.Assets.exists("crash/"))
			FileSystem.createDirectory("crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsgPrint);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		var crashDialoguePath:String = "FE-CrashDialog";

		#if windows
		crashDialoguePath += ".exe";
		#end

		if (openfl.Assets.exists(crashDialoguePath))
		{
			Sys.println("Found crash dialog: " + crashDialoguePath);
			new Process(crashDialoguePath, [path]);
		}
		else
		{
			Sys.println("No crash dialog found! Making a simple alert instead...");
			Application.current.window.alert(errMsg, "Error!");
		}
	}
}
