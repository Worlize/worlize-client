package com.worlize.api.model
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.APIEvent;
	import com.worlize.worlize_internal;
	
	[Event(name="messageReceived",type="com.worlize.api.event.MessageEvent")]
	[Event(name="objectResized",type="com.worlize.api.event.RoomObjectEvent")]
	[Event(name="objectMoved",type="com.worlize.api.event.RoomObjectEvent")]
	public class ThisRoomObject extends RoomObject
	{
		use namespace worlize_internal;
		
		public function set x(newValue:Number):void {
			moveTo(newValue, _y);
		}
		
		public function set y(newValue:Number):void {
			moveTo(_x, newValue);
		}
		
		public function set width(newValue:Number):void {
			setSize(newValue, _height);
		}
		
		public function set height(newValue:Number):void {
			setSize(_width, newValue);
		}
		
		public function moveTo(x:Number, y:Number):void {
			var event:APIEvent = new APIEvent(APIEvent.MOVE_OBJECT);
			event.data = {
				x: x,
				y: y
			};
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		public function setSize(width:Number, height:Number):void {
			if (_width !== width || _height !== height) {
				var event:APIEvent = new APIEvent(APIEvent.RESIZE_OBJECT);
				event.data = {
					width: width,
					height: height
				};
				WorlizeAPI.sharedEvents.dispatchEvent(event);
			}
		}
		
		worlize_internal static function fromData(data:Object):ThisRoomObject {
			var obj:ThisRoomObject = new ThisRoomObject();
			obj._instanceGuid = data.instanceGuid;
			obj._state = data.state;
			obj._guid = data.guid;
			obj._name = data.name;
			obj._identifier = data.identifier;
//			obj._creatorGuid = data.creatorGuid;
			obj._width = data.width;
			obj._height = data.height;
			obj._x = data.x;
			obj._y = data.y;
			return obj;
		}
	}
}