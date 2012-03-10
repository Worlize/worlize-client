package com.worlize.interactivity.api
{
	import com.worlize.event.AuthorModeNotification;
	import com.worlize.event.NotificationCenter;
	import com.worlize.interactivity.api.adapter.ClientAdapterV1;
	import com.worlize.interactivity.api.adapter.IAPIClientAdapter;
	import com.worlize.interactivity.event.ChatEvent;
	import com.worlize.interactivity.event.RoomEvent;
	import com.worlize.interactivity.model.CurrentRoom;
	import com.worlize.interactivity.model.InteractivityUser;
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
		
		protected function addMouseEvents():void {
			if (mouseEventsAdded) { return; }
			FlexGlobals.topLevelApplication.addEventListener(MouseEvent.MOUSE_UP, handleApplicationMouseUp);
			thisRoom.roomView.addEventListener(MouseEvent.MOUSE_MOVE, handleRoomMouseMove);
			mouseEventsAdded = true;
		}
		
		protected function removeMouseEvents():void {
			mouseEventsAdded = false;
			FlexGlobals.topLevelApplication.removeEventListener(MouseEvent.MOUSE_UP, handleApplicationMouseUp);
			thisRoom.roomView.removeEventListener(MouseEvent.MOUSE_MOVE, handleRoomMouseMove);
		}
		
		protected function addInteractivityClientEvents():void {
			var room:CurrentRoom = interactivityClient.currentRoom;
			room.addEventListener(RoomEvent.USER_ENTERED, handleUserEntered);
			room.addEventListener(RoomEvent.USER_LEFT, handleUserLeft);
			room.addEventListener(RoomEvent.USER_MOVED, handleUserMoved);
			room.addEventListener(RoomEvent.ROOM_CLEARED, handleRoomCleared);
			room.addEventListener(RoomEvent.OBJECT_ADDED, handleObjectAdded);
			room.addEventListener(RoomEvent.OBJECT_REMOVED, handleObjectRemoved);
			room.addEventListener(RoomEvent.OBJECT_MOVED, handleObjectMoved);
			room.addEventListener(RoomEvent.OBJECT_RESIZED, handleObjectResized);
			room.addEventListener(RoomEvent.OBJECT_STATE_CHANGED, handleObjectStateChanged);
			dimLevelChangeWatcher = ChangeWatcher.watch(room, 'dimLevel', handleRoomDimLevelChanged);
		}
		
		protected function removeInteractivityClientEvents():void {
			var room:CurrentRoom = interactivityClient.currentRoom;
			room.removeEventListener(RoomEvent.USER_ENTERED, handleUserEntered);
			room.removeEventListener(RoomEvent.USER_LEFT, handleUserLeft);
			room.removeEventListener(RoomEvent.USER_MOVED, handleUserMoved);
			room.removeEventListener(RoomEvent.ROOM_CLEARED, handleRoomCleared);
			room.removeEventListener(RoomEvent.OBJECT_ADDED, handleObjectAdded);
			room.removeEventListener(RoomEvent.OBJECT_REMOVED, handleObjectRemoved);
			room.removeEventListener(RoomEvent.OBJECT_MOVED, handleObjectMoved);
			room.removeEventListener(RoomEvent.OBJECT_RESIZED, handleObjectResized);
			room.removeEventListener(RoomEvent.OBJECT_STATE_CHANGED, handleObjectStateChanged);
			dimLevelChangeWatcher.unwatch();
		}
		
		protected function addNotificationListeners():void {
			NotificationCenter.addListener(AuthorModeNotification.AUTHOR_ENABLED, handleAuthorEnabled);
			NotificationCenter.addListener(AuthorModeNotification.AUTHOR_DISABLED, handleAuthorDisabled);
		}
		
		protected function removeNotificationListeners():void {
			NotificationCenter.removeListener(AuthorModeNotification.AUTHOR_ENABLED, handleAuthorEnabled);
			NotificationCenter.removeListener(AuthorModeNotification.AUTHOR_DISABLED, handleAuthorDisabled);
		}

		public function getClientAdapterForVersion(version:int):IAPIClientAdapter {
			var adapter:IAPIClientAdapter = null;
			switch (version) {
				case 1:
					adapter = new ClientAdapterV1();
					break;
				default:
					logger.error("Unable to provide API Client Adapter for requested API version: " + version);
					break;
			}
			return adapter;
		}
		
		public function addClientAdapter(client:IAPIClientAdapter):void {
			if (!mouseEventsAdded) {
				addMouseEvents();
			}
			if (apiClientAdapters.indexOf(client) === -1) {
				apiClientAdapters.push(client);
				apiClientAdaptersByGuid[client.appGuid] = client;
			}
		}
		
		public function removeClientAdapter(client:IAPIClientAdapter):void {
			delete apiClientAdaptersByGuid[client.appGuid];
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
		
		protected function handleObjectAdded(event:RoomEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.objectAdded(event.roomObject);
			}
		}
		
		protected function handleObjectRemoved(event:RoomEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.objectRemoved(event.roomObject);
			}
		}
		
		protected function handleObjectMoved(event:RoomEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.objectMoved(event.roomObject);
			}
		}
		
		protected function handleObjectResized(event:RoomEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.objectResized(event.roomObject);
			}
		}
		
		protected function handleObjectStateChanged(event:RoomEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.objectStateChanged(event.roomObject);
			}
		}
		
		protected function handleRoomDimLevelChanged(event:PropertyChangeEvent):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.roomDimLevelChanged(Math.round(int(event.newValue)*100));
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
		
		public function setThisUserFace(face:int):void {
			interactivityClient.setFace(face);
		}
		
		public function setThisUserColor(color:int):void {
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
		
		public function moveObject(objectGuid:String, x:int, y:int):void {
			thisRoom.moveObject(objectGuid, x, y);
		}
		
		public function resizeObject(objectGuid:String, width:int, height:int):void {
			thisRoom.resizeObject(objectGuid, width, height);
		}
		
		// Broadcast a data message to the specified object via the server for
		// event synchronization across clients.
		public function sendObjectMessage(fromAppInstanceGuid:String, message:ByteArray, toAppInstanceGuid:String, toUserGuid:String=null):void {
			var fromAdapter:IAPIClientAdapter = apiClientAdaptersByGuid[fromAppInstanceGuid];
			if (fromAdapter && message) {
				if (toUserGuid !== null && thisRoom.getUserById(toUserGuid) === null) {
					return;
				}
				interactivityClient.broadcastObjectMessage(fromAppInstanceGuid, message, toAppInstanceGuid, toUserGuid);
			}
		}
		
		// Broadcast a data message to the specified object on this computer
		// only, without going through the server.
		public function sendObjectMessageLocal(fromAppInstanceGuid:String, message:ByteArray, toAppInstanceGuid:String, fromUserGuid:String):void {
			var fromUser:InteractivityUser = thisRoom.getUserById(fromUserGuid);
			var fromAdapter:IAPIClientAdapter = apiClientAdaptersByGuid[fromAppInstanceGuid];
			if (fromAdapter) {
				if (toAppInstanceGuid !== null) {
					var toAdapter:IAPIClientAdapter = apiClientAdaptersByGuid[toAppInstanceGuid];
					if (toAdapter) {
						toAdapter.receiveMessage(message, fromAdapter.appGuid, fromUser? fromUserGuid : null);
					}
				}
				else {
					// broadcast to all objects
					for each (var client:IAPIClientAdapter in apiClientAdapters) {
						client.receiveMessage(message, fromAdapter.appGuid, fromUser ? fromUserGuid : null);
					}
				}
			}
		}
		
		
		// Methods meant to be called by InteractivityClient
		
		public function processChat(record:ChatRecord):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.processChat(record);
			}
		}
		
		public function userAvatarChanged(user:InteractivityUser):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.userAvatarChanged(user);
			}
		}
		
		public function userFaceChanged(user:InteractivityUser):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.userFaceChanged(user);
			}
		}
		
		public function userColorChanged(user:InteractivityUser):void {
			for each (var client:IAPIClientAdapter in apiClientAdapters) {
				client.userColorChanged(user);
			}
		}
	}
}