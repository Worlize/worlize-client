package com.worlize.command
{
	import com.worlize.model.App;
	import com.worlize.model.AppInstance;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.rpc.events.FaultEvent;
	
	public class GetAnotherAppCopyCommand extends EventDispatcher
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_COMPLETE:String = "complete";
		public static const STATE_ERROR:String = "error";
		
		[Bindable]
		public var appInstance:AppInstance;
		
		[Bindable]
		public var state:String = STATE_INIT;
		
		public function GetAnotherAppCopyCommand(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function execute(app:App):void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send("/locker/apps/" + app.guid + "/get_another_copy.json", HTTPMethod.POST);
			state = STATE_LOADING;
		}
		
		private function handleResult(event:WorlizeResultEvent):void {
			if (event.resultJSON.success) {
				state = STATE_COMPLETE;
				appInstance = AppInstance.fromLockerData(event.resultJSON.app_instance);
			}
			else {
				state = STATE_ERROR;
			}
			dispatchEvent(event);
		}
		
		private function handleFault(event:FaultEvent):void {
			state = STATE_ERROR;
			dispatchEvent(event);
		}
	}
}