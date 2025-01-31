package
{
	import com.worlize.api.WorlizeAPI;
	
	import flash.display.Sprite;
	
	public class CircleSprite extends Sprite
	{
		private var _radius:Number = 100;
		private var _color:uint = 0xFF0000;
		
		public function CircleSprite()
		{
			super();
		}
		
		public function get color():uint {
			return _color;
		}
		
		public function drawCircle(radius:Number, color:uint = 0x000000):void {
			_color = color;
			_radius = radius;
			WorlizeAPI.getInstance().thisObject.setSize(radius*2 + 6, radius*2 + 6);
			x = y = radius + 3;
			graphics.clear();
			graphics.beginFill(_color, 1.0);
			graphics.lineStyle(3, 0x000000);
			graphics.drawCircle(0, 0, radius);
			graphics.endFill();
		}
		
		public function setColor(color:uint):void {
			drawCircle(_radius, color);
		}
	}
}