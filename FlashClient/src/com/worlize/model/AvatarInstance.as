package com.worlize.model
{
	import com.worlize.command.DeleteAvatarInstanceCommand;

	[Bindable]
	public class AvatarInstance
	{
		public var avatar:SimpleAvatar;
		public var guid:String;
		public var userGuid:String;
		public var gifter:UserListEntry;
		public var emptySlot:Boolean = false;
		
		public static function fromData(data:Object):AvatarInstance {
			var avatarInstance:AvatarInstance = new AvatarInstance();
			avatarInstance.guid = data.guid;
			avatarInstance.userGuid = data.userGuid;
			avatarInstance.avatar = SimpleAvatar.fromData(data.avatar);
			if (data.gifter) {
				var gifter:UserListEntry = new UserListEntry();
				gifter.userGuid = data.gifter.guid;
				gifter.username = data.gifter.username;
				avatarInstance.gifter = gifter;
			}
			return avatarInstance;
		}
		
		public function requestDelete():void {
			var command:DeleteAvatarInstanceCommand = new DeleteAvatarInstanceCommand();
			command.execute(guid);
		}
	}
}