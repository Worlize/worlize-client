package com.worlize.command
{
	import com.worlize.interactivity.model.CurrentRoom;
	import com.worlize.interactivity.model.Hotspot;
	import com.worlize.model.RoomDefinition;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;
	
	public class CreateHotspotCommand extends EventDispatcher
	{
		public var currentRoom:CurrentRoom;
		
		private var logger:ILogger = Log.getLogger('com.worlize.command.CreateHotspotCommand');
		
		public function CreateHotspotCommand(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function execute(roomGuid:String):void {
			logger.info("execute()");
			var service:WorlizeServiceClient = new WorlizeServiceClient();
			service.addEventListener(FaultEvent.FAULT, handleFault);
			service.send("/rooms/" + roomGuid + "/hotspots", HTTPMethod.POST)				
		}
		
		private function handleFault(event:FaultEvent):void {
			logger.error("Error creating new hotspot");
		}
	}
}