package com.worlize.model
{
	import com.worlize.command.DeleteAvatarInstanceCommand;

	public class AvatarInstance
	{
		public var avatar:SimpleAvatar;
		public var guid:String;
		public var userGuid:String;
		
		public static function fromData(data:Object):AvatarInstance {
			var avatarInstance:AvatarInstance = new AvatarInstance();
			avatarInstance.guid = data.guid;
			avatarInstance.userGuid = data.userGuid;
			avatarInstance.avatar = SimpleAvatar.fromData(data.avatar);
			return avatarInstance;
		}
		
		public function requestDelete():void {
			var command:DeleteAvatarInstanceCommand = new DeleteAvatarInstanceCommand();
			command.execute(guid);
		}
	}
}