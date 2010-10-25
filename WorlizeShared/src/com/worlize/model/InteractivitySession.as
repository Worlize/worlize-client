package com.worlize.model
{
	public class InteractivitySession
	{
		public var worldGuid:String;
		public var roomGuid:String;
		public var serverId:String;
		public var username:String;
		public var userGuid:String;
		public var sessionGuid:String;
		
		public static function fromData(data:Object):InteractivitySession {
			var obj:InteractivitySession = new InteractivitySession();
			obj.worldGuid = data.world_guid;
			obj.roomGuid = data.room_guid;
			obj.serverId = data.server_id;
			obj.username = data.username;
			obj.userGuid = data.user_guid;
			obj.sessionGuid = data.session_guid;
			return obj;
		}
	}
}