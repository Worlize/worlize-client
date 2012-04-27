package com.worlize.model
{
	import flash.events.EventDispatcher;
	
	import mx.events.FlexEvent;

	[Bindable]
	public class UserListEntry extends EventDispatcher
	{
		public var userGuid:String;
		public var username:String;
		private var _roomListEntry:RoomListEntry;
		
		[Bindable(event="roomListEntryChanged")]
		public function set roomListEntry(newValue:RoomListEntry):void {
			if (_roomListEntry !== newValue) {
				_roomListEntry = newValue;
				dispatchEvent(new FlexEvent("roomListEntryChanged"));
			}
		}
		
		public function get roomListEntry():RoomListEntry {
			return _roomListEntry;
		}
		
		[Bindable(event="roomListEntryChanged")]
		public function get roomGuid():String {
			if (_roomListEntry) {
				return _roomListEntry.guid;
			}
			return null;
		}
		
		[Bindable(event="roomListEntryChanged")]
		public function get roomName():String {
			if (_roomListEntry) {
				return _roomListEntry.name;
			}
			return "(Private Room)";
		}
		
		public static function fromData(data:Object, roomList:RoomList):UserListEntry {
			var user:UserListEntry = new UserListEntry();
			for each (var roomListEntry:RoomListEntry in roomList.rooms) {
				if (roomListEntry.guid === data.room_guid) {
					user.roomListEntry = roomListEntry;
					break;
				}
			}
			user.username = data.username;
			user.userGuid = data.user_guid;
			return user;
		}
		
		public function clone():UserListEntry {
			var e:UserListEntry = new UserListEntry();
			e.userGuid = userGuid;
			e.username = username;
			e.roomListEntry = _roomListEntry;
			return e;
		}
	}
}