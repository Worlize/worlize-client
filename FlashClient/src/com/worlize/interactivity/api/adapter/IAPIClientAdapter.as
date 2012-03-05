package com.worlize.interactivity.api.adapter
{
	import com.worlize.interactivity.api.APIController;
	import com.worlize.interactivity.api.AppLoader;
	import com.worlize.interactivity.model.InteractivityUser;
	import com.worlize.interactivity.record.ChatRecord;
	
	import flash.events.UncaughtErrorEvent;

	public interface IAPIClientAdapter
	{
		function get state():uint;
		function attachHost(host:APIController):void;
		function attachClient(client:AppLoader):void;
		function handshakeClient(handshakeData:Object):void;
		function handleUncaughtError(event:UncaughtErrorEvent):void;
		function unload():void;
		
		// Methods to be called from the host.
		function processChat(record:ChatRecord):void;
		function userEntered(user:InteractivityUser):void;
		function userLeft(user:InteractivityUser):void;
		function allUsersLeft():void;
		function userMoved(user:InteractivityUser):void;
		function userFaceChanged(user:InteractivityUser):void;
		function userColorChanged(user:InteractivityUser):void;
		function userAvatarChanged(user:InteractivityUser):void;
		function roomDimLevelChanged(dimLevel:int):void;
	}
}