package com.worlize.interactivity.model
{
	import com.worlize.command.CreateHotspotCommand;
	import com.worlize.event.NotificationCenter;
	import com.worlize.interactivity.event.ChatEvent;
	import com.worlize.interactivity.event.RoomEvent;
	import com.worlize.interactivity.util.WorlizeTextUtil;
	import com.worlize.interactivity.view.RoomView;
	import com.worlize.model.BackgroundImageInstance;
	import com.worlize.model.InWorldObject;
	import com.worlize.model.InWorldObjectInstance;
	import com.worlize.model.RoomListEntry;
	import com.worlize.model.YouTubePlayerDefinition;
	import com.worlize.notification.InWorldObjectNotification;
	import com.worlize.notification.YouTubePlayerNotification;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;

	[Event(name="chatLogUpdated")]
	[Event(name="chat",type="com.worlize.interactivity.event.ChatEvent")]
	[Event(name="userEntered",type="com.worlize.interactivity.event.RoomEvent")]
	[Event(name="userLeft",type="com.worlize.interactivity.event.RoomEvent")]
	[Event(name="roomCleared",type="com.worlize.interactivity.event.RoomEvent")]
	[Event(name="userMoved",type="com.worlize.interactivity.event.RoomEvent")]
	
	[Bindable]
	public class CurrentRoom extends EventDispatcher
	{
		public var id:String;
		public var name:String = "Connecting";
		public var backgroundFile:String;
		public var users:ArrayCollection = new ArrayCollection();
		public var usersHash:Object = {};
		public var roomFlags:int;
		public var images:Object = {};
		public var spotImages:Object = {};
		public var hotSpots:ArrayCollection = new ArrayCollection();
		public var hotSpotsAboveNothing:ArrayCollection = new ArrayCollection();
		public var hotSpotsAboveAvatars:ArrayCollection = new ArrayCollection();
		public var hotSpotsAboveNametags:ArrayCollection = new ArrayCollection();
		public var hotSpotsAboveEverything:ArrayCollection = new ArrayCollection();
		public var hotSpotsById:Object = {};
		public var hotSpotsByGuid:Object = {};
		public var drawFrontCommands:ArrayCollection = new ArrayCollection();
		public var drawBackCommands:ArrayCollection = new ArrayCollection();
		public var drawLayerHistory:Vector.<uint> = new Vector.<uint>();
		public var inWorldObjects:ArrayCollection = new ArrayCollection();
		public var inWorldObjectsByGuid:Object = {};
		public var youtubePlayers:ArrayCollection = new ArrayCollection();
		public var youtubePlayersByGuid:Object = {};
		public var _selectedUser:InteractivityUser;
		public var selfUserId:String = null;
		public var roomView:RoomView;
		public var dimLevel:Number = 1;
		public var showAvatars:Boolean = true;
		
		private var videoServer:String;
		public var netConnection:NetConnection;
		
		public var chatLog:String = "Welcome to Worlize<br>Chat log ready.<br>\n";
		
		public var lastMessage:String;
		public var lastMessageCount:int = 0;
		public var lastMessageReceived:Number = 0;
		public var lastMessageTimer:Timer = new Timer(250, 1);
		
		public var statusMessageString:String = "";
		
		private var statusDisappearTimer:Timer = new Timer(30000, 1);
		
		public function CurrentRoom()
		{
			lastMessageTimer.addEventListener(TimerEvent.TIMER, handleLastMessageTimer);
			statusDisappearTimer.addEventListener(TimerEvent.TIMER, handleStatusDisappearTimer);
		}
		
		public function connectVideoServer(url:String):void {
			if (netConnection && netConnection.connected) {
				disconnectVideoServer();
			}
			netConnection = new NetConnection();
			netConnection.addEventListener(NetStatusEvent.NET_STATUS, handleNetStatus);
			netConnection.connect(url);
		}
		
		private function handleNetStatus(event:NetStatusEvent):void {
			trace("NetConnection: " + event.info.code + " (" + event.info.description + ")");
		}
		
		public function disconnectVideoServer():void {
			if (netConnection) {
				netConnection.close();				
			}
		}
		
		public function resetYoutubePlayers():void {
			youtubePlayers.removeAll();
			youtubePlayersByGuid = {};
		}
		
		public function addYoutubePlayer(playerDefinition:YouTubePlayerDefinition):void {
			youtubePlayers.addItem(playerDefinition);
			youtubePlayersByGuid[playerDefinition.guid] = playerDefinition;
			
			var notification:YouTubePlayerNotification = new YouTubePlayerNotification(YouTubePlayerNotification.ADDED_TO_ROOM);
			notification.roomGuid = this.id;
			notification.playerDefinition = playerDefinition;
			NotificationCenter.postNotification(notification);
		}
		
		public function removeYoutubePlayer(guid:String):void {
			var playerDefinition:YouTubePlayerDefinition = youtubePlayersByGuid[guid];
			if (playerDefinition) {
				var index:int = youtubePlayers.getItemIndex(playerDefinition);
				if (index != -1) {
					youtubePlayers.removeItemAt(index);
				}
				delete youtubePlayersByGuid[guid];
			}
		}
		
		public function getYoutubePlayerByGuid(guid:String):YouTubePlayerDefinition {
			return YouTubePlayerDefinition(youtubePlayersByGuid[guid]);
		}
		
		public function resetInWorldObjects():void {
			inWorldObjects.removeAll();
			inWorldObjectsByGuid = {};
		}
		
		public function addObject(guid:String, x:int, y:int, fullsizeURL:String, dest:String = null):void {
			var inWorldObjectInstance:InWorldObjectInstance = new InWorldObjectInstance();
			inWorldObjectInstance.guid = guid;
			inWorldObjectInstance.x = x;
			inWorldObjectInstance.y = y;
			inWorldObjectInstance.dest = dest;
			inWorldObjectInstance.inWorldObject = new InWorldObject();
			inWorldObjectInstance.inWorldObject.fullsizeURL = fullsizeURL;
			var roomListEntry:RoomListEntry = new RoomListEntry();
			roomListEntry.guid = id;
			roomListEntry.name = name;
			inWorldObjectInstance.room = roomListEntry;
			
			inWorldObjects.addItem(inWorldObjectInstance);
			inWorldObjectsByGuid[inWorldObjectInstance.guid] = inWorldObjectInstance;
			
			var notification:InWorldObjectNotification =
				new InWorldObjectNotification(InWorldObjectNotification.IN_WORLD_OBJECT_ADDED_TO_ROOM);
			notification.instanceGuid = guid;
			notification.room = roomListEntry;
			NotificationCenter.postNotification(notification);
		}
		
		public function removeObject(guid:String):void {
			var inWorldObjectInstance:InWorldObjectInstance = inWorldObjectsByGuid[guid];
			if (inWorldObjectInstance) {
				var index:int = inWorldObjects.getItemIndex(inWorldObjectInstance);
				if (index != -1) {
					inWorldObjects.removeItemAt(index);
					var notification:InWorldObjectNotification =
						new InWorldObjectNotification(InWorldObjectNotification.IN_WORLD_OBJECT_REMOVED_FROM_ROOM);
					notification.instanceGuid = guid;
					NotificationCenter.postNotification(notification);
				}
			}
		}
		
		public function moveObject(guid:String, x:int, y:int):void {
			var inWorldObjectInstance:InWorldObjectInstance = inWorldObjectsByGuid[guid];
			if (inWorldObjectInstance) {
				inWorldObjectInstance.x = x;
				inWorldObjectInstance.y = y;
			}
		}
		
		public function updateObject(guid:String, dest:String):void {
			var inWorldObjectInstance:InWorldObjectInstance = inWorldObjectsByGuid[guid];
			if (inWorldObjectInstance) {
				inWorldObjectInstance.dest = dest;
			}
		}
		
		[Bindable(event="selectedUserChanged")]
		public function set selectedUser(newValue:InteractivityUser):void {
			if (_selectedUser !== newValue) {
				_selectedUser = newValue;
				dispatchEvent(new Event("selectedUserChanged"));
			}
		}
		public function get selectedUser():InteractivityUser {
			return _selectedUser;
		}
		
		private function handleLastMessageTimer(event:TimerEvent):void {
			logMessage("(Last message received " + lastMessageCount.toString() + ((lastMessageCount == 1) ? " time.)" : " times.)"));
			lastMessage = "";
			lastMessageCount = 0;
			lastMessageReceived = 0;
		}
		
		public function createHotspot():void {
			var command:CreateHotspotCommand = new CreateHotspotCommand();
			command.currentRoom = this;
			command.execute(this.id);
		}
		
		public function createYoutubePlayer():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				// New player shows up in response to an event broadcast
				// to the room by the server.
				if (!event.resultJSON.success) {
					Alert.show("There was an error while tring to create a new embedded YouTube player: " +
								event.resultJSON.description, "Error");
				}
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was a fault encountered while trying to create a new embedded YouTube player.", "Error");
			});
			client.send("/rooms/" + this.id + "/youtube_players.json", HTTPMethod.POST);
		}
		
		private function shouldDisplayMessage(message:String):Boolean {
			var retValue:Boolean = true;
			if (lastMessage == message && lastMessageReceived > (new Date()).valueOf() - 250) {
				lastMessageTimer.stop();
				lastMessageTimer.reset();
				lastMessageTimer.start();
				lastMessageCount ++;
				retValue = false;
			}
			else {
				lastMessageCount = 1;
			}
			lastMessage = message;
			lastMessageReceived = (new Date()).valueOf();
			return retValue;
		}
		
		public function getHotspotById(spotId:int):Hotspot {
			return Hotspot(hotSpotsById[spotId]);
		}
		
		public function dimRoom(level:int):void {
			level = Math.max(0, level);
			level = Math.min(100, level);
			dimLevel = level / 100;
		}
		
		public function addUser(user:InteractivityUser):void {
			usersHash[user.id] = user;
			users.addItem(user);
			var event:RoomEvent = new RoomEvent(RoomEvent.USER_ENTERED, user);
			dispatchEvent(event);
		}
		
		public function getUserById(id:String):InteractivityUser {
			return InteractivityUser(usersHash[id]);
		}
		
		public function getUserByName(name:String):InteractivityUser {
			for each (var user:InteractivityUser in users) {
				if (user.name == name) {
					return user;
				}
			}
			return null;
		}
		
		public function getUserByIndex(userIndex:int):InteractivityUser {
			return InteractivityUser(users.getItemAt(userIndex));
		}
		
		public function getSelfUser():InteractivityUser {
			return getUserById(selfUserId);
		}
		
		public function removeUser(user:InteractivityUser):void {
			removeUserById(user.id);
		}
		
		public function removeUserById(id:String):void {
			var user:InteractivityUser = getUserById(id);
			var index:int = users.getItemIndex(user);
			if (index != -1) {
				users.removeItemAt(users.getItemIndex(user));
			}
			var event:RoomEvent = new RoomEvent(RoomEvent.USER_LEFT, user);
			dispatchEvent(event);
		}
		
		public function removeAllUsers():void {
			usersHash = {};
			users.removeAll();
			var event:RoomEvent = new RoomEvent(RoomEvent.ROOM_CLEARED);
			dispatchEvent(event);
		}
		
		public function chat(userId:String, message:String, logMessage:String = null):void {
			var user:InteractivityUser = getUserById(userId);
			
			if (logMessage == null) {
				logMessage = message;
			}
			if (logMessage.length > 0) {
				recordChat("<b>", WorlizeTextUtil.htmlEscape(user.name), ":</b> ", WorlizeTextUtil.htmlEscape(logMessage), "\n");
				dispatchEvent(new Event('chatLogUpdated'));
			}
			if (shouldDisplayMessage(message) && message.length > 0) {
				var event:ChatEvent = new ChatEvent(ChatEvent.CHAT, message, user);
				dispatchEvent(event);
			}
		}
		
		public function whisper(userId:String, message:String, logMessage:String = null):void {
			var user:InteractivityUser = getUserById(userId);
			if (logMessage == null) {
				logMessage = message;
			}
			if (logMessage.length > 0) {
				recordChat("<em><b>", WorlizeTextUtil.htmlEscape(user.name), " (whisper):</b> ", WorlizeTextUtil.htmlEscape(logMessage), "</em>\n");
				dispatchEvent(new Event('chatLogUpdated'));
			}
			if (shouldDisplayMessage(message) && message.length > 0) {
				var event:ChatEvent = new ChatEvent(ChatEvent.WHISPER, message, user);
				dispatchEvent(event);
			}
		}
		
		public function localMessage(message:String):void {
			roomMessage(message);
		}
		
		public function roomMessage(message:String):void {
			if (shouldDisplayMessage(message) && message.length > 0) {
				recordChat("<b>*** " + WorlizeTextUtil.htmlEscape(message), "</b>\n");
				dispatchEvent(new Event('chatLogUpdated'));
				var event:ChatEvent = new ChatEvent(ChatEvent.ROOM_MESSAGE, "@0,35 " + message);
				dispatchEvent(event);
			}
		}
		
		private function handleStatusDisappearTimer(event:TimerEvent):void {
			clearStatusMessage();
		}
		
		public function clearStatusMessage():void {
			statusMessageString = "";
		}
		
		public function statusMessage(message:String):void {
			recordChat("<i>" + message + "</i>\n");
			statusMessageString = message;
			statusDisappearTimer.reset();
			statusDisappearTimer.start();
			dispatchEvent(new Event('chatLogUpdated'));
		}
		
		public function logMessage(message:String):void {
			recordChat("<i>" + message + "</i>\n");
			dispatchEvent(new Event('chatLogUpdated'));
		}
		
		public function logScript(message:String):void {
			recordChat("<font face=\"Courier New\">" + WorlizeTextUtil.htmlEscape(message) + "</font>\n")
			dispatchEvent(new Event('chatLogUpdated'));
		}
		
		public function roomWhisper(message:String):void {
			if (shouldDisplayMessage(message) && message.length > 0) {
				recordChat("<b><i>*** " + WorlizeTextUtil.htmlEscape(message), "</i></b>\n");
				dispatchEvent(new Event('chatLogUpdated'));
				var event:ChatEvent = new ChatEvent(ChatEvent.ROOM_MESSAGE, message);
				dispatchEvent(event);
			}
		}
		
		private function recordChat(... args):void {
			var temp:String = "";
			if (chatLog.length > 2) {
				temp = chatLog.substr(0, chatLog.length-1);
			}
			for (var i:int = 0; i < args.length; i ++) {
				temp += args[i];
			}
			chatLog = temp + "\n";
		}
		
		public function moveUser(userId:String, x:int, y:int):void {
			var user:InteractivityUser = getUserById(userId);
			user.x = x;
			user.y = y;
			var event:RoomEvent = new RoomEvent(RoomEvent.USER_MOVED, user);
			dispatchEvent(event);
//			trace("User " + userId + " moved to " + x + "," + y);
		}
	}
}