package com.worlize.model
{
	import com.worlize.model.friends.FriendsListEntry;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.events.FlexEvent;

	[Bindable]
	public class DirectoryEntry extends EventDispatcher
	{
		private var _room:RoomListEntry;
		public var world:WorldListEntry;
		public var friendsInRoom:ArrayList;
		public var friendCount:int = 0;
		
		[Bindable(event="roomChanged")]
		public function set room(newValue:RoomListEntry):void {
			if (_room !== newValue) {
				_room = newValue;
				dispatchEvent(new FlexEvent('roomChanged'));
			}
		}
		public function get room():RoomListEntry {
			return _room;
		}
		
		[Bindable(event="roomChanged")]
		public function get userCount():int {
			if (_room === null) { return 0; }
			return _room.userCount;
		}
		
		[Bindable(event="roomChanged")]
		public function get roomName():String {
			if (_room === null) { return ""; }
			return _room.name;
		}
		
		[Bindable(event="roomChanged")]
		public function get roomFull():Boolean {
			return room.userCount >= 20;
		}
		
		public static function fromData(data:Object):DirectoryEntry {
			var instance:DirectoryEntry = new DirectoryEntry();
			instance.room = RoomListEntry.fromData(data.room);
			instance.world = WorldListEntry.fromData(data.world);
			instance.friendsInRoom = new ArrayList();
			for each (var friendData:Object in data.friends_in_room) {
				instance.friendsInRoom.addItem(FriendsListEntry.fromData(friendData));
			}
			instance.friendCount = instance.friendsInRoom.length;
			return instance;
		}
	}
}