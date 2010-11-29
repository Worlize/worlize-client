package com.worlize.model
{
	public class BackgroundImageInstance
	{
		public var backgroundImageAsset:BackgroundImageAsset;
		public var guid:String;
		public var room:RoomListEntry;
		
		public static function fromData(data:Object):BackgroundImageInstance {
			var object:BackgroundImageInstance = new BackgroundImageInstance();
			object.guid = data.guid;
			object.backgroundImageAsset = BackgroundImageAsset.fromData(data.background);
			if (data.room) {
				object.room = new RoomListEntry();
				object.room.name = data.room.name;
				object.room.guid = data.room.guid;
			}
			return object;
		}
	}
}