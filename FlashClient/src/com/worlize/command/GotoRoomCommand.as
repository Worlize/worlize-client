package com.worlize.command
{
	import com.worlize.event.GotoRoomResultEvent;
	import com.worlize.model.InteractivitySession;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.rpc.events.FaultEvent;

	[Event(name='gotoRoomResult', type='com.worlize.event.GotoRoomResultEvent')]
	public class GotoRoomCommand extends EventDispatcher
	{
		public function GotoRoomCommand(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function execute(roomGuid:String):void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send('/rooms/' + roomGuid + '/enter.json', HTTPMethod.POST);
		}
		
		private function handleResult(event:WorlizeResultEvent):void {
			if (event.resultJSON.success) {
				var resultEvent:GotoRoomResultEvent = new GotoRoomResultEvent(GotoRoomResultEvent.GOTO_ROOM_RESULT);
				resultEvent.interactivitySession = InteractivitySession.fromData(event.resultJSON.interactivity_session);
				dispatchEvent(resultEvent);
			}
		}
		private function handleFault(event:FaultEvent):void {
			dispatchEvent(event.clone());
		}
	}
}