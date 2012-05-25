package com.worlize.model
{
	[Bindable]
	public class App
	{
		public var guid:String;
		public var creatorGuid:String;
		public var name:String;
		public var iconURL:String;
		public var mediumIconURL:String;
		public var smallIconURL:String;
		public var appURL:String;
		public var width:uint;
		public var height:uint;
		
		public static function fromData(data:Object):App {
			var app:App = new App();
			app.guid = data.guid;
			app.creatorGuid = data.creator;
			app.name = data.name;
			app.appURL = data.app_url;
			app.iconURL = data.icon;
			app.mediumIconURL = data.medium_icon;
			app.smallIconURL = data.small_icon;
			return app;
		}
	}
}