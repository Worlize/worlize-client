package
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.ChatEvent;
	import com.worlize.api.event.MessageEvent;
	import com.worlize.api.event.RoomEvent;
	import com.worlize.api.event.RoomObjectEvent;
	import com.worlize.api.event.UserEvent;
	import com.worlize.api.model.Avatar;
	import com.worlize.api.model.RoomObject;
	import com.worlize.api.model.ThisRoom;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class ObjectStateLogger extends Sprite
	{
		public var api:WorlizeAPI;
		
		private var moveCounter:int = 0;
		
		
		public function ObjectStateLogger() {
			api = WorlizeAPI.init(this);
			api.thisObject.setSize(50,50);
			
			graphics.beginFill(0x0000FF);
			graphics.drawCircle(25,25,23);
			graphics.endFill();
						
			api.thisRoom.addEventListener(RoomEvent.USER_LEFT, handleUserLeft);
			api.thisRoom.addEventListener(RoomEvent.USER_ENTERED, handleUserEntered);
			api.thisRoom.addEventListener(RoomObjectEvent.OBJECT_STATE_CHANGED, handleObjectStateChanged);
			api.thisRoom.addEventListener(RoomEvent.OBJECT_ADDED, handleObjectAdded);
			api.thisRoom.addEventListener(RoomEvent.OBJECT_REMOVED, handleObjectRemoved);
//			api.thisRoom.addEventListener(RoomObjectEvent.MOVED, handleObjectMoved);
			api.thisRoom.addEventListener(RoomObjectEvent.OBJECT_RESIZED, handleObjectResized);
			api.thisRoom.addEventListener(UserEvent.USER_AVATAR_CHANGED, handleUserAvatarChanged);
			api.thisRoom.addEventListener(UserEvent.USER_COLOR_CHANGED, handleUserColorChanged);
			api.thisRoom.addEventListener(UserEvent.USER_FACE_CHANGED, handleUserFaceChanged);
			api.thisRoom.addEventListener(UserEvent.USER_MOVED, handleUserMoved);
			
			api.thisRoom.addEventListener(MouseEvent.MOUSE_MOVE, handleRoomMouseMove);
			api.thisRoom.addEventListener(ChatEvent.OUTGOING_CHAT, handleOutgoingChat);
			
			api.log("Object State Logger initialized.  My instance guid: " + api.thisObject.instanceGuid);
			for each (var obj:RoomObject in api.thisRoom.objects) {
				api.log("Object " + obj.instanceGuid + " state: " + obj.state);
			}
			
			api.thisObject.addEventListener(MessageEvent.MESSAGE_RECEIVED, handleMessageReceived);
		}
		
		private function handleRoomMouseMove(event:MouseEvent):void {
			if (!api.authorMode) {
				api.thisObject.moveTo(api.thisRoom.width - event.localX - 25, api.thisRoom.height - event.localY - 25);
			}
		}
				
		private function handleOutgoingChat(event:ChatEvent):void {
			var match:Array = event.text.match(/^msay (.*)$/);
			if (match) {
				var x:int = api.thisRoom.mouseX;
				var y:int = api.thisRoom.mouseY;
				event.text = "@" + x + "," + y + " " + match[1]; 
			}
		}
		
		private function handleObjectStateChanged(event:RoomObjectEvent):void {
			api.log("Object " + event.roomObject.instanceGuid + " state changed to " + event.roomObject.state);
		}
		
		private function handleObjectAdded(event:RoomObjectEvent):void {
			api.log("Object " + event.roomObject.instanceGuid + " added.");
		}
		
		private function handleObjectRemoved(event:RoomObjectEvent):void {
			api.log("Object " + event.roomObject.instanceGuid + " added.");
		}
		
		private function handleObjectMoved(event:RoomObjectEvent):void {
			api.log("Object " + event.roomObject.instanceGuid + " moved to " + event.roomObject.x + "," + event.roomObject.y);
		}
		
		private function handleObjectResized(event:RoomObjectEvent):void {
			api.log("Object " + event.roomObject.instanceGuid + " resized to " + event.roomObject.width + "x" + event.roomObject.height);
		}
		
		private function handleUserColorChanged(event:UserEvent):void {
			api.log("User " + event.user.name + " changed their color to " + event.user.color);
		}
		
		private function handleUserFaceChanged(event:UserEvent):void {
			api.log("User " + event.user.name + " changed their face to " + event.user.face);
		}
		
		private function handleMessageReceived(event:MessageEvent):void {
			api.log("Object " + event.fromObject.instanceGuid + " from user " + event.fromUser.name + " sent message: " + JSON.stringify(event.message));
		}
		
		private function handleUserEntered(event:RoomEvent):void {
			api.log(event.user.name + " entered.  There are now " + api.thisRoom.users.length + " users in the room.");
		}
		
		private function handleUserLeft(event:RoomEvent):void {
			api.log(event.user.name + " left.  There are " + api.thisRoom.users.length + " users remaining.");
		}

		private function handleUserMoved(event:UserEvent):void {
			api.log((moveCounter++) + " - User " + event.user.name + " moved. " + event.user.x + "," + event.user.y);
		}
		
		private function handleUserAvatarChanged(event:UserEvent):void {
			var av:Avatar = event.user.avatar;
			
			if (av.type === Avatar.TYPE_WEBCAM) {
				api.log("User " + event.user.name + " is wearing their webcam.");
			}
			else if (av.type === Avatar.TYPE_DEFAULT) {
				api.log("User " + event.user.name + " is not wearing an avatar.");
			}
			else if (av.type === Avatar.TYPE_IMAGE) {
				api.log("User " + event.user.name + " is wearing avatar " + av.guid);
			}
		}
	}
}