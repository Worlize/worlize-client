package com.worlize.interactivity.event
{
	import flash.events.Event;
	
	public class DragHandleEvent extends Event
	{
		public static const DRAG_COMPLETE:String = "dragComplete";
		public static const DRAG_MOVE:String = "dragMove";
		
		public var x:Number;
		public var y:Number;
		
		public function DragHandleEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}