package com.worlize.event
{
	import flash.events.Event;
	
	public class SocialShareEvent extends Event
	{
		public static const SNAPSHOT_REQUESTED:String = "snapshotRequested";
		
		public function SocialShareEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}