package states.data;

import flixel.FlxSubState;
import gameObjects.gameFonts.Alphabet;
import dependency.Discord;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import gameObjects.userInterface.menu.Checkmark;
import gameObjects.userInterface.menu.Selector;
import states.MusicBeatState;

/**
 * The Base Options class manages Option Attachements;
 * among some useful functions for the main options menu;
 *
 * simply put, it initializes elements like Checkmarks and Selectors;
 * along with having neat little functions to go from a section to another;
 */
class BaseOptions extends MusicBeatState
{
	// category name - [category options],
	public var categoriesMap:Map<String, Array<String>> = ["main" => ["preferences", "accessibility", "visuals", "controls"],];

	public var alphabetGroup:FlxTypedGroup<Alphabet>;
	public var attachmentsGroup:FlxTypedGroup<Dynamic>;

	public var activeGroup:Array<String> = [];

	public var lockedMovement:Bool = false;

	public var curSelected:Int = 0;
	public var curCategory:String = 'main';

	override public function create()
	{
		super.create();

		// set up category contents;
		categoriesMap.set("preferences", OptionsData.preferences);
		categoriesMap.set("accessibility", OptionsData.accessibility);
		categoriesMap.set("visuals", OptionsData.visuals);

		updateDiscord();
	}

	public function updateDiscord(?forcedPresence:String)
	{
		var myPresence:String = curCategory == 'main' ? 'Navigating through Categories' : 'Changing $curCategory';

		#if DISCORD_RPC
		// changes depending on your current category;
		Discord.changePresence(forcedPresence == null ? myPresence.toUpperCase() : forcedPresence, 'Options Menu');
		#end
	}

	public function callGroups()
	{
		// destroy existing instances of groups;
		if (attachmentsGroup != null)
			remove(attachmentsGroup);

		// re-add
		attachmentsGroup = new FlxTypedGroup<Dynamic>();
		add(attachmentsGroup);
	}

	public function switchCategory(newCategory:String)
	{
		curCategory = newCategory;
		updateDiscord();

		// reload groups
		callGroups();

		generateAlphabet(categoriesMap.get(newCategory));

		// reset selection;
		curSelected = 0;
	}

	public function generateAlphabet(groupArray:Array<String>)
	{
		activeGroup = groupArray;

		if (alphabetGroup != null)
			remove(alphabetGroup);

		alphabetGroup = new FlxTypedGroup<Alphabet>();
		add(alphabetGroup);

		generateAttachements(alphabetGroup);

		for (i in 0...groupArray.length)
		{
			var thisOption:Alphabet = new Alphabet(0, 0, groupArray[i], true, false);
			thisOption.screenCenter();
			thisOption.y += (125 * (i - Math.floor(groupArray.length / 2)));
			thisOption.y += 75; // probably shouldn't do this but yeah;
			thisOption.targetY = i;
			thisOption.disableX = true;
			// hardcoded main so it doesnt have scroll
			if (curCategory != 'main')
			{
				thisOption.x += 100;
				thisOption.isMenuItem = true;
			}
			thisOption.alpha = 0.6;
			alphabetGroup.add(thisOption);

			// eh, no.
			// alphabetGroup.members[i].xTo = 200 + ((i - curSelected) * 25);

			if (attachmentsGroup != null && attachmentsGroup.members[curSelected] != null)
			{
				var thisAttachment = attachmentsGroup.members[i];
				thisAttachment.x = alphabetGroup.members[i].x - 100;
				thisAttachment.y = alphabetGroup.members[i].y - 50;
			}
		}
	}

	public function generateAttachements(alpha:FlxTypedGroup<Alphabet>)
	{
		for (option in alpha)
		{
			if (Init.gameSettings.get(option.text) != null)
			{
				switch (Init.gameSettings.get(option.text)[1])
				{
					case Init.SettingTypes.Checkmark:
						// checkmark
						var checkmark = ForeverAssets.generateCheckmark(10, option.y, 'checkboxThingie', 'base', 'default', 'UI');
						checkmark.playAnim(Std.string(Init.trueSettings.get(option.text)) + ' finished');
						attachmentsGroup.add(checkmark);
					case Init.SettingTypes.Selector:
						// selector
						var selector:Selector = new Selector(10, option.y, option.text, Init.gameSettings.get(option.text)[4]);
						attachmentsGroup.add(selector);
					default:
						// dont do ANYTHING
				}
				//
			}
		}
	}

	/*
		Checkmarks!
	 */
	public function updateCheckmarks()
	{
		if (Controls.getPressEvent("accept"))
		{
			FlxG.sound.play(Paths.sound('base/menus/scrollMenu'));

			if (attachmentsGroup != null && attachmentsGroup.members[curSelected] != null)
			{
				if (Init.trueSettings.get(alphabetGroup.members[curSelected].text) != null)
					Init.trueSettings.set(alphabetGroup.members[curSelected].text, !Init.trueSettings.get(alphabetGroup.members[curSelected].text));

				attachmentsGroup.members[curSelected].playAnim(Std.string(Init.trueSettings.get(alphabetGroup.members[curSelected].text)));
				trace('${alphabetGroup.members[curSelected].text} is: ${Init.trueSettings.get(alphabetGroup.members[curSelected].text)}');

				// save the setting
				Init.saveSettings();
			}
		}
	}

	/*
		Selectors!
	 */
	public function updateSelectors()
	{
		//
		if (attachmentsGroup != null && attachmentsGroup.members[curSelected] != null)
		{
			var selector:Selector = attachmentsGroup.members[curSelected];

			if (!Controls.getPressEvent("ui_left", "pressed"))
				selector.selectorPlay('left');
			if (!Controls.getPressEvent("ui_right", "pressed"))
				selector.selectorPlay('right');

			if (Controls.getPressEvent("ui_left"))
				updateSelector(selector, -1);
			if (Controls.getPressEvent("ui_right"))
				updateSelector(selector, 1);
		}
	}

	public function updateSelector(selector:Selector, updateBy:Int)
	{
		if (selector.isNumber)
		{
			switch (selector.name)
			{
				case 'Framerate Cap':
					setupSelector(updateBy, selector, 30, 360, 15);
				case 'Darkness Opacity':
					setupSelector(updateBy, selector, 0, 100, 5);
				case 'Arrow Opacity' | 'Hold Opacity':
					setupSelector(updateBy, selector, 0, 100, 1);
				default:
					setupSelector(updateBy, selector);
			}
		}
		else
		{
			// get the current option as a number
			var storedNumber:Int = 0;
			var newSelection:Int = storedNumber;
			if (selector.options != null)
			{
				for (curOption in 0...selector.options.length)
				{
					if (selector.options[curOption] == selector.chosenOptionString)
						storedNumber = curOption;
				}

				newSelection = storedNumber + updateBy;
				if (newSelection < 0)
					newSelection = selector.options.length - 1;
				else if (newSelection >= selector.options.length)
					newSelection = 0;
			}

			if (updateBy == -1)
				selector.selectorPlay('left', 'press');
			else
				selector.selectorPlay('right', 'press');

			FlxG.sound.play(Paths.sound('base/menus/scrollMenu'));

			selector.chosenOptionString = selector.options[newSelection];

			Init.trueSettings.set(selector.name, selector.chosenOptionString);
			Init.saveSettings();

			trace('${selector.name} is: ${selector.chosenOptionString}');
		}
	}

	public function setupSelector(updateBy:Int, selector:Selector, min:Float = 0, max:Float = 100, inc:Float = 5)
	{
		// lazily hardcoded selector generator.
		var originalValue = Init.trueSettings.get(selector.name);
		var increase = inc * updateBy;
		// min
		if (originalValue + increase < min)
			increase = 0;
		// max
		if (originalValue + increase > max)
			increase = 0;

		if (updateBy == -1)
			selector.selectorPlay('left', 'press');
		else
			selector.selectorPlay('right', 'press');

		FlxG.sound.play(Paths.sound('base/menus/scrollMenu'));

		originalValue += increase;
		selector.chosenOptionString = Std.string(originalValue);
		Init.trueSettings.set(selector.name, originalValue);
		Init.saveSettings();
	}
}
