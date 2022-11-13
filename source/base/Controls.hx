package base;

import flixel.FlxG;
import openfl.events.KeyboardEvent;
import lime.app.Event;
import openfl.ui.Keyboard;

enum KeyState
{
	PRESSED;
	RELEASED;
}

typedef KeyCall = (Int, KeyState) -> Void; // ID in Array, State -> Function;
typedef BindCall = (String, Int, KeyState) -> Void; // Name, ID in Array, State -> Function;
// for convenience;
typedef Key = Null<Int>;

class Controls
{
	//
	public static var keyPressed:Event<KeyCall> = new Event<KeyCall>();
	public static var keyReleased:Event<KeyCall> = new Event<KeyCall>();
	public static var keyTriggered:Event<KeyCall> = new Event<KeyCall>();

	public static var keyEventPress:Event<BindCall> = new Event<BindCall>();
	public static var keyEventRelease:Event<BindCall> = new Event<BindCall>();
	// used by playstate for main controls;
	public static var keyEventTrigger:Event<BindCall> = new Event<BindCall>();

	public static var defaultActions:Map<String, Array<Key>> = [
		// NOTE KEYS
		"left" => [Keyboard.LEFT, Keyboard.D],
		"down" => [Keyboard.DOWN, Keyboard.F],
		"up" => [Keyboard.UP, Keyboard.J],
		"right" => [Keyboard.RIGHT, Keyboard.K],
		// UI KEYS
		"ui_left" => [Keyboard.LEFT, Keyboard.A],
		"ui_down" => [Keyboard.DOWN, Keyboard.S],
		"ui_up" => [Keyboard.UP, Keyboard.W],
		"ui_right" => [Keyboard.RIGHT, Keyboard.D],
		"accept" => [Keyboard.ENTER, Keyboard.SPACE],
		"pause" => [Keyboard.ENTER, Keyboard.P],
		"back" => [Keyboard.ESCAPE, Keyboard.BACKSPACE],
		// MISC GAME KEYS
		"reset" => [Keyboard.R, Keyboard.END],
		"autoplay" => [Keyboard.NUMBER_6],
		"skip" => [Keyboard.SHIFT, Keyboard.END],
		"debug" => [Keyboard.NUMBER_7, Keyboard.NUMBER_8],
	];

	public static var actions:Map<String, Array<Key>> = [];

	public static var keysHeld:Array<Key> = [];

	public static function init()
	{
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		if (FlxG.save.data.actionBinds == null)
			actions = defaultActions;
	}

	public static function destroy()
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
	}

	public static function onKeyPress(event:KeyboardEvent)
	{
		//
		if (FlxG.keys.enabled && (FlxG.state.active || FlxG.state.persistentUpdate))
		{
			if (!keysHeld.contains(event.keyCode))
			{
				keysHeld.push(event.keyCode);
				keyPressed.dispatch(event.keyCode, PRESSED);
				keyTriggered.dispatch(event.keyCode, PRESSED);

				for (key in catchKeys(event.keyCode))
				{
					keyEventPress.dispatch(key, event.keyCode, PRESSED);
					keyEventTrigger.dispatch(key, event.keyCode, PRESSED);
					// trace('Pressed Key: ' + key);
				}
			}
		}
	}

	public static function onKeyRelease(event:KeyboardEvent)
	{
		//
		if (FlxG.keys.enabled && (FlxG.state.active || FlxG.state.persistentUpdate))
		{
			if (keysHeld.contains(event.keyCode))
			{
				keysHeld.remove(event.keyCode);
				keyReleased.dispatch(event.keyCode, RELEASED);
				keyTriggered.dispatch(event.keyCode, RELEASED);

				for (key in catchKeys(event.keyCode))
				{
					keyEventRelease.dispatch(key, event.keyCode, RELEASED);
					keyEventTrigger.dispatch(key, event.keyCode, RELEASED);
					// trace('Released Key: ' + key);
				}
			}
		}
	}

	private static function catchKeys(key:Key):Array<String>
	{
		//
		if (key == null)
			return [];

		var gottenKeys:Array<String> = [];
		for (action => keys in actions)
		{
			if (keys.contains(key))
				gottenKeys.push(action);
		}

		return gottenKeys;
	}

	public static function getKeyState(key:Key):KeyState
	{
		//
		return keysHeld.contains(key) ? PRESSED : RELEASED;
	}

	public static function getKeyString(action:String)
	{
		//
		if (actions.exists(action))
			return action;
		return '';
	}

	public static function getPressEvent(action:String, type:String = 'justPressed'):Bool
	{
		// stores the last registered key event;
		var lastEvent:String = 'justReleased';

		// check event keys
		if (actions.exists(action))
		{
			var keys:Array<Key> = actions.get(action);

			lastEvent = type;

			// checks if the event is the one specified on the type parameter for the action we want;
			if (Reflect.field(FlxG.keys, 'any' + type.charAt(0).toUpperCase() + type.substr(1))(keys))
				return true;
		}

		return false;
	}

	public static function addActionKey(action:String, keys:Array<Key>)
	{
		//
		if (actions.exists(action))
		{
			actions.set(action, keys);
			// trace('binded $action to ID $keys');
		}
	}

	public static function setActionKey(action:String, id:Int, key:Key)
	{
		//
		if (actions.exists(action))
		{
			actions.get(action)[id] = key;
			// trace(actions.get(action)[id]);
		}
	}
}
