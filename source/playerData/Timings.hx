package playerData;

import states.PlayState;

/**
	Here's a class that calculates timings and judgements for the songs and such
**/
class Timings
{
	//
	public static var score:Int = 0;
	public static var combo:Int = 0;
	public static var misses:Int = 0;

	public static var accuracy:Float;
	public static var trueAccuracy:Float;

	// from left to right
	// max milliseconds, score from it and percentage
	public static var judgementsMap:Map<String, Array<Dynamic>> = [
		"sick" => [0, 45, 350, 100, 'SFC'],
		"good" => [1, 90, 150, 75, 'GFC'],
		"bad" => [2, 135, 0, 25, 'FC'],
		"shit" => [3, 157.5, -50, -150],
		"miss" => [4, 180, -100, -175],
	];

	public static var msThreshold:Float = 0;

	// set the score judgements for later use
	public static var scoreRating:Map<String, Int> = [
		"S+" => 100,
		"S" => 95,
		"A" => 90,
		"B" => 85,
		"C" => 80,
		"D" => 75,
		"E" => 70,
		"F" => 65,
	];

	public static var notesHit:Int = 0;

	public static var ratingFinal:String = "F";
	public static var comboDisplay:String = "";

	public static var gottenJudgements:Map<String, Int> = [];
	public static var smallestRating:String;

	public static var perfectCombo:Bool = false;

	public static function resetAccuracy()
	{
		// reset the accuracy to 0%
		accuracy = 0.001;
		trueAccuracy = 0;

		// reset ms threshold
		var biggestThreshold:Float = 0;
		for (i in judgementsMap.keys())
			if (judgementsMap.get(i)[1] > biggestThreshold)
				biggestThreshold = judgementsMap.get(i)[1];
		msThreshold = biggestThreshold;

		// set the gotten judgement amounts
		for (judgement in judgementsMap.keys())
			gottenJudgements.set(judgement, 0);
		smallestRating = 'sick';

		notesHit = 0;
		perfectCombo = true;

		// reset score;
		score = 0;
		combo = 0;
		misses = 0;

		ratingFinal = "N/A";
		comboDisplay = "";
		// updateRanking();
	}

	public static function updateAccuracy(judgement:Int, ?isSustain:Bool = false, ?segmentCount:Int = 1)
	{
		if (!isSustain)
		{
			notesHit++;
			accuracy += (Math.max(0, judgement));
		}
		else
			accuracy += (Math.max(0, judgement) / segmentCount);
		trueAccuracy = (accuracy / notesHit);

		// avoid over 100% accuracy bug;
		if (trueAccuracy >= 100)
			trueAccuracy = 100;

		// avoid increasing memory for updating the score bar text;
		if (!isSustain)
			updateRanking();
	}

	public static function updateRanking()
	{
		var biggest:Int = 0;
		for (score in scoreRating.keys())
		{
			if ((scoreRating.get(score) <= trueAccuracy) && (scoreRating.get(score) >= biggest))
			{
				biggest = scoreRating.get(score);
				ratingFinal = score;
			}

			// update combo display
			comboDisplay = "";
			if (judgementsMap.get(smallestRating)[4] != null)
				comboDisplay = judgementsMap.get(smallestRating)[4];
			else if (misses < 10)
				comboDisplay = 'SDCB';
		}

		// this updates the most so uh
		PlayState.uiHUD.updateScoreText();
	}

	public static function returnAccuracy()
	{
		var accuracyFinal:String = 'N/A';
		if (notesHit > 0)
			accuracyFinal = '${Math.floor(trueAccuracy * 100) / 100}%';
		return accuracyFinal;
	}

	public static function returnScoreRating()
		return ratingFinal;
}
