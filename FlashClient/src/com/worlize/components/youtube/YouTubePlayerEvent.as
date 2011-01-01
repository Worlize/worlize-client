package com.worlize.components.youtube
{
	import flash.events.Event;
	
	public class YouTubePlayerEvent extends Event
	{
		public static const READY:String = "ready";
		public static const STATE_CHANGE:String = "stateChange";
		public static const QUALITY_CHANGE:String = "qualityChange";
		public static const ERROR:String = "error";
		
		public var newState:int;
		public var oldState:int;
		public var quality:String;
		public var errorCode:int;
		public var data:Object;
		
		public function YouTubePlayerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}