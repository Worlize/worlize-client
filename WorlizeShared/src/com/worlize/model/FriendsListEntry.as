package com.worlize.model
{
	[Bindable]
	public class FriendsListEntry
	{
		public var username:String;
		public var guid:String;
		public var online:Boolean;
		public var worldEntrance:String;
		
		public static function fromData(data:Object):FriendsListEntry {
			var instance:FriendsListEntry = new FriendsListEntry();
			instance.username = data.username;
			instance.guid = data.guid;
			instance.online = data.online;
			instance.worldEntrance = data.world_entrance;
			return instance;
		}
		
		public function toString():String {
			return username;
		}
	}
}