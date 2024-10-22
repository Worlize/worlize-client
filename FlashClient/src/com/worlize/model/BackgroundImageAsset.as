package com.worlize.model
{
	public class BackgroundImageAsset
	{
		public var guid:String;
		public var name:String;
		public var thumbnailURL:String;
		public var mediumURL:String;
		public var fullsizeURL:String;
		public var returnCoins:int;
		
		public static function fromData(data:Object):BackgroundImageAsset {
			var object:BackgroundImageAsset = new BackgroundImageAsset();
			object.guid = data.guid;
			object.name = data.name;
			object.thumbnailURL = data.thumbnail;
			object.mediumURL = data.medium;
			object.fullsizeURL = data.fullsize;
			return object;
		}
	}
}