package states.data;

typedef GroupData =
{
	var name:String; // can be anything;
	var type:String; // may be option, subgroup, or divider;
}

/**
 * Stores Option Category Contents;
 * and data associated with it;
 */
class OptionsData
{
	public static var preferences:Array<String> = [
		'Downscroll', 'Centered Notefield', 'Ghost Tapping', 'Display Accuracy', 'Skip Text', 'Auto Pause', 'Framerate Cap', 'FPS Counter', 'Memory Counter',
		'Debug Info'
	];

	public static var accessibility:Array<String> = [
		'Disable Antialiasing',
		'Disable Flashing Lights',
		'Disable Screen Shaders',
		'Opaque User Interface',
		"No Camera Note Movement",
		'Reduced Movements',
		'Colored Health Bar',
		'Stage Opacity',
		'Filter'
	];

	public static var visuals:Array<String> = [
		"Fixed Judgements", "Simply Judgements", "Judgement Recycling", "Accuracy Hightlight", "Counter", "Note Skin", "Disable Note Splashes", "Clip Style",
		"Arrow Opacity", "Hold Opacity"
	];
}
