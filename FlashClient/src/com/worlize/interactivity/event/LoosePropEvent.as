package com.worlize.interactivity.event
{
	import com.worlize.interactivity.model.LooseProp;
	
	import flash.events.Event;
	
	public class LoosePropEvent extends Event
	{
		public static const PROPS_RESET:String = "propsReset";
		public static const PROP_ADDED:String = "propAdded";
		public static const PROP_REMOVED:String = "propRemoved";
		public static const PROP_MOVED:String = "propMoved";
		public static const PROP_BROUGHT_FORWARD:String = "propBroughtForward";
		public static const PROP_SENT_BACKWARD:String = "propSentBackward";
		
		public var looseProp:LooseProp;
		public var layerCount:int;
		
		public function LoosePropEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}