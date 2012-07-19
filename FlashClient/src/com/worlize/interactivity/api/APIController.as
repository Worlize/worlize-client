package com.worlize.interactivity.api
{
	import com.worlize.event.AuthorModeNotification;
	import com.worlize.event.NotificationCenter;
	import com.worlize.interactivity.api.adapter.ClientAdapterV1;
	import com.worlize.interactivity.api.adapter.IAPIClientAdapter;
	import com.worlize.interactivity.event.ChatEvent;
	import com.worlize.interactivity.event.LoosePropEvent;
	import com.worlize.interactivity.event.RoomEvent;
	import com.worlize.interactivity.model.CurrentRoom;
	import com.worlize.interactivity.model.ILinkableRoomItem;
	import com.worlize.interactivity.model.InteractivityUser;
	import com.worlize.interactivity.model.LooseProp;
	import com.worlize.interactivity.record.ChatRecord;
	import com.worlize.interactivity.rpc.InteractivityClient;
	import com.worlize.model.WorldDefinition;
	import com.worlize.state.AuthorModeState;
	
	import flash.events.MouseEvent;
	import flash.utils.ByteArray;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.events.PropertyChangeEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class APIController
	{
		private var logger:ILogger = Log.getLogger('com.worlize.interactivity.api.APIController');
		
		public static const GUID_REGEXP:RegExp =
			/^[\da-fA-F]{8}-[\da-fA-F]{4}-[\da-fA-F]{4}-[\da-fA-F]{4}-[\da-fA-F]{12}$/;
		
		protected var interactivityClient:InteractivityClient;
		
		protected var apiClientAdapters:Vector.<IAPIClientAdapter>;
		
		protected var apiClientAdaptersByGuid:Object;
		
		protected var mouseEventsAdded:Boolean = false;
		
		public function APIController(interactivityClient:InteractivityClient) {
			apiClientAdapters = new Vector.<IAPIClientAdapter>();
			apiClientAdaptersByGuid = {};
			this.interactivityClient = interactivityClient;
			addInteractivityClientEvents();
			addNotificationListeners();
			logger.debug("APIController Instantiated.");
		}
		
		protected var dimLevelChangeWatcher:ChangeWatcher;
		protected var roomNameChangeWatcher:ChangeWatcher;
		
		protected function addMouseEvents():void {
			if (mouseEventsAdded) { return; }
			FlexGlobals.topLevelApplication.addEventListener(MouseEvent.MOUSE_UP, handleApplicationMouseUp);
			thisRoom.roomView.addEventListener("customMouseMove", handleRoomMouseMove);
			mouseEventsAdded = true;
		}
		
		protected function removeMouseEvents():void {
			mouseEventsAdded = false;
			FlexGlobals.topLevelApplication.removeEventListener(MouseEvent.MOUSE_UP, handleApplicationMouseUp);
			thisRoom.roomView.removeEventListener("customMouseMove", handleRoomMouseMove);
		}
		
		protected function addInteractivityClientEvents():void {
			var room:CurrentRoom = interactivityClient.currentRoom;
			room.addEventListener(RoomEvent.USER_ENTERED, handleUserEntered);
			room.addEventListener(RoomEvent.USER_LEFT, handleUserLeft);
			room.addEventListener(RoomEvent.USER_MOVED, handleUserMoved);
			room.addEventListener(RoomEvent.ROOM_CLEARED, handleRoomCleared);
			room.addEventListener(RoomEvent.ITEM_ADDED, handleItemAdded);
			room.addEventListener(RoomEvent.ITEM_REMOVED, handleItemRemoved);
			room.addEventListener(RoomEvent.ITEM_MOVED, handleItemMoved);
			room.addEventListener(RoomEvent.ITEM_RESIZED, handleItemResized);
			room.addEventListener(RoomEvent.ITEM_DEST_CHANGED, handleItemDestChanged);
			room.addEventListener(RoomEvent.APP_STATE_CHANGED, handleAppStateChanged);
			room.loosePropList.addEventListener(LoosePropEvent.PROP_ADDED, handleLoosePropAdded);
			room.loosePropList.addEventListener(LoosePropEvent.PROP_REMOVED, handleLoosePropRemoved);
			room.loosePropList.addEventListener(LoosePropEvent.PROP_MOVED, handleLoosePropMoved);
			room.loosePropList.addEventListener(LoosePropEvent.PROPS_RESET, handleLoosePropsReset);
			room.loosePropList.addEventListener(LoosePropEvent.PROP_BROUGHT_FORWARD, handleLoosePropBroughtForward);
			room.loosePropList.addEventListener(LoosePropEvent.PROP_SENT_BACKWARD, handleLoosePropSentBackward);
			dimLevelChangeWatcher = ChangeWatcher.watch(room, 'dimLevel', handleRoomDimLevelChanged);
			roomNameChangeWatcher = ChangeWatcher.watch(room, 'name', handleRoomNameChanged);
		}
		
		protected function removeInteractivityClientEvents():void {
			var room:CurrentRoom = interactivityClient.currentRoom;
			room.removeEventListener(RoomEvent.USER_ENTERED, handleUserEntered);
			room.removeEventListener(RoomEvent.USER_LEFT, handleUserLeft);
			room.removeEventListener(RoomEvent.USER_MOVED, handleUserMoved);
			room.removeEventListener(RoomEvent.ROOM_CLEARED, handleRoomCleared);
			room.removeEventListener(RoomEvent.ITEM_ADDED, handleItemAdded);
			room.removeEventListener(RoomEvent.ITEM_REMOVED, handleItemRemoved);
			room.removeEventListener(RoomEvent.ITEM_MOVED, handleItemMoved);
			room.removeEventListener(RoomEvent.ITEM_RESIZED, handleItemResized);
			room.removeEventListener(RoomEvent.APP_STATE_CHANGED, handleAppStateChanged);
			room.loosePropList.removeEventListener(LoosePropEvent.PROP_ADDED, handleLoosePropAdded);
			room.loosePropList.removeEventListener(LoosePropEvent.PROP_REMOVED, handleLoosePropRemoved);
			room.loosePropList.removeEventListener(LoosePropEvent.PROP_MOVED, handleLoosePropMoved);
			room.loosePropList.removeEventListener(LoosePropEvent.PROPS_RESET, handleLoosePropsReset);
			room.loosePropList.removeEventListener(LoosePropEvent.PROP_BROUGHT_FORWARD, handleLoosePropBroughtForward);
			room.loosePropList.removeEventListener(LoosePropEvent.PROP_SENT_BACKWARD, handleLoosePropSentBackward);
			dimLevelChangeWatcher.unwatch();
			dimLevelChangeWatcher = null;
			roomNameChangeWatcher.unwatch();
			roomNameChangeWatcher = null;
		}
		
		protected function addNotificationListeners():void {
			NotificationCenter.addListener(AuthorModeNotification.AUTHOR_ENABLED, handleAuthorEnabled);
			NotificationCenter.addListener(AuthorModeNotification.AUTHOR_DISABLED, handleAuthorDisabled);
			NotificationCenter.addListener(AuthorModeNotification.EDIT_MODE_ENABLED, handleEditModeEnabled);
			NotificationCenter.addListener(AuthorModeNotification.EDIT_MODE_DISABLED, handleEditModeDisabled);
		}
		
		protected function removeNotificationListeners():void {
			NotificationCenter.removeListener(AuthorModeNotification.AUTHOR_ENABLED, handleAuthorEnabled);
			NotificationCenter.removeListener(AuthorModeNotification.AUTHOR_DISABLED, handleAuthorDisabled);
			NotificationCenter.removeListener(AuthorModeNotification.EDIT_MODE_ENABLED, handleEditModeEnabled);
			NotificationCenter.removeListener(AuthorModeNotification.EDIT_MODE_DISABLED, handleEditModeDisabled);
		}

		public function getClientAdapterForVersion(version:int):IAPIClientAdapter {
			var adapter:IAPIClientAdapter = null;
			if (version >= 1 && version <= 4) {
				// ClientAdapterV1 handles api versions 1-4.
				adapter = new ClientAdapterV1();
			}
			else {
				logger.error("Unable to provide API Client Adapter for requested API version: " + version);
			}
			return adapter;
		}
		
		public function addClientAdapter(client:IAPIClientAdapter):void {
			if (!mouseEventsAdded) {
				addMouseEvents();
			}
			if (apiClientAdapters.indexOf(client) === -1) {
				apiClientAdapters.push(client);
				apiClientAdaptersByGuid[client.appInstanceGuid] = client;
			}
		}
		
		public function removeClientAdapter(client:IAPIClientAdapter):void {
			delete apiClientAdaptersByGuid[client.appInstanceGuid];
			var index:int = apiClientAdapters.indexOf(client);
			if (index !== -1) {
				apiClientAdapters.splice(index, 1);
			}
			if (apiClientAdapters.length === 0) {
				removeMouseEvents();
			}
		}
		
		public function getClientAdapters():Vector.<IAPIClientAdapter> {
			return apiClientAdapters.slice();
		}
		
		public function getClientByGuid(guid:String):IAPIClientAdapter {
			return apiClientAdaptersByGuid[guid];
		}
		
		// Mouse Event Handlers
		protected function handleApplicationMouseUp(event:MouseEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.applicationMouseUp(event);
			}
		}
		
		protected function handleRoomMouseMove(event:MouseEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.roomMouseMove(event);
			}
		}
		
		// Notification Handlers
		protected function handleAuthorEnabled(notification:AuthorModeNotification):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.authorModeChanged(true);
			}
		}
		
		protected function handleAuthorDisabled(notification:AuthorModeNotification):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.authorModeChanged(false);
			}
		}
		
		protected function handleEditModeEnabled(notification:AuthorModeNotification):void {
			if (notification.roomItem) {
				var client:IAPIClientAdapter = getClientByGuid(notification.roomItem.guid);
				if (client) {
					client.editModeChanged(true);
				}
			}
		}
		
		protected function handleEditModeDisabled(notification:AuthorModeNotification):void {
			if (notification.roomItem) {
				var client:IAPIClientAdapter = getClientByGuid(notification.roomItem.guid);
				if (client) {
					client.editModeChanged(false);
				}
			}
		}
		
		
		// Room Event Handlers
		protected function handleUserEntered(event:RoomEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.userEntered(event.user);
			}
		}
		
		protected function handleUserLeft(event:RoomEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.userLeft(event.user);
			}
		}
		
		protected function handleUserMoved(event:RoomEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.userMoved(event.user);
			}
		}
		
		protected function handleRoomCleared(event:RoomEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.allUsersLeft();
			}
		}
		
		protected function handleItemAdded(event:RoomEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.itemAdded(event.roomItem);
			}
		}
		
		protected function handleItemRemoved(event:RoomEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.itemRemoved(event.roomItem);
			}
		}
		
		protected function handleItemMoved(event:RoomEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.itemMoved(event.roomItem);
			}
		}
		
		protected function handleItemResized(event:RoomEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.itemResized(event.roomItem);
			}
		}
		
		protected function handleItemDestChanged(event:RoomEvent):void {
			if (!(event.roomItem is ILinkableRoomItem)) { return; }
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.itemDestChanged(ILinkableRoomItem(event.roomItem));
			}
		}
		
		protected function handleAppStateChanged(event:RoomEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.appStateChanged(event.appInstance);
			}
		}
		
		protected function handleRoomDimLevelChanged(event:PropertyChangeEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.roomDimLevelChanged(Math.round(int(event.newValue)*100));
			}
		}
		
		protected function handleRoomNameChanged(event:PropertyChangeEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.roomNameChanged(interactivityClient.currentRoom.id, interactivityClient.currentRoom.name);
			}
		}
		
		protected function handleLoosePropAdded(event:LoosePropEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.loosePropAdded(event.looseProp);
			}
		}
		
		protected function handleLoosePropRemoved(event:LoosePropEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.loosePropRemoved(event.looseProp.id);
			}
		}
		
		protected function handleLoosePropMoved(event:LoosePropEvent):void {
			var looseProp:LooseProp = event.looseProp;
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.loosePropMoved(looseProp.id, looseProp.x, looseProp.y);
			}
		}
		
		protected function handleLoosePropsReset(event:LoosePropEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.loosePropsReset();
			}
		}
		
		protected function handleLoosePropBroughtForward(event:LoosePropEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.loosePropBroughtForward(event.looseProp.id, event.layerCount);
			}	
		}
		
		protected function handleLoosePropSentBackward(event:LoosePropEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.loosePropSentBackward(event.looseProp.id, event.layerCount);
			}
		}
		
		
		// Public Getters
		
		public function get thisUser():InteractivityUser {
			return interactivityClient.currentRoom.getSelfUser();
		}
		
		public function get thisRoom():CurrentRoom {
			return interactivityClient.currentRoom;
		}
		
		public function get thisWorld():WorldDefinition {
			return interactivityClient.currentWorld;
		}
		
		public function get authorMode():Boolean {
			return AuthorModeState.getInstance().enabled;
		}
		
		
		// Methods meant to be called from the client
		public function addErrorToLog(message:String):void {
			thisRoom.logMessage(message);
		}
		
		public function logMessage(message:String, appGuid:String = null):void {
			thisRoom.logMessage(message);
		}
		
		public function localMessage(message:String, appGuid:String = null):void {
			thisRoom.localMessage(message);
		}
		
		public function roomMessage(message:String, appGuid:String = null):void {
			interactivityClient.roomMessage(message);
		}
		
		public function moveThisUser(x:int, y:int):void {
			interactivityClient.move(x, y);
		}
		
		public function setThisUserColor(face:int):void {
			interactivityClient.setFace(face);
		}
		
		public function setThisUserBalloonColor(color:int):void {
			interactivityClient.setColor(color);
		}
		
		public function setThisUserNaked():void {
			interactivityClient.naked();
		}
		
		public function setThisUserAvatar(avatar:String):void {
			if (avatar !== null && avatar.match(GUID_REGEXP)) {
				interactivityClient.setSimpleAvatar(avatar);
			}
		}
		
		public function gotoRoom(roomGuid:String, insertHistory:Boolean = true):void {
			if (roomGuid !== null && roomGuid.search(GUID_REGEXP) !== -1) {
				interactivityClient.gotoRoom(roomGuid, insertHistory);
			}
		}
		
		public function say(text:String, whisperToUserGuid:String):void {
			if (text) {
				if (whisperToUserGuid) {
					// It's a whisper
					var recipient:InteractivityUser = thisRoom.getUserById(whisperToUserGuid);
					if (recipient) {
						// make sure we have a real recipient
						interactivityClient.privateMessage(text, recipient.id);
					}
				}
				else {
					interactivityClient.say(text);
				}
			}
		}
		
		public function dimRoom(dimLevel:int):void {
			thisRoom.dimRoom(dimLevel);
		}
		
		public function lockRoom():void {
			interactivityClient.lockRoom();
		}
		
		public function unlockRoom():void {
			interactivityClient.unlockRoom();
		}
		
		public function moveItem(objectGuid:String, x:int, y:int):void {
			thisRoom.moveItem(objectGuid, x, y);
		}
		
		public function resizeItem(objectGuid:String, width:int, height:int):void {
			thisRoom.resizeItem(objectGuid, width, height);
		}
		
		// Broadcast a data message to the specified object via the server for
		// event synchronization across clients.
		public function sendAppMessage(fromAppInstanceGuid:String, message:ByteArray, toAppInstanceGuid:String, toUserGuids:Array=null):void {
			var specificUsersRequested:Boolean = false;
			var fromAdapter:IAPIClientAdapter = apiClientAdaptersByGuid[fromAppInstanceGuid];
			if (fromAdapter && message) {
				if (toUserGuids && toUserGuids.length > 0) {
					specificUsersRequested = true;
					for (var i:int = toUserGuids.length - 1; i >= 0; i--) {
						var guidObj:* = toUserGuids[i];
						if (!(guidObj is String) || thisRoom.getUserById(guidObj) === null) {
							toUserGuids.splice(i, 1);
						}
					}
				}
				if (specificUsersRequested && toUserGuids.length === 0) {
					return;
				}
				interactivityClient.broadcastAppMessage(fromAppInstanceGuid, message, toAppInstanceGuid, toUserGuids);
			}
		}
		
		// Broadcast a data message to the specified object on this computer
		// only, without going through the server.
		public function sendAppMessageLocal(fromAppInstanceGuid:String, message:ByteArray, toAppInstanceGuid:String, fromUserGuid:String):void {
			var fromUser:InteractivityUser = thisRoom.getUserById(fromUserGuid);
			var fromAdapter:IAPIClientAdapter = apiClientAdaptersByGuid[fromAppInstanceGuid];
			if (fromAdapter) {
				if (toAppInstanceGuid !== null) {
					var toAdapter:IAPIClientAdapter = apiClientAdaptersByGuid[toAppInstanceGuid];
					if (toAdapter) {
						toAdapter.receiveMessage(message, fromAdapter.appInstanceGuid, fromUser ? fromUserGuid : null);
					}
				}
				else {
					// broadcast to all objects
					for each (var client:IAPIClientAdapter in apiClientAdapters) {
						client.receiveMessage(message, fromAdapter.appInstanceGuid, fromUser ? fromUserGuid : null);
					}
				}
			}
		}
		
		public function stateHistoryPush(appInstanceGuid:String, data:ByteArray):void {
			interactivityClient.stateHistoryPush(appInstanceGuid, data);
		}
		
		public function stateHistoryShift(appInstanceGuid:String):void {
			interactivityClient.stateHistoryShift(appInstanceGuid);
		}
		
		public function stateHistoryClear(appInstanceGuid:String, initialData:ByteArray = null):void {
			interactivityClient.stateHistoryClear(appInstanceGuid, initialData);
		}
		
		public function syncedDataSet(appInstanceGuid:String, key:String, value:ByteArray):void {
			interactivityClient.syncedDataSet(appInstanceGuid, key, value);
		}
		
		public function syncedDataDelete(appInstanceGuid:String, key:String):void {
			interactivityClient.syncedDataDelete(appInstanceGuid, key);
		}
		
		public function saveAppConfig(appInstanceGuid:String, configData:Object):void {
			if (thisUser.id === thisRoom.ownerGuid) {
				interactivityClient.saveAppConfig(appInstanceGuid, configData);
			}
		}
		
		public function addLooseProp(guid:String, x:int, y:int):void {
			interactivityClient.addLooseProp(guid, x, y);
		}
		
		public function removeLooseProp(id:uint):void {
			interactivityClient.removeLooseProp(id);
		}
		
		public function moveLooseProp(id:uint, x:int, y:int):void {
			interactivityClient.moveLooseProp(id, x, y);
		}
		
		public function bringLoosePropForward(id:uint, layerCount:int = 1):void {
			interactivityClient.bringLoosePropForward(id, layerCount);
		}
		
		public function sendLoosePropBackward(id:uint, layerCount:int = 1):void {
			interactivityClient.sendLoosePropBackward(id, layerCount);
		}
		
		public function clearLooseProps():void {
			interactivityClient.clearLooseProps();
		}
		
		
		
		// Methods meant to be called by InteractivityClient
		
		public function processChat(record:ChatRecord):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.processChat(record);
			}
			if (record.canceled) {
				record.chatstr = "";
			}
		}
		
		public function userAvatarChanged(user:InteractivityUser):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.userAvatarChanged(user);
			}
		}
		
		public function userPermissionsChanged(user:InteractivityUser):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.userPermissionsChanged(user);
			}
		}
		
		public function userColorChanged(user:InteractivityUser):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.userColorChanged(user);
			}
		}
		
		public function userBalloonColorChanged(user:InteractivityUser):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.userBalloonColorChanged(user);
			}
		}
		
		public function roomLocked(userGuid:String):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.roomLocked(userGuid);
			}
		}
		
		public function roomUnlocked(userGuid:String):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.roomUnlocked(userGuid);
			}
		}
		
		public function receiveStateHistoryPush(appInstanceGuid:String, data:ByteArray):void {
			var client:IAPIClientAdapter = getClientByGuid(appInstanceGuid);
			if (client) {
				client.receiveStateHistoryPush(data);
			}
		}
		
		public function receiveStateHistoryShift(appInstanceGuid:String):void {
			var client:IAPIClientAdapter = getClientByGuid(appInstanceGuid);
			if (client) {
				client.receiveStateHistoryShift();
			}
		}
		
		public function receiveStateHistoryClear(appInstanceGuid:String):void {
			var client:IAPIClientAdapter = getClientByGuid(appInstanceGuid);
			if (client) {
				client.receiveStateHistoryClear();
			}
		}
		
		public function receiveSyncedDataSet(appInstanceGuid:String, key:String, value:ByteArray):void {
			var client:IAPIClientAdapter = getClientByGuid(appInstanceGuid);
			if (client) {
				client.receiveSyncedDataSet(key, value);
			}
		}
		
		public function receiveSyncedDataDelete(appInstanceGuid:String, key:String):void {
			var client:IAPIClientAdapter = getClientByGuid(appInstanceGuid);
			if (client) {
				client.receiveSyncedDataDelete(key);
			}
		}
		
		public function receiveSaveAppConfig(appInstanceGuid:String, changedByUserGuid:String, config:Object):void {
			var client:IAPIClientAdapter = getClientByGuid(appInstanceGuid);
			if (client) {
				client.receiveSaveAppConfig(changedByUserGuid, config);
			}
		}
	}
}