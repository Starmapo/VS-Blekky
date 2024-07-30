package objects;

import flixel.math.FlxRect;

class Bar extends FlxSpriteGroup
{
	public var leftBar:FlxSprite;
	public var rightBar:FlxSprite;
	public var bg:FlxSprite;
	public var outline:FlxSprite;
	public var valueFunction:Void->Float = null;
	public var percent(default, set):Float = 0;
	public var bounds:Dynamic = {min: 0, max: 1};
	public var leftToRight(default, set):Bool = true;
	public var barCenter(default, null):Float = 0;

	// you might need to change this if you want to use a custom bar
	public var barWidth(default, set):Int = 1;
	public var barHeight(default, set):Int = 1;
	public var barOffset:FlxPoint = new FlxPoint(3, 3);
	public var bgOffset:FlxPoint = new FlxPoint(0, 0);

	var desktop:Bool;

	public function new(x:Float, y:Float, bgImage:String = '', barImage:String = '', outlineImage:String = 'healthBar', valueFunction:Void->Float = null, boundX:Float = 0, boundY:Float = 1, desktop:Bool = false)
	{
		super(x, y);
		
		this.valueFunction = valueFunction;
		setBounds(boundX, boundY);
		this.desktop = desktop;

		if (bgImage.length > 0)
		{
			bg = new FlxSprite().loadGraphic(Paths.image(bgImage));
			bg.antialiasing = ClientPrefs.data.antialiasing;
		}
		
		outline = new FlxSprite().loadGraphic(Paths.image(outlineImage));
		outline.antialiasing = ClientPrefs.data.antialiasing;
		barWidth = Std.int(outline.width - 6);
		barHeight = Std.int(outline.height - 6);

		if (barImage.length > 0)
			leftBar = new FlxSprite().loadGraphic(Paths.image(barImage));
		else
			leftBar = new FlxSprite().makeGraphic(Std.int(outline.width), Std.int(outline.height), FlxColor.WHITE);
		//leftBar.color = FlxColor.WHITE;
		leftBar.antialiasing = antialiasing = ClientPrefs.data.antialiasing;

		if (barImage.length > 0)
			rightBar = new FlxSprite().loadGraphic(Paths.image(barImage));
		else
			rightBar = new FlxSprite().makeGraphic(Std.int(outline.width), Std.int(outline.height), FlxColor.WHITE);
		rightBar.color = FlxColor.BLACK;
		rightBar.antialiasing = ClientPrefs.data.antialiasing;

		if (bg != null)
			add(bg);
		add(leftBar);
		add(rightBar);
		add(outline);
		regenerateClips();
	}

	public var enabled:Bool = true;
	override function update(elapsed:Float) {
		if(!enabled)
		{
			super.update(elapsed);
			return;
		}

		if(valueFunction != null)
		{
			var value:Null<Float> = FlxMath.remapToRange(FlxMath.bound(valueFunction(), bounds.min, bounds.max), bounds.min, bounds.max, 0, 100);
			percent = (value != null ? value : 0);
		}
		else percent = 0;
		super.update(elapsed);
	}
	
	public function setBounds(min:Float, max:Float)
	{
		bounds.min = min;
		bounds.max = max;
	}

	public function setColors(left:FlxColor = null, right:FlxColor = null)
	{
		if (left != null)
			leftBar.color = left;
		if (right != null)
			rightBar.color = right;
	}

	public function updateBar()
	{
		if(leftBar == null || rightBar == null) return;

		if (bg != null)
			bg.setPosition(outline.x + bgOffset.x, outline.y + bgOffset.y);
		leftBar.setPosition(outline.x, outline.y);
		rightBar.setPosition(outline.x, outline.y);

		var leftSize:Float = 0;
		var size = desktop ? barHeight : barWidth;
		if(leftToRight) leftSize = FlxMath.lerp(0, size, percent / 100);
		else leftSize = FlxMath.lerp(0, size, 1 - percent / 100);

		leftBar.clipRect.width = desktop ? barWidth : leftSize;
		leftBar.clipRect.height = desktop ? leftSize : barHeight;
		leftBar.clipRect.x = barOffset.x;
		leftBar.clipRect.y = barOffset.y;

		rightBar.clipRect.width = barWidth - (desktop ? 0 : leftSize);
		rightBar.clipRect.height = barHeight - (desktop ? leftSize : 0);
		rightBar.clipRect.x = barOffset.x + (desktop ? 0 : leftSize);
		rightBar.clipRect.y = barOffset.y + (desktop ? leftSize : 0);

		if (desktop)
			barCenter = leftBar.y + leftSize + barOffset.y;
		else
			barCenter = leftBar.x + leftSize + barOffset.x;

		leftBar.clipRect = leftBar.clipRect;
		rightBar.clipRect = rightBar.clipRect;
	}

	public function regenerateClips()
	{
		if(leftBar != null)
		{
			leftBar.setGraphicSize(Std.int(outline.width), Std.int(outline.height));
			leftBar.updateHitbox();
			leftBar.clipRect = new FlxRect(0, 0, Std.int(outline.width), Std.int(outline.height));
		}
		if(rightBar != null)
		{
			rightBar.setGraphicSize(Std.int(outline.width), Std.int(outline.height));
			rightBar.updateHitbox();
			rightBar.clipRect = new FlxRect(0, 0, Std.int(outline.width), Std.int(outline.height));
		}
		updateBar();
	}

	private function set_percent(value:Float)
	{
		var doUpdate:Bool = false;
		if(value != percent) doUpdate = true;
		percent = value;

		if(doUpdate) updateBar();
		return value;
	}

	private function set_leftToRight(value:Bool)
	{
		leftToRight = value;
		updateBar();
		return value;
	}

	private function set_barWidth(value:Int)
	{
		barWidth = value;
		regenerateClips();
		return value;
	}

	private function set_barHeight(value:Int)
	{
		barHeight = value;
		regenerateClips();
		return value;
	}
}