package com.worlize.event
{
	import flash.events.Event;
	
	public class TutorialEvent extends Event
	{
		public static const LAUNCH_TUTORIAL:String = "launchTutorial";
		public static const CLOSE_TUTORIAL:String = "closeTutorial";
		
		public function TutorialEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}