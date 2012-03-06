package com.worlize.interactivity.api.adapter
{
	import com.worlize.interactivity.api.APIController;
	import com.worlize.interactivity.api.AppLoader;
	import com.worlize.interactivity.model.InteractivityUser;
	import com.worlize.interactivity.record.ChatRecord;
	import com.worlize.model.InWorldObjectInstance;
	
	import flash.events.MouseEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.ui.Mouse;

	public interface IAPIClientAdapter
	{
		function get state():uint;
		function get appGuid():String;		
		
		// Called from AppLoader to attach the adapter
		function attachHost(host:APIController):void;
		function attachClient(client:AppLoader):void;
		
		// Called from AppLoader which handles the first handshake event from
		// the client.  The adapter should do what is necessary to wire up
		// further communications with the loaded SWF client app here.
		function handshakeClient(handshakeData:Object):void;
		
		// When an uncaught error happens in the embedded client, this function
		// is called by AppLoader to handle it, which probably means logging the
		// error.
		function handleUncaughtError(event:UncaughtErrorEvent):void;
		
		// This function is called by AppLoader when the embedded SWF is being
		// unloaded and we need to clean up after ourselves.
		function unload():void;
		
		// Methods to be called from the host.
		function authorModeChanged(enabled:Boolean):void;
		function processChat(record:ChatRecord):void;
		function userEntered(user:InteractivityUser):void;
		function userLeft(user:InteractivityUser):void;
		function allUsersLeft():void;
		function objectAdded(roomObject:InWorldObjectInstance):void;
		function objectRemoved(roomObject:InWorldObjectInstance):void;
		function objectMoved(roomObject:InWorldObjectInstance):void;
		function objectResized(roomObject:InWorldObjectInstance):void;
		function userMoved(user:InteractivityUser):void;
		function userFaceChanged(user:InteractivityUser):void;
		function userColorChanged(user:InteractivityUser):void;
		function userAvatarChanged(user:InteractivityUser):void;
		function roomDimLevelChanged(dimLevel:int):void;
		function receiveMessage(message:String, fromGuid:String):void;
		function roomMouseMove(event:MouseEvent):void;
		function applicationMouseUp(event:MouseEvent):void;
	}
}