package com.worlize.command
{
	import com.adobe.serialization.json.JSON;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.rpc.events.FaultEvent;
	
	public class MoveHotspotCommand extends EventDispatcher
	{		
		public function MoveHotspotCommand(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function execute(roomGuid:String, hotspotGuid:String, x:int, y:int, points:Array=null):void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			var params:Object = {
				x: x,
				y: y
			};
			if (points) {
				params['points'] = JSON.encode(points);
			}
			client.send("/rooms/" + roomGuid + "/hotspots/" + hotspotGuid + ".json", HTTPMethod.PUT, params);
		} 
		
		private function handleResult(event:WorlizeResultEvent):void {
			
		}
		private function handleFault(event:FaultEvent):void {
			
		}
	}
}