package com.worlize.command
{
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;
	
	public class CheckUsernameAvailabilityCommand extends EventDispatcher
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_AVAILABLE:String = "available";
		public static const STATE_UNAVAILABLE:String = "unavailable";
		public static const STATE_ERROR:String = "error";
		
		private var logger:ILogger = Log.getLogger("com.worlize.command.CheckUsernameAvailabilityCommand");
		
		[Bindable]
		public var state:String = STATE_INIT;
		
		[Bindable]
		public var requestedUsername:String;
		
		private var client:WorlizeServiceClient;
		
		public function CheckUsernameAvailabilityCommand(target:IEventDispatcher=null)
		{
			super(target);
			client = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
		}
		
		public function reset():void {
			state = STATE_INIT;
			requestedUsername = null;
			client.cancel();
		}
		
		public function execute(requestedUsername:String):void {
			state = STATE_LOADING;
			this.requestedUsername = requestedUsername;
			
			client.cancel();
			client.send("/users/check_username_availability.json", HTTPMethod.POST, {
				username: requestedUsername
			});
		}
		
		private function handleResult(event:WorlizeResultEvent):void {
			if (event.resultJSON.success) {
				state = STATE_AVAILABLE;
				dispatchEvent(event);
				return;
			}
			state = STATE_UNAVAILABLE;
		}
		
		private function handleFault(event:FaultEvent):void {
			state = STATE_ERROR;
		}
	}
}