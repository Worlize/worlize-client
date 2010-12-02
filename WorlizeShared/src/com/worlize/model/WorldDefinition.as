package com.worlize.model
{
	import com.worlize.event.NotificationCenter;
	import com.worlize.notification.RoomChangeNotification;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import mx.rpc.events.FaultEvent;

	[Bindable]
	public class WorldDefinition
	{
		public var name:String;
		public var guid:String;
		
		public var canCreateNewRoom:Boolean;
		
		public var roomList:RoomList;
		
		public var ownerGuid:String;
		
		public function WorldDefinition()
		{
			NotificationCenter.addListener(RoomChangeNotification.ROOM_DELETED, handleRoomListChanged);
			NotificationCenter.addListener(RoomChangeNotification.ROOM_ADDED, handleRoomListChanged);
		}
		
		private function handleRoomListChanged(notification:RoomChangeNotification):void {
			load(guid);
		}
		
		public function load(worldGuid:String):void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send('/worlds/' + worldGuid + ".json", HTTPMethod.GET); 
		}
		
		private function handleResult(event:WorlizeResultEvent):void {
			if (event.resultJSON.success) {
				this.name = event.resultJSON.data.name;
				this.guid = event.resultJSON.data.guid;
				this.ownerGuid = event.resultJSON.data.owner.guid;
				this.canCreateNewRoom = event.resultJSON.data.can_create_new_room;
				if (!this.roomList) {
					this.roomList = new RoomList();
				}
				this.roomList.updateFromData(event.resultJSON.data.rooms);
				trace("Got updated worlz definition");
			}
		}
		private function handleFault(event:FaultEvent):void {
			/* Do nothing */
		}
	}
}