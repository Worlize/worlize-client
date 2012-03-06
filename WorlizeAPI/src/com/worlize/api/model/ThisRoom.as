package com.worlize.api.model
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.APIEvent;
	import com.worlize.api.event.ChatEvent;
	import com.worlize.api.event.RoomEvent;
	import com.worlize.api.event.RoomObjectEvent;
	import com.worlize.api.event.UserEvent;
	import com.worlize.worlize_internal;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	[Event(name="incomingChat",type="com.worlize.api.event.ChatEvent")]
	[Event(name="outgoingChat",type="com.worlize.api.event.ChatEvent")]
	[Event(name="userEntered",type="com.worlize.api.event.RoomEvent")]
	[Event(name="userLeft",type="com.worlize.api.event.RoomEvent")]
	[Event(name="userMoved",type="com.worlize.api.event.UserEvent")]
	[Event(name="userAvatarChanged",type="com.worlize.api.event.UserEvent")]
	[Event(name="userFaceChanged",type="com.worlize.api.event.UserEvent")]
	[Event(name="userColorChanged",type="com.worlize.api.event.UserEvent")]
	[Event(name="objectResized",type="com.worlize.api.event.RoomObjectEvent")]
	[Event(name="objectMoved",type="com.worlize.api.event.RoomObjectEvent")]
	[Event(name="objectAdded",type="com.worlize.api.event.RoomEvent")]
	[event(name="objectRemoved",type="com.worlize.api.event.RoomEvent")]
	[Event(name="mouseMove",type="flash.events.MouseEvent")]
	public class ThisRoom extends Room
	{
		use namespace worlize_internal;
		
		protected var _users:Vector.<User> = new Vector.<User>();
		protected var _objects:Vector.<RoomObject> = new Vector.<RoomObject>();
		protected var _hotspots:Vector.<Hotspot> = new Vector.<Hotspot>();
		protected var _dimLevel:Number = 1.0;
		protected var _width:int;
		protected var _height:int;

		public function get users():Vector.<User> {
			return _users.slice();
		}
		
		public function get objects():Vector.<RoomObject> {
			return _objects.slice();
		}
		
		public function get hotspots():Vector.<Hotspot> {
			return _hotspots.slice();
		}

		public function get dimLevel():uint {
			return _dimLevel;
		}
		
		public function get width():int {
			return _width;
		}
		
		public function get height():int {
			return _height;
		}
		
		public function set dimLevel(newValue:uint):void {
			var event:APIEvent = new APIEvent(APIEvent.SET_ROOM_DIMLEVEL);
			event.data = { dimLevel: newValue };
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		public function get mouseX():Number {
			var event:APIEvent = new APIEvent(APIEvent.GET_ROOM_MOUSE_COORDS);
			var eo:Object = event;
			WorlizeAPI.sharedEvents.dispatchEvent(event);
			return eo.data.mouseX;
		}
		
		public function get mouseY():Number {
			var event:APIEvent = new APIEvent(APIEvent.GET_ROOM_MOUSE_COORDS);
			var eo:Object = event;
			WorlizeAPI.sharedEvents.dispatchEvent(event);
			return eo.data.mouseY;
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
				if (obj.instanceGuid === guid) {
					return obj;
				}
			}
			return null;
		}
		
		override public function toJSON():Object {
			var obj:Object = super.toJSON();
			var usersArray:Array = obj['users'] = [];
			for each (var user:User in _users) {
				usersArray.push(user.toJSON());
			}
			
			var objectsArray:Array = obj['objects'] = [];
			for each (var roomObject:RoomObject in _objects) {
				objectsArray.push(roomObject.toJSON());
			}
			
			var hotspotsArray:Array = obj['hotspots'] = [];
			for each (var hotspot:Hotspot in _hotspots) {
				hotspotsArray.push(hotspot.toJSON());
			}
			
			return obj;
		}
		
		override public function toString():String {
			return "[ThisRoom guid=" + _guid + " name=" + _name + "]";
		}
		
		private function redispatchUserEvent(event:UserEvent):void {
			dispatchEvent(event);
		}
		
		private function redispatchRoomObjectEvent(event:RoomObjectEvent):void {
			dispatchEvent(event);
		}
		
		worlize_internal function addObject(obj:RoomObject):void {
			_objects.push(obj);
			addRoomObjectEventListeners(obj);
		}
		
		worlize_internal function removeObject(objGuid:String):RoomObject {
			for (var i:int=0; i < _objects.length; i++) {
				if (_objects[i].instanceGuid === objGuid) {
					var obj:RoomObject = _objects[i];
					removeRoomObjectEventListeners(obj);
					_objects.splice(i, 1);
					return obj;
				}
			}
			return null;
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
					var e:RoomEvent = new RoomEvent(RoomEvent.USER_LEFT);
					e.user = user;
					dispatchEvent(e);
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
		
		private function addRoomObjectEventListeners(obj:RoomObject):void {
			obj.addEventListener(RoomObjectEvent.MOVED, redispatchRoomObjectEvent);
			obj.addEventListener(RoomObjectEvent.RESIZED, redispatchRoomObjectEvent);
		}
		
		private function removeRoomObjectEventListeners(obj:RoomObject):void {
			obj.removeEventListener(RoomObjectEvent.MOVED, redispatchRoomObjectEvent);
			obj.removeEventListener(RoomObjectEvent.RESIZED, redispatchRoomObjectEvent);
		}
		
		worlize_internal static function fromData(data:Object, thisUser:ThisUser, thisObject:ThisRoomObject):ThisRoom {
			var room:ThisRoom = new ThisRoom();
			room._guid = data.guid;
			room._name = data.name;
			room._width = data.width;
			room._height = data.height;
			
			for each (var userData:Object in data.users) {
				if (userData.guid === thisUser.guid) {
					room.addUser(thisUser);
				}
				else {
					room.addUser(User.fromData(userData));
				}
			}
			
			for each (var objectData:Object in data.objects) {
				if (objectData.instanceGuid === thisObject.instanceGuid) {
					room.addObject(thisObject);
				}
				else {
					room.addObject(RoomObject.fromData(objectData));
				}
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
		
		worlize_internal function setThisObject(obj:ThisRoomObject):void {
			for (var i:int=0; i < _objects.length; i++) {
				var existingObject:RoomObject = _objects[i];
				if (existingObject.instanceGuid === obj.instanceGuid) {
					removeRoomObjectEventListeners(existingObject);
					addRoomObjectEventListeners(obj);
					_objects.splice(i, 1, obj);
					return;
				}
			}
		}
		
		worlize_internal function addSharedEventHandlers(sharedEvents:EventDispatcher):void {
			sharedEvents.addEventListener('host_roomMouseMove', handleRoomMouseMove);
			sharedEvents.addEventListener('host_chatEvent', handleChat);
			sharedEvents.addEventListener('host_userEntered', handleUserEnter);
			sharedEvents.addEventListener('host_userLeft', handleUserLeave);
			sharedEvents.addEventListener('host_allUsersLeft', handleAllUsersLeft);
			sharedEvents.addEventListener('host_userMoved', handleUserMoved);
			sharedEvents.addEventListener('host_userAvatarChanged', handleUserAvatarChanged);
			sharedEvents.addEventListener('host_userFaceChanged', handleUserFaceChanged);
			sharedEvents.addEventListener('host_userColorChanged', handleUserColorChanged);
			sharedEvents.addEventListener('host_roomDimLevelChanged', handleRoomDimLevelChanged);
			sharedEvents.addEventListener('host_roomObjectAdded', handleObjectAdded);
			sharedEvents.addEventListener('host_roomObjectRemoved', handleObjectRemoved);
			sharedEvents.addEventListener('host_roomObjectMoved', handleObjectMoved);
			sharedEvents.addEventListener('host_roomObjectResized', handleObjectResized);
			sharedEvents.addEventListener('host_hotspotAdded', handleHotspotAdded);
			sharedEvents.addEventListener('host_hotspotRemoved', handleHotspotRemoved);
			sharedEvents.addEventListener('host_hotspotChanged', handleHotspotChanged);
		}
		
		private function handleRoomMouseMove(event:Event):void {
			var data:Object = event['data'];
			dispatchEvent(
				new MouseEvent(MouseEvent.MOUSE_MOVE, false, false,
							   data.localX, data.localY, null,
							   data.ctrlKey, data.altKey,
							   data.shiftKey, data.buttonDown, 0)
			);
		}
		
		private function handleChat(event:Event):void {
			var e:Object = event;
			
			var type:String = (e.data.type === "incomingChat") ? ChatEvent.INCOMING_CHAT : ChatEvent.OUTGOING_CHAT;
			var chatEvent:ChatEvent = new ChatEvent(type, false, true);
			chatEvent.isWhisper = e.data.isWhisper;
			chatEvent.text = e.data.text;
			if (e.data.recipient) {
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
		}
		
		private function handleAllUsersLeft(event:Event):void {
			for (var i:int = 0, len:int = _users.length; i < len; i++) {
				removeUser(_users[0].guid);
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
				user.updateAvatar(Avatar.fromData(eo.data.avatar));
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
			addObject(RoomObject.fromData(event['data'].roomObject));
		}
		
		private function handleObjectRemoved(event:Event):void {
			removeObject(event['data'].guid);
		}
		
		private function handleObjectResized(event:Event):void {
			var eo:Object = event;
			var roomObj:RoomObject = getObjectByGuid(eo.data.guid);
			if (roomObj) {
				roomObj.updateSize(eo.data.width, eo.data.height);
			}
		}
		
		private function handleObjectMoved(event:Event):void {
			var eo:Object = event;
			var roomObj:RoomObject = getObjectByGuid(eo.data.guid);
			if (roomObj) {
				roomObj.updatePosition(eo.data.x, eo.data.y);
			}
		}
		
		private function handleHotspotAdded(event:Event):void {
			
		}
		
		private function handleHotspotChanged(event:Event):void {
			
		}
		
		private function handleHotspotRemoved(event:Event):void {
			
		}
	}
}