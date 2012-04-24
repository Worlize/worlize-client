package com.worlize.model
{
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.Event;
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
		
		public function addRoom(entry:RoomListEntry):void {
			for each (var existingEntry:RoomListEntry in rooms) {
				if (existingEntry.guid === entry.guid) {
					return;
				}
			}
			rooms.addItem(entry);
		}
		
		public function removeRoomByGuid(roomGuid:String):void {
			for (var i:int = 0; i < rooms.length; i++) {
				var entry:RoomListEntry = RoomListEntry(rooms.getItemAt(i));
				if (entry.guid === roomGuid) {
					rooms.removeItemAt(i);
					return;
				}
			}
		}
		
		public function updateRoom(entry:RoomListEntry):void {
			for (var i:int = 0; i < rooms.length; i++) {
				var existingEntry:RoomListEntry = RoomListEntry(rooms.getItemAt(i));
				if (existingEntry.guid === entry.guid) {
					existingEntry.name = entry.name;
					existingEntry.thumbnail = entry.thumbnail;
					rooms.removeItemAt(i);
					rooms.addItemAt(entry, i);
					return;
				}
			}
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