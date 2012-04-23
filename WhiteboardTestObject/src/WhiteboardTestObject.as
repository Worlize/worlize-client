package
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.MessageEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import mx.core.BitmapAsset;
	
	public class WhiteboardTestObject extends Sprite
	{
		
		public var api:WorlizeAPI;
		public var canvas:WhiteboardCanvas;
		
		public var greenSwatch:ColorSwatch;
		public var redSwatch:ColorSwatch;
		public var blueSwatch:ColorSwatch;
		public var blackSwatch:ColorSwatch;
		public var currentSwatch:ColorSwatch;
		
		[Embed(source="eraser.png")]
		public var eraserImage:Class;
		public var eraserBitmapData:BitmapData;
		
		public function WhiteboardTestObject()
		{
			WorlizeAPI.options.defaultWidth = 405;
			WorlizeAPI.options.defaultHeight = 335;
			WorlizeAPI.options.resizableByUser = false;
			WorlizeAPI.options.name = "Whiteboard Test App";
			
			initAssets();
			
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
				0x000000,
				0xFFFFFF
			];
			
			var currentX:int = 1;
			for each (var color:uint in colors) {
				var swatch:ColorSwatch = new ColorSwatch(color);
//				addChild(swatch);
				swatch.x = currentX;
				swatch.y = 1;
				currentX += 25;
			}
			
			currentSwatch = new ColorSwatch(0x000000);
//			addChild(currentSwatch);
			currentSwatch.x = api.thisObject.width-26;
			currentSwatch.y = 1;
			
			addEventListener(MouseEvent.CLICK, handleClick);
			
			var eraserSprite:Sprite = new Sprite();
			var eraserBitmap:Bitmap = new Bitmap(eraserBitmapData);
			eraserBitmap.x = api.thisObject.width / 2 - eraserBitmap.width / 2;
			eraserBitmap.y = api.thisObject.height - eraserBitmap.height;
			eraserSprite.addChild(eraserBitmap);
			addChild(eraserSprite);
			eraserSprite.addEventListener(MouseEvent.CLICK, handleEraserClick);
		}
		
		private function initAssets():void {
			eraserBitmapData = BitmapAsset(new eraserImage()).bitmapData;
		}
		
		private function handleEraserClick(event:MouseEvent):void {
			canvas.eraseCanvas();
		}
		
		private function handleMessageReceived(event:MessageEvent):void {
			if (event.message && event.message.type === 'setColor') {
				if ('color' in event.message) {
					canvas.color = event.message.color;
					currentSwatch.updateColor(event.message.color);
				}
			}
		}
		
		private function handleClick(event:MouseEvent):void {
			if (event.target is ColorSwatch) {
				var color:uint = (event.target as ColorSwatch).color;
				api.thisRoom.broadcastMessageLocal({ type: 'setColor', color: color });
			}
		}
	}
}