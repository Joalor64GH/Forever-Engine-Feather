package gameObjects.userInterface;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import playerData.Timings;
import song.Conductor;
import states.PlayState;

using StringTools;

class ClassHUD extends FlxSpriteGroup
{
	// set up variables and stuff here
	public var scoreBar:FlxText;

	// fnf mods
	public var scoreDisplay:String = 'beep bop bo skdkdkdbebedeoop brrapadop';

	public var cornerMark:FlxText; // engine mark at the upper right corner
	public var centerMark:FlxText; // song display name and difficulty at the center

	public var autoplayMark:FlxText;
	public var autoplaySine:Float = 0;

	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public var timingsMap:Map<String, FlxText> = [];

	public var infoDisplay:String = CoolUtil.dashToSpace(PlayState.SONG.song);
	public var diffDisplay:String = CoolUtil.difficultyString;
	public var engineDisplay:String = "F.E. FEATHER v" + Main.featherVersion;

	// eep
	public function new()
	{
		// call the initializations and stuffs
		super();

		// le healthbar setup
		var barY = FlxG.height * 0.875;
		if (Init.trueSettings.get('Downscroll'))
			barY = 64;

		healthBarBG = new FlxSprite(0,
			barY).loadGraphic(Paths.image(ForeverTools.returnSkinAsset('healthBar', PlayState.assetModifier, PlayState.changeableSkin, 'UI')));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8));
		healthBar.scrollFactor.set();
		reloadHealthBar();
		add(healthBar);

		iconP1 = new HealthIcon(PlayState.boyfriend.characterData.icon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(PlayState.opponent.characterData.icon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		scoreBar = new FlxText(FlxG.width / 2, Math.floor(healthBarBG.y + 40), 0, scoreDisplay);
		scoreBar.setFormat(Paths.font('vcr'), 18, FlxColor.WHITE);
		scoreBar.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		scoreBar.visible = !PlayState.bfStrums.autoplay;
		updateScoreText();
		add(scoreBar);

		cornerMark = new FlxText(0, 0, 0, engineDisplay);
		cornerMark.setFormat(Paths.font('vcr'), 18, FlxColor.WHITE);
		cornerMark.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		cornerMark.setPosition(FlxG.width - (cornerMark.width + 5), 5);
		add(cornerMark);

		centerMark = new FlxText(0, (Init.trueSettings.get('Downscroll') ? FlxG.height - 40 : 10), 0, '- ${infoDisplay + " [" + diffDisplay}] -');
		centerMark.setFormat(Paths.font('vcr'), 24, FlxColor.WHITE);
		centerMark.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		centerMark.screenCenter(X);
		add(centerMark);

		// counter
		if (Init.trueSettings.get('Counter') != 'None')
		{
			var judgementNameArray:Array<String> = [];
			for (i in Timings.judgementsMap.keys())
				judgementNameArray.insert(Timings.judgementsMap.get(i)[0], i);
			judgementNameArray.sort(sortByShit);
			for (i in 0...judgementNameArray.length)
			{
				var textAsset:FlxText = new FlxText(5
					+ (!left ? (FlxG.width - 10) : 0),
					(FlxG.height / 2)
					- (counterTextSize * (judgementNameArray.length / 2))
					+ (i * counterTextSize), 0, '', counterTextSize);
				if (!left)
					textAsset.x -= textAsset.text.length * counterTextSize;
				textAsset.setFormat(Paths.font("vcr"), counterTextSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				textAsset.scrollFactor.set();
				timingsMap.set(judgementNameArray[i], textAsset);
				add(textAsset);
			}
		}

		autoplayMark = new FlxText(-5, (Init.trueSettings.get('Downscroll') ? centerMark.y - 60 : centerMark.y + 60), FlxG.width - 800, '[AUTOPLAY]\n', 32);
		autoplayMark.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE, CENTER);
		autoplayMark.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.3);
		autoplayMark.screenCenter(X);
		autoplayMark.visible = PlayState.bfStrums.autoplay;

		// repositioning for it to not be covered by the receptors
		if (Init.trueSettings.get('Centered Notefield'))
		{
			if (Init.trueSettings.get('Downscroll'))
				autoplayMark.y = autoplayMark.y - 125;
			else
				autoplayMark.y = autoplayMark.y + 125;
		}

		add(autoplayMark);

		updateScoreText();
	}

	var counterTextSize:Int = 18;

	function sortByShit(Obj1:String, Obj2:String):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Timings.judgementsMap.get(Obj1)[0], Timings.judgementsMap.get(Obj2)[0]);

	var left = (Init.trueSettings.get('Counter') == 'Left');

	override public function update(elapsed:Float)
	{
		// pain, this is like the 7th attempt
		healthBar.percent = (PlayState.health * 50);

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		iconP1.updateAnim(healthBar.percent);
		iconP2.updateAnim(100 - healthBar.percent);

		if (autoplayMark.visible)
		{
			autoplaySine += 180 * (elapsed / 4);
			autoplayMark.alpha = 1 - Math.sin((Math.PI * autoplaySine) / 80);
		}
	}

	public static var divider:String = " • ";

	private var markupDivider:String = '';

	public function updateScoreText()
	{
		if (Timings.notesHit > 0 && Init.trueSettings.get('Accuracy Hightlight'))
			markupDivider = '°';

		scoreDisplay = 'Score: ' + Timings.score;

		var isRated = (Timings.comboDisplay != null && Timings.comboDisplay != '' && Timings.notesHit > 0);
		var rank:String = (Timings.returnScoreRating() != null
			&& Timings.returnScoreRating() != ''
			&& Timings.notesHit > 0 ? '[${Timings.returnScoreRating()}]' : '');

		// testing purposes
		var displayAccuracy:Bool = Init.trueSettings.get('Display Accuracy');
		if (displayAccuracy)
		{
			scoreDisplay += divider + markupDivider + 'Accuracy: ${Timings.returnAccuracy()}' + markupDivider;
			scoreDisplay += isRated ? ' $markupDivider[' + Timings.comboDisplay + divider + Timings.returnScoreRating() + ']$markupDivider' : '$markupDivider'
				+ rank
				+ '$markupDivider';
			scoreDisplay += divider + 'Combo Breaks: ${Timings.misses}';
		}
		scoreDisplay += '\n';

		scoreBar.text = scoreDisplay;

		if (Init.trueSettings.get('Accuracy Hightlight'))
		{
			if (Timings.notesHit > 0)
				scoreBar.applyMarkup(scoreBar.text, [new FlxTextFormatMarkerPair(scoreFlashFormat, markupDivider)]);
		}

		scoreBar.screenCenter(X);

		// update counter
		if (Init.trueSettings.get('Counter') != 'None')
		{
			for (i in timingsMap.keys())
			{
				timingsMap[i].text = '${(i.charAt(0).toUpperCase() + i.substring(1, i.length))}: ${Timings.gottenJudgements.get(i)}';
				timingsMap[i].x = (5 + (!left ? (FlxG.width - 10) : 0) - (!left ? (6 * counterTextSize) : 0));
			}
		}

		// update playstate
		PlayState.detailsSub = scoreBar.text;
		PlayState.updateRPC(false);
	}

	public function reloadHealthBar()
	{
		var colorOpponent = PlayState.opponent.characterData.healthColor;
		var colorPlayer = PlayState.boyfriend.characterData.healthColor;

		if (!Init.trueSettings.get('Colored Health Bar'))
			healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33 - 0xFFFF0000);
		else
			healthBar.createFilledBar(FlxColor.fromRGB(Std.int(colorOpponent[0]), Std.int(colorOpponent[1]), Std.int(colorOpponent[2])),
				FlxColor.fromRGB(Std.int(colorPlayer[0]), Std.int(colorPlayer[1]), Std.int(colorPlayer[2])));
	}

	public function beatHit(curBeat:Int)
	{
		if (!Init.trueSettings.get('Reduced Movements'))
		{
			iconP1.bop(60 / Conductor.bpm);
			iconP2.bop(60 / Conductor.bpm);
		}
	}

	var scoreFlashFormat:FlxTextFormat;

	public function colorHighlight(judge:String, perfectSick:Bool)
	{
		// highlights the accuracy mark on the score bar;
		var ratingMap:Map<String, FlxColor> = [
			"S+" => FlxColor.fromString('#F8D482'),
			"S" => FlxColor.CYAN,
			"A" => FlxColor.LIME,
			"B" => FlxColor.GREEN,
			"C" => FlxColor.BROWN,
			"D" => FlxColor.PINK,
			"E" => FlxColor.ORANGE,
			"F" => FlxColor.RED,
		];

		var color:FlxColor = FlxColor.WHITE;
		for (scoreRating => ratingColor in ratingMap)
		{
			if (scoreRating == Timings.returnScoreRating())
				color = ratingColor;
		}

		scoreFlashFormat = new FlxTextFormat(color, true);
	}

	override function add(Object:FlxSprite):FlxSprite
	{
		if (Init.trueSettings.get('Disable Antialiasing'))
		{
			if (Std.isOfType(Object, FlxText))
				cast(Object, FlxText).antialiasing = false;
			if (Std.isOfType(Object, FlxSprite))
				cast(Object, FlxSprite).antialiasing = false;
		}
		return super.add(Object);
	}
}
