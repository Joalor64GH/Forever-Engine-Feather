package base.feather;

import base.feather.ScriptHandler;

using StringTools;

class Events
{
	public static var eventArray:Array<String> = [];
	public static var needsValue3:Array<String> = [];

	// public static var loadedEvents:Array<ScriptHandler> = [];
	// public static var pushedEvents:Array<String> = [];
	public static var loadedEvents:Map<String, ScriptHandler> = [];

	public static function getScriptEvents()
	{
		loadedEvents.clear();
		eventArray = [];

		var myEvents:Array<String> = [];

		for (event in CoolUtil.listFilesPathsInPath('assets/events'))
		{
			if (event.contains('.'))
			{
				event = event.substring(0, event.indexOf('.', 0));
				try
				{
					loadedEvents.set(event, new ScriptHandler(Paths.module('$event', 'events')));
					// trace('new event module loaded: ' + event);
					myEvents.push(event);
				}
				catch (e)
				{
					// have to use FlxG instead of main since this isn't a class;
					flixel.FlxG.switchState(new states.menus.MainMenu('[CHART EVENT]: Uncaught Error: $e'));
				}
			}
		}
		myEvents.sort(function(e1, e2) return Reflect.compare(e1.toLowerCase(), e2.toLowerCase()));

		for (e in myEvents)
		{
			if (!eventArray.contains(e))
				eventArray.push(e);
		}
		eventArray.insert(0, '');

		for (e in eventArray)
			returnValue3(e);

		myEvents = [];
	}

	public static function returnValue3(event:String):Array<String>
	{
		if (loadedEvents.get(event) != null)
		{
			var script:ScriptHandler = loadedEvents.get(event);
			var scriptCall = script.call('returnValue3', []);

			if (scriptCall != null)
			{
				needsValue3.push(event);
				// trace(needsValue3);
			}
		}
		return needsValue3.copy();
	}

	public static function returnEventDescription(event:String):String
	{
		if (loadedEvents.get(event) != null)
		{
			var script:ScriptHandler = loadedEvents.get(event);
			var descString = script.call('returnDescription', []);
			return descString;
		}
		trace('Event $event has no description.');
		return '';
	}
}
