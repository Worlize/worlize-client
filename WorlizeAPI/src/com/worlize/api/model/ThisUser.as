package com.worlize.api.model
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.APIEvent;
	import com.worlize.worlize_internal;
	
	public class ThisUser extends User
	{
		use namespace worlize_internal;
		
		public function set y(newValue:int):void {
			move(_x, newValue);
		}

		public function set x(newValue:int):void {
			move(newValue, _y);
		}
		
		public function set avatar(newValue:String):void {
			if (_avatar !== newValue) {
				if (newValue === null || newValue.match(WorlizeAPI.GUID_REGEXP)) {
					var event:APIEvent = new APIEvent(APIEvent.SET_AVATAR);
					event.data = { avatar: newValue };
					WorlizeAPI.sharedEvents.dispatchEvent(event);
				}
				else {
					throw new ArgumentError("Invalid avatar value: " + newValue);
				}
			}
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
			user._avatar = data.avatar;
			return user;
		}
	}
}