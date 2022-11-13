package states.menus;

import flixel.FlxG;
import gameObjects.gameFonts.Alphabet;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import states.data.BaseOptions;

class NewOptions extends BaseOptions
{
	override public function create()
	{
		super.create();

		var bg = new FlxSprite(-85).loadGraphic(Paths.image('menus/base/menuDesat'));
		bg.scrollFactor.set(0, 0.18);
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = 0xD8B168;
		bg.antialiasing = true;
		add(bg);

		generateAlphabet(categoriesMap.get("main"));
		updateSelections();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// typical controls array tomfoolery
		var up = Controls.getPressEvent("ui_up", "pressed");
		var down = Controls.getPressEvent("ui_down", "pressed");
		var up_p = Controls.getPressEvent("ui_up");
		var down_p = Controls.getPressEvent("ui_down");
		var controlArray:Array<Bool> = [up, down, up_p, down_p];

		if ((controlArray.contains(true)) && (!lockedMovement))
		{
			for (i in 0...controlArray.length)
			{
				// here we check which keys are pressed
				if (controlArray[i] == true)
				{
					// if single press
					if (i > 1)
					{
						// up == 2 - down == 3
						if (i == 2)
							updateSelections(-1);
						else if (i == 3)
							updateSelections(1);

						FlxG.sound.play(Paths.sound('base/menus/scrollMenu'));
					}
				}
				//
			}
		}

		if (curCategory != 'main')
		{
			switch (Init.gameSettings.get(alphabetGroup.members[curSelected].text)[1])
			{
				case Init.SettingTypes.Checkmark:
					// update checkmark
					updateCheckmarks();
				case Init.SettingTypes.Selector:
					// selector
					updateSelectors();
				default:
					// dont do ANYTHING
			}
		}
		else
		{
			if (Controls.getPressEvent("accept"))
			{
				if (alphabetGroup.members[curSelected].text.toLowerCase() == "controls")
				{
					//
					openSubState(new states.substates.OptionsSubstate());
				}
				else
				{
					switchCategory(alphabetGroup.members[curSelected].text.toLowerCase());
					updateSelections();
				}
			}
		}

		if (Controls.getPressEvent("back"))
		{
			if (curCategory != 'main')
			{
				switchCategory('main');
				updateSelections();
			}
			else
			{
				if (states.substates.PauseSubstate.toOptions)
					Main.switchState(this, new PlayState());
				else
					Main.switchState(this, new MainMenu());
			}
		}
	}

	public function updateSelections(newSelection:Int = 0)
	{
		curSelected += newSelection;

		if (curSelected < 0)
			curSelected = activeGroup.length - 1;
		else if (curSelected >= activeGroup.length)
			curSelected = 0;

		var bullShit:Int = 0;
		for (item in alphabetGroup)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}
}
