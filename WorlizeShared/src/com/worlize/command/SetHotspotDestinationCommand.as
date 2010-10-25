package com.worlize.command
{
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.FaultEvent;

	public class SetHotspotDestinationCommand extends EventDispatcher
	{
		public function execute(roomGuid:String, hotspotGuid:String, destGuid:String):void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send("/rooms/" + roomGuid + "/hotspots/" + hotspotGuid, HTTPMethod.PUT, {
				dest: destGuid
			});
		}
		
		private function handleFault(event:FaultEvent):void {
			
		}
	}
}