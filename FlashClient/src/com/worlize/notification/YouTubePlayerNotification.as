package com.worlize.notification
{
	import com.worlize.model.YouTubePlayerDefinition;
	
	import flash.events.Event;
	
	public class YouTubePlayerNotification extends Event
	{
		public static const ADDED_TO_ROOM:String = "youtubePlayerAddedToRoom";
		public static const REMOVED_FROM_ROOM:String = "youtubePlayerRemovedFromRoom";
		
		public var playerDefinition:YouTubePlayerDefinition;
		public var roomGuid:String;
		
		public function YouTubePlayerNotification(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}