package com.worlize.api.model
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.APIEvent;
	import com.worlize.api.event.RoomObjectEvent;
	import com.worlize.worlize_internal;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	[Event(name="objectResized",type="com.worlize.api.event.RoomObjectEvent")]
	[Event(name="objectMoved",type="com.worlize.api.event.RoomObjectEvent")]
	public class RoomObject extends EventDispatcher
	{
		use namespace worlize_internal;
		
		protected var _instanceGuid:String;
		protected var _guid:String;
		protected var _name:String;
		protected var _identifier:String;
		protected var _creatorGuid:String;
		protected var _destinationRoomGuid:String;
		protected var _width:Number;
		protected var _height:Number;
		protected var _x:Number;
		protected var _y:Number;
		
		public function toJSON():Object {
			return {
				instanceGuid: _instanceGuid,
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
		
		public function RoomObject() {
			super(null);
		}
		
		public function get instanceGuid():String {
			return _instanceGuid;
		}
		
		public function get guid():String {
			return _guid;
		}
		
		public function get name():String {
			return _name;
		}
		
		public function get identifier():String {
			return _identifier;
		}
		
		public function get destinationRoomGuid():String {
			return _destinationRoomGuid;
		}
		
		public function get creatorGuid():String {
			return _creatorGuid;
		}
		
		public function get width():Number {
			return _width;
		}
		
		public function get height():Number {
			return _height;
		}
		
		public function get x():Number {
			return _x;
		}
		
		public function get y():Number {
			return _y;
		}
		
		public function sendMessage(message:String, toUserGuid:String = null):void {
			var event:APIEvent = new APIEvent(APIEvent.SEND_OBJECT_MESSAGE);
			event.data = {
				message: message,
				toObjectGuid: _instanceGuid
			};
			if (toUserGuid) {
				event.data.toUserGuid = toUserGuid;
			}
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		public function sendMessageLocal(message:String):void {
			var event:APIEvent = new APIEvent(APIEvent.SEND_OBJECT_MESSAGE_LOCAL);
			event.data = {
				message: message,
				toObjectGuid: _instanceGuid
			};
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		override public function toString():String {
			return "[RoomObject instanceGuid=" + _instanceGuid + " guid=" + _guid + " identifier=" + _identifier + "]";
		}
		
		worlize_internal function updatePosition(x:Number, y:Number):void {
			_x = x;
			_y = y;
			var event:RoomObjectEvent = new RoomObjectEvent(RoomObjectEvent.MOVED);
			event.roomObject = this;
			dispatchEvent(event);
		}
		
		worlize_internal function updateSize(width:Number, height:Number):void {
			_width = width;
			_height = height;
			var event:RoomObjectEvent = new RoomObjectEvent(RoomObjectEvent.RESIZED);
			event.roomObject = this;
			dispatchEvent(event);
		}
		
		worlize_internal static function fromData(data:Object):RoomObject {
			var obj:RoomObject = new RoomObject();
			obj._instanceGuid = data.instanceGuid;
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