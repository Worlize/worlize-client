package
{
	import flash.display.Sprite;
	
	public class ColorSwatch extends Sprite
	{
		public var color:uint = 0;
		
		public function ColorSwatch(color:uint = 0)
		{
			super();
			updateColor(color);
		}
		
		public function updateColor(color:uint):void {
			this.color = color;
			graphics.beginFill(color);
			graphics.drawRect(0,0,25,25);
			graphics.endFill();
		}
	}
}