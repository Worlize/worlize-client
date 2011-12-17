package com.worlize.model
{
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.rpc.events.FaultEvent;
	
	[Bindable]
	public class RoomList extends EventDispatcher
	{
		public var rooms:ArrayCollection;
		
		function RoomList() {
			rooms = new ArrayCollection();
			rooms.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleCollectionChange);
		}
		
		private function handleCollectionChange(event:CollectionEvent):void {
			markUserCountChange();
		}

		public function markUserCountChange():void {
			dispatchEvent(new Event('totalUserCountChange'));
		}
		
		[Bindable(event='totalUserCountChange')]
		public function get totalUserCount():int {
			var count:int = 0;
			for each (var room:RoomListEntry in rooms) {
				count += room.userCount;
			}
			return count;
		}
		
		public function updateFromData(data:Array):void {
			rooms.disableAutoUpdate();
			rooms.removeAll();
			for each (var roomDefinition:Object in data) {
				rooms.addItem(RoomListEntry.fromData(roomDefinition));
			}
			rooms.enableAutoUpdate();
			markUserCountChange();
		}
	}
}