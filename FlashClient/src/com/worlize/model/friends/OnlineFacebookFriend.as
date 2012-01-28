package com.worlize.model.friends
{
	import com.adobe.net.URI;
	import com.worlize.interactivity.model.InteractivityUser;
	import com.worlize.interactivity.rpc.InteractivityClient;
	import com.worlize.model.CurrentUser;
	import com.worlize.model.SimpleAvatar;
	
	import flash.external.ExternalInterface;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;

	[Bindable]
	public class OnlineFacebookFriend
	{
		public var listPriority:int = FriendsList.LIST_PRIORITY_ONLINE_FACEBOOK_FRIEND;
		public var isHeader:Boolean = false;
		public var online:Boolean = true;
		
		public var name:String;
		public var picture:String;
		public var facebookId:String;
		public var onlinePresence:String;
		
		public static function fromData(data:Object):OnlineFacebookFriend {
			var instance:OnlineFacebookFriend = new OnlineFacebookFriend();
			instance.name = data.name;
			instance.picture = data.picture;
			instance.onlinePresence = data.fb_online_presence;
			instance.facebookId = data.id;
			return instance;
		}
		
		public function updateFromData(data:Object):void {
			this.name = data.name;
			this.picture = data.picture;
			this.onlinePresence = data.fb_online_presence;
			this.facebookId = data.id;
		}
				
		public function invite():void {
			var client:InteractivityClient = InteractivityClient.getInstance();
			if (!client.currentUser) {
				return;
			}
			
			var picture:String;
			var avatar:SimpleAvatar = client.currentUser.simpleAvatar;
			if (avatar && avatar.thumbnailURL) {
				picture = avatar.thumbnailURL;
			}
			else {
				picture = "https://www.worlize.com/images/share-facebook-link-picture-2.png";
			}
			
			var appURI:URI = new URI(FlexGlobals.topLevelApplication.url);
			var base:String = appURI.scheme + "://" + appURI.authority;
			var shareLink:String = base + "/users/" + encodeURIComponent(client.worlizeConfig.currentUser.username) + "/join";
			
			ExternalInterface.call('showFacebookDialog', {
				method: 'feed',
				link: shareLink,
				picture: picture,
				name: "I'm chatting Live in Worlize Right Now!  Come Join Me!",
				caption: "In the world of Worlize I'm known as " + client.currentUser.name,
				description: "Worlize is a place of collaborative imagination where you can be whomever you want and " +
							 "your world can be anything you dream up!",
				to: facebookId,
				actions: JSON.stringify([
					{
						name: "Chat Now",
						link: shareLink
					}
				])
			});
			
			// Send direct message
//			ExternalInterface.call('showFacebookDialog', {
//				method: 'send',
//				link: shareLink,
//				to: facebookId,
//				picture: picture,
//				name: "I'm chatting Live in Worlize Right Now!  Come Join Me!",
//				description: "In the world of Worlize I'm known as " + client.currentUser.name + ". " + 
//				             "Worlize is a place of collaborative imagination where you can be whomever you want and " +
//				             "your world can be anything you dream up!"
//			});
			
			// For app requests dialog:
			//				data: JSON.stringify({
			//					action: 'join',
			//					inviter_guid: CurrentUser.getInstance().guid
			//				})
		}
	}
}