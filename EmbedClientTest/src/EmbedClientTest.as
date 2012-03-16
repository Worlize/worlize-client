package
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.data.StateHistoryEntry;
	import com.worlize.api.data.StateHistoryEvent;
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
			api.thisObject.addEventListener(MessageEvent.MESSAGE_RECEIVED, handleMessageReceived);
			
			api.stateHistory.addEventListener(StateHistoryEvent.ITEM_ADDED, handleStateAdded);
			
			circle = new CircleSprite();
			addChild(circle);
			circle.drawCircle(100);
			
			if (api.stateHistory.length > 0) {
				var lastState:StateHistoryEntry = api.stateHistory.getItemAt(api.stateHistory.length-1) as StateHistoryEntry;
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
			
			api.stateHistory.push({ color: color });
			
			// api.thisObject.sendMessage({ msg: "setColor", color: color });
		}
		
		private function handleStateAdded(event:StateHistoryEvent):void {
			circle.setColor(event.item.data.color);
		}
		
		private function handleMessageReceived(event:MessageEvent):void {
			if (event.message.msg === 'setColor') {
				circle.setColor(event.message.color);
			}
		}
		
		private function handleIncomingChat(event:ChatEvent):void {
			if (event.text.search(/^\d*$/) !== -1) {
				circle.drawCircle(parseInt(event.text,10));
			}
		}
	}
}