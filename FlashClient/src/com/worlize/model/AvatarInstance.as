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
		public var editGuid:String;
		public var aviaryGuid:String;
		public var gifter:UserListEntry;
		public var emptySlot:Boolean = false;
		public var editable:Boolean = false;
		public var animatedGIF:Boolean = false;
		
		public static function fromData(data:Object):AvatarInstance {
			var avatarInstance:AvatarInstance = new AvatarInstance();
			avatarInstance.guid = data.guid;
			avatarInstance.userGuid = data.user_guid;
			avatarInstance.editGuid = data.edit_guid;
			avatarInstance.aviaryGuid = data.aviary_guid;
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
		
		public function get aviaryEditUrl():String {
			var appUrl:URI = new URI(FlexGlobals.topLevelApplication.url);
			var postUrl:String = appUrl.scheme + "://" + appUrl.authority +
								 "/aviary/edit_complete?type=avatar&edit_guid=" + editGuid;
			
			var params:Object = {
				apil: "392bffc24",
				posturl: postUrl,
				loadurl: aviaryGuid ? aviaryGuid : avatar.fullsizeURL,
				userhash: userGuid,
				defaultfilename: avatar.name,
				postagent: "client",
				sitename: "Worlize"
			};
			
			var pairs:Array = [];
			for (var key:String in params) {
				var value:String = params[key];
				pairs.push(encodeURIComponent(key) + "=" + encodeURIComponent(value));
			}
			
			var aviaryUrl:String = "http://www.aviary.com/online/image-editor?" + pairs.join('&');
			
			return aviaryUrl;
		}
	}
}