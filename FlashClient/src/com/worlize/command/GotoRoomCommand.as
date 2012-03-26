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
		public var complete:Boolean = false;
		public var canceled:Boolean = false;
		
		public function GotoRoomCommand(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function cancel():void {
			canceled = true;
		}
		
		public function execute(roomGuid:String):void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send('/rooms/' + roomGuid + '/enter.json', HTTPMethod.POST);
		}
		
		private function handleResult(event:WorlizeResultEvent):void {
			complete = true;
			var resultEvent:GotoRoomResultEvent;
			if (canceled) { return; }
			if (event.resultJSON.success) {
				resultEvent = new GotoRoomResultEvent(GotoRoomResultEvent.GOTO_ROOM_RESULT);
				resultEvent.success = true;
				resultEvent.roomLocked = false;
				resultEvent.interactivitySession = InteractivitySession.fromData(event.resultJSON.interactivity_session);
				dispatchEvent(resultEvent);
			}
			else {
				resultEvent = new GotoRoomResultEvent(GotoRoomResultEvent.GOTO_ROOM_RESULT);
				resultEvent.success = false;
				if (event.resultJSON.room_locked) {
					resultEvent.roomLocked = true;
				}
				dispatchEvent(resultEvent);
			}
		}
		private function handleFault(event:FaultEvent):void {
			complete = true;
			if (canceled) { return; }
			dispatchEvent(event.clone());
		}
	}
}