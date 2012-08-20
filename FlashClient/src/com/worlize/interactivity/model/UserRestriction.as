package com.worlize.interactivity.model
{
	import com.adobe.utils.DateUtil;

	public class UserRestriction
	{
		public static const BAN:String = "ban";
		public static const PIN:String = "pin";
		public static const GAG:String = "gag";
		public static const BLOCK_AVATARS:String = "block_avatars";
		public static const BLOCK_WEBCAMS:String = "block_webcams";
		public static const BLOCK_PROPS:String = "block_props";
		
		public var name:String;
		public var expires:Date;
		public var createdBy:String;
		public var updatedBy:String;
		
		public static function fromData(data:Object):UserRestriction {
			var r:UserRestriction = new UserRestriction();
			r.name = data.name;
			r.expires = DateUtil.parseW3CDTF(data.expires);
			r.createdBy = data.created_by;
			r.updatedBy = data.updated_by;
			return r;
		}
	}
}