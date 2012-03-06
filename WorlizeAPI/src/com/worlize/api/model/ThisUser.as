package com.worlize.api.model
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.APIEvent;
	import com.worlize.worlize_internal;
	
	public class ThisUser extends User
	{
		use namespace worlize_internal;
		
		public function setAvatar(avatarOrGuid:Object):void {
			var avatarGuid:String;
			if (avatarOrGuid is Avatar) {
				avatarGuid = (avatarOrGuid as Avatar).guid;
			}
			else if (avatarOrGuid === null) {
				avatarOrGuid = null;
			}
			else if (avatarOrGuid is String) {
				avatarGuid = avatarOrGuid as String;
			}
			else {
				throw new ArgumentError("Invalid parameter passed to setAvatar.");
			}
			
			if (_avatar === null && avatarGuid === null) { return; };
			if (_avatar !== null && avatar.guid === avatarGuid) { return; }

			if (avatarGuid === null || avatarGuid.match(WorlizeAPI.GUID_REGEXP)) {
				var event:APIEvent = new APIEvent(APIEvent.SET_AVATAR);
				event.data = { guid: avatarGuid };
				WorlizeAPI.sharedEvents.dispatchEvent(event);
			}
			else {
				throw new ArgumentError("Invalid avatar guid: " + avatarGuid);
			}
		}
		
		public function removeAvatar():void {
			setAvatar(null);
		}
		
		public function set face(newValue:int):void {
			var event:APIEvent = new APIEvent(APIEvent.SET_USER_FACE);
			event.data = { face: newValue };
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		public function set color(newValue:int):void {
			var event:APIEvent = new APIEvent(APIEvent.SET_USER_COLOR);
			event.data = { color: newValue };
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		public function move(x:int, y:int):void {
			var event:APIEvent = new APIEvent(APIEvent.MOVE_USER);
			event.data = {
				x: x,
				y: y
			};
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		public function say(text:String, whisperTo:User=null):void {
			var event:APIEvent = new APIEvent(APIEvent.SEND_CHAT);
			event.data = {
				text: text
			};
			if (whisperTo) {
				event.data.whisperTo = whisperTo.guid
			}
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		override public function toString():String {
			return "[ThisUser guid=" + _guid + " name=" + _name + "]";
		}
		
		worlize_internal static function fromData(data:Object):ThisUser {
			var user:ThisUser = new ThisUser();
			user._guid = data.guid;
			user._name = data.name;
			user._x = data.x;
			user._y = data.y;
			user._face = data.face;
			user._color = data.color;
			user._avatar = Avatar.fromData(data.avatar);
			return user;
		}
	}
}