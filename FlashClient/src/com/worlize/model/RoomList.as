package com.worlize.model
{
	import com.worlize.interactivity.model.InteractivityUser;
	import com.worlize.interactivity.rpc.InteractivityClient;
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
		
		private var currentUser:InteractivityUser;
		private var currentWorld:WorldDefinition;
		
		function RoomList() {
			rooms = new ArrayCollection();
			rooms.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleCollectionChange);
			rooms.filterFunction = filterFunction;
		}
		
		private function filterFunction(item:Object):Boolean {
			if (currentUser === null || currentWorld === null) { return false; }
			var entry:RoomListEntry = RoomListEntry(item);
			if (entry.hidden && currentWorld.ownerGuid !== currentUser.id) {
				return false;
			}
			return true;
		}
		
		public function initFilter(currentUser:InteractivityUser, currentWorld:WorldDefinition):void {
			this.currentUser = currentUser;
			this.currentWorld = currentWorld;
			rooms.filterFunction = filterFunction;
		}
		
		public function clone():RoomList {
			var rl:RoomList = new RoomList();
			for each (var entry:RoomListEntry in rooms) {
				rl.rooms.addItem(entry.clone());
			}
			return rl;
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
					return;
				}
			}
		}
		
		public function updateFromData(data:Array):void {
			rooms.disableAutoUpdate();
			rooms.filterFunction = null;
			rooms.sort = null;
			rooms.refresh();
			rooms.removeAll();
			for each (var roomDefinition:Object in data) {
				rooms.addItem(RoomListEntry.fromData(roomDefinition));
			}
			rooms.enableAutoUpdate();
			markUserCountChange();
		}
	}
}