package com.worlize.command
{
	import com.worlize.model.RoomDefinition;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.rpc.events.FaultEvent;
	
	import com.worlize.interactivity.model.CurrentRoom;
	import com.worlize.interactivity.model.Hotspot;
	
	public class CreateHotspotCommand extends EventDispatcher
	{
		public var currentRoom:CurrentRoom;
		
		public function CreateHotspotCommand(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function execute(roomGuid:String):void {
			var service:WorlizeServiceClient = new WorlizeServiceClient();
			service.addEventListener(FaultEvent.FAULT, handleFault);
			service.send("/rooms/" + roomGuid + "/hotspots", HTTPMethod.POST)				
		}
		
		private function handleFault(event:FaultEvent):void {
			trace("Error creating new hotspot");
		}
	}
}