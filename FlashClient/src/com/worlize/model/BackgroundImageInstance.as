package com.worlize.model
{
	import com.worlize.event.NotificationCenter;
	import com.worlize.notification.BackgroundImageNotification;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;

	[Bindable]
	public class BackgroundImageInstance
	{
		private var logger:ILogger = Log.getLogger('com.worlize.model.BackgroundImageInstance');
		
		public var backgroundImageAsset:BackgroundImageAsset;
		public var guid:String;
		public var room:RoomListEntry;
		public var emptySlot:Boolean = false;
		
		public static function fromData(data:Object):BackgroundImageInstance {
			var object:BackgroundImageInstance = new BackgroundImageInstance();
			object.guid = data.guid;
			object.backgroundImageAsset = BackgroundImageAsset.fromData(data.background);
			if (data.room) {
				object.room = new RoomListEntry();
				object.room.name = data.room.name;
				object.room.guid = data.room.guid;
			}
			return object;
		}
		
		public function updateData(data:Object):void {
			guid = data.guid;
			backgroundImageAsset = BackgroundImageAsset.fromData(data.background);
			if (data.room) {
				room = new RoomListEntry();
				room.name = data.room.name;
				room.guid = data.room.guid;
			}
			else {
				room = null;
			}
		}
		
		public function requestDelete():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleDeleteResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send("/locker/backgrounds/" + guid + ".json", HTTPMethod.DELETE);
		}
		
		private function handleFault(event:FaultEvent):void {
			logger.error("Background Delete Failed. " + event);
		}
		
		private function handleDeleteResult(event:WorlizeResultEvent):void {
			var notification:BackgroundImageNotification = new BackgroundImageNotification(BackgroundImageNotification.BACKGROUND_INSTANCE_DELETED);
			notification.instanceGuid = guid;
			NotificationCenter.postNotification(notification);
		}
	}
}