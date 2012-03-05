package com.worlize.interactivity.api.event
{
	import flash.events.ErrorEvent;
	
	public class ClientValidationErrorEvent extends ErrorEvent
	{
		public static const VALIDATION_ERROR:String = "validationError";
		
		public function ClientValidationErrorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, text:String="", id:int=0)
		{
			super(type, bubbles, cancelable, text, id);
		}
	}
}