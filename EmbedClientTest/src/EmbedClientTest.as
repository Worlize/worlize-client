package
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.data.StateHistoryEvent;
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
			WorlizeAPI.init(this);
			
			api = WorlizeAPI.getInstance();
			api.thisRoom.addEventListener(ChatEvent.INCOMING_CHAT, handleIncomingChat);
			
			api.stateHistory.addEventListener(StateHistoryEvent.ENTRY_ADDED, handleStateAdded);
			
			circle = new CircleSprite();
			addChild(circle);
			var color:uint = 0xFF0000;
			
			if (api.config.data.lastColor !== undefined) {
				color = api.config.data.lastColor;
			}
			circle.drawCircle(100, color);
			
			if (api.stateHistory.length > 0) {
				api.log("There are currently " + api.stateHistory.length + " state entries.");
				var lastState:Object = api.stateHistory.getItemAt(api.stateHistory.length-1);
				circle.setColor(lastState.color);
			}
			
			circle.addEventListener(MouseEvent.CLICK, handleCircleClick);
		}
		
		private function handleCircleClick(event:MouseEvent):void {
			var red:uint = Math.floor(Math.random() * 0xFF);
			var green:uint = Math.floor(Math.random() * 0xFF);
			var blue:uint = Math.floor(Math.random() * 0xFF);
			var color:uint = 0x00000000;
			color = color | (red & 0xFF) << 16;
			color = color | (green & 0xFF) << 8;
			color = color | (blue & 0xFF);
			
			api.stateHistory.clear({ color: color });
//			var toUserGuids:Array = [];
//			var user:User = api.thisRoom.users[Math.floor(api.thisRoom.users.length*Math.random())];
//			toUserGuids.push(user.guid);

			api.thisRoom.broadcastMessage({ type: "setColor", color: color });
			
			if (api.thisUser.canAuthor) {
				api.config.data.lastColor = color;
				api.config.save();
			}
			
			// api.thisObject.sendMessage({ msg: "setColor", color: color });
		}
		
		private function handleStateAdded(event:StateHistoryEvent):void {
			circle.setColor(event.entry.color);
		}
		
		private function handleIncomingChat(event:ChatEvent):void {
			if (event.text.search(/^\d*$/) !== -1) {
				circle.drawCircle(parseInt(event.text,10));
			}
		}
	}
}