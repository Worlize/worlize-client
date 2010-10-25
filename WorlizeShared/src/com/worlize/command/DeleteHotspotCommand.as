package com.worlize.command
{
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.FaultEvent;

	public class DeleteHotspotCommand extends EventDispatcher
	{
		public function execute(roomGuid:String, hotspotGuid:String):void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send('/rooms/' + roomGuid + '/hotspots/' + hotspotGuid, HTTPMethod.DELETE);
		}
		
		private function handleFault(event:FaultEvent):void {
			
		}
	}
}