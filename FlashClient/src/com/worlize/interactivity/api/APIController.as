package com.worlize.interactivity.api
{
	import com.worlize.interactivity.api.adapter.ClientAdapterV1;
	import com.worlize.interactivity.api.adapter.IAPIClientAdapter;
	import com.worlize.interactivity.event.ChatEvent;
	import com.worlize.interactivity.event.RoomEvent;
	import com.worlize.interactivity.model.CurrentRoom;
	import com.worlize.interactivity.model.InteractivityUser;
	import com.worlize.interactivity.record.ChatRecord;
	import com.worlize.interactivity.rpc.InteractivityClient;
	import com.worlize.model.WorldDefinition;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.events.PropertyChangeEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class APIController
	{
		private var logger:ILogger = Log.getLogger('com.worlize.interactivity.api.APIController');
		
		public static const GUID_REGEXP:RegExp =
			/^[\da-fA-F]{8}-[\da-fA-F]{4}-[\da-fA-F]{4}-[\da-fA-F]{4}-[\da-fA-F]{12}$/;
		
		protected var interactivityClient:InteractivityClient;
		
		protected var apiClients:Vector.<IAPIClientAdapter>;
		
		public function APIController(interactivityClient:InteractivityClient) {
			apiClients = new Vector.<IAPIClientAdapter>();
			this.interactivityClient = interactivityClient;
			addInteractivityClientEvents()
			logger.debug("APIController Instantiated.");
		}
		
		protected var dimLevelChangeWatcher:ChangeWatcher;
		
		protected function addInteractivityClientEvents():void {
			var room:CurrentRoom = interactivityClient.currentRoom;
			room.addEventListener(RoomEvent.USER_ENTERED, handleUserEntered);
			room.addEventListener(RoomEvent.USER_LEFT, handleUserLeft);
			room.addEventListener(RoomEvent.USER_MOVED, handleUserMoved);
			room.addEventListener(RoomEvent.ROOM_CLEARED, handleRoomCleared);
			dimLevelChangeWatcher = ChangeWatcher.watch(room, 'dimLevel', handleRoomDimLevelChanged);
		}
		
		protected function removeInteractivityClientEvents():void {
			var room:CurrentRoom = interactivityClient.currentRoom;
			room.removeEventListener(RoomEvent.USER_ENTERED, handleUserEntered);
			room.removeEventListener(RoomEvent.USER_LEFT, handleUserLeft);
			room.removeEventListener(RoomEvent.USER_MOVED, handleUserMoved);
			room.removeEventListener(RoomEvent.ROOM_CLEARED, handleRoomCleared);
			dimLevelChangeWatcher.unwatch();
		}

		public function getClientAdapterForVersion(version:int):IAPIClientAdapter {
			var adapter:IAPIClientAdapter = null;
			switch (version) {
				case 1:
					adapter = new ClientAdapterV1();
					break;
				default:
					logger.error("Unable to provide client API Adapter for requested API version: " + version);
					break;
			}
			if (adapter !== null) {
				adapter.attachHost(this);
			}
			return adapter;
		}
		
		public function addClient(client:IAPIClientAdapter):void {
			if (apiClients.indexOf(client) === -1) {
				apiClients.push(client);
			}
		}
		
		public function removeClient(client:IAPIClientAdapter):void {
			var index:int = apiClients.indexOf(client);
			if (index !== -1) {
				apiClients.splice(index, 1);
			}
		}
		
		public function getClients():Vector.<IAPIClientAdapter> {
			return apiClients;
		}
		
		public function getClientByGuid(guid:String):IAPIClientAdapter {
//			for each (var client:IAPIClientAdapter in apiClients) {
//				
//			}
			return null;
		}
		
		
		// Room Event Handlers
		protected function handleUserEntered(event:RoomEvent):void {
			for each (var client:IAPIClientAdapter in apiClients) {
				client.userEntered(event.user);
			}
		}
		
		protected function handleUserLeft(event:RoomEvent):void {
			for each (var client:IAPIClientAdapter in apiClients) {
				client.userLeft(event.user);
			}
		}
		
		protected function handleUserMoved(event:RoomEvent):void {
			for each (var client:IAPIClientAdapter in apiClients) {
				client.userMoved(event.user);
			}
		}
		
		protected function handleRoomCleared(event:RoomEvent):void {
			for each (var client:IAPIClientAdapter in apiClients) {
				client.allUsersLeft();
			}
		}
		
		protected function handleRoomDimLevelChanged(event:PropertyChangeEvent):void {
			for each (var client:IAPIClientAdapter in apiClients) {
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
		
		
		
		// Methods meant to be called from the client
		public function addErrorToLog(message:String):void {
			thisRoom.logMessage(message);
		}
		
		public function logMessage(message:String):void {
			thisRoom.logMessage(message);
		}
		
		public function localMessage(message:String):void {
			thisRoom.localMessage(message);
		}
		
		public function roomMessage(message:String):void {
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
		
		public function say(text:String, whisperToGuid:String):void {
			if (text) {
				if (whisperToGuid) {
					// It's a whisper
					var recipient:InteractivityUser = thisRoom.getUserById(whisperToGuid);
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
		
		
		// Methods meant to be called by InteractivityClient
		
		public function processChat(record:ChatRecord):void {
			for each (var client:IAPIClientAdapter in apiClients) {
				client.processChat(record);
			}
		}
		
		public function userAvatarChanged(user:InteractivityUser):void {
			for each (var client:IAPIClientAdapter in apiClients) {
				client.userAvatarChanged(user);
			}
		}
		
		public function userFaceChanged(user:InteractivityUser):void {
			for each (var client:IAPIClientAdapter in apiClients) {
				client.userFaceChanged(user);
			}
		}
		
		public function userColorChanged(user:InteractivityUser):void {
			for each (var client:IAPIClientAdapter in apiClients) {
				client.userColorChanged(user);
			}
		}
	}
}