package com.worlize.interactivity.event
{
	import com.worlize.model.UserListEntry;
	
	import flash.events.Event;
	
	public class WorlizeYouTubeEvent extends Event
	{
		public static const LOAD_VIDEO_REQUESTED:String = "loadVideoRequested";
		public static const PLAY_REQUESTED:String = "playRequested";
		public static const STOP_REQUESTED:String = "stopRequested";
		public static const PAUSE_REQUESTED:String = "pauseRequested";
		public static const SEEK_REQUESTED:String = "seekRequested";
		public static const PLAYER_LOCKED:String = "playerLocked";
		public static const PLAYER_UNLOCKED:String = "playerUnlocked";
		
		public var lockDurationSeconds:int;
		public var lockRequestedBy:UserListEntry;
		public var videoId:String;
		public var autoPlay:Boolean;
		public var title:String;
		public var seekTo:int;
		
		public function WorlizeYouTubeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}