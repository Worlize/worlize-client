package com.worlize.model.friends
{
	import com.worlize.model.CurrentUser;
	
	import flash.external.ExternalInterface;

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
			ExternalInterface.call('showFacebookDialog', {
				method: 'apprequests',
				message: "I'm online chatting right now in Worlize.  Come join me!  Hope to see you soon!",
				to: facebookId,
				title: 'Invite ' + name + ' to Join You',
				data: JSON.stringify({
					action: 'join',
					inviter_guid: CurrentUser.getInstance().guid
				})
			});
		}
	}
}