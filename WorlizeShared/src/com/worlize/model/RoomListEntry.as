package com.worlize.model
{
	[Bindable]
	public class RoomListEntry
	{
		public var name:String;
		public var userCount:String;
		public var guid:String;
		
		public static function fromData(data:Object):RoomListEntry {
			var obj:RoomListEntry = new RoomListEntry();
			obj.name = data.name;
			obj.userCount = data.user_count;
			obj.guid = data.guid;
			return obj;
		}
	}
}