package com.worlize.model
{
	public class BackgroundImageInstance
	{
		public var backgroundImageAsset:BackgroundImageAsset;
		public var guid:String;
		public var roomGuid:String;
		public var roomName:String;
		
		public static function fromData(data:Object):BackgroundImageInstance {
			var object:BackgroundImageInstance = new BackgroundImageInstance();
			object.guid = data.guid;
			object.backgroundImageAsset = BackgroundImageAsset.fromData(data.background);
			object.roomName = data.room.name;
			object.roomGuid = data.room.guid;
			return object;
		}
	}
}