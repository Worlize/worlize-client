package com.worlize.api.model
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.UserEvent;
	import com.worlize.worlize_internal;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	[Event(name="userMoved",type="com.worlize.api.event.UserEvent")]
	[Event(name="userAvatarChanged",type="com.worlize.api.event.UserEvent")]
	[Event(name="userFaceChanged",type="com.worlize.api.event.UserEvent")]
	[Event(name="userColorChanged",type="com.worlize.api.event.UserEvent")]
	[Event(name="userPrivilegesChanged",type="com.worlize.api.event.UserEvent")]
	public class User extends EventDispatcher
	{
		use namespace worlize_internal;
		
		protected var _name:String;
		protected var _guid:String;
		protected var _x:int;
		protected var _y:int;
		protected var _face:int;
		protected var _color:int;
		protected var _avatar:Avatar;
		protected var _privileges:Array;
		
		public function User() {
			super(null);
		}
		
		public function get name():String {
			return _name;
		}
		
		public function get guid():String {
			return _guid;
		}
		
		public function get x():int {
			return _x;
		}
		
		public function get y():int {
			return _y;
		}
		
		public function get face():int {
			return _face;
		}
		
		public function get color():int {
			return _color;
		}
		
		public function get avatar():Avatar {
			return _avatar;
		}
		
		public function get canAuthor():Boolean {
			return _privileges && _privileges.indexOf('canAuthor') !== -1;
		}
		
		public function get privileges():Array {
			return _privileges.slice(0);
		}
		
		public function toJSON():Object {
			return {
				name: _name,
				guid: _guid,
				x: _x,
				y: _y,
				face: _face,
				color: _color,
				avatar: _avatar ? _avatar.toJSON() : null
			};
		}
		
		override public function toString():String {
			return "[User guid=" + _guid + " name=" + _name + "]";
		}
		
		worlize_internal function updatePosition(x:int, y:int):void {
			if (_x !== x || _y !== y) {
				_x = x;
				_y = y;
				var event:UserEvent = new UserEvent(UserEvent.USER_MOVED);
				event.user = this;
				dispatchEvent(event);
			}
		}
		
		worlize_internal function updateAvatar(avatar:Avatar):void {
			if (_avatar !== avatar) {
				_avatar = avatar;
				var event:UserEvent = new UserEvent(UserEvent.USER_AVATAR_CHANGED);
				event.user = this;
				dispatchEvent(event);
			}
		}
		
		worlize_internal function updateFace(newValue:uint):void {
			if (_face !== newValue) {
				_face = newValue;
				var event:UserEvent = new UserEvent(UserEvent.USER_FACE_CHANGED);
				event.user = this;
				dispatchEvent(event);
			}
		}
		
		worlize_internal function updateColor(newValue:uint):void {
			if (_color !== newValue) {
				_color = newValue;
				var event:UserEvent = new UserEvent(UserEvent.USER_COLOR_CHANGED);
				event.user = this;
				dispatchEvent(event);
			}
		}
		
		worlize_internal function updatePrivileges(newValue:Array):void {
			if (newValue === null) { return; }
			
			var valuesDiffer:Boolean = false;
			if (newValue.length === _privileges.length) {
				var sortedPrivileges:Array = newValue.sort();
				for (var i:int = 0; i < sortedPrivileges.length; i++) {
					if (sortedPrivileges[i] !==	_privileges[i]) {
						valuesDiffer = true;
						break;
					}
				}
			}
			else {
				valuesDiffer = true;
			}
			if (valuesDiffer) {
				_privileges = sortedPrivileges;
				var event:UserEvent = new UserEvent(UserEvent.USER_PRIVILEGES_CHANGED);
				event.user = this;
				dispatchEvent(event);
			}
		}
		
		worlize_internal static function fromData(data:Object):User {
			var user:User = new User();
			user._privileges = data.privileges.sort();
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