package com.worlize.interactivity.rpc
{
	import com.adobe.net.URI;
	import com.adobe.serialization.json.JSON;
	import com.worlize.command.GotoRoomCommand;
	import com.worlize.event.AuthorModeNotification;
	import com.worlize.event.GotoRoomResultEvent;
	import com.worlize.event.NotificationCenter;
	import com.worlize.interactivity.event.InteractivityEvent;
	import com.worlize.interactivity.event.InteractivitySecurityErrorEvent;
	import com.worlize.interactivity.event.WorlizeCommEvent;
	import com.worlize.interactivity.iptscrae.IptEventHandler;
	import com.worlize.interactivity.iptscrae.IptInteractivityController;
	import com.worlize.interactivity.model.CurrentRoom;
	import com.worlize.interactivity.model.Hotspot;
	import com.worlize.interactivity.model.InteractivityConfig;
	import com.worlize.interactivity.model.InteractivityUser;
	import com.worlize.interactivity.model.RoomHistoryManager;
	import com.worlize.interactivity.record.ChatRecord;
	import com.worlize.interactivity.view.SoundPlayer;
	import com.worlize.model.PreferencesManager;
	import com.worlize.model.RoomDefinition;
	import com.worlize.model.SimpleAvatarStore;
	import com.worlize.model.WorldDefinition;
	import com.worlize.notification.RoomChangeNotification;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeComm;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	import com.worlize.state.AuthorModeState;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.XMLSocket;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.rpc.events.FaultEvent;
	
	import org.openpalace.iptscrae.IptEngineEvent;
	import org.openpalace.iptscrae.IptTokenList;
	
	[Event(type="net.codecomposer.event.InteractivityEvent",name="connectStart")]
	[Event(type="net.codecomposer.event.InteractivityEvent",name="connectComplete")]
	[Event(type="net.codecomposer.event.InteractivityEvent",name="connectFailed")]
	[Event(type="net.codecomposer.event.InteractivityEvent",name="disconnected")]
	[Event(type="net.codecomposer.event.InteractivityEvent",name="gotoURL")]
	[Event(type="net.codecomposer.event.InteractivityEvent",name="roomChanged")]
	[Event(type="net.codecomposer.event.InteractivityEvent",name="authenticationRequested")]
	[Event(type="net.codecomposer.event.InteractivitySecurityErrorEvent",name="securityError")]
	
	public class InteractivityClient extends EventDispatcher
	{
		
		private static var instance:InteractivityClient;
		
		[Bindable]
		public static var loaderContext:LoaderContext = new LoaderContext();
		
		public var version:int;
		
		public function get id():String {
			return worlizeComm.interactivitySession.userGuid;
		}
		
		public var serverId:String;
		
		[Bindable]
		public var preferencesManager:PreferencesManager = PreferencesManager.getInstance();
		
		[Bindable]
		public var currentWorld:WorldDefinition = new WorldDefinition();
		[Bindable]
		public var utf8:Boolean = false;
		[Bindable]
		public var port:uint = 0;
		[Bindable]
		public var host:String = null;
		[Bindable]
		public var initialRoom:uint = 0;
		[Bindable]
		public var state:int = STATE_DISCONNECTED;
		[Bindable]
		public var connected:Boolean = false;
		[Bindable]
		public var connecting:Boolean = false;
		[Bindable]
		public var currentRoom:CurrentRoom = new CurrentRoom();
		
		public var roomById:Object = {};
		
		public var chatstr:String = "";
		public var whochat:String = null;
		public var needToRunSignonHandlers:Boolean = true; 
		
		private var assetRequestQueueTimer:Timer = null;
		private var assetRequestQueue:Array = [];
		private var assetRequestQueueCounter:int = 0;
		private var assetsLastRequestedAt:Date = new Date();
		
		private var chatQueue:Vector.<ChatRecord> = new Vector.<ChatRecord>;
		private var currentChatItem:ChatRecord;
		
		public var cyborgHotspot:Hotspot = new Hotspot();
		
		private var recentLogonUserIds:ArrayCollection = new ArrayCollection();
		
		private var worlizeComm:WorlizeComm = WorlizeComm.getInstance();
		
		[Bindable]
		public var iptInteractivityController:IptInteractivityController;
		
		[Bindable]
		public var roomHistoryManager:RoomHistoryManager;
		
		[Bindable]
		public var canAuthor:Boolean = false;
		
		private var expectingDisconnect:Boolean = false;
		
		private var temporaryUserFlags:int;
		// We get the user flags before we have the current user
		
		// States
		public static const STATE_DISCONNECTED:int = 0;
		public static const STATE_HANDSHAKING:int = 1;
		public static const STATE_READY:int = 2; 
		
		public static function getInstance():InteractivityClient {
			if (InteractivityClient.instance == null) {
				InteractivityClient.instance = new InteractivityClient();
			}
			return InteractivityClient.instance;
		}
		
		public function InteractivityClient()
		{
			if (InteractivityClient.instance != null) {
				throw new Error("Cannot create more than one instance of a singleton.");
			}
			
			roomHistoryManager = new RoomHistoryManager();
			roomHistoryManager.client = this;
			
			iptInteractivityController = new IptInteractivityController();
			iptInteractivityController.client = this;
			
			worlizeComm.addEventListener(WorlizeCommEvent.CONNECTED, handleConnected);
			worlizeComm.addEventListener(WorlizeCommEvent.MESSAGE, handleIncomingMessage);
			worlizeComm.addEventListener(WorlizeCommEvent.DISCONNECTED, handleDisconnected);
			
			currentWorld.load(worlizeComm.interactivitySession.worldGuid);
		}
		
		private function handleConnected(event:WorlizeCommEvent):void {
			worlizeComm.send({
				msg: "handshake",
				data: {
					session_guid: worlizeComm.interactivitySession.sessionGuid
				}
			});
		}
		
		private function handleDisconnected(event:WorlizeCommEvent):void {
			if (expectingDisconnect) {
				// do nothing
			}
			else {
				trace("Disconnected");
				resetState();
				Alert.show( "The connection to the server has been lost.  Press OK to reconnect.",
						    "Connection Lost",
						    Alert.OK,
						    null,
						  	function(event:CloseEvent):void {
								worlizeComm.connect();
							}
				);
			}
			expectingDisconnect = false;
		}
		
		private function handleIncomingMessage(event:WorlizeCommEvent):void {
			if (event.message && event.message.msg) {
				var data:Object = null;
				if (event.message['data']) {
					data = event.message.data;
				}
				switch (event.message.msg) {
					case "user_enter":
						handleUserNew(data);
						break;
					case "handshake":
						handleHandshakeResponse(data);
						break;
					case "say":
						handleReceiveTalk(data);
						break;
					case "move":
						handleMove(data);
						break;
					case "set_face":
						handleUserFace(data);
						break;
					case "set_color":
						handleUserColor(data);
						break;
					case "user_leave":
						handleUserLeaving(data);
						break;
					case "room_entered":
						handleRoomEntered(data);
						break;
					case "room_definition_updated":
						handleRoomDefinitionUpdated(data);
						break;
					case "new_hotspot":
						handleNewHotspot(data);
						break;
					case "hotspot_moved":
						handleHotspotMoved(data);
						break;
					case "hotspot_removed":
						handleHotspotRemoved(data);
						break;
					case "hotspot_dest_updated":
						handleHotspotDestUpdated(data);
						break;
					case "ping":
						handlePing(data);
						break;
					case "set_simple_avatar":
						handleSetSimpleAvatar(data);
						break;
					case "naked":
						handleNaked(data);
						break;
					case "goto_room":
						handleGotoRoomMessage(data);
						break;
					case "new_object":
						handleNewObject(data);
						break;
					case "object_moved":
						handleObjectMoved(data);
						break;
					case "object_updated": // dest changed
						handleObjectUpdated(data);
						break;
					case "object_removed":
						handleObjectRemoved(data);
						break;
					default:
						trace("Unhandled message: " + JSON.encode(event.message));
						break;
				}
			}
		}
		
		private function handleNewObject(data:Object):void {
			if (data.room == currentRoom.id && data.object) {
				currentRoom.addObject(data.object.guid, data.object.x, data.object.y, data.object.fullsize_url);
			}
		}
		
		private function handleObjectMoved(data:Object):void {
			if (data.room == currentRoom.id && data.object) {
				currentRoom.moveObject(data.object.guid, data.object.x, data.object.y);
			}
		}
		
		private function handleObjectUpdated(data:Object):void {
			if (data.room == currentRoom.id && data.object) {
				currentRoom.updateObject(data.object.guid, data.object.dest);
			}
		}
		
		private function handleObjectRemoved(data:Object):void {
			if (data.room == currentRoom.id && data.guid) {
				currentRoom.removeObject(data.guid);
			}
		}
		
		private function handleGotoRoomMessage(data:Object):void {
			var guid:String = String(data);
			gotoRoom(guid);
		}
		
		private function handleNaked(data:Object):void {
			var user:InteractivityUser = currentRoom.getUserById(data.user);
			if (user) {
				user.simpleAvatar = null;
			}
		}
		
		private function handleSetSimpleAvatar(data:Object):void {
			var user:InteractivityUser = currentRoom.getUserById(data.user);
			if (user) {
				user.simpleAvatar = SimpleAvatarStore.getInstance().getAvatar(data.avatar.guid);
			}
		}
		
		private function handlePing(data:Object):void {
			worlizeComm.send({
				msg: "pong"
			});
		}
		
		private function handleHotspotDestUpdated(data:Object):void {
			var hotspot:Hotspot = currentRoom.hotSpotsByGuid[data.guid];
			if (hotspot) {
				hotspot.dest = data.dest;
			}
		}
		
		private function handleHotspotRemoved(data:Object):void {
			var hotspot:Hotspot = currentRoom.hotSpotsByGuid[data.guid];
			if (hotspot) {
				var authorModeState:AuthorModeState = AuthorModeState.getInstance();
				if (authorModeState.selectedItem === hotspot) {
					authorModeState.selectedItem = null;
				}
				
				var index:int = currentRoom.hotSpots.getItemIndex(hotspot);
				if (index != -1) {
					currentRoom.hotSpots.removeItemAt(index);
				}
				
				index = currentRoom.hotSpotsAboveNothing.getItemIndex(hotspot);
				if (index != -1) {
					currentRoom.hotSpotsAboveNothing.removeItemAt(index);
				}
				
				delete currentRoom.hotSpotsById[hotspot.id];
				delete currentRoom.hotSpotsByGuid[hotspot.guid];
			}
		}
		
		private function handleHotspotMoved(data:Object):void {
			var hotspot:Hotspot = currentRoom.hotSpotsByGuid[data.guid];
			if (hotspot) {
				hotspot.moveTo(data.x, data.y, data.points);
			}
		}
		
		private function handleNewHotspot(data:Object):void {
			var hotspot:Hotspot = Hotspot.fromData(data)
			currentRoom.hotSpots.addItem(hotspot);
			currentRoom.hotSpotsAboveNothing.addItem(hotspot);
			currentRoom.hotSpotsByGuid[hotspot.guid] = hotspot;
			currentRoom.hotSpotsById[hotspot.id] = hotspot;
		}
		
		private function handleRoomEntered(data:Object):void {
			loadRoomDefinition(data as String);
		}
		
		private function handleRoomDefinitionUpdated(data:Object):void {
			loadRoomDefinition(currentRoom.id);
		}
		
		private function loadRoomDefinition(roomGuid:String):void {
			trace("Loading room definition for room " + roomGuid);
			var service:WorlizeServiceClient = new WorlizeServiceClient();
			service.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					var room:RoomDefinition = RoomDefinition.fromData(event.resultJSON.data.room_definition);
					currentRoom.id = room.guid;
					currentRoom.name = room.name;
					currentRoom.backgroundFile = room.backgroundImageURL;
					canAuthor = event.resultJSON.data.can_author;
					
					if (shouldInsertHistory) {
						roomHistoryManager.addItem(currentRoom.id, currentRoom.name, currentWorld.name);
					}
					
					// Hotspots:
					currentRoom.hotSpotsAboveNothing.removeAll();
					currentRoom.hotSpots.removeAll();
					currentRoom.hotSpotsByGuid = {};
					currentRoom.hotSpotsById = {};
					
					for each (var hotspot:Hotspot in room.hotspots) {
						currentRoom.hotSpots.addItem(hotspot);
						currentRoom.hotSpotsAboveNothing.addItem(hotspot);
						currentRoom.hotSpotsById[hotspot.id] = hotspot;
						currentRoom.hotSpotsByGuid[hotspot.guid] = hotspot;
					}
					
					// In-World Objects
					currentRoom.inWorldObjects.removeAll();
					currentRoom.inWorldObjectsByGuid = new Dictionary();
					for each (var objectData:Object in room.objects) {
						currentRoom.addObject(objectData.guid, objectData.x, objectData.y, objectData.fullsize_url, objectData.dest);
					}			
				}
				else {
					disconnect();
					Alert.show("Unable to load room definition.", "Error");
				}
			});
			service.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				disconnect();
				Alert.show("Unable to load room definition.", "Error");
			});
			service.send("/rooms/" + roomGuid, HTTPMethod.GET);
		}
		
		private function handleHandshakeResponse(data:Object):void {
			if (data.success) {
				connected = true;
				expectingDisconnect = false;
				var event:InteractivityEvent = new InteractivityEvent(InteractivityEvent.CONNECT_COMPLETE);
				dispatchEvent(event);
				currentRoom.selfUserId = id;
			}
			else {
				disconnect();
			}
		}
		
		public function setCyborg(cyborgScript:String):void {
			cyborgHotspot = new Hotspot();
			cyborgHotspot.scriptString = cyborgScript;
			cyborgHotspot.loadScripts();
		}
		
		public function gotoURL(url:String):void {
			var event:InteractivityEvent = new InteractivityEvent('gotoURL');
			event.url = url;
			dispatchEvent(event);
		}
		
		private function resetState():void {
			iptInteractivityController.clearAlarms();
			needToRunSignonHandlers = true;
			connected = false;
			currentRoom.name = "";
			currentRoom.backgroundFile = null;
			currentRoom.selectedUser = null;
			currentRoom.removeAllUsers();
			currentRoom.hotSpots.removeAll();
			currentRoom.hotSpotsAboveAvatars.removeAll();
			currentRoom.hotSpotsAboveEverything.removeAll();
			currentRoom.hotSpotsAboveNametags.removeAll();
			currentRoom.hotSpotsAboveNothing.removeAll();
			currentRoom.hotSpotsByGuid = {};
			currentRoom.hotSpotsById = {};
			currentRoom.drawBackCommands.removeAll();
			currentRoom.drawFrontCommands.removeAll();
			currentRoom.drawLayerHistory = new Vector.<uint>();
			currentRoom.inWorldObjects.removeAll();
			currentRoom.inWorldObjectsByGuid = {};
			currentRoom.showAvatars = true;
		}
		
		// ***************************************************************
		// Begin public functions for user interaction
		// ***************************************************************
		
		public function connect():void {
			InteractivityClient.loaderContext.checkPolicyFile = true;
			worlizeComm.connect();
		}
		
		public function disconnect():void {
			expectingDisconnect = true;
			worlizeComm.disconnect();
			resetState();
		}
		
		public function roomChat(message:String):void {
			if (!connected || message == null || message.length == 0) {
				return;
			}
			trace("Saying: " + message);

			worlizeComm.send({
				msg: "say",
				data: message
			});
		}
		
		public function privateMessage(message:String, targetUserGuid:String):void {
			if (!connected || message == null || message.length == 0) {
				return;
			}
			
			worlizeComm.send({
				msg: "whisper",
				data: {
					to_user: targetUserGuid,
					text: message
				}
			});
		}
		
		public function say(message:String):void {
			if (!connected || message == null || message.length == 0) {
				return;
			}
			
			if (handleClientCommand(message)) { return; }
			
			if (message.charAt(0) == "/") {
				// Run iptscrae
				iptInteractivityController.executeScript(message.substr(1));
				return;
			}
			
			var selectedUserId:String = currentRoom.selectedUser ?
				currentRoom.selectedUser.id : null;
			
			var chatRecord:ChatRecord = new ChatRecord(
				ChatRecord.OUTCHAT,
				currentUser.id,
				selectedUserId,
				message,
				currentRoom.selectedUser ? true : false
			);
			chatRecord.eventHandlers = iptInteractivityController.getHotspotEvents(IptEventHandler.TYPE_OUTCHAT);
			chatQueue.push(chatRecord);
			processChatQueue();
		}
		
		public function globalMessage(message:String):void {
			if (!connected || message == null || message.length == 0) {
				return;
			}
			
			if (message.length > 254) {
				message = message.substr(0, 254);
			}
			worlizeComm.send({
				msg: "global_msg",
				data: message
			});
		}
		
		public function roomMessage(message:String):void {
			if (!connected || message == null || message.length == 0) {
				return;
			}
			if (message.length > 254) {
				message = message.substr(0, 254);
			}
			
			worlizeComm.send({
				msg: "room_msg",
				data: message
			});
		}
		
		public function superUserMessage(message:String):void {
			if (!connected || message == null || message.length == 0) {
				return;
			}

			if (message.length > 254) {
				message = message.substr(0, 254);
			}
			
			worlizeComm.send({
				msg: "susr_msg",
				data: message
			});
		}
		
		private function handleClientCommand(message:String):Boolean {
			var clientCommandMatch:Array = message.match(/^~(\w+) (.*)$/);
			if (clientCommandMatch && clientCommandMatch.length > 0) {
				var command:String = clientCommandMatch[1];
				var argument:String = clientCommandMatch[2];
				switch (command) {
					default:
						trace("Unrecognized command: " + command + " argument " + argument);
				}
				return true;
			}
			else {
				return false;
			}
		}
		
		public function naked():void {
			currentUser.simpleAvatar = null;
			worlizeComm.send({
				msg: "naked"
			});
		}
		
		public function setSimpleAvatar(guid:String):void {
			currentUser.simpleAvatar = SimpleAvatarStore.getInstance().getAvatar(guid);
			worlizeComm.send({
				msg: "set_simple_avatar",
				data: guid
			});
		}
		
		public function move(x:int, y:int):void {
			if (!connected || !currentUser) {
				return;
			}
			
			x = Math.max(x, 22);
			x = Math.min(x, currentRoom.roomView.backgroundImage.width - 22);
			
			y = Math.max(y, 22);
			y = Math.min(y, currentRoom.roomView.backgroundImage.height - 22);
			
			worlizeComm.send({
				msg: "move",
				data: [x,y]
			});
			
			currentUser.x = x;
			currentUser.y = y;
		}
		
		public function setFace(face:int):void {
			if (!connected || currentUser.face == face) {
				return;
			}
			
			if (face < 0) { face = 12; }
			if (face > 12) { face = 0; }
			
			currentUser.face = face;
			
			worlizeComm.send({
				msg: "set_face",
				data: face
			});
		}
		
		public function setColor(color:int):void {
			if (!connected || currentUser.color == color) {
				return;
			}
			
			if (color > 15) { color = 15; }
			if (color < 0) { color = 0; }
			
			currentUser.color = color;
			
			worlizeComm.send({
				msg: "set_color",
				data: color
			});
			
			return;
		}
		
		public function createNewRoom(roomName:String = null):void {
			var newRoomOptions:Object = {};
			if (roomName) {
				newRoomOptions['room_name'] = roomName;
			}
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					var notification:RoomChangeNotification = new RoomChangeNotification(RoomChangeNotification.ROOM_ADDED);
					NotificationCenter.postNotification(notification);
					gotoRoom(event.resultJSON.data.room_guid);
				}
				else {
					Alert.show("There was an error while trying to create the new area.", "Error");
				}
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was an error while trying to create the new area.", "Error");
			});
			client.send("/worlds/" + currentWorld.guid + "/rooms.json", HTTPMethod.POST, newRoomOptions);
		}
		
		private var leaveEventHandlers:Vector.<IptTokenList>;
		private var requestedRoomId:String = null;
		private var shouldInsertHistory:Boolean = true;
		
		public function gotoRoom(roomId:String, insertHistory:Boolean = true):void {
			if (!connected || currentRoom.id == roomId) {
				return;
			}

			shouldInsertHistory = insertHistory;
			needToRunSignonHandlers = false;
			
			requestedRoomId = roomId;
			
			leaveEventHandlers = iptInteractivityController.getHotspotEvents(IptEventHandler.TYPE_LEAVE);
			if (leaveEventHandlers) {
				for each (var handler:IptTokenList in leaveEventHandlers) {
					handler.addEventListener(IptEngineEvent.FINISH, handleLeaveEventHandlersFinish);
				}
				iptInteractivityController.triggerHotspotEvents(IptEventHandler.TYPE_LEAVE);
			}
			else {
				actuallyGotoRoom(roomId);
			}
		}
		
		private function handleLeaveEventHandlersFinish(event:IptEngineEvent):void {
			if (leaveEventHandlers == null) {
				actuallyGotoRoom(requestedRoomId);
			}
			
			// Make sure each ON LEAVE handler has finished before actually
			// leaving the room.
			var index:int = leaveEventHandlers.indexOf(IptTokenList(event.target));
			if (index != -1) {
				leaveEventHandlers.splice(index, 1);
			}
			if (leaveEventHandlers.length < 1) {
				actuallyGotoRoom(requestedRoomId);
				leaveEventHandlers = null;
				requestedRoomId = null;
			}
		}
		
		private function actuallyGotoRoom(roomId:String):void {
			if (!connected) {
				return;
			}
			
			var gotoRoomCommand:GotoRoomCommand = new GotoRoomCommand();
			gotoRoomCommand.addEventListener(GotoRoomResultEvent.GOTO_ROOM_RESULT, function(event:GotoRoomResultEvent):void {
				resetState();

				worlizeComm.interactivitySession = event.interactivitySession;
				
				expectingDisconnect = true;
				worlizeComm.disconnect();
				worlizeComm.connect();
			});
			gotoRoomCommand.execute(roomId);
		}
		
		public function lockDoor(roomId:String, spotId:int):void {
			worlizeComm.send({
				msg: 'lock_door',
				data: {
					door_id: spotId
				}
			});
		}
		
		public function unlockDoor(roomGuid:String, spotId:int):void {
			worlizeComm.send({
				msg: 'unlock_door',
				data: {
					roomGuid: roomGuid,
					spotId: spotId
				}
			});
		}
		
		[Bindable(event="currentUserChanged")]
		public function get currentUser():InteractivityUser {
			return currentRoom.getUserById(id);
		}
		
		public function updateUserProps():void {
			// tell server what props the user is wearing...
		}
		
		
		
		// ***************************************************************
		// Begin private functions to messages from the server
		// ***************************************************************
		
		private function handleUserNew(data:Object):void {
			var user:InteractivityUser = new InteractivityUser();
			user.isSelf = Boolean(data.guid == id);
			user.id = data.guid;
			user.x = data.position[0];
			user.y = data.position[1];
			user.name = data.userName;
			user.face = data.face;
			user.color = data.color;
			
			if (data.avatar) {
				if (data.avatar.type == "simple") {
					user.simpleAvatar = SimpleAvatarStore.getInstance().getAvatar(data.avatar.guid);
				}
			}
			
			currentRoom.addUser(user);
			
			trace("User " + user.name + " entered.");
			
			if (user.id == id) {
				// Self entered
				// Signon handlers
				setTimeout(function():void {
					if (needToRunSignonHandlers) {
						
						iptInteractivityController.triggerHotspotEvents(IptEventHandler.TYPE_SIGNON);
						needToRunSignonHandlers = false;
					}
					
					// Enter handlers
					iptInteractivityController.triggerHotspotEvents(IptEventHandler.TYPE_ENTER);
				}, 20);
			}
			else if (currentRoom.selectedUser && user.id == currentRoom.selectedUser.id) {
				//if user was selected in user list then entered room
				currentRoom.selectedUser = user;
			}
		}

		/*
			Iptscrae event handlers have to process chat one piece at a time.
			Since iptscrae is run asynchronously, we have to wait for all event
			handlers for one chat event to complete before we process the next
			one.
		*/
		private function processChatQueue():void {
			if (chatQueue.length > 0) {
				if (currentChatItem) {
					// Bail if the current item isn't finished yet.
					return;
				}
				var currentItem:ChatRecord = chatQueue.shift();
				currentChatItem = currentItem;
				
				// These are global variables that need to persist even after
				// the last chat message has been processed
				whochat = currentItem.whochat;
				chatstr = currentItem.chatstr;
				
				if (currentItem.eventHandlers) {
					for each (var handler:IptTokenList in currentItem.eventHandlers) {
						handler.addEventListener(IptEngineEvent.FINISH, handleChatEventFinish);
					}
					iptInteractivityController.triggerHotspotEvents(
						(currentItem.direction == ChatRecord.INCHAT) ?
							IptEventHandler.TYPE_INCHAT :
							IptEventHandler.TYPE_OUTCHAT
					);
				}
				else {
					// If there aren't any event handlers, skip directly to
					// processing the chat.
					handleChatEventFinish();
				}
			}
		}
		
		private function handleChatEventFinish(event:IptEngineEvent=null):void {
			if (currentChatItem) {
				
				if (event) {
					// If an event handler has fired, pull it from the
					// currentChatItem's list of events, and continue
					// processing the chat only after all event handlers
					// have executed.
					IptTokenList(event.target).removeEventListener(IptEngineEvent.FINISH, handleChatEventFinish);
					var listIndex:int = currentChatItem.eventHandlers.indexOf(IptTokenList(event.target));
					if (listIndex != -1) {
						currentChatItem.eventHandlers.splice(listIndex, 1);
					}
					else {
						return;
					}
					if (currentChatItem.eventHandlers.length > 0) {
						// If there are more event handlers still to run,
						// bail and wait for them to finish.
						return;
					}
				}
				else if (currentChatItem.eventHandlers != null) {
					throw new Error("There are event handlers to run for this " +
                                    "chat record, but processing was attempted " +
									"without an event triggering it!");
				}
				
				currentChatItem.chatstr = chatstr;
				
				if (currentChatItem.direction == ChatRecord.INCHAT) {

					if (currentChatItem.whisper) {
						currentRoom.whisper(currentChatItem.whochat, currentChatItem.chatstr, currentChatItem.originalChatstr);
					}
					else {
						currentRoom.chat(currentChatItem.whochat, currentChatItem.chatstr, currentChatItem.originalChatstr);
					}
					
				}
				else if (currentChatItem.direction == ChatRecord.OUTCHAT) {
					
					if (currentChatItem.whisper) {
						privateMessage(currentChatItem.chatstr, currentChatItem.whotarget);
					}
					else {
						roomChat(currentChatItem.chatstr);
					}
					
				}
				
				currentChatItem = null;
			}
			
			// Keep processing the queue until it's empty.
			processChatQueue();
		}
		
		private function handleReceiveWhisper(data:Object):void {
			var message:String = data.text;
			var whochat:String = data.user;
			if (message.length > 0) {
				var chatRecord:ChatRecord = new ChatRecord(
					ChatRecord.INCHAT,
					whochat,
					null,
					message,
					true
				);
				chatRecord.eventHandlers = iptInteractivityController.getHotspotEvents(IptEventHandler.TYPE_INCHAT);
				chatQueue.push(chatRecord);
				processChatQueue();
			}
		}
		
		private function handleReceiveTalk(data:Object):void {
			var message:String = data.text;
			var whochat:String = data.user;
			var chatRecord:ChatRecord = new ChatRecord(
				ChatRecord.INCHAT,
				whochat,
				null,
				message
			);
			chatRecord.eventHandlers = iptInteractivityController.getHotspotEvents(IptEventHandler.TYPE_INCHAT);
			chatQueue.push(chatRecord);
			processChatQueue();
//			trace("Got xtalk from userID " + referenceId + ": " + chatstr);
		}
		
		private function handleMove(data:Object):void {
			var user:String = data.user;
			var y:int = data.position[1];
			var x:int = data.position[0];
			currentRoom.moveUser(user, x, y);
		}
		
		private function handleUserFace(data:Object):void {
			var user:InteractivityUser = currentRoom.getUserById(data.user);
			user.face = data.face;
		}
		
		private function handleUserColor(data:Object):void {
			var user:InteractivityUser = currentRoom.getUserById(data.user);
			user.color = data.color;
		}
		
		private function handleUserRename(data:Object):void {
			var user:InteractivityUser = currentRoom.getUserById(data.user);
			var userName:String = data.username;
			user.name = userName;
		}
		
		private function handleUserLeaving(data:Object):void {
			var userId:String = String(data);
			if (currentRoom.getUserById(userId) != null) {
				currentRoom.removeUserById(userId);
			}

			//if user left room and ESP is active when they sign off
			if (currentRoom.selectedUser && currentRoom.selectedUser.id == userId)
			{
				currentRoom.selectedUser = null;
			}
		}
	}
}