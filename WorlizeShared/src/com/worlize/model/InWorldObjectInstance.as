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
		public var emptySlot:Boolean = false;
		
		public static function fromData(data:Object):InWorldObjectInstance {
			var object:InWorldObjectInstance = new InWorldObjectInstance();
			object.guid = data.guid;
			object.inWorldObject = InWorldObject.fromData(data.in_world_object);
			object.emptySlot = false;
			return object;
		}
		
		public function updateData(data:Object):void {
			guid = data.guid;
			inWorldObject  = InWorldObject.fromData(data.in_world_object);
			emptySlot = false;
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