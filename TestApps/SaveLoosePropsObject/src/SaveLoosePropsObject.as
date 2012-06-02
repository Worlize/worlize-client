package
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.AuthorEvent;
	import com.worlize.api.event.ChatEvent;
	import com.worlize.api.event.LoosePropEvent;
	import com.worlize.api.model.LooseProp;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	
	import mx.core.BitmapAsset;
	
	public class SaveLoosePropsObject extends Sprite
	{
		[Embed(source="blockdevice.png")]
		public var iconImage:Class;
		public var iconBitmap:Bitmap;
		
		public static var api:WorlizeAPI;
		
		public function SaveLoosePropsObject() {
			WorlizeAPI.options.defaultWidth = 64;
			WorlizeAPI.options.defaultHeight = 64;
			WorlizeAPI.options.name = "Room Prop";
			
			api = WorlizeAPI.init(this);
			
			api.thisRoom.addEventListener(ChatEvent.OUTGOING_CHAT, handleOutgoingChat);
			api.addEventListener(AuthorEvent.AUTHOR_MODE_ENABLED, updateIconVisibility);
			api.addEventListener(AuthorEvent.AUTHOR_MODE_DISABLED, updateIconVisibility);
			
//			api.thisRoom.addEventListener(LoosePropEvent.PROP_ADDED, handlePropAdded);
//			api.thisRoom.addEventListener(LoosePropEvent.PROP_MOVED, handlePropMoved);
//			api.thisRoom.addEventListener(LoosePropEvent.PROP_REMOVED, handlePropRemoved);
//			api.thisRoom.addEventListener(LoosePropEvent.PROP_LAYER_CHANGED, handlePropLayerChanged);
//			api.thisRoom.addEventListener(LoosePropEvent.PROPS_CLEARED, handlePropsCleared);

			// Restore previously saved props
			if (api.syncedDataStore['initialized'] !== true && api.thisRoom.looseProps.length === 0) {
				restoreProps();
			}
						
			// Add the icon for author mode
			iconBitmap = new Bitmap(BitmapAsset(new iconImage()).bitmapData);
			iconBitmap.x = 0;
			iconBitmap.y = 0;
			addChild(iconBitmap);
			
			updateIconVisibility();
		}
		
		private function updateIconVisibility(event:AuthorEvent=null):void {
			iconBitmap.visible = api.authorMode;
		}
		
		private function restoreProps():void {
			api.thisRoom.clearLooseProps();
			for each (var obj:Array in api.config.data.savedProps) {
				api.thisRoom.addLooseProp(obj[0], obj[1], obj[2]);
			}
			api.syncedDataStore.set("initialized", true);
		}
		
		public function saveLooseProps():void {
			if (!api.thisUser.canAuthor) { return; }
			var savedProps:Array = [];
			for each (var looseProp:LooseProp in api.thisRoom.looseProps) {
				api.log("Saving prop " + looseProp.prop.guid + " at " +
					    looseProp.x + "," + looseProp.y);
				savedProps.push([
					looseProp.prop.guid,
					looseProp.x,
					looseProp.y
				]);
			}
			api.config.data.savedProps = savedProps;
			api.config.save();
		}
		
		private function handleOutgoingChat(event:ChatEvent):void {
			var looseProp:LooseProp;
			if (event.originalText === 'saveprops') {
				event.preventDefault();
				saveLooseProps();
			}
			else if (event.originalText === 'resetprops') {
				event.preventDefault();
				restoreProps();
			}
//			else if (event.originalText === 'scramble') {
//				event.preventDefault();
//				for each (looseProp in api.thisRoom.looseProps) {
//					looseProp.moveTo(
//						Math.ceil(Math.random()*950),
//						Math.ceil(Math.random()*570)
//					);
//				}
//			}
//			else if (event.originalText === 'remove') {
//				event.preventDefault();
//				var looseProps:Vector.<LooseProp> = api.thisRoom.looseProps;
//				
//				looseProp = looseProps[Math.ceil(Math.random()*looseProps.length)];
//				looseProp.remove();
//			}
		}
		
		// **************************
		// Begin test functions
		
		
//		private function handlePropAdded(event:LoosePropEvent):void {
//			api.log("Prop " + event.looseProp.id + " - " + event.looseProp.prop.guid + " added at " + event.looseProp.x + "," + event.looseProp.y);
//		}
//		
//		private function handlePropRemoved(event:LoosePropEvent):void {
//			api.log("Prop " + event.looseProp.id + " - " + event.looseProp.prop.guid + " removed.");
//		}
//		
//		private function handlePropMoved(event:LoosePropEvent):void {
//			api.log("Prop " + event.looseProp.id + " moved to " + event.looseProp.x + "," + event.looseProp.y);
//		}
//		
//		private function handlePropsCleared(event:LoosePropEvent):void {
//			api.log("Props cleared.");
//		}
//		
//		private function handlePropLayerChanged(event:LoosePropEvent):void {
//			api.log("Prop " + event.looseProp.id + " layer changed from " + event.oldIndex + " to " + event.newIndex + ".  Delta: " + event.delta);
//			var order:Array = [];
//			for (var i:int = 0; i < api.thisRoom.looseProps.length; i++) {
//				order.push(api.thisRoom.looseProps[i].id);
//			}
//			api.log("New prop order: " + order.join(', '));
//		}
	}
}