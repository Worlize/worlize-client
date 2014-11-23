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
		public var roomFlags:Vector.<String>;
		
		[Bindable(event="roomChanged")]
		public function set room(newValue:RoomListEntry):void {
			if (_room !== newValue) {
				_room = newValue;
				updateRoomFlags();
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
			return room.userCount >= room.maxOccupancy;
		}
		
		private function updateRoomFlags():void {
			roomFlags = new Vector.<String>();
			if (room.hidden) { roomFlags.push('Hidden'); }
			if (room.locked) { roomFlags.push('Locked'); }
			if (room.moderatorsOnly) { roomFlags.push('Mods Only'); }
			if (room.noDirectEntry) { roomFlags.push('No Direct Entry'); }
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