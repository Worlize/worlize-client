package
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.AuthorEvent;
	import com.worlize.api.event.ChatEvent;
	import com.worlize.api.event.RoomObjectEvent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import mx.core.BitmapAsset;
	
	public class TrippyRoom extends Sprite
	{
		[Embed(source="icon-small.jpg")]
		public var iconImage:Class;
		public var iconBitmap:Bitmap;
		
		private var api:WorlizeAPI;
		
		public var posX:Number;
		public var posY:Number;
		
		public var enabled:Boolean = false;
		
		public function TrippyRoom()
		{
			WorlizeAPI.options.defaultWidth = 64;
			WorlizeAPI.options.defaultHeight = 64;
			WorlizeAPI.options.name = "On a Trip";
			
			api = WorlizeAPI.init(this);
			
			api.thisRoom.addEventListener(ChatEvent.OUTGOING_CHAT, handleOutgoingChat);
			
			api.addEventListener(AuthorEvent.AUTHOR_MODE_ENABLED, handleAuthorModeChanged);
			api.addEventListener(AuthorEvent.AUTHOR_MODE_DISABLED, handleAuthorModeChanged);
			
			api.thisObject.addEventListener(RoomObjectEvent.OBJECT_MOVED, handleObjectMoved);
			
			api.thisRoom.addEventListener(MouseEvent.MOUSE_MOVE, handleRoomMouseMove);
			
			// Add the icon for author mode
			iconBitmap = new Bitmap(BitmapAsset(new iconImage()).bitmapData);
			iconBitmap.x = 0;
			iconBitmap.y = 0;
			addChild(iconBitmap);
			
			handleAuthorModeChanged();
		}
		
		private function handleOutgoingChat(event:ChatEvent):void {
			var text:String = event.originalText.toLocaleLowerCase();
			if (text === 'trippy on') {
				enabled = true;
				event.preventDefault();
			}
			else if (text === 'trippy off') {
				enabled = false;
				event.preventDefault();
			}
		}
		
		private function handleRoomMouseMove(event:MouseEvent):void {
			if (!enabled) { return; }
			var x:int = 950 - event.localX;
			var y:int = 540 - event.localY;
			api.thisUser.moveTo(x, y);
		}
		
		private function updateIconVisibility(event:AuthorEvent=null):void {
			iconBitmap.visible = api.authorMode;
		}
		
		private function handleAuthorModeChanged(event:AuthorEvent=null):void {
			updateIconVisibility();
			if (api.authorMode) {
				api.thisObject.moveTo(posX, posY);
				api.thisObject.setSize(64, 64);
			}
			else {
				api.thisObject.moveTo(0,0);
				api.thisObject.setSize(950,540);
			}
		}
		
		private function handleObjectMoved(event:RoomObjectEvent):void {
			if (api.thisObject.x !== 0 && api.thisObject.y !== 0) {
				posX = api.thisObject.x;
				posY = api.thisObject.y;
			}
			if (!api.authorMode) {
				api.thisObject.moveTo(0,0);
			}
		}
	}
}