package com.worlize.model
{
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import mx.rpc.events.FaultEvent;

	[Bindable]
	public class WorldDefinition
	{
		public var name:String;
		public var guid:String;
		
		public var roomList:RoomList;
		
		public var ownerGuid:String;
		
		public function WorldDefinition()
		{
		}
		
		public function load(worldGuid:String):void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send('/worlds/' + worldGuid, HTTPMethod.GET); 
		}
		
		private function handleResult(event:WorlizeResultEvent):void {
			if (event.resultJSON.success) {
				this.name = event.resultJSON.data.name;
				this.guid = event.resultJSON.data.guid;
				this.ownerGuid = event.resultJSON.data.owner.guid;
				if (!this.roomList) {
					this.roomList = new RoomList();
				}
				this.roomList.updateFromData(event.resultJSON.data.rooms);
				trace("Got updated worlz definition");
			}
		}
		private function handleFault(event:FaultEvent):void {
			/* Do nothing */
		}
	}
}