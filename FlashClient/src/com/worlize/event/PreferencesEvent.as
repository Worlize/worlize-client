package com.worlize.event
{
	import flash.events.Event;

	public class PreferencesEvent extends Event
	{
		public static const PREFERENCES_LOADED:String = "preferencesLoaded";
		public static const PREFERENCES_SAVED:String = "preferencesSaved";
		public static const PREFERENCES_INITIALIZED:String = "preferencesInitialized";
		
		public function PreferencesEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}