package
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.RoomEvent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import mx.core.BitmapAsset;
	import mx.core.SoundAsset;
	
	public class RoomLock extends Sprite
	{
		[Embed(source="locked.gif")]
		public var lockedImage:Class;
		public var lockedBitmapData:BitmapData;
		
		[Embed(source="unlocked.gif")]
		public var unlockedImage:Class;
		public var unlockedBitmapData:BitmapData;
		
		[Embed(source="DoorClose.mp3")]
		public var doorCloseAsset:Class;
		public var doorCloseSound:SoundAsset;
		
		[Embed(source="DoorOpen.mp3")]
		public var doorOpenAsset:Class;
		public var doorOpenSound:SoundAsset;
		
		public var bitmap:Bitmap;
		
		public var container:Sprite;
		
		public var api:WorlizeAPI;
		
		public function RoomLock() {
			// Initialize Worlize API
			WorlizeAPI.options.defaultWidth = 32;
			WorlizeAPI.options.defaultHeight = 32;
			api = WorlizeAPI.init(this);
			
			// Prepare image/sound assets
			initAssets();
			
			// Add a sprite to capture mouse events
			container = new Sprite();
			addChild(container);
			bitmap = new Bitmap();
			container.addChild(bitmap);
			
			// Make sure to display the correct icon based on the room's
			// locked/unlocked status when we are done being loaded.
			if (api.thisRoom.locked) {
				showLocked();
			}
			else {
				showUnlocked();
			}
			
			// Update the display and play the correct sound when the room
			// is locked or unlocked.
			api.thisRoom.addEventListener(RoomEvent.LOCKED, handleRoomLocked);
			api.thisRoom.addEventListener(RoomEvent.UNLOCKED, handleRoomUnlocked);
			
			// Toggle room locked/unlocked on click.
			addEventListener(MouseEvent.CLICK, handleClick);
			
			// Rollover and rollout events to change the mouse cursor to a hand
			addEventListener(MouseEvent.ROLL_OVER, handleRollOver);
			addEventListener(MouseEvent.ROLL_OUT, handleRollOut);
		}
		
		private function initAssets():void {
			lockedBitmapData = BitmapAsset(new lockedImage()).bitmapData;
			unlockedBitmapData = BitmapAsset(new unlockedImage()).bitmapData;
			doorOpenSound = SoundAsset(new doorOpenAsset());
			doorCloseSound = SoundAsset(new doorCloseAsset());
		}
		
		private function handleRoomLocked(event:RoomEvent):void {
			api.log("Room locked by " + event.user.name);
			showLocked();
			doorCloseSound.play();
		}
		
		private function handleRoomUnlocked(event:RoomEvent):void {
			api.log("Room unlocked by " + event.user.name);
			showUnlocked();
			doorOpenSound.play();
		}
		
		private function handleClick(event:MouseEvent):void {
			if (api.thisRoom.locked) {
				api.thisRoom.unlock();
			}
			else {
				api.thisRoom.lock();
			}
		}
		
		private function handleRollOver(event:MouseEvent):void {
			Mouse.cursor = MouseCursor.BUTTON;
		}
		
		private function handleRollOut(event:MouseEvent):void {
			Mouse.cursor = MouseCursor.ARROW;
		}
		
		private function showLocked():void {
			bitmap.bitmapData = lockedBitmapData;
		}
		
		private function showUnlocked():void {
			bitmap.bitmapData = unlockedBitmapData;
		}
	}
}