package com.worlize.interactivity.event
{
	import flash.events.Event;
	
	public class PropSelectEvent extends Event
	{
		public static const SHOW_PROP_CONTEXT_MENU:String = "showPropContextMenu";
		
		public function PropSelectEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}