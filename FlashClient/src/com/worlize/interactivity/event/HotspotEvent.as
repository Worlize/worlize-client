package com.worlize.interactivity.event
{
	import flash.events.Event;
	
	import com.worlize.interactivity.model.Hotspot;

	public class HotspotEvent extends Event
	{
		public static const REDRAW_REQUESTED:String = "redrawRequested";
		public static const SELECTED_FOR_AUTHOR:String = "selectedForAuthor";
		
		public var hotSpot:Hotspot;
		public var state:int;
		public var previousState:int;
				
		public function HotspotEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}