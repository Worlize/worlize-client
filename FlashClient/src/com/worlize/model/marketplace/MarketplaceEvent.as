package com.worlize.model.marketplace
{
	import com.worlize.model.WorlizeAsset;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class MarketplaceEvent extends Event
	{
		public static const RESULT:String = "result";
		public static const FAULT:String = "fault";
		
		public var result:ArrayCollection;
		
		
		public function MarketplaceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}