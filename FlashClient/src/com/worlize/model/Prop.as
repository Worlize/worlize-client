package com.worlize.model
{
	public class Prop
	{
		public var name:String;
		public var guid:String;
		public var imageURL:String;
		public var thumbnailURL:String;
		public var creatorGuid:String;
		
		// not yet used
		public var offsetX:int = 0;
		public var offsetY:int = 0;
		public var width:int = 0;
		public var height:int = 0;
		
		public static function fromData(data:Object):void {
			var prop:Prop = new Prop();
			prop.name = data.name;
			prop.guid = data.guid;
			prop.imageURL = data.image;
			prop.thumbnailURL = data.thumbnail_url;
			prop.creatorGuid = data.creator_guid;
		}
	}
}