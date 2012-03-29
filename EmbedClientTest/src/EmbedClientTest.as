package
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.StateHistoryEvent;
	import com.worlize.api.event.AuthorEvent;
	import com.worlize.api.event.ChangeEvent;
	import com.worlize.api.event.ChatEvent;
	import com.worlize.api.event.MessageEvent;
	import com.worlize.api.event.RoomEvent;
	import com.worlize.api.event.RoomObjectEvent;
	import com.worlize.api.event.UserEvent;
	import com.worlize.api.model.Avatar;
	import com.worlize.api.model.User;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setInterval;
	
	public class EmbedClientTest extends Sprite
	{
		private var api:WorlizeAPI;
		
		public var circle:CircleSprite;
		
		public function EmbedClientTest() {
			WorlizeAPI.options.defaultWidth = 106;
			WorlizeAPI.options.defaultHeight = 106;
			WorlizeAPI.options.editModeSupported = true;
			
			WorlizeAPI.init(this);
			
			api = WorlizeAPI.getInstance();
			api.thisRoom.addEventListener(ChatEvent.INCOMING_CHAT, handleIncomingChat);
			api.thisObject.addEventListener(MessageEvent.MESSAGE_RECEIVED, handleMessageReceived);
				
			
			api.addEventListener(AuthorEvent.EDIT_MODE_ENABLED, handleEditModeEnabled);
			api.addEventListener(AuthorEvent.EDIT_MODE_DISABLED, handleEditModeDisabled);
			
			
//			api.stateHistory.addEventListener(StateHistoryEvent.ENTRY_ADDED, handleStateAdded);
			api.syncedDataStore.addEventListener(ChangeEvent.PROPERTY_CHANGED, handleSyncedPropertyChanged);
			
			circle = new CircleSprite();
			addChild(circle);
			var color:uint = 0xFF0000;
			
//			if (api.config.data.lastColor !== undefined) {
//				color = api.config.data.lastColor;
//			}
			circle.drawCircle(50, color);
			
//			if (api.stateHistory.length > 0) {
//				api.log("There are currently " + api.stateHistory.length + " state entries.");
//				var lastState:Object = api.stateHistory.getItemAt(api.stateHistory.length-1);
//				circle.setColor(lastState.color);
//			}

			if ('color' in api.syncedDataStore) {
				circle.setColor(api.syncedDataStore.color);
			}
			
			circle.addEventListener(MouseEvent.CLICK, handleCircleClick);
		}
		
		private function handleMessageReceived(event:MessageEvent):void {
			api.log("Received message: " + JSON.stringify(event.message));
			if (event.message && event.message.type === 'setColor') {
				circle.setColor(event.message.color);
			}
		}		
		
		private var lastColor:uint;
		private function handleEditModeEnabled(event:AuthorEvent):void {
			lastColor = circle.color;
			circle.setColor(0xFF8800);
		}
		
		private function handleEditModeDisabled(event:AuthorEvent):void {
			circle.setColor(lastColor);
		}
		
		private function handleCircleClick(event:MouseEvent):void {
			var red:uint = Math.floor(Math.random() * 0xFF);
			var green:uint = Math.floor(Math.random() * 0xFF);
			var blue:uint = Math.floor(Math.random() * 0xFF);
			var color:uint = 0x00000000;
			color = color | (red & 0xFF) << 16;
			color = color | (green & 0xFF) << 8;
			color = color | (blue & 0xFF);
			
//			api.stateHistory.clear({ color: color });
//			var toUserGuids:Array = [];
//			var user:User = api.thisRoom.users[Math.floor(api.thisRoom.users.length*Math.random())];
//			toUserGuids.push(user.guid);

			api.thisRoom.broadcastMessage({ type: "setColor", color: color });
			
//			if (api.thisUser.canAuthor) {
//				api.config.data.lastColor = color;
//				api.config.save();
//			}
		}
		
		private function handleSyncedPropertyChanged(event:ChangeEvent):void {
			if (event.name === 'color') {
				circle.setColor(event.newValue);
			}
		}
		
		private function handleStateAdded(event:StateHistoryEvent):void {
			circle.setColor(event.entry.color);
		}
		
		private function handleIncomingChat(event:ChatEvent):void {
			if (event.text.search(/^\d*$/) !== -1) {
				circle.drawCircle(parseInt(event.text,10), circle.color);
			}
		}
	}
}