package com.worlize.model
{
	import com.worlize.command.DeleteAvatarInstanceCommand;
	
	import flash.events.EventDispatcher;

	[Event(name="avatarLoaded",type="com.worlize.event.AvatarEvent")]
	[Event(name="avatarError",type="com.worlize.event.AvatarEvent")]
	
	[Bindable]
	public class SimpleAvatar extends EventDispatcher
	{
		public var name:String;
		public var ready:Boolean = false;
		public var guid:String;
		public var thumbnailURL:String;
		public var fullsizeURL:String;
		public var mediumURL:String;
		public var smallURL:String;
		public var tinyURL:String;
		public var error:Boolean = false;
		
		public function fromData(data:Object):void {
			name = data.name;
			guid = data.guid;
			fullsizeURL = data.fullsize;
			mediumURL = data.medium;
			smallURL = data.small;
			tinyURL = data.tiny;
			thumbnailURL = data.thumbnail;
			ready = true;
		}
		
		public static function fromData(data:Object):SimpleAvatar {
			var avatarDefinition:SimpleAvatar = new SimpleAvatar();
			avatarDefinition.fromData(data);
			return avatarDefinition;
		}
	}
}