package
{
	import com.worlize.api.WorlizeAPI;
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
			
			loaderInfo.addEventListener(Event.INIT, handleLoaderInfoInit);
			
			api = WorlizeAPI.getInstance();
			api.thisRoom.addEventListener(ChatEvent.OUTGOING_CHAT, filterLanguage);
			api.thisRoom.addEventListener(ChatEvent.INCOMING_CHAT, handleIncomingChat);
			api.thisRoom.addEventListener(UserEvent.MOVED, handleUserMoved);
			api.thisRoom.addEventListener(UserEvent.AVATAR_CHANGED, handleUserAvatarChanged);
			api.thisRoom.addEventListener(RoomEvent.USER_ENTERED, handleUserEntered);
			api.thisRoom.addEventListener(RoomEvent.USER_LEFT, handleUserLeft);
//			api.thisRoom.addEventListener(MouseEvent.MOUSE_MOVE, handleRoomMouseMove);

			api.thisObject.addEventListener(MessageEvent.MESSAGE_RECEIVED, handleMessageReceived);
			
			api.thisObject.addEventListener(RoomObjectEvent.RESIZED, handleObjectResized);
			
			for each (var user:User in api.thisRoom.users) {
				user.addEventListener(UserEvent.AVATAR_CHANGED, handleUserAvatarChanged);
			}
			
			circle = new CircleSprite();
			circle.drawCircle(100);
//			circle.mouseEnabled = false;
			addChild(circle);
			
			circle.addEventListener(MouseEvent.CLICK, handleCircleClick);
			
			var counter:int = 0;
//			setInterval(function():void {
//				counter ++;
//				trace("Before dispatching error - " + counter);
//				api.log("Before dispatching error - " + counter);
//				throw new Error("Regularly dispatched error!", 994499);
//			}, 4000);
		}
		
		private function handleCircleClick(event:MouseEvent):void {
			var red:uint = Math.floor(Math.random() * 0xFF);
			var green:uint = Math.floor(Math.random() * 0xFF);
			var blue:uint = Math.floor(Math.random() * 0xFF);
			var color:uint = 0x00000000;
			color = color | (red & 0xFF) << 16;
			color = color | (green & 0xFF) << 8;
			color = color | (blue & 0xFF);
			api.thisObject.sendMessage(JSON.stringify({ color: color }));
		}
		
		private function handleMessageReceived(event:MessageEvent):void {
			try {
				var data:Object = JSON.parse(event.message);
				circle.setColor(data.color);
			}
			catch(e:Error) {
				// do nothing
			}
		}
		
		private function handleObjectResized(event:RoomObjectEvent):void {
			circle.x = api.thisObject.width / 2;
			circle.y = api.thisObject.height / 2;
			centerOnCursor();
		}
		
		private function centerOnCursor():void {
			api.thisObject.moveTo(api.thisRoom.mouseX - api.thisObject.width/2, api.thisRoom.mouseY - api.thisObject.height/2);
		}
		
		private function handleRoomMouseMove(event:MouseEvent):void {
//			circle.x = event.localX - api.thisObject.x;
//			circle.y = event.localY - api.thisObject.y;
			centerOnCursor();
//			api.thisObject.moveTo(event.localX - loaderInfo.width/2, event.localY - loaderInfo.height/2);
		}
		
		private function handleLoaderInfoInit(event:Event):void {
			circle.x = api.thisObject.width/2;
			circle.y = api.thisObject.height/2;

//			circle.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseEvent);
//			circle.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseEvent);
		}
		
		private function handleUserEntered(event:RoomEvent):void {
			api.log(event.user.name + " entered.  There are now " + api.thisRoom.users.length + " users in the room.");
			event.user.addEventListener(UserEvent.AVATAR_CHANGED, handleUserAvatarChanged);
		}
		
		private function handleUserLeft(event:RoomEvent):void {
			api.log(event.user.name + " left.  There are " + api.thisRoom.users.length + " users remaining.");
			event.user.removeEventListener(UserEvent.AVATAR_CHANGED, handleUserAvatarChanged);
		}
		
		private function handleIncomingChat(event:ChatEvent):void {
			if (event.text.search(/^\d*$/) !== -1) {
				circle.drawCircle(parseInt(event.text,10));
			}
		}
		
		private function filterLanguage(event:ChatEvent):void {
			if (event.text === "takeitoff") {
				api.thisUser.removeAvatar();
				event.preventDefault();
				return;
			}
			if (event.text === "error") {
				throw new Error("Requested error", 12345);
			}
			if (event.text === "take") {
				takeAvatar(event);
				return;
			}
			var originalText:String = event.text;
			event.text = event.text.replace(/(fuck|shit|cunt|damn)/gi, '****');
			
			api.thisUser.color = api.thisUser.face = Math.random() * 13;
			
			var x:int = 100 + Math.random() * 750;
			var y:int = 100 + Math.random() * 370;
			api.thisUser.move(x,y);
		}
		
		private function takeAvatar(event:ChatEvent):void {
			if (event.isWhisper) {
				api.thisUser.setAvatar(event.recipient.avatar);
			}
			event.preventDefault();
		}
		
		private var moveCounter:int = 0;
		private function handleUserMoved(event:UserEvent):void {
			api.thisUser.color = Math.random() * 13;
			api.thisUser.face = Math.random() * 13;
			api.log((moveCounter++) + " " + event.user.name + " moved. " + event.user.x + "," + event.user.y);
		}
		
		private function handleUserAvatarChanged(event:UserEvent):void {
			var av:Avatar = event.user.avatar;
			
			if (av.type === Avatar.TYPE_WEBCAM) {
				api.log(event.user.name + " is wearing their webcam.");
			}
			else if (av.type === Avatar.TYPE_DEFAULT) {
				api.log(event.user.name + " is not wearing an avatar.");
			}
			else if (av.type === Avatar.TYPE_IMAGE) {
				api.log(event.user.name + " is wearing avatar " + av.guid);
			}
		}
	}
}