package com.worlize.model
{
	import com.adobe.utils.DateUtil;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	[Bindable]
	public class LinkedProfile extends EventDispatcher
	{
		public static const TWITTER:String = "twitter";
		public static const FACEBOOK:String = "facebook";
		
		public var provider:String;
		public var uid:String;
		public var createdAt:Date;
		public var token:String;
		public var profileURL:String;
		public var displayName:String;
		public var profilePicture:String;
		
		public function LinkedProfile(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public static function fromData(data:Object):LinkedProfile {
			var p:LinkedProfile = new LinkedProfile();
			p.provider = data.provider;
			p.uid = data.uid;
			p.createdAt = DateUtil.parseW3CDTF(data.created_at);
			p.token = data.token;
			p.profileURL = data.profile_url;
			p.displayName = data.display_name;
			p.profilePicture = data.profile_picture;
			return p;
		}
		
		public function clone():LinkedProfile {
			var p:LinkedProfile = new LinkedProfile();
			p.provider = provider;
			p.uid = uid;
			p.createdAt = new Date(createdAt.valueOf());
			p.token = token;
			p.profileURL = profileURL;
			p.profilePicture = profilePicture;
			return p;
		}
	}
}