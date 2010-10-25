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
	
	public class DeleteAvatarInstanceCommand extends EventDispatcher
	{
		private var guid:String;
		
		public function execute(avatarGuid:String):void {
			guid = avatarGuid;
			var service:WorlizeServiceClient = new WorlizeServiceClient();
			service.addEventListener(WorlizeResultEvent.RESULT, handleResult);
			service.addEventListener(FaultEvent.FAULT, handleFault);
			service.send('/locker/avatars/' + avatarGuid, HTTPMethod.DELETE);
		}
		
		private function handleResult(event:WorlizeResultEvent):void {
			if (event.resultJSON.success) {
				var notification:AvatarNotification = new AvatarNotification(AvatarNotification.AVATAR_INSTANCE_DELETED);
				notification.deletedInstanceGuid = guid;
				NotificationCenter.postNotification(notification);
			}
		}
		
		private function handleFault(event:FaultEvent):void {
			
		}
	}
}