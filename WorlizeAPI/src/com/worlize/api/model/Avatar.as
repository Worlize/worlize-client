package com.worlize.api.model
{
	import com.worlize.worlize_internal;
	
	import flash.events.EventDispatcher;
	
	public class Avatar extends EventDispatcher
	{
		use namespace worlize_internal;
		
		public static const TYPE_DEFAULT:String = "default";
		public static const TYPE_IMAGE:String = "image";
		public static const TYPE_WEBCAM:String = "webcam";
		
		protected var _guid:String;
		protected var _type:String;
		protected var _thumbnailURL:String;
		
		public function get guid():String {
			return _guid;
		}
		
		public function get type():String {
			return _type;
		}
		
		public function get thumbnailURL():String {
			return _thumbnailURL;
		}
		
		public function toJSON():Object {
			return {
				type: _type,
				guid: _guid,
				thumbnailURL: _thumbnailURL
			};
		}
		
		override public function toString():String {
			return "[Avatar type=" + _type + " guid=" + _guid + "]";
		}
		
		worlize_internal static function fromData(data:Object):Avatar {
			var avatar:Avatar = new Avatar();
			if (data === null) {
				avatar._type = TYPE_DEFAULT;
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