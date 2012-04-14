package com.worlize.command
{
	import com.worlize.event.NotificationCenter;
	import com.worlize.notification.AvatarNotification;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.rpc.events.FaultEvent;
	
	import com.worlize.interactivity.view.Avatar;
	
	public class DeletePropInstanceCommand extends EventDispatcher
	{
		private var guid:String;
		
		public function execute(propGuid:String):void {
			guid = propGuid;
			var service:WorlizeServiceClient = new WorlizeServiceClient();
			service.addEventListener(WorlizeResultEvent.RESULT, handleResult);
			service.addEventListener(FaultEvent.FAULT, handleFault);
			service.send('/locker/props/' + propGuid, HTTPMethod.DELETE);
		}
		
		private function handleResult(event:WorlizeResultEvent):void {
			// This is handled by receiving an async notification through websockets.
		}
		
		private function handleFault(event:FaultEvent):void {
			// do nothing
		}
	}
}