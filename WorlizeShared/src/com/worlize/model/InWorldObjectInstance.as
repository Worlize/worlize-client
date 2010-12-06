package com.worlize.model
{
	import com.worlize.event.NotificationCenter;
	import com.worlize.notification.InWorldObjectNotification;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import mx.rpc.events.FaultEvent;

	[Bindable]
	public class InWorldObjectInstance
	{
		public var inWorldObject:InWorldObject;
		public var guid:String;
		public var x:int;
		public var y:int;
		public var room:RoomListEntry;
		public var dest:String;
		public var emptySlot:Boolean = false;
		
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
		
		public function requestDelete():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleDeleteResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send("/locker/in_world_objects/" + guid + ".json", HTTPMethod.DELETE);
		}
		
		private function handleFault(event:FaultEvent):void {
			trace("Object Delete Failed. " + event);
		}
		
		private function handleDeleteResult(event:WorlizeResultEvent):void {
			var notification:InWorldObjectNotification = new InWorldObjectNotification(InWorldObjectNotification.IN_WORLD_OBJECT_DELETED);
			notification.deletedInstanceGuid = guid;
			NotificationCenter.postNotification(notification);
		}

	}
}