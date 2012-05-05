package com.worlize.api.model
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.APIEvent;
	import com.worlize.api.event.ChatEvent;
	import com.worlize.api.event.LoosePropEvent;
	import com.worlize.api.event.RoomEvent;
	import com.worlize.api.event.RoomObjectEvent;
	import com.worlize.api.event.UserEvent;
	import com.worlize.worlize_internal;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * Dispatched when incoming chat is received from any user in the
	 * room.
	 * 
	 * <p>This event will be triggered by all incoming chat, including
	 * chat from the current user, after it has been received from the
	 * server.  That means that when the current user chats, both
	 * <code>outgoingChat</code> and <code>incomingChat</code> events
	 * will be dispatched, in that order.</p>
	 * 
	 * @eventType com.worlize.api.event.ChatEvent.INCOMING_CHAT
	 * @productversion Worlize API.v1
	 */	
	[Event(name="incomingChat",type="com.worlize.api.event.ChatEvent")]
	
	/**
	 * Dispatched when the user sends an outgoing chat message, before
	 * it is sent to the server.
	 *
	 * <p>Be aware that when the current user chats, both
	 * <code>outgoingChat</code> and <code>incomingChat</code> events
	 * will be dispatched, in that order.</p>
	 *  
	 * @eventType com.worlize.api.event.ChatEvent.OUTGOING_CHAT
	 * @productversion Worlize API.v1
	 */	
	[Event(name="outgoingChat",type="com.worlize.api.event.ChatEvent")]
	
	/**
	 * Dispatched after a user has entered the room.
	 * 
	 * @eventType com.worlize.api.event.RoomEvent.USER_ENTERED
	 * @productversion Worlize API.v1
	 */	
	[Event(name="userEntered",type="com.worlize.api.event.RoomEvent")]
	
	/**
	 * Dispatched after a user has left the room.
	 * 
	 * @eventType com.worlize.api.event.RoomEvent.USER_ENTERED
	 * @productversion Worlize API.v1
	 */	
	[Event(name="userLeft",type="com.worlize.api.event.RoomEvent")]

	/**
	 * Dispatched after a user's avatar has moved.
	 * 
	 * @eventType com.worlize.api.event.UserEvent.USER_MOVED
	 * @productversion Worlize API.v1
	 */	
	[Event(name="userMoved",type="com.worlize.api.event.UserEvent")]
	
	/**
	 * Dispatched after a user's avatar has changed.
	 * 
	 * @eventType com.worlize.api.event.UserEvent.USER_AVATAR_CHANGED
	 * @productversion Worlize API.v1
	 */	
	[Event(name="userAvatarChanged",type="com.worlize.api.event.UserEvent")]
	
	/**
	 * Dispatched after the color of a user's default "gummy" avatar has changed.
	 * 
	 * @eventType com.worlize.api.event.UserEvent.USER_COLOR_CHANGED
	 * @productversion Worlize API.v1 
	 */	
	[Event(name="userColorChanged",type="com.worlize.api.event.UserEvent")]
	
	/**
	 * Dispatched after a user's text baloon background color has changed.
	 * 
	 * @eventType com.worlize.api.event.UserEvent.USER_BALLOON_COLOR_CHANGED 
	 * @productversion Worlize API.v1
	 */	
	[Event(name="userBalloonColorChanged",type="com.worlize.api.event.UserEvent")]
	
	/**
	 * Dispatched after a user's privileges have changed
	 * 
	 * @eventType com.worlize.api.event.UserEvent.USER_PRIVILEGES_CHANGED
	 * @productversion Worlize API.v1 
	 */	
	[Event(name="userPrivilegesChanged",type="com.worlize.api.event.UserEvent")]
	
	/**
	 * Dispatched after an object in the room has been resized.
	 * 
	 * @eventType com.worlize.api.event.RoomObjectEvent.OBJECT_RESIZED
	 * @productversion Worlize API.v1 
	 */	
	[Event(name="objectResized",type="com.worlize.api.event.RoomObjectEvent")]
	
	/**
	 * Dispatched after an object in the room has been moved.
	 * 
	 * @eventType com.worlize.api.event.RoomObjectEvent.OBJECT_MOVED
	 * @productversion Worlize API.v1 
	 */	
	[Event(name="objectMoved",type="com.worlize.api.event.RoomObjectEvent")]
	
	/**
	 * Dispatched after an object in the room has changed state.
	 * 
	 * @eventType com.worlize.api.event.RoomObjectEvent.OBJECT_STATE_CHANGED
	 * @productversion Worlize API.v1 
	 */	
	[Event(name="objectStateChanged",type="com.worlize.api.event.RoomObjectEvent")]
	
	/**
	 * Dispatched after an object has been added to the room.
	 * 
	 * @eventType com.worlize.api.event.RoomEvent.OBJECT_ADDED
	 * @productversion Worlize API.v1 
	 */	
	[Event(name="objectAdded",type="com.worlize.api.event.RoomEvent")]
	
	/**
	 * Dispatched after the room's name has been changed by its owner.
	 * 
	 * @eventType com.worlize.api.event.RoomEvent.NAME_CHANGED
	 * @productversion Worlize API.v3 
	 */	
	[Event(name="nameChanged",type="com.worlize.api.event.RoomEvent")]
	
	/**
	 * Dispatched after an object has been removed from the room.
	 * 
	 * @eventType com.worlize.api.event.RoomEvent.OBJECT_REMOVED
	 * @productversion Worlize API.v1 
	 */	
	[Event(name="objectRemoved",type="com.worlize.api.event.RoomEvent")]
	
	/**
	 * Dispatched after the room has been locked.
	 * 
	 * @eventType com.worlize.api.event.RoomEvent.LOCKED
	 * @productversion Worlize API.v1 
	 */	
	[Event(name="locked",type="com.worlize.api.event.RoomEvent")]
	
	/**
	 * Dispatched after the room has been unlocked.
	 * 
	 * @eventType com.worlize.api.event.RoomEvent.UNLOCKED
	 * @productversion Worlize API.v1 
	 */	
	[Event(name="unlocked", type="com.worlize.api.event.RoomEvent")]
	
	/**
	 * Dispatched after a loose prop has been added to the room.
	 * 
	 * @eventType com.worlize.api.event.LoosePropEvent.PROP_ADDED
	 * @productversion Worlize APIv.2
	 */	
	[Event(name="propAdded", type="com.worlize.api.event.LoosePropEvent")]
	
	/**
	 * Dispatched after a loose prop has been removed from the room.
	 * 
	 * @eventType com.worlize.api.event.LoosePropEvent.PROP_REMOVED
	 * @productversion Worlize APIv.2 
	 */	
	[Event(name="propRemoved", type="com.worlize.api.event.LoosePropEvent")]
	
	/**
	 * Dispatched after a loose prop has been moved.
	 * 
	 * @eventType com.worlize.api.event.LoosePropEvent.PROP_MOVED
	 * @productversion Worlize APIv.2 
	 */	
	[Event(name="propMoved", type="com.worlize.api.event.LoosePropEvent")]
	
	/**
	 * Dispatched after a loose prop has changed its stacking order.
	 * 
	 * @eventType com.worlize.api.event.LoosePropEvent.PROP_LAYER_CHANGED
	 * @productversion Worlize APIv.2 
	 */	
	[Event(name="propLayerChanged", type="com.worlize.api.event.LoosePropEvent")]
	
	/**
	 * Dispatched after all loose props have been removed from the room.
	 * 
	 * @eventType com.worlize.api.event.LoosePropEvent.PROPS_CLEARED
	 * @productversion Worlize APIv.2 
	 */	
	[Event(name="propsCleared", type="com.worlize.api.event.LoosePropEvent")]
	
	
	/**
	 * Dispatched continuously as the user moves their mouse over the room
	 * background.
	 * 
	 * <p>Since embedded apps don't have access to the screen area outside
	 * the boundaries of their own rectangle, listen to this event to track
	 * mouse movement outside the app's boundaries.</p>
	 * 
	 * @eventType flash.events.MouseEvent
	 * @productversion Worlize API.v1 
	 */	
	[Event(name="mouseMove",type="flash.events.MouseEvent")]
	
	/**
	 * Represents the current room ("this" room).
	 * 
	 * <p>Extends the <code>Room</code> class with properties and methods
	 * relevant to observing actions occurring in the current room and
	 * manipulating its state.</p>
	 * 
	 * @author Brian McKelvey
	 * @productversion Worlize APIv.1
	 * @see com.worlize.api.model.Room
	 * @see com.worlize.api.model.RoomObject
	 * @see com.worlize.api.model.User
	 * @see com.worlize.api.model.LooseProp
	 */	
	public class ThisRoom extends Room
	{
		use namespace worlize_internal;
		
		/**
		 * Storage for the User instances representing the room's denizens
		 * 
		 * @private 
		 */		
		protected var _users:Vector.<User> = new Vector.<User>();
		
		/**
		 * Storage for the RoomObject instances representing the objects (apps)
		 * in the room.
		 * 
		 * @private 
		 */		
		protected var _objects:Vector.<RoomObject> = new Vector.<RoomObject>();
		
		/**
		 * Storage for the LooseProp instances representing the room's props.
		 * 
		 * @private 
		 */		
		protected var _looseProps:Vector.<LooseProp> = new Vector.<LooseProp>();
		
		/**
		 * Lookup table for LooseProp instances by their id
		 * 
		 * @private 
		 */		
		protected var _loosePropsById:Object = {};
		
		/**
		 * Storage for the room's current dim level.
		 * 
		 * @private 
		 */		
		protected var _dimLevel:Number = 1.0;
		
		/**
		 * Storage for the room's width.  For now will always be 950.
		 * 
		 * @private 
		 */		
		protected var _width:int;
		
		/**
		 * Storage for the room's height.  For now will always be 570.
		 * 
		 * @private 
		 */		
		protected var _height:int;

		/**
		 * A list of users in the room.
		 *  
		 * @return the user list. 
		 * @productversion Worlize APIv.1
		 */		
		public function get users():Vector.<User> {
			return _users.slice();
		}
		
		/**
		 * A list of objects (apps) in the room.
		 *  
		 * @return the list of objects. 
		 * @productversion Worlize APIv.1 
		 */		
		public function get objects():Vector.<RoomObject> {
			return _objects.slice();
		}
		
		/**
		 * A list of loose props in the room.
		 *  
		 * @return the list of loose props.
		 * @productversion Worlize APIv.2 
		 */		
		public function get looseProps():Vector.<LooseProp> {
			return _looseProps.slice();
		}		
		
		/**
		 * A number representing how dim the room is.
		 * 
		 * <p>This is a value from 0 to 100, where 0 is full black, and 100
		 * is full brightness</p>
		 *   
		 * @return a number representing the room's dim level. 
		 * @productversion Worlize APIv.1
		 */		
		public function get dimLevel():uint {
			return _dimLevel;
		}
		
		/**
		 * @private
		 */		
		public function set dimLevel(newValue:uint):void {
			var event:APIEvent = new APIEvent(APIEvent.SET_ROOM_DIMLEVEL);
			event.data = { dimLevel: newValue };
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		/**
		 * The room's width.
		 *  
		 * @return an integer representing the room's width.
		 * @productversion Worlize APIv.1
		 */		
		public function get width():int {
			return _width;
		}
		
		/**
		 * The room's height.
		 *  
		 * @return an integer representing the room's height. 
		 * @productversion Worlize APIv.1
		 */		
		public function get height():int {
			return _height;
		}
		
		/**
		 * The horizontal position of the mouse cursor relative to the room's coordinate space 
		 * 
		 * @return the horizontal mouse position
		 * @productversion Worlize APIv.1
		 */		
		public function get mouseX():Number {
			var event:APIEvent = new APIEvent(APIEvent.GET_ROOM_MOUSE_COORDS);
			var eo:Object = event;
			WorlizeAPI.sharedEvents.dispatchEvent(event);
			return eo.data.mouseX;
		}
		
		/**
		 * The vertical position of the mouse cursor relative to the room's coordinate space
		 * 
		 * @return the vertical mouse position
		 * @productversion Worlize APIv.1
		 */		
		public function get mouseY():Number {
			var event:APIEvent = new APIEvent(APIEvent.GET_ROOM_MOUSE_COORDS);
			var eo:Object = event;
			WorlizeAPI.sharedEvents.dispatchEvent(event);
			return eo.data.mouseY;
		}
		
		/**
		 * Displays a disembodied white chat balloon for all users in the room.
		 * 
		 * <p>The text will appear in the chat log without a username.</p> 
		 * 
		 * <p>The text appears in the top left corner by default.  You may
		 * position the text by prepending an &#64; symbol followed by x and
		 * y coordinates to the text</p>
		 * 
		 * @param text the text to display in the chat balloon.
		 * @see #announceLocal()
		 * @productversion Worlize APIv.1
		 * @example Display a specifically positioned chat bubble for all users in the room
		 * <listing version="3.0">
		 * 
		 * var api:WorlizeAPI = WorlizeAPI.getInstance();
		 * api.thisRoom.announce("&#64;100,200 OMG, a disembodied chat bubble!");
		 * 
		 * </listing>
		 */		
		public function announce(text:String):void {
			var event:APIEvent = new APIEvent(APIEvent.ROOM_ANNOUNCE_MESSAGE);
			event.data = { text: text };
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		/**
		 * Displays a disembodied white chat balloon only for the current user.
		 * 
		 * <p>Only the current user will see balloons produced with
		 * <code>announceLocal()</code>.  Other users
		 * <strong><em>will not</em></strong> see them and the text will not
		 * be routed through the server.</p> 
		 * 
		 * <p>The text will appear in the chat log without a username.</p> 
		 * 
		 * <p>The text appears in the top left corner by default.  You may
		 * position the text by prepending an &#64; symbol followed by x and
		 * y coordinates to the text</p>
		 * 
		 * @param text the text to display in the chat balloon.
		 * @see #announce()
		 * @productversion Worlize APIv.1
		 * @example Display a specifically positioned chat bubble for only the current user in the room
		 * <listing version="3.0">
		 * 
		 * var api:WorlizeAPI = WorlizeAPI.getInstance();
		 * api.thisRoom.announceLocal("&#64;100,200 OMG, a disembodied chat bubble!");
		 * 
		 * </listing>
		 */		
		public function announceLocal(text:String):void {
			var event:APIEvent = new APIEvent(APIEvent.ROOM_LOCAL_ANNOUNCE_MESSAGE);
			event.data = { text: text };
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		/**
		 * Lock the room.
		 * 
		 * <p>Subsequent visitors will be denied entrance to the room as long
		 * as it remains locked.  Rooms will automatically unlock when they
		 * become empty.</p>
		 * 
		 * <p>The owner of a room may always enter, even if it is locked.</p> 
		 * 
		 * @productversion Worlize APIv.1
		 * @see #unlock()
		 */		
		public function lock():void {
			var event:APIEvent = new APIEvent(APIEvent.LOCK_ROOM);
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		/**
		 * Unlock the room.
		 * 
		 * <p>Subsequent visitors will be allowed entrance to the room.</p>
		 * 
		 * <p>Rooms will automatically unlock when they become empty.  The
		 * owner of a room may always enter, even if it is locked.</p>
		 * 
		 * @productversion Worlize APIv.1
		 * @see #lock()
		 */		
		public function unlock():void {
			var event:APIEvent = new APIEvent(APIEvent.UNLOCK_ROOM);
			WorlizeAPI.sharedEvents.dispatchEvent(event);	
		}
		
		/**
		 * Send a message to all objects in the room.
		 * 
		 * <p>Broadcasts any AMF3-serializable object to all objects (apps)
		 * in the room, facilitating inter-app communications and events.</p>
		 * 
		 * <p>To restrict the message to only be sent to a subset of users,
		 * specify an array of user guids as the second parameter</p>
		 *  
		 * @param message an AMF3-serializable object
		 * @param toUserGuids (optional) an array of user guids to which the message should be sent
		 * @productversion Worlize APIv.1
		 * @see RoomObject#sendMessage()
		 * @example A color-picker app broadcasts the chosen color to any other app that might be interested, for all users in the room.
		 * <listing version="3.0">
		 * 
		 * var api:WorlizeAPI = WorlizeAPI.getInstance();
		 * 
		 * var myNewColor:uint = 0xFF0000; // Replace with color from picker
		 * var message:Object = {
		 *     name: "colorSelected",
		 *     color: myNewColor
		 * };
		 * api.thisRoom.broadcastMessage(message);
		 * 
		 * </listing>
		 */		
		public function broadcastMessage(message:Object, toUserGuids:Array = null):void {
			var event:APIEvent = new APIEvent(APIEvent.SEND_APP_MESSAGE);
			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.BIG_ENDIAN;
			byteArray.writeObject(message);
			byteArray.position = 0;
			event.data = {
				message: byteArray
			};
			if (toUserGuids) {
				event.data.toUserGuids = toUserGuids;
			}
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		/**
		 * Send a message to all objects in the room for only the current user.
		 * 
		 * <p>Like <code>broadcastMessage()</code> but the message is not
		 * routed through the server and is delivered only to objects running
		 * on the current user's machine.</p>
		 * 
		 * @param message an AMF3-serializable object
		 * @productversion Worlize APIv.1
		 * @see RoomObject#sendMessageLocal()
		 * @example A color-picker app broadcasts the chosen color to any other app that might be interested, for only the current user.
		 * <listing version="3.0">
		 * 
		 * var api:WorlizeAPI = WorlizeAPI.getInstance();
		 * 
		 * var myNewColor:uint = 0xFF0000; // Replace with color from picker
		 * var message:Object = {
		 *     name: "colorSelected",
		 *     color: myNewColor
		 * };
		 * api.thisRoom.broadcastMessageLocal(message);
		 * 
		 * </listing>
		 */		
		public function broadcastMessageLocal(message:Object):void {
			var event:APIEvent = new APIEvent(APIEvent.SEND_APP_MESSAGE_LOCAL);
			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.BIG_ENDIAN;
			byteArray.writeObject(message);
			byteArray.position = 0;
			event.data = {
				message: byteArray
			};
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		/**
		 * Look up a <code>User</code> object by GUID.
		 *  
		 * @param guid the user's guid
		 * @return a <code>User</code> object
		 * @productversion Worlize APIv.1
		 */		
		public function getUserByGuid(guid:String):User {
			for each (var user:User in _users) {
				if (user.guid === guid) {
					return user;
				}
			}
			return null;
		}
		
		/**
		 * Look up a <code>RoomObject</code> object by its
		 * <code>instanceGuid</code>.
		 *  
		 * @param guid the object's instanceGuid
		 * @return a <code>RoomObject</code> object
		 * @productversion Worlize APIv.1
		 */		
		public function getObjectByGuid(guid:String):RoomObject {
			for each (var obj:RoomObject in _objects) {
				if (obj.instanceGuid === guid) {
					return obj;
				}
			}
			return null;
		}
		
		/**
		 * Look up a <code>LooseProp</code> object by its <code>id</code>.
		 *  
		 * @param id the loose prop's id
		 * @return a <code>LooseProp</code> object
		 * 
		 * @see com.worlize.model.LooseProp#id
		 * 
		 * @productversion Worlize APIv.2
		 */
		public function getLoosePropById(id:uint):LooseProp {
			return LooseProp(_loosePropsById[id]);
		}
		
		/**
		 * Add a new loose prop to the room.
		 * 
		 * <p>This does not immediately add the new loose prop, but rather
		 * sends the request to the server to have the new loose prop added.
		 * The new prop will trigger a <code>LoosePropEvent.PROP_ADDED</code>
		 * event once the server update is received.</p>
		 * 
		 * @param propGuid the GUID of the prop you would like to add
		 * @param x the horizonal position of the center of the prop in the room
		 * @param y the vertical position of the center of the prop in the room
		 * 
		 * @see #event:propAdded propAdded event
		 * @see com.worlize.api.model.LooseProp#remove()
		 * 
		 * @productversion Worlize APIv.2
		 */			
		public function addLooseProp(propGuid:String, x:int, y:int):void {
			var event:APIEvent = new APIEvent(APIEvent.ADD_LOOSE_PROP);
			event.data = {
				guid: propGuid,
				x: x,
				y: y
			};
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		/**
		 * Remove all loose props from the room.
		 * 
		 * <p>This does not immediately remove the loose props, but rather
		 * sends the request to the server to have the loose props removed.
		 * The props will be cleared once confirmation has been received from
		 * the server, and a <code>LoosePropEvent.PROPS_CLEARED</code> event
		 * will be dispatched, after dispatching a
		 * <code>LoosePropEvent.PROP_REMOVED</code> event for each loose prop
		 * that was in the room.</p> 
		 * 
		 * @see #event:propsCleared propsCleared event
		 * @see #event:propRemoved propRemoved event
		 * @see com.worlize.api.model.LooseProp#remove()
		 * 
		 * @productversion Worlize APIv.2
		 */		
		public function clearLooseProps():void {
			var event:APIEvent = new APIEvent(APIEvent.CLEAR_LOOSE_PROPS);
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}

		
		/**
		 * @private
		 */		
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
			
			
			return obj;
		}
		
		/**
		 * @private
		 */		
		override public function toString():String {
			return "[ThisRoom guid=" + _guid + " name=" + _name + "]";
		}
		
		private function redispatchUserEvent(event:UserEvent):void {
			dispatchEvent(event);
		}
		
		private function redispatchRoomObjectEvent(event:RoomObjectEvent):void {
			dispatchEvent(event);
		}
		
		private function redispatchLoosePropEvent(event:LoosePropEvent):void {
			dispatchEvent(event);
		}
		
		/**
		 * @private
		 */		
		worlize_internal function addObject(obj:RoomObject):void {
			_objects.push(obj);
			addRoomObjectEventListeners(obj);
		}
		
		/**
		 * @private
		 */		
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
		
		/**
		 * @private
		 */		
		worlize_internal function addUser(user:User):void {
			_users.push(user);
			addUserEventListeners(user);
		}
		
		/**
		 * @private
		 */		
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
			user.addEventListener(UserEvent.USER_AVATAR_CHANGED, redispatchUserEvent);
			user.addEventListener(UserEvent.USER_BALLOON_COLOR_CHANGED, redispatchUserEvent);
			user.addEventListener(UserEvent.USER_COLOR_CHANGED, redispatchUserEvent);
			user.addEventListener(UserEvent.USER_MOVED, redispatchUserEvent);
			user.addEventListener(UserEvent.USER_PRIVILEGES_CHANGED, redispatchUserEvent);
		}
		
		private function removeUserEventListeners(user:User):void {
			user.removeEventListener(UserEvent.USER_AVATAR_CHANGED, redispatchUserEvent);
			user.removeEventListener(UserEvent.USER_BALLOON_COLOR_CHANGED, redispatchUserEvent);
			user.removeEventListener(UserEvent.USER_COLOR_CHANGED, redispatchUserEvent);
			user.removeEventListener(UserEvent.USER_MOVED, redispatchUserEvent);
			user.removeEventListener(UserEvent.USER_PRIVILEGES_CHANGED, redispatchUserEvent);
		}
		
		private function addRoomObjectEventListeners(obj:RoomObject):void {
			obj.addEventListener(RoomObjectEvent.OBJECT_MOVED, redispatchRoomObjectEvent);
			obj.addEventListener(RoomObjectEvent.OBJECT_RESIZED, redispatchRoomObjectEvent);
			obj.addEventListener(RoomObjectEvent.OBJECT_STATE_CHANGED, redispatchRoomObjectEvent);
		}
		
		private function removeRoomObjectEventListeners(obj:RoomObject):void {
			obj.removeEventListener(RoomObjectEvent.OBJECT_MOVED, redispatchRoomObjectEvent);
			obj.removeEventListener(RoomObjectEvent.OBJECT_RESIZED, redispatchRoomObjectEvent);
			obj.removeEventListener(RoomObjectEvent.OBJECT_STATE_CHANGED, redispatchRoomObjectEvent);
		}
		
		private function addLoosePropEventListeners(looseProp:LooseProp):void {
			looseProp.addEventListener(LoosePropEvent.PROP_LAYER_CHANGED, redispatchLoosePropEvent);
			looseProp.addEventListener(LoosePropEvent.PROP_MOVED, redispatchLoosePropEvent);
		}
		
		private function removeLoosePropEventListeners(looseProp:LooseProp):void {
			looseProp.removeEventListener(LoosePropEvent.PROP_LAYER_CHANGED, redispatchLoosePropEvent);
			looseProp.removeEventListener(LoosePropEvent.PROP_MOVED, redispatchLoosePropEvent);
		}
		
		/**
		 * @private
		 */		
		worlize_internal static function fromData(data:Object, thisUser:ThisUser, thisObject:ThisRoomObject):ThisRoom {
			var room:ThisRoom = new ThisRoom();
			room._guid = data.guid;
			room._name = data.name;
			room._width = data.width;
			room._height = data.height;
			room._ownerGuid = data.ownerGuid;
			room._locked = data.locked;
			
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
			
			for each (var loosePropData:Object in data.looseProps) {
				var looseProp:LooseProp = LooseProp.fromData(loosePropData);
				room.doAddLooseProp(looseProp);
			}
			
			return room;
		}
		
		/**
		 * @private
		 */		
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
		
		/**
		 * @private
		 */		
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
		
		/**
		 * @private
		 */		
		worlize_internal function addSharedEventHandlers(sharedEvents:EventDispatcher):void {
			sharedEvents.addEventListener('host_roomMouseMove', handleRoomMouseMove);
			sharedEvents.addEventListener('host_chatEvent', handleChat);
			sharedEvents.addEventListener('host_userEntered', handleUserEnter);
			sharedEvents.addEventListener('host_userLeft', handleUserLeave);
			sharedEvents.addEventListener('host_allUsersLeft', handleAllUsersLeft);
			sharedEvents.addEventListener('host_userMoved', handleUserMoved);
			sharedEvents.addEventListener('host_userAvatarChanged', handleUserAvatarChanged);
			sharedEvents.addEventListener('host_userColorChanged', handleUserColorChanged);
			sharedEvents.addEventListener('host_userBalloonColorChanged', handleUserBalloonColorChanged);
			sharedEvents.addEventListener('host_userPrivilegesChanged', handleUserPrivilegesChanged);
			sharedEvents.addEventListener('host_roomDimLevelChanged', handleRoomDimLevelChanged);
			sharedEvents.addEventListener('host_roomLockedChanged', handleRoomLockedChanged);
			sharedEvents.addEventListener('host_roomObjectAdded', handleObjectAdded);
			sharedEvents.addEventListener('host_roomObjectRemoved', handleObjectRemoved);
			sharedEvents.addEventListener('host_roomObjectMoved', handleObjectMoved);
			sharedEvents.addEventListener('host_roomObjectResized', handleObjectResized);
			sharedEvents.addEventListener('host_roomObjectStateChanged', handleObjectStateChanged);
			sharedEvents.addEventListener('host_loosePropAdded', handleLoosePropAdded);
			sharedEvents.addEventListener('host_loosePropRemoved', handleLoosePropRemoved);
			sharedEvents.addEventListener('host_loosePropMoved', handleLoosePropMoved);
			sharedEvents.addEventListener('host_loosePropBroughtForward', handleLoosePropBroughtForward);
			sharedEvents.addEventListener('host_loosePropSentBackward', handleLoosePropSentBackward);
			sharedEvents.addEventListener('host_loosePropsReset', handleLoosePropsReset);
			sharedEvents.addEventListener('host_roomNameChanged', handleRoomNameChanged);
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
		
		private function handleRoomLockedChanged(event:Event):void {
			var data:Object = event['data'];
			var newValue:Boolean = data.locked;
			var roomEvent:RoomEvent;
			if (_locked !== newValue) {
				_locked = newValue;
				if (_locked) {
					roomEvent = new RoomEvent(RoomEvent.LOCKED);
				}
				else {
					roomEvent = new RoomEvent(RoomEvent.UNLOCKED);
				}
				roomEvent.user = getUserByGuid(data.user);
				if (!roomEvent.user) {
					roomEvent.user = User.fromData({
						name: "Unknown User",
						guid: data.user,
						privileges: [],
						x: 0,
						y:0,
						face:0,
						color:0
					});
				}
				dispatchEvent(roomEvent);
			}
		}
		
		private function handleChat(event:Event):void {
			var e:Object = event;
			
			var type:String = (e.data.type === "incomingChat") ? ChatEvent.INCOMING_CHAT : ChatEvent.OUTGOING_CHAT;
			var chatEvent:ChatEvent = new ChatEvent(type);
			chatEvent.text = e.data.text;
			chatEvent.originalText = e.data.originalText;
			chatEvent.isWhisper = e.data.isWhisper;
			if (e.data.recipient) {
				chatEvent.recipient = getUserByGuid(e.data.recipient);
			}
			if (e.data.user) {
				chatEvent.user = getUserByGuid(e.data.user);
			}
			
			if (!dispatchEvent(chatEvent)) {
				event.preventDefault();
			}
			
			e.data.text = chatEvent.text;
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
		
		private function handleUserColorChanged(event:Event):void {
			var eo:Object = event;
			var user:User = getUserByGuid(eo.data.userGuid);
			if (user) {
				user.updateColor(eo.data.color);
			}
		}
		
		private function handleUserBalloonColorChanged(event:Event):void {
			var eo:Object = event;
			var user:User = getUserByGuid(eo.data.userGuid);
			if (user) {
				user.updateBalloonColor(eo.data.color);
			}
		}
		
		private function handleUserPrivilegesChanged(event:Event):void {
			var eo:Object = event;
			var user:User = getUserByGuid(eo.data.userGuid);
			if (user) {
				user.updatePrivileges(eo.data.privileges);
			}
		}
		
		private function handleRoomDimLevelChanged(event:Event):void {
			var eo:Object = event;
			_dimLevel = eo.data.dimLevel;
		}
		
		private function handleObjectAdded(event:Event):void {
			var obj:RoomObject = RoomObject.fromData(event['data'].roomObject);
			addObject(obj);
			var addedEvent:RoomEvent = new RoomEvent(RoomEvent.OBJECT_ADDED);
			addedEvent.roomObject = obj;
			dispatchEvent(addedEvent);
		}
		
		private function handleObjectRemoved(event:Event):void {
			var obj:RoomObject = removeObject(event['data'].guid);
			if (obj !== null) {
				var removedEvent:RoomEvent = new RoomEvent(RoomEvent.OBJECT_REMOVED);
				removedEvent.roomObject = obj;
				dispatchEvent(removedEvent);
			}
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
		
		private function handleObjectStateChanged(event:Event):void {
			var eo:Object = event;
			var roomObj:RoomObject = getObjectByGuid(eo.data.guid);
			if (roomObj) {
				roomObj.updateState(eo.data.state);
			}
		}
		
		private function handleLoosePropAdded(event:Event):void {
			var eo:Object = event;
			var looseProp:LooseProp = LooseProp.fromData(eo.data);
			
			doAddLooseProp(looseProp);
			
			var propEvent:LoosePropEvent = new LoosePropEvent(LoosePropEvent.PROP_ADDED);
			propEvent.looseProp = looseProp;
			dispatchEvent(propEvent);
		}
		
		private function handleLoosePropRemoved(event:Event):void {
			var eo:Object = event;
			var id:uint = eo.data;
			var looseProp:LooseProp = _loosePropsById[id];
			if (looseProp) {
				doRemoveLooseProp(looseProp);
			}
		}
		
		private function doAddLooseProp(looseProp:LooseProp):void {
			_loosePropsById[looseProp.id] = looseProp;
			_looseProps.push(looseProp);
			addLoosePropEventListeners(looseProp);
		}
		
		private function doRemoveLooseProp(looseProp:LooseProp):void {
			delete _loosePropsById[looseProp.id];
			var index:int = _looseProps.indexOf(looseProp);
			if (index !== -1) {
				_looseProps.splice(index, 1);
			}
			removeLoosePropEventListeners(looseProp);
			var propEvent:LoosePropEvent = new LoosePropEvent(LoosePropEvent.PROP_REMOVED);
			propEvent.looseProp = looseProp;
			dispatchEvent(propEvent);
		}
		
		private function handleLoosePropMoved(event:Event):void {
			var eo:Object = event;
			var id:uint = eo.data.id;
			var looseProp:LooseProp = _loosePropsById[id];
			if (looseProp) {
				looseProp.updatePosition(eo.data.x, eo.data.y);
			}
		}
		
		private function handleLoosePropBroughtForward(event:Event):void {
			var eo:Object = event;
			var id:uint = eo.data.id;
			var looseProp:LooseProp = _loosePropsById[id];
			if (looseProp) {
				var index:int = _looseProps.indexOf(looseProp);
				if (index !== -1) {
					var newidx:int = index + eo.data.layerCount;
					_looseProps.splice(index, 1);
					_looseProps.splice(newidx, 0, looseProp);
					var propEvent:LoosePropEvent = new LoosePropEvent(LoosePropEvent.PROP_LAYER_CHANGED);
					propEvent.looseProp = looseProp;
					propEvent.oldIndex = index;
					propEvent.newIndex = newidx;
					propEvent.delta = newidx - index;
					looseProp.dispatchEvent(propEvent);
				}
			}
		}
		
		private function handleLoosePropSentBackward(event:Event):void {
			var eo:Object = event;
			var id:uint = eo.data.id;
			var looseProp:LooseProp = _loosePropsById[id];
			if (looseProp) {
				var index:int = _looseProps.indexOf(looseProp);
				if (index !== -1) {
					var newidx:int = index - eo.data.layerCount;
					_looseProps.splice(index, 1);
					_looseProps.splice(newidx, 0, looseProp);
					var propEvent:LoosePropEvent = new LoosePropEvent(LoosePropEvent.PROP_LAYER_CHANGED);
					propEvent.looseProp = looseProp;
					propEvent.oldIndex = index;
					propEvent.newIndex = newidx;
					propEvent.delta = newidx - index;
					looseProp.dispatchEvent(propEvent);
				}
			}
		}
		
		private function handleLoosePropsReset(event:Event):void {
			for each (var looseProp:LooseProp in _looseProps) {
				doRemoveLooseProp(looseProp);
			}
			var propEvent:LoosePropEvent = new LoosePropEvent(LoosePropEvent.PROPS_CLEARED);
			dispatchEvent(propEvent);
		}
		
		private function handleRoomNameChanged(event:Event):void {
			var data:Object = (event as Object).data;
			if (data.guid && data.name) {
				if (_guid === data.guid) {
					_name = data.name;
					var roomEvent:RoomEvent = new RoomEvent(RoomEvent.NAME_CHANGED);
					dispatchEvent(roomEvent);
				}
			}
		}
	}
}