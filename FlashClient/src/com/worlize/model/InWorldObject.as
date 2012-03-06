package com.worlize.model
{
	[Bindable]
	public class InWorldObject
	{
		public static const KIND_IMAGE:String = "image";
		public static const KIND_APP:String = "app";
		
		public var guid:String;
		public var creatorGuid:String;
		public var kind:String;
		public var name:String;
		public var iconURL:String;
		public var mediumIconURL:String;
		public var smallIconURL:String;
		public var appURL:String;
		public var thumbnailURL:String;
		public var mediumURL:String;
		public var fullsizeURL:String;
		public var returnCoins:int;
		public var width:uint;
		public var height:uint;
		
		public static function fromData(data:Object):InWorldObject {
			var object:InWorldObject = new InWorldObject();
			object.guid = data.guid;
			object.creatorGuid = data.creator;
			object.name = data.name;
			object.kind = data.kind;
			if (object.kind === KIND_APP) {
				object.appURL = data.app_url;
				object.iconURL = data.icon;
				object.thumbnailURL = object.mediumIconURL = data.medium_icon;
				object.smallIconURL = data.small_icon;
			}
			else { // KIND_IMAGE
				object.thumbnailURL = data.thumbnail;
				object.mediumURL = data.medium;
				object.fullsizeURL = data.fullsize;
			}
			return object;
		}
	}
}