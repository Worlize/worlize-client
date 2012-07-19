package com.worlize.interactivity.api.adapter
{
	import com.worlize.interactivity.api.APIController;
	import com.worlize.interactivity.api.AppLoader;
	import com.worlize.interactivity.model.ILinkableRoomItem;
	import com.worlize.interactivity.model.IRoomItem;
	import com.worlize.interactivity.model.InteractivityUser;
	import com.worlize.interactivity.model.LooseProp;
	import com.worlize.interactivity.record.ChatRecord;
	import com.worlize.model.AppInstance;
	
	import flash.events.MouseEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.ui.Mouse;
	import flash.utils.ByteArray;

	public interface IAPIClientAdapter
	{
		function get state():String;
		function get appInstanceGuid():String;		
		
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
		function editModeChanged(enabled:Boolean):void;
		function processChat(record:ChatRecord):void;
		function userEntered(user:InteractivityUser):void;
		function userLeft(user:InteractivityUser):void;
		function allUsersLeft():void;
		function itemAdded(item:IRoomItem):void;
		function itemRemoved(item:IRoomItem):void;
		function itemMoved(item:IRoomItem):void;
		function itemResized(item:IRoomItem):void;
		function itemDestChanged(item:ILinkableRoomItem):void;
		function appStateChanged(appInstance:AppInstance):void;
		function userMoved(user:InteractivityUser):void;
		function userColorChanged(user:InteractivityUser):void;
		function userBalloonColorChanged(user:InteractivityUser):void;
		function userAvatarChanged(user:InteractivityUser):void;
		function userPermissionsChanged(user:InteractivityUser):void;
		function roomDimLevelChanged(dimLevel:int):void;
		function roomNameChanged(guid:String, name:String):void;
		function roomLocked(lockedByUserGuid:String):void;
		function roomUnlocked(unlockedByUserGuid:String):void;
		function receiveMessage(message:ByteArray, fromAppInstanceGuid:String, fromUserGuid:String):void;
		function receiveStateHistoryPush(data:ByteArray):void;
		function receiveStateHistoryShift():void;
		function receiveStateHistoryClear():void;
		function receiveSyncedDataSet(key:String, value:ByteArray):void;
		function receiveSyncedDataDelete(key:String):void;
		function receiveSaveAppConfig(changedByUserGuid:String, config:Object):void;
		function roomMouseMove(event:MouseEvent):void;
		function applicationMouseUp(event:MouseEvent):void;
		function loosePropAdded(looseProp:LooseProp):void;
		function loosePropMoved(id:uint, x:int, y:int):void;
		function loosePropRemoved(id:uint):void;
		function loosePropsReset():void;
		function loosePropBroughtForward(id:uint, layerCount:int):void;
		function loosePropSentBackward(id:uint, layerCount:int):void;
	}
}