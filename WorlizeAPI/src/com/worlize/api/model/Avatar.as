package com.worlize.api.model
{
	import com.worlize.api.constants.AvatarType;
	import com.worlize.worlize_internal;
	
	/**
	 * Represents a Worlize Avatar
	 *  
	 * @author Brian McKelvey
	 * @productversion Worlize APIv.1
	 */	
	public class Avatar
	{
		use namespace worlize_internal;
		
		/**
		 * @private
		 */		
		protected var _guid:String;
		
		/**
		 * @private
		 */		
		protected var _type:String;
		
		/**
		 * @private
		 */		
		protected var _thumbnailURL:String;
		
		/**
		 * The Avatar's Globally Unique Identifier
		 *  
		 * @return the Avatar's GUID
		 * @productversion Worlize APIv.1
		 * @see http://en.wikipedia.org/wiki/GUID GUID on Wikipedia
		 */		
		public function get guid():String {
			return _guid;
		}
		
		/**
		 * Which type of avatar is being worn.
		 * 
		 * <p>Possible values are enumerated by the
		 * com.worlize.api.constants.AvatarType class</p>
		 *  
		 * @return the avatar type
		 * @productversion Worlize APIv.1
		 * @see com.worlize.api.constants.AvatarType
		 */
		public function get type():String {
			return _type;
		}
		
		/**
		 * A thumbnail image URL for the avatar, if available.
		 *  
		 * @return thumbnail url
		 * @productversion Worlize APIv.1
		 */		
		public function get thumbnailURL():String {
			return _thumbnailURL;
		}
		
		/**
		 * @private
		 */		
		public function toJSON():Object {
			return {
				type: _type,
				guid: _guid,
				thumbnailURL: _thumbnailURL
			};
		}
		
		/**
		 * @private
		 */		
		public function toString():String {
			return "[Avatar type=" + _type + " guid=" + _guid + "]";
		}
		
		/**
		 * @private
		 */		
		worlize_internal static function fromData(data:Object):Avatar {
			var avatar:Avatar = new Avatar();
			if (data === null) {
				avatar._type = AvatarType.DEFAULT;
			}
			else {
				avatar._guid = data.guid;
				avatar._type = data.type;
				avatar._thumbnailURL = data.thumbnailURL;
			}
			return avatar;
		}
	}
}