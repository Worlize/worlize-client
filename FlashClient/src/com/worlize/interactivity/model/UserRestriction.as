package com.worlize.interactivity.model
{
	import com.adobe.utils.DateUtil;

	[Bindable]
	public class UserRestriction
	{
		public static const BAN:String = "ban";
		public static const PIN:String = "pin";
		public static const GAG:String = "gag";
		public static const BLOCK_AVATARS:String = "block_avatars";
		public static const BLOCK_WEBCAMS:String = "block_webcams";
		public static const BLOCK_PROPS:String = "block_props";
		
		public var id:uint;
		public var name:String;
		public var expires:Date;
		public var user:InteractivityUser;
		public var createdBy:InteractivityUser;
		public var updatedBy:InteractivityUser;
		
		public static function fromData(data:Object):UserRestriction {
			var r:UserRestriction = new UserRestriction();
			r.name = data.name;
			r.expires = DateUtil.parseW3CDTF(data.expires);
			if (data.user) {
				r.user = new InteractivityUser();
				r.user.name = data.user.username;
				r.user.id = data.user.guid;
			}
			if (data.created_by) {
				r.createdBy = new InteractivityUser();
				r.createdBy.name = data.created_by.username;
				r.createdBy.id = data.created_by.guid;
			}
			if (data.updated_by) {
				r.updatedBy = new InteractivityUser();
				r.updatedBy.name = data.updated_by.username;
				r.updatedBy.id = data.updated_by.guid;
			}
			return r;
		}
	}
}