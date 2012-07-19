package
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.AuthorEvent;
	import com.worlize.api.event.ChatEvent;
	import com.worlize.api.event.MessageEvent;
	import com.worlize.api.event.RoomObjectEvent;
	import com.worlize.api.event.StateHistoryEvent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.setTimeout;
	
	import mx.core.BitmapAsset;
	
	public class ZapApp extends Sprite
	{
		[Embed(source="icon-small.jpg")]
		public var iconImage:Class;
		public var iconBitmap:Bitmap;
		
		[Embed(source="no.mp3")]
		public var noSoundEffect:Class;
		public var sound:Sound = new noSoundEffect() as Sound;
		public var soundChannel:SoundChannel;
		
		public var api:WorlizeAPI;
		
		public var posX:Number;
		public var posY:Number;
		
		public function ZapApp()
		{
			WorlizeAPI.options.defaultWidth = 64;
			WorlizeAPI.options.defaultHeight = 64;
			
			api = WorlizeAPI.init(this);
			
			posX = api.thisObject.x;
			posY = api.thisObject.y;
			
			api.thisRoom.addEventListener(ChatEvent.OUTGOING_CHAT, handleOutgoingChat);
			
			api.addEventListener(AuthorEvent.AUTHOR_MODE_ENABLED, handleAuthorModeChanged);
			api.addEventListener(AuthorEvent.AUTHOR_MODE_DISABLED, handleAuthorModeChanged);
			
			api.thisObject.addEventListener(RoomObjectEvent.OBJECT_MOVED, handleObjectMoved);
			
			api.thisObject.addEventListener(MessageEvent.MESSAGE_RECEIVED, handleMessageReceived);
			
			// Add the icon for author mode
			iconBitmap = new Bitmap(BitmapAsset(new iconImage()).bitmapData);
			iconBitmap.x = 0;
			iconBitmap.y = 0;
			addChild(iconBitmap);
			
			handleAuthorModeChanged();
		}
		
		private function updateIconVisibility(event:AuthorEvent=null):void {
			iconBitmap.visible = api.authorMode;
		}
		
		private function handleOutgoingChat(event:ChatEvent):void {
			if (event.originalText.toLocaleLowerCase() === 'zap') {
				event.preventDefault();
				
				var startX:int = api.thisUser.x;
				var startY:int = api.thisUser.y;
				var endX:int = api.thisRoom.mouseX;
				var endY:int = api.thisRoom.mouseY;

				api.thisUser.say("@" + endX + "," + endY + " !Zap!");
				api.thisObject.sendMessage([startX, startY, endX, endY, api.thisUser.guid]);
			}
		}
		
		private function handleMessageReceived(event:MessageEvent):void {
			if (event.fromObject !== api.thisObject) { return; }
			var sprite:Sprite = new Sprite();
			sprite.mouseEnabled = sprite.mouseChildren = false;
			var data:Array = event.message as Array;
			sprite.graphics.lineStyle(4, 0xFF0000);
			sprite.graphics.moveTo(data[0], data[1]);
			sprite.graphics.lineTo(data[2], data[3]);
			addChild(sprite);
			
			if (soundChannel) {
				soundChannel.stop();
			}
			var soundTransform:SoundTransform = new SoundTransform(0.7);
			soundChannel = sound.play(0,0,soundTransform);
			
			setTimeout(function():void {
				removeChild(sprite);
			}, 2000);
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