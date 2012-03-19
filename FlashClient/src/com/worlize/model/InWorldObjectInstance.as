package com.worlize.model
{
	import com.worlize.event.NotificationCenter;
	import com.worlize.interactivity.event.RoomEvent;
	import com.worlize.notification.InWorldObjectNotification;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	
	import mx.events.FlexEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;
	import mx.utils.object_proxy;

	[Bindable]
	public class InWorldObjectInstance extends EventDispatcher
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_LOAD_ERROR:String = "loadError";
		public static const STATE_READY:String = "ready";
		public static const STATE_HANDSHAKING:String = "handshaking";
		public static const STATE_UNLOADING:String = "unloading";
		public static const STATE_UNLOADED:String = "unloaded";
		public static const STATE_BOMBED:String = "bombed";
		
		private var _state:String = STATE_INIT;
		public var inWorldObject:InWorldObject;
		public var guid:String;
		public var x:int;
		public var y:int;
		public var width:Number;
		public var height:Number;
		public var room:RoomListEntry;
		public var dest:String;
		public var emptySlot:Boolean = false;
		
		public var stateHistory:Array;
		
		public var sizedByScript:Boolean = false;
		
		[Bindable(event="stateChanged")]
		public function get state():String {
			return _state;
		}
		public function set state(newValue:String):void {
			if (_state !== newValue) {
				_state = newValue;
				dispatchEvent(new FlexEvent('stateChanged'));
				var event:RoomEvent = new RoomEvent(RoomEvent.OBJECT_STATE_CHANGED);
				event.roomObject = this;
				dispatchEvent(event);
			}
		}
		
		public static function fromData(data:Object):InWorldObjectInstance {
			var object:InWorldObjectInstance = new InWorldObjectInstance();
			object.guid = data.guid;
			object.inWorldObject = InWorldObject.fromData(data.in_world_object);
			if (data.room) {
				object.room = new RoomListEntry();
				object.room.name = data.room.name;
				object.room.guid = data.room.guid;
			}
			object.emptySlot = false;
			return object;
		}
		
		public function moveLocal(x:int, y:int):void {
			this.x = x;
			this.y = y;
			var event:RoomEvent = new RoomEvent(RoomEvent.OBJECT_MOVED);
			event.roomObject = this;
			dispatchEvent(event);
		}
		
		public function resizeLocal(width:int, height:int):void {
			if (this.width !== width || this.height !== height) {
				this.width = width;
				this.height = height;
				var event:RoomEvent = new RoomEvent(RoomEvent.OBJECT_RESIZED);
				event.roomObject = this;
				dispatchEvent(event);
			}
		}
		
		public function requestDelete():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleDeleteResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send("/locker/in_world_objects/" + guid + ".json", HTTPMethod.DELETE);
		}
		
		private function handleFault(event:FaultEvent):void {
			var logger:ILogger = Log.getLogger("com.worlize.model.InWorldObjectInstance");
			logger.error("Object Delete Failed. " + event);
		}
		
		private function handleDeleteResult(event:WorlizeResultEvent):void {
			var notification:InWorldObjectNotification = new InWorldObjectNotification(InWorldObjectNotification.IN_WORLD_OBJECT_INSTANCE_DELETED);
			notification.deletedInstanceGuid = guid;
			NotificationCenter.postNotification(notification);
		}

	}
}