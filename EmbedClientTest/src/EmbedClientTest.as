package
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.ChatEvent;
	import com.worlize.api.event.RoomEvent;
	import com.worlize.api.event.UserEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setInterval;
	
	public class EmbedClientTest extends Sprite
	{
		private var api:WorlizeAPI;
		
		private var avatars:Array = [];
		
		public function EmbedClientTest() {
			WorlizeAPI.init(this);
			
			loaderInfo.addEventListener(Event.INIT, handleLoaderInfoInit);
			
			api = WorlizeAPI.getInstance();
			api.thisRoom.addEventListener(ChatEvent.OUTGOING_CHAT, filterLanguage);
			api.thisUser.addEventListener(UserEvent.MOVED, handleUserMoved);
			api.thisRoom.addEventListener(UserEvent.AVATAR_CHANGED, handleUserAvatarChanged);
			api.thisRoom.addEventListener(RoomEvent.USER_ENTERED, handleUserEntered);
			api.thisRoom.addEventListener(RoomEvent.USER_LEFT, handleUserLeft);

			var counter:int = 0;
//			setInterval(function():void {
//				counter ++;
//				trace("Before dispatching error - " + counter);
//				api.log("Before dispatching error - " + counter);
//				throw new Error("Regularly dispatched error!", 994499);
//			}, 4000);
		}
		
		private function handleMouseMove(event:MouseEvent):void {
			trace("Mouse Event " + event.type + ": " + mouseX + "," + mouseY);
			drawCircle(event.localX, event.localY, 50);
		}
		
		private function handleLoaderInfoInit(event:Event):void {
			var x:int = loaderInfo.width/2;
			var y:int = loaderInfo.height/2;

			drawCircle(x, y, 100);
			
			addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouseMove);
			
		}
		
		private function drawCircle(x:Number, y:Number, radius:Number):void {
			graphics.clear();
			graphics.beginFill(0xFF0000, 1.0);
			graphics.lineStyle(3, 0x000000);
			graphics.drawCircle(x, y, radius);
			graphics.endFill();
		}
		
		private function handleUserEntered(event:RoomEvent):void {
			api.log(event.user.name + " entered.  There are now " + api.thisRoom.users.length + " users in the room.");
		}
		
		private function handleUserLeft(event:RoomEvent):void {
			api.log(event.user.name + " left.  There are " + api.thisRoom.users.length + " users remaining.");
		}
		
		private function filterLanguage(event:ChatEvent):void {
			if (event.text.search(/^\d*$/) !== -1) {
				var x:int = loaderInfo.width/2;
				var y:int = loaderInfo.height/2;
				drawCircle(x, y, parseInt(event.text,10));
			}
			if (event.text === "takeitoff") {
				api.thisUser.avatar = null;
				event.preventDefault();
				return;
			}
			if (event.text === "error") {
				throw new Error("Requested error", 12345);
				return;
			}
			var originalText:String = event.text;
			event.text = event.text.replace(/(fuck|shit|cunt|damn)/gi, '****');
			
			api.thisUser.color = api.thisUser.face = Math.random() * 13;
			
			api.thisUser.x = 100 + Math.random() * 750;
			api.thisUser.y = 100 + Math.random() * 370;
		}
		
		private var moveCounter:int = 0;
		private function handleUserMoved(event:UserEvent):void {
			api.thisUser.color = Math.random() * 13;
			api.thisUser.face = Math.random() * 13;
			trace((moveCounter++) + " User moved. " + api.thisUser.x + "," + api.thisUser.y);
			
			var avatarGuid:String = avatars[Math.floor(Math.random()*avatars.length)];
			if (avatarGuid !== null) {
				api.thisUser.avatar = avatarGuid;
			}
		}
		
		private function handleUserAvatarChanged(event:UserEvent):void {
			api.log(event.user.name + " is wearing " + event.user.avatar);
			if (event.user.avatar && avatars.indexOf(event.user.avatar) === -1) {
				avatars.push(event.user.avatar);
			}
		}
	}
}