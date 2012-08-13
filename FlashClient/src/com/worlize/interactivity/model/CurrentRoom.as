package com.worlize.interactivity.model
{
	import com.worlize.event.NotificationCenter;
	import com.worlize.interactivity.event.ChatEvent;
	import com.worlize.interactivity.event.RoomEvent;
	import com.worlize.interactivity.rpc.InteractivityClient;
	import com.worlize.interactivity.util.WorlizeTextUtil;
	import com.worlize.interactivity.view.RoomView;
	import com.worlize.model.AppInstance;
	import com.worlize.model.BackgroundImageInstance;
	import com.worlize.model.InWorldObject;
	import com.worlize.model.InWorldObjectInstance;
	import com.worlize.model.RoomListEntry;
	import com.worlize.model.YouTubePlayerDefinition;
	import com.worlize.notification.AppNotification;
	import com.worlize.notification.InWorldObjectNotification;
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
	import mx.formatters.DateFormatter;
	import mx.rpc.events.FaultEvent;

	[Event(name="chatLogUpdated")]
	[Event(name="chat",type="com.worlize.interactivity.event.ChatEvent")]
	[Event(name="userEntered",type="com.worlize.interactivity.event.RoomEvent")]
	[Event(name="userLeft",type="com.worlize.interactivity.event.RoomEvent")]
	[Event(name="roomCleared",type="com.worlize.interactivity.event.RoomEvent")]
	[Event(name="userMoved",type="com.worlize.interactivity.event.RoomEvent")]
	[Event(name="itemAdded",type="com.worlize.interactivity.event.RoomEvent")]
	[Event(name="itemRemoved",type="com.worlize.interactivity.event.RoomEvent")]
	[Event(name="itemMoved",type="com.worlize.interactivity.event.RoomEvent")]
	[Event(name="itemResized",type="com.worlize.interactivity.event.RoomEvent")]
	[Bindable]
	public class CurrentRoom extends EventDispatcher
	{
		public var id:String;
		public var name:String = "Connecting";
		public var ownerGuid:String = null;
		public var backgroundFile:String;
		public var snowEnabled:Boolean = false;
		public var users:ArrayCollection = new ArrayCollection();
		public var usersHash:Object = {};
		public var roomFlags:int;
		public var images:Object = {};
		public var spotImages:Object = {};
		public var items:ArrayCollection = new ArrayCollection();
		public var itemsByGuid:Object = {};
		public var _selectedUser:InteractivityUser;
		public var selfUserId:String = null;
		public var roomView:RoomView;
		public var dimLevel:Number = 1;
		public var showAvatars:Boolean = true;
		public var locked:Boolean = false;
		
		public var plainTextChatLog:String = "Welcome to Worlize\nChat log ready.\n\n";
		public var chatLog:String = "Welcome to Worlize<br>Chat log ready.<br>\n";
		
		public var lastMessage:String;
		public var lastMessageCount:int = 0;
		public var lastMessageReceived:Number = 0;
		public var lastMessageTimer:Timer = new Timer(250, 1);
		
		public var statusMessageString:String = "";
		
		private var statusDisappearTimer:Timer = new Timer(30000, 1);
		
		public var loosePropList:LoosePropList = new LoosePropList(); 
		
		public function CurrentRoom()
		{
			lastMessageTimer.addEventListener(TimerEvent.TIMER, handleLastMessageTimer);
			statusDisappearTimer.addEventListener(TimerEvent.TIMER, handleStatusDisappearTimer);
		}
		
		public function get htmlLogData():String {
			return "<html><head><title>Worlize Chat Log</title></head><body>\n" +
				   chatLog.replace(/\n/g, "<br>\n") +
				   "</body></html>";
		}
		
		public function addItem(item:IRoomItem):void {
			items.addItem(item);
			itemsByGuid[item.guid] = item;
			addRoomItemListeners(item);
			
			if (item is InWorldObjectInstance) {
				var objectNotification:InWorldObjectNotification =
					new InWorldObjectNotification(InWorldObjectNotification.IN_WORLD_OBJECT_ADDED_TO_ROOM);
				objectNotification.instanceGuid = item.guid;
				objectNotification.room = InWorldObjectInstance(item).room;
				NotificationCenter.postNotification(objectNotification);
			}
			
			else if (item is AppInstance) {
				var appNotification:AppNotification =
					new AppNotification(AppNotification.APP_INSTANCE_ADDED_TO_ROOM);
				appNotification.instanceGuid = item.guid;
				appNotification.room = AppInstance(item).room;
				NotificationCenter.postNotification(appNotification);
			}
			
			
			
			var event:RoomEvent = new RoomEvent(RoomEvent.ITEM_ADDED);
			event.roomItem = item;
			dispatchEvent(event);
		}
		
		public function getItemByGuid(guid:String):IRoomItem {
			return itemsByGuid[guid];
		}
		
		public function removeItemByGuid(guid:String):IRoomItem {
			var item:IRoomItem = itemsByGuid[guid];
			if (item) {
				var index:int = items.getItemIndex(item);
				if (index !== -1) {
					items.removeItemAt(index);
				}
				delete itemsByGuid[guid];
				removeRoomItemListeners(item);
				
				if (item is InWorldObjectInstance) {
					var on:InWorldObjectNotification = new InWorldObjectNotification(InWorldObjectNotification.IN_WORLD_OBJECT_REMOVED_FROM_ROOM);
					on.instanceGuid = item.guid;
					NotificationCenter.postNotification(on);
				}
				
				if (item is AppInstance) {
					var an:AppNotification = new AppNotification(AppNotification.APP_INSTANCE_REMOVED_FROM_ROOM);
					an.instanceGuid = item.guid;
					NotificationCenter.postNotification(an);
				}
				
				var event:RoomEvent = new RoomEvent(RoomEvent.ITEM_REMOVED);
				event.roomItem = item;
				dispatchEvent(event);
			}
			return item;
		}
		
		public function resetItems():void {
			items.removeAll();
			itemsByGuid = {};
		}
		
		public function resetProperties():void {
			updateProperties({}, true);
		}
		
		public function updateProperties(properties:Object, shouldReset:Boolean = false):void {
			var mergedProperties:Object;
			var propertyName:String;
			if (shouldReset) {
				// set room defaults here
				mergedProperties = {
					snowEnabled: false
				};
			}
			else {
				mergedProperties = {};
			}
			
			for (propertyName in properties) {
				if (properties.hasOwnProperty(propertyName)) {
					mergedProperties[propertyName] = properties[propertyName];
				}
			}
			
			for (propertyName in mergedProperties) {
				updateProperty(propertyName, mergedProperties[propertyName]);
			}
		}
		
		public function updateProperty(name:String, value:*):void {
			switch(name) {
				case 'snowEnabled':
					snowEnabled = Boolean(value);
					break;
				default:
					break;
			}
		}
		
		private function addRoomItemListeners(item:IRoomItem):void {
			item.addEventListener(RoomEvent.ITEM_MOVED, redispatchItemEvent);
			item.addEventListener(RoomEvent.ITEM_RESIZED, redispatchItemEvent);
			if (item is AppInstance) {
				item.addEventListener(RoomEvent.APP_STATE_CHANGED, redispatchItemEvent);
			}
		}
		
		private function removeRoomItemListeners(item:IRoomItem):void {
			item.removeEventListener(RoomEvent.ITEM_MOVED, redispatchItemEvent);
			item.removeEventListener(RoomEvent.ITEM_RESIZED, redispatchItemEvent);
			if (item is AppInstance) {
				item.removeEventListener(RoomEvent.APP_STATE_CHANGED, redispatchItemEvent);
			}
		}

		public function redispatchItemEvent(event:RoomEvent):void {
			dispatchEvent(event);
		}
		
		public function moveItem(guid:String, x:int, y:int):void {
			var roomItem:IRoomItem = itemsByGuid[guid];
			if (roomItem) {
				roomItem.x = x;
				roomItem.y = y;
				
				var event:RoomEvent = new RoomEvent(RoomEvent.ITEM_MOVED);
				event.roomItem = roomItem;
				dispatchEvent(event);
			}
		}
		
		public function resizeItem(guid:String, width:int, height:int):void {
			var roomItem:IRoomItem = itemsByGuid[guid];
			if (roomItem) {
				roomItem.width = width;
				roomItem.height = height;
				
				var event:RoomEvent = new RoomEvent(RoomEvent.ITEM_RESIZED);
				event.roomItem = roomItem;
				dispatchEvent(event);
			}
		}
		
		public function setItemDest(guid:String, dest:String):void {
			var item:IRoomItem = itemsByGuid[guid];
			if (!(item is ILinkableRoomItem)) { return; }
			var linkableItem:ILinkableRoomItem = ILinkableRoomItem(IRoomItem);
			if (item) {
				linkableItem.dest = dest;
				var event:RoomEvent = new RoomEvent(RoomEvent.ITEM_DEST_CHANGED);
				event.roomItem = linkableItem;
				dispatchEvent(event);
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
			var x:int = 950/2;
			var y:int = 570/2;
			var points:Array = [ [-150,-100], [150,-100], [150,100], [-150,100] ];
			var client:InteractivityClient = InteractivityClient.getInstance();
			client.addHotspot(x, y, points);
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
				lastMessageTimer.stop();
			}
			lastMessage = message;
			lastMessageReceived = (new Date()).valueOf();
			return retValue;
		}
		
		public function getHotspotByGuid(spotGuid:String):Hotspot {
			var item:IRoomItem = itemsByGuid[spotGuid];
			if (item && item is Hotspot) {
				return Hotspot(item);
			}
			return null;
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
				recordPlainChat(user.name + ": " + logMessage);
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
				recordPlainChat(user.name + " (whisper): " + logMessage);
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
				recordPlainChat("*** " + message);
				recordChat("<b>*** " + WorlizeTextUtil.htmlEscape(message), "</b>\n");
				dispatchEvent(new Event('chatLogUpdated'));
				var event:ChatEvent = new ChatEvent(ChatEvent.ROOM_MESSAGE, message);
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
			recordPlainChat(" --- " + message);
			recordChat("<i>" + message + "</i>\n");
			statusMessageString = message;
			statusDisappearTimer.reset();
			statusDisappearTimer.start();
			dispatchEvent(new Event('chatLogUpdated'));
		}
		
		public function logMessage(message:String):void {
			recordPlainChat(" --- " + message);
			recordChat("<i>" + message + "</i>\n");
			dispatchEvent(new Event('chatLogUpdated'));
		}
		
		public function logScript(message:String):void {
			recordPlainChat(" --- " + message);
			recordChat("<font face=\"Courier New\">" + WorlizeTextUtil.htmlEscape(message) + "</font>\n")
			dispatchEvent(new Event('chatLogUpdated'));
		}
		
		public function roomWhisper(message:String):void {
			if (shouldDisplayMessage(message) && message.length > 0) {
				recordPlainChat("(ESP) - " + message);
				recordChat("<b><i>*** " + WorlizeTextUtil.htmlEscape(message), "</i></b>\n");
				dispatchEvent(new Event('chatLogUpdated'));
				var event:ChatEvent = new ChatEvent(ChatEvent.ROOM_MESSAGE, message);
				dispatchEvent(event);
			}
		}
		
		private function recordPlainChat(... args):void {
			var newString:String = "";
			for (var i:int = 0; i < args.length; i ++) {
				newString += (args[i] + "\n");
			}
			plainTextChatLog += newString;
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
		
		public function clearLog():void {
			var date:Date = new Date();
			var formatter:DateFormatter = new DateFormatter();
			formatter.formatString = "YYYY-MM-DD at L:NN:SS A";
			chatLog = "Worlize Chat log cleared at " + formatter.format(date) + "\n\n";
			plainTextChatLog = "Worlize Chat log cleared at " + formatter.format(date) + "\n\n";
		}
		
		public function moveUser(userId:String, x:int, y:int):void {
			var user:InteractivityUser = getUserById(userId);
			if (user) {
				user.x = x;
				user.y = y;
				var event:RoomEvent = new RoomEvent(RoomEvent.USER_MOVED, user);
				dispatchEvent(event);
				//			trace("User " + userId + " moved to " + x + "," + y);
			}
		}
	}
}