package com.worlize.model
{
	import com.worlize.event.NotificationCenter;
	import com.worlize.interactivity.event.RoomEvent;
	import com.worlize.interactivity.model.ILinkableRoomItem;
	import com.worlize.interactivity.model.IRoomItem;
	import com.worlize.interactivity.rpc.InteractivityClient;
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
	public class InWorldObjectInstance extends EventDispatcher implements ILinkableRoomItem
	{
		public var inWorldObject:InWorldObject;
		public var guid:String;
		public var x:int;
		public var y:int;
		public var width:Number;
		public var height:Number;
		public var room:RoomListEntry;
		public var dest:String;
		public var emptySlot:Boolean = false;
		
		public static function fromLockerData(data:Object):InWorldObjectInstance {
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
			var event:RoomEvent = new RoomEvent(RoomEvent.ITEM_MOVED);
			event.roomItem = this;
			dispatchEvent(event);
		}
		
		public function resizeLocal(width:int, height:int):void {
			if (this.width !== width || this.height !== height) {
				this.width = width;
				this.height = height;
				var event:RoomEvent = new RoomEvent(RoomEvent.ITEM_RESIZED);
				event.roomItem = this;
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
			notification.instanceGuid = guid;
			NotificationCenter.postNotification(notification);
		}

		public static function fromData(objectData:Object):InWorldObjectInstance {
			var inWorldObjectInstance:InWorldObjectInstance = new InWorldObjectInstance();
			inWorldObjectInstance.guid = objectData.guid;
			inWorldObjectInstance.x = objectData.x;
			inWorldObjectInstance.y = objectData.y;
			
			inWorldObjectInstance.inWorldObject = new InWorldObject();
			inWorldObjectInstance.inWorldObject.creatorGuid = objectData.creator;
			inWorldObjectInstance.inWorldObject.guid = objectData.object_guid;
			inWorldObjectInstance.inWorldObject.width = objectData.width;
			inWorldObjectInstance.inWorldObject.height = objectData.height;
			inWorldObjectInstance.dest = objectData.dest;
			inWorldObjectInstance.inWorldObject.thumbnailURL = objectData.thumbnail_url;
			inWorldObjectInstance.inWorldObject.fullsizeURL = objectData.fullsize_url;
			
			return inWorldObjectInstance;
		}
	}
}