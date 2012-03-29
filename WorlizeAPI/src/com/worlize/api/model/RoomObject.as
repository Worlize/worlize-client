package com.worlize.api.model
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.APIEvent;
	import com.worlize.api.event.RoomObjectEvent;
	import com.worlize.worlize_internal;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * Dispatched after the object has been resized.
	 * 
	 * @eventType com.worlize.api.event.RoomObjectEvent.OBJECT_RESIZED
	 * @productversion Worlize API.v1 
	 */	
	[Event(name="objectResized",type="com.worlize.api.event.RoomObjectEvent")]
	
	/**
	 * Dispatched after the object has been moved.
	 * 
	 * @eventType com.worlize.api.event.RoomObjectEvent.OBJECT_MOVED
	 * @productversion Worlize API.v1 
	 */	
	[Event(name="objectMoved",type="com.worlize.api.event.RoomObjectEvent")]
	
	/**
	 * Dispatched after the object has changed state.
	 * 
	 * @eventType com.worlize.api.event.RoomObjectEvent.OBJECT_STATE_CHANGED
	 * @productversion Worlize API.v1 
	 */	
	[Event(name="objectStateChanged",type="com.worlize.api.event.RoomObjectEvent")]
	
	/**
	 * Represents a Worlize Object (app) in the current room.
	 * 
	 * @author Brian McKelvey
	 * @productversion Worlize APIv.1
	 * 
	 * @see com.worlize.api.model.ThisRoomObject
	 * @see com.worlize.api.model.ThisRoom
	 */	
	public class RoomObject extends EventDispatcher
	{
		use namespace worlize_internal;
		
		/**
		 * @private 
		 */		
		protected var _instanceGuid:String;
		
		/**
		 * @private 
		 */		
		protected var _state:String;
		
		/**
		 * @private 
		 */
		protected var _guid:String;
		
		/**
		 * @private 
		 */
		protected var _name:String;
		
		/**
		 * @private 
		 */
		protected var _identifier:String;
		
		/**
		 * @private 
		 */
		protected var _creatorGuid:String;
		
		/**
		 * @private 
		 */
		protected var _destinationRoomGuid:String;
		
		/**
		 * @private 
		 */
		protected var _width:Number;
		
		/**
		 * @private 
		 */
		protected var _height:Number;
		
		/**
		 * @private 
		 */
		protected var _x:Number;
		
		/**
		 * @private 
		 */
		protected var _y:Number;
		
		/**
		 * @private
		 */		
		public function toJSON():Object {
			return {
				instanceGuid: _instanceGuid,
				state: _state,
				guid: _guid,
				name: _name,
				identifier: _identifier,
				creatorGuid: _creatorGuid,
				destinationRoomGuid: _destinationRoomGuid,
				width: _width,
				height: _height,
				x: _x,
				y: _y
			};
		}
		
		/**
		 * Constructor. 
		 * 
		 * @productversion Worlize API.v1
		 */		
		public function RoomObject() {
			super(null);
		}
		
		/**
		 * This Object Instance's Globally Unique Identifier
		 * 
		 * <p>The <code>instanceGuid</code> represents this specific instance
		 * of the object (app).  This is as opposed to the <code>guid</code>
		 * property which will be the same for every instance of the given
		 * app.</p>
		 * 
		 * <p>For example, if you create a checkers game to sell in the
		 * app store and 5,000 people buy it and place it into rooms,
		 * each of those 5,000 instances will have a unique
		 * <code>instanceGuid</code> but will share the same <code>guid</code>.
		 * </p>
		 * 
		 * <p>Any persistent data, such as is stored by the
		 * <code>ConfigData</code> class, is keyed based on the
		 * <code>instanceGuid</code> and so will be unique to that particular
		 * instance.</p>
		 *  
		 * @return object instance guid
		 * @see http://en.wikipedia.org/wiki/GUID GUID on Wikipedia
		 * @see #guid
		 * @productversion Worlize APIv.1
		 */		
		public function get instanceGuid():String {
			return _instanceGuid;
		}
		
		public function get state():String {
			return _state;
		}
		
		/**
		 * The Object's Globally Unique Identifier
		 * 
		 * <p>The <code>guid</code> represents the object definition's guid
		 * which is the same across all instances of the object (app).
		 * This is as opposed to the <code>instanceGuid</code> property, which
		 * will be unique for each instance of the object (app).</p>
		 * 
		 * <p>For example, if you create a checkers game to sell in the
		 * app store and 5,000 people buy it and place it into rooms,
		 * each of those 5,000 instances will have a unique
		 * <code>instanceGuid</code> but will share the same <code>guid</code>.
		 * </p>
		 *  
		 * @return the object definition GUID
		 * @see #instanceGuid
		 * @see http://en.wikipedia.org/wiki/GUID GUID on Wikipedia
		 * @productversion Worlize APIv.1
		 */		
		public function get guid():String {
			return _guid;
		}
		
		/**
		 * The given name of the object.
		 * 
		 * <p>This is the name that the app author
		 * chose for the object when publishing the app, by setting the
		 * static <code>APIOptions.name</code> property before app
		 * initialization.</p>
		 *  
		 * @return the object name
		 * @see com.worlize.api.APIOptions#name
		 * @productversion Worlize API.v1
		 */		
		public function get name():String {
			return _name;
		}
		
		/**
		 * The text identifier that the user chose for this object within the
		 * room.
		 * 
		 * <p>The user can choose to assign a text identifier to objects
		 * in their rooms.  To do so, in Author mode select an object (app)
		 * and enter an identifier in the Object Properties panel.</p>
		 * 
		 * <p><em>Not yet implemented.</em></p>
		 *  
		 * @return the app's given identifier within the room
		 * @productversion Worlize API.v1
		 */		
		public function get identifier():String {
			return _identifier;
		}
		
		/**
		 * The GUID of the "destination" room chosen by the user for this
		 * object within the room.
		 *  
		 * @return the destination room guid 
		 * @see com.worlize.api.model.ThisRoom#gotoRoom()
		 * @productversion Worlize API.v1
		 */		
		public function get destinationRoomGuid():String {
			return _destinationRoomGuid;
		}
		
		/**
		 * The GUID of the user who originally uploaded this app and/or
		 * published it in the app store.
		 *  
		 * @return the app creator's user GUID 
		 * @see com.worlize.api.model.User#guid
		 * @see http://en.wikipedia.org/wiki/GUID GUID on Wikipedia
		 * @productversion Worlize API.v1
		 */		
		public function get creatorGuid():String {
			return _creatorGuid;
		}
		
		/**
		 * The current width of the object (app) in pixels.
		 *  
		 * @return width in pixels
		 * @productversion Worlize API.v1
		 */		
		public function get width():Number {
			return _width;
		}
		
		/**
		 * The current height of the object (app) in pixels.
		 * 
		 * @return height in pixels
		 * @productversion Worlize API.v1
		 */		
		public function get height():Number {
			return _height;
		}
		
		/**
		 * The horizontal position of the top-left corner of the object (app)
		 * in pixels.
		 * 
		 * <p>The number is relative to the room's coordinate space.</p>
		 *  
		 * @return the app's horizontal position
		 * @productversion Worlize API.v1
		 */		
		public function get x():Number {
			return _x;
		}
		
		/**
		 * The vertical position of the top-left corner of the object (app)
		 * in pixels.
		 * 
		 * <p>The number is relative to the room's coordinate space.</p>
		 *  
		 * @return the app's vertical position
		 * @productversion Worlize API.v1
		 */		
		public function get y():Number {
			return _y;
		}
		
		/**
		 * Sends a message to the object (app) via the server.
		 * 
		 * <p>This method can be used for updating state across multiple
		 * connected clients or for inter-app messaging.</p>
		 * 
		 * <p>A <code>messageReceived</code> event will be emitted in all the
		 * apps that receive the message</p>
		 * 
		 * @param message any AMF3-serializable object
		 * @param toUserGuids (optional) an array of user guids to restrict
		 * which users will receive the message. Pass <code>null</code> to send
		 * the message to all users in the room.
		 * 
		 * @see com.worlize.api.model.ThisRoomObject#event:messageReceived
		 *      messageReceived event
		 * @see #sendMessageLocal()
		 * @see com.worlize.api.model.ThisRoom#broadcast()
		 * @productversion Worlize API.v1
		 */		
		public function sendMessage(message:Object, toUserGuids:Array = null):void {
			var event:APIEvent = new APIEvent(APIEvent.SEND_APP_MESSAGE);
			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.BIG_ENDIAN;
			byteArray.writeObject(message);
			byteArray.position = 0;
			event.data = {
				message: byteArray,
				toAppInstanceGuid: _instanceGuid
			};
			if (toUserGuids) {
				event.data.toUserGuids = toUserGuids;
			}
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		/**
		 * Sends a message to the object (app) only for the current user.
		 * 
		 * <p>This method can be used for inter-app messaging.</p>
		 * 
		 * <p>A <code>messageReceived</code> event will be emitted in all the
		 * apps that receive the message</p>
		 * 
		 * <p>This is similar to the <code>sendMessage</code> except that the
		 * message is not routed through the server and instead is delivered
		 * directly to the given app on the local machine only.</p>
		 * 
		 * @param message any AMF3-serializable object
		 * 
		 * @see com.worlize.api.model.ThisRoomObject#event:messageReceived
		 *      messageReceived event
		 * @see #sendMessage()
		 * @see com.worlize.api.model.ThisRoom#broadcastLocal()
		 * @productversion Worlize API.v1
		 */		
		public function sendMessageLocal(message:Object):void {
			var event:APIEvent = new APIEvent(APIEvent.SEND_APP_MESSAGE_LOCAL);
			var byteArray:ByteArray = new ByteArray();
			byteArray.endian = Endian.BIG_ENDIAN;
			byteArray.writeObject(message);
			byteArray.position = 0;
			event.data = {
				message: byteArray,
				toAppInstanceGuid: _instanceGuid
			};
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		/**
		 * @private
		 */		
		override public function toString():String {
			return "[RoomObject instanceGuid=" + _instanceGuid + " guid=" + _guid + " identifier=" + _identifier + "]";
		}
		
		/**
		 * @private
		 */		
		worlize_internal function updatePosition(x:Number, y:Number):void {
			if (_x !== x || _y !== y) {
				_x = x;
				_y = y;
				var event:RoomObjectEvent = new RoomObjectEvent(RoomObjectEvent.OBJECT_MOVED);
				event.roomObject = this;
				dispatchEvent(event);
			}
		}
		
		/**
		 * @private
		 */		
		worlize_internal function updateSize(width:Number, height:Number):void {
			if (_width !== width || _height !== height) {
				_width = width;
				_height = height;
				var event:RoomObjectEvent = new RoomObjectEvent(RoomObjectEvent.OBJECT_RESIZED);
				event.roomObject = this;
				dispatchEvent(event);
			}
		}
		
		/**
		 * @private
		 */		
		worlize_internal function updateState(state:String):void {
			if (_state !== state) {
				_state = state;
				var event:RoomObjectEvent = new RoomObjectEvent(RoomObjectEvent.OBJECT_STATE_CHANGED);
				event.roomObject = this;
				dispatchEvent(event);
			}
		}
		
		/**
		 * @private
		 */		
		worlize_internal static function fromData(data:Object):RoomObject {
			var obj:RoomObject = new RoomObject();
			obj._instanceGuid = data.instanceGuid;
			obj._state = data.state;
			obj._guid = data.guid;
			obj._name = data.name;
			obj._identifier = data.identifier;
			obj._creatorGuid = data.creatorGuid;
			obj._width = data.width;
			obj._height = data.height;
			obj._x = data.x;
			obj._y = data.y;
			return obj;
		}
	}
}