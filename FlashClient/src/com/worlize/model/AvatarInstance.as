package com.worlize.model
{
	import com.adobe.net.URI;
	import com.worlize.command.DeleteAvatarInstanceCommand;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;

	[Bindable]
	public class AvatarInstance
	{
		public var avatar:SimpleAvatar;
		public var videoAvatar:VideoAvatar;
		public var guid:String;
		public var userGuid:String;
		public var gifter:UserListEntry;
		public var emptySlot:Boolean = false;
		public var editable:Boolean = false;
		public var animatedGIF:Boolean = false;
		
		public static function fromData(data:Object):AvatarInstance {
			var avatarInstance:AvatarInstance = new AvatarInstance();
			avatarInstance.guid = data.guid;
			avatarInstance.userGuid = data.user_guid;
			avatarInstance.avatar = SimpleAvatar.fromData(data.avatar);
			avatarInstance.animatedGIF = data.avatar.animated_gif;
			avatarInstance.editable = !avatarInstance.animatedGIF; 
					//(avatarInstance.userGuid === avatarInstance.avatar.creatorGuid);
			
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