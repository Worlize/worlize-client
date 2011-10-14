package com.worlize.model
{
	[Bindable]
	public class RoomListEntry
	{
		public var name:String;
		public var userCount:int;
		public var guid:String;
		public var thumbnail:String;
		
		public static function fromData(data:Object):RoomListEntry {
			var obj:RoomListEntry = new RoomListEntry();
			obj.name = data.name;
			obj.userCount = data.user_count;
			obj.guid = data.guid;
			if (data.thumbnail) {
				obj.thumbnail = data.thumbnail;				
			}
			return obj;
		}
	}
}