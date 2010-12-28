package com.worlize.rpc
{
	import flash.events.Event;
	
	import mx.messaging.messages.IMessage;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	
	public class WorlizeResultEvent extends ResultEvent
	{
		public static const RESULT:String = "result";
		
		public var resultJSON:Object;
		
		public function WorlizeResultEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=true, result:Object=null, token:AsyncToken=null, message:IMessage=null)
		{
			super(type, bubbles, cancelable, result, token, message);
		}
		
		override public function clone():Event {
			var event:ResultEvent = new WorlizeResultEvent(type, bubbles, cancelable, result, token, message);
			WorlizeResultEvent(event).resultJSON = resultJSON;
			return event;
		} 
	}
}