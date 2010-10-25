package com.worlize.command
{
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.rpc.events.FaultEvent;
	
	public class LoadBackgroundLockerCommand extends EventDispatcher
	{
		public function LoadBackgroundLockerCommand(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function execute(params:Object = null):void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send('/locker/backgrounds', HTTPMethod.GET);
		}
		
		private function handleResult(event:WorlizeResultEvent):void {
			dispatchEvent(event.clone());
		}
		private function handleFault(event:FaultEvent):void {
			dispatchEvent(event.clone());
		}
	}
}