package com.worlize.model
{
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	
	[Bindable]
	public class RoomList
	{
		public var rooms:ArrayCollection = new ArrayCollection();
		
		public static function fromData(data:Array):RoomList {
			var roomList:RoomList = new RoomList();
			roomList.updateFromData(data);
			return roomList;
		}
		
		public function updateFromData(data:Array):void {
			rooms.disableAutoUpdate();
			rooms.removeAll();
			for each (var roomDefinition:Object in data) {
				rooms.addItem(RoomListEntry.fromData(roomDefinition));
			}
			rooms.enableAutoUpdate();
		}
	}
}