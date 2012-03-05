package com.worlize.api.model
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.APIEvent;
	import com.worlize.api.event.ChatEvent;
	import com.worlize.api.event.RoomEvent;
	import com.worlize.api.event.UserEvent;
	import com.worlize.worlize_internal;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	[Event(name="incomingChat",type="com.worlize.api.event.ChatEvent")]
	[Event(name="outgoingChat",type="com.worlize.api.event.ChatEvent")]
	[Event(name="userEntered",type="com.worlize.api.event.RoomEvent")]
	[Event(name="userLeft",type="com.worlize.api.event.RoomEvent")]
	[Event(name="userMoved",type="com.worlize.api.event.UserEvent")]
	[Event(name="userAvatarChanged",type="com.worlize.api.event.UserEvent")]
	[Event(name="userFaceChanged",type="com.worlize.api.event.UserEvent")]
	[Event(name="userColorChanged",type="com.worlize.api.event.UserEvent")]
	[Event(name="mouseMove",type="flash.events.MouseEvent")]
	public class ThisRoom extends Room
	{
		use namespace worlize_internal;
		
		protected var _users:Vector.<User>;
		protected var _objects:Vector.<RoomObject>;
		protected var _hotspots:Vector.<Hotspot>;		
		protected var _dimLevel:Number = 1.0;

		public function get users():Vector.<User> {
			return _users;
		}
		
		public function get objects():Vector.<RoomObject> {
			return _objects;
		}
		
		public function get hotspots():Vector.<Hotspot> {
			return _hotspots;
		}

		public function get dimLevel():uint {
			return _dimLevel;
		}
		
		public function set dimLevel(newValue:uint):void {
			var event:APIEvent = new APIEvent(APIEvent.SET_ROOM_DIMLEVEL);
			event.data = { dimLevel: newValue };
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		public function announce(text:String):void {
			var event:APIEvent = new APIEvent(APIEvent.ROOM_ANNOUNCE_MESSAGE);
			event.data = { text: text };
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		public function localAnnounce(text:String):void {
			var event:APIEvent = new APIEvent(APIEvent.ROOM_LOCAL_ANNOUNCE_MESSAGE);
			event.data = { text: text };
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		public function getUserByGuid(guid:String):User {
			for each (var user:User in _users) {
				if (user.guid === guid) {
					return user;
				}
			}
			return null;
		}
		
		public function getObjectByGuid(guid:String):RoomObject {
			for each (var obj:RoomObject in _objects) {
				if (obj.guid === guid) {
					return obj;
				}
			}
			return null;
		}
		
		override public function toString():String {
			return "[ThisRoom guid=" + _guid + " name=" + _name + "]";
		}
		
		private function redispatchUserEvent(event:UserEvent):void {
			dispatchEvent(event);
		}
		
		worlize_internal function addUser(user:User):void {
			_users.push(user);
			addUserEventListeners(user);
		}
		
		worlize_internal function removeUser(userGuid:String):User {
			for (var i:int=0; i < _users.length; i++) {
				if (_users[i].guid === userGuid) {
					var user:User = _users[i];
					_users.splice(i, 1);
					removeUserEventListeners(user);
					return user;
				}
			}
			return null;
		}
		
		private function addUserEventListeners(user:User):void {
			user.addEventListener(UserEvent.AVATAR_CHANGED, redispatchUserEvent);
			user.addEventListener(UserEvent.COLOR_CHANGED, redispatchUserEvent);
			user.addEventListener(UserEvent.FACE_CHANGED, redispatchUserEvent);
			user.addEventListener(UserEvent.MOVED, redispatchUserEvent);
		}
		
		private function removeUserEventListeners(user:User):void {
			user.removeEventListener(UserEvent.AVATAR_CHANGED, redispatchUserEvent);
			user.removeEventListener(UserEvent.COLOR_CHANGED, redispatchUserEvent);
			user.removeEventListener(UserEvent.FACE_CHANGED, redispatchUserEvent);
			user.removeEventListener(UserEvent.MOVED, redispatchUserEvent);
		}
		
		worlize_internal static function fromData(data:Object):ThisRoom {
			var room:ThisRoom = new ThisRoom();
			room._guid = data.guid;
			room._name = data.name;
			
			room._users = new Vector.<User>();
			for each (var userData:Object in data.users) {
				room._users.push(User.fromData(userData));
			}
			
			room._objects = new Vector.<RoomObject>();
			for each (var objectData:Object in data.objects) {
				room._objects.push(RoomObject.fromData(objectData));
			}
			
			return room;
		}
		
		worlize_internal function setThisUser(user:ThisUser):void {
			for (var i:int=0; i < _users.length; i++) {
				var existingUser:User = _users[i];
				if (existingUser.guid === user.guid) {
					removeUserEventListeners(existingUser);
					addUserEventListeners(user);
					_users.splice(i, 1, user);
					return;
				}
			}
		}
		
		worlize_internal function addSharedEventHandlers(sharedEvents:EventDispatcher):void {
			sharedEvents.addEventListener('host_chatEvent', handleChat);
			sharedEvents.addEventListener('host_userEntered', handleUserEnter);
			sharedEvents.addEventListener('host_userLeft', handleUserLeave);
			sharedEvents.addEventListener('host_userMoved', handleUserMoved);
			sharedEvents.addEventListener('host_userAvatarChanged', handleUserAvatarChanged);
			sharedEvents.addEventListener('host_userFaceChanged', handleUserFaceChanged);
			sharedEvents.addEventListener('host_userColorChanged', handleUserColorChanged);
			sharedEvents.addEventListener('host_roomDimLevelChanged', handleRoomDimLevelChanged);
			sharedEvents.addEventListener('host_roomObjectAdded', handleObjectAdded);
			sharedEvents.addEventListener('host_roomObjectRemoved', handleObjectRemoved);
			sharedEvents.addEventListener('host_roomObjectMoved', handleObjectMoved);
			sharedEvents.addEventListener('host_roomObjectChanged', handleObjectChanged);
			sharedEvents.addEventListener('host_roomObjectResized', handleObjectResized);
			sharedEvents.addEventListener('host_hotspotAdded', handleHotspotAdded);
			sharedEvents.addEventListener('host_hotspotRemoved', handleHotspotRemoved);
			sharedEvents.addEventListener('host_hotspotChanged', handleHotspotChanged);
		}
		
		private function handleChat(event:Event):void {
			var e:Object = event;
			
			var type:String = (e.data.type === "incomingChat") ? ChatEvent.INCOMING_CHAT : ChatEvent.OUTGOING_CHAT;
			var chatEvent:ChatEvent = new ChatEvent(type, false, true);
			chatEvent.isWhisper = e.data.isWhisper;
			chatEvent.text = e.data.text;
			if (e.data.whisperTarget) {
				chatEvent.recipient = getUserByGuid(e.data.recipient);
			}
			if (e.data.user) {
				chatEvent.user = getUserByGuid(e.data.user);
			}
			
			var canceled:Boolean = !dispatchEvent(chatEvent);
			
			e.data.text = chatEvent.text;
			if (canceled) {
				event.preventDefault();
			}
		}
		
		private function handleUserEnter(event:Event):void {
			var user:User = User.fromData((event as Object).data.user)
			addUser(user);
			var e:RoomEvent = new RoomEvent(RoomEvent.USER_ENTERED);
			e.user = user;
			dispatchEvent(e);
		}
		
		private function handleUserLeave(event:Event):void {
			var user:User = removeUser((event as Object).data.userGuid);
			if (user) {
				var e:RoomEvent = new RoomEvent(RoomEvent.USER_LEFT);
				e.user = user;
				dispatchEvent(e);
			}
		}
		
		private function handleUserMoved(event:Event):void {
			var eo:Object = event;
			var user:User = getUserByGuid(eo.data.userGuid);
			if (user) {
				user.updatePosition(eo.data.x, eo.data.y);
			}
		}
		
		private function handleUserAvatarChanged(event:Event):void {
			var eo:Object = event;
			var user:User = getUserByGuid(eo.data.userGuid);
			if (user) {
				user.updateAvatar(eo.data.avatar);
			}
		}
		
		private function handleUserFaceChanged(event:Event):void {
			var eo:Object = event;
			var user:User = getUserByGuid(eo.data.userGuid);
			if (user) {
				user.updateFace(eo.data.face);
			}
		}
		
		private function handleUserColorChanged(event:Event):void {
			var eo:Object = event;
			var user:User = getUserByGuid(eo.data.userGuid);
			if (user) {
				user.updateColor(eo.data.color);
			}
		}
		
		private function handleRoomDimLevelChanged(event:Event):void {
			var eo:Object = event;
			_dimLevel = eo.data.dimLevel;
		}
		
		private function handleObjectAdded(event:Event):void {
			
		}
		
		private function handleObjectRemoved(event:Event):void {
			
		}
		
		private function handleObjectResized(event:Event):void {
			
		}
		
		private function handleObjectChanged(event:Event):void {
			
		}
		
		private function handleObjectMoved(event:Event):void {
			
		}
		
		private function handleHotspotAdded(event:Event):void {
			
		}
		
		private function handleHotspotChanged(event:Event):void {
			
		}
		
		private function handleHotspotRemoved(event:Event):void {
			
		}
	}
}