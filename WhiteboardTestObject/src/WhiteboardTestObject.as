package
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.MessageEvent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class WhiteboardTestObject extends Sprite
	{
		
		public var api:WorlizeAPI;
		public var canvas:WhiteboardCanvas;
		
		public var greenSwatch:ColorSwatch;
		public var redSwatch:ColorSwatch;
		public var blueSwatch:ColorSwatch;
		public var blackSwatch:ColorSwatch;
		public var currentSwatch:ColorSwatch;
		
		public function WhiteboardTestObject()
		{
			WorlizeAPI.options.resizableByUser = false;
			WorlizeAPI.options.name = "Whiteboard Test App";
			
			api = WorlizeAPI.init(this);
			
			api.thisObject.addEventListener(MessageEvent.MESSAGE_RECEIVED, handleMessageReceived);
			
			canvas = new WhiteboardCanvas();
			canvas.x = canvas.y = 0;
			addChild(canvas);
			
			
			var colors:Array = [
				0xAA0000,
				0x00AA00,
				0x0000FF,
				0xFF8800,
				0xDDDD00,
				0xAA00AA,
				0x000000
			];
			
			var currentX:int = 1;
			for each (var color:uint in colors) {
				var swatch:ColorSwatch = new ColorSwatch(color);
				addChild(swatch);
				swatch.x = currentX;
				swatch.y = 1;
				currentX += 25;
			}
			
			currentSwatch = new ColorSwatch(0x000000);
			addChild(currentSwatch);
			currentSwatch.x = api.thisObject.width-26;
			currentSwatch.y = 1;
			
			addEventListener(MouseEvent.CLICK, handleClick);
		}
		
		private function handleMessageReceived(event:MessageEvent):void {
			if (event.message && event.message.type === 'setColor') {
				if (event.message.color) {
					canvas.color = event.message.color;
					currentSwatch.updateColor(event.message.color);
				}
			}
		}
		
		private function handleClick(event:MouseEvent):void {
			if (event.target is ColorSwatch) {
				var color:uint = (event.target as ColorSwatch).color;
				canvas.color = color;
				currentSwatch.updateColor(color);
			}
		}
	}
}