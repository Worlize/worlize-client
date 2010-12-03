package com.worlize.model
{
	public class UserListEntry
	{
		public var userGuid:String;
		public var userName:String;
		public var roomGuid:String;
		public var roomName:String;
		
		public static function fromData(data:Object):UserListEntry {
			var user:UserListEntry = new UserListEntry();
			user.roomGuid = data.room_guid;
			user.roomName = data.room_name;
			user.userName = data.user_name;
			user.userGuid = data.user_guid;
			return user;
		}
	}
}