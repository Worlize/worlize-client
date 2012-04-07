package com.worlize.model
{
	public class PropInstance
	{
		public var guid:String;
		public var userGuid:String;
		public var gifter:UserListEntry;
		
		public static function fromData(data:Object):PropInstance {
			var pi:PropInstance = new PropInstance();
			pi.guid = data.guid;
			pi.userGuid = data.user_guid;
			if (data.gifter) {
				var gifter:UserListEntry = new UserListEntry();
				gifter.userGuid = data.gifter.guid;
				gifter.username = data.gifter.username;
				pi.gifter = gifter;
			}
		}
	}
}