package com.worlize.model
{
	import com.adobe.net.URI;
	import com.worlize.event.NotificationCenter;
	import com.worlize.interactivity.rpc.InteractivityClient;
	import com.worlize.notification.RoomChangeNotification;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;
	
	import spark.collections.Sort;
	import spark.collections.SortField;

	[Bindable]
	public class WorldDefinition extends EventDispatcher
	{
		private var logger:ILogger = Log.getLogger('com.worlize.model.WorldDefinition');
		
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_READY:String = "ready";
		public static const STATE_ERROR:String = "error";
		
		public var state:String = STATE_INIT;
		
		public var name:String;
		public var guid:String;
		private var _permalink:String;
		
		public var canCreateNewRoom:Boolean;
		
		public var roomList:RoomList = new RoomList();
		public var userList:UserList = new UserList();
		
		public var ownerGuid:String;
		
		// moderators and restrictions are only used for the moderation dialog
		public var moderators:ArrayCollection = new ArrayCollection();
		public var restrictions:ArrayCollection = new ArrayCollection();
		
		public function WorldDefinition() {
			var sort:Sort = new Sort();
			sort.fields = [
				new SortField("expires", false)
			];
			restrictions.sort = sort;
			restrictions.refresh();
		}
		
		[Bindable(event="permalinkChanged")]
		public function set permalink(newValue:String):void {
			if (_permalink !== newValue) {
				_permalink = newValue;
				dispatchEvent(new FlexEvent("permalinkChanged"));
			}
		}
		public function get permalink():String {
			return _permalink;
		}
		
		[Bindable(event="permalinkChanged")]
		public function get url():String {
			var uri:String;
			
			if (permalink === null) {
				return baseURL + "worlds/" + guid;
			}
			
			return baseURL + permalink;
		}
		
		[Bindable(event="baseURLChanged")]
		public function get baseURL():String {
			var appURI:URI = new URI(FlexGlobals.topLevelApplication.url);
			return appURI.scheme + "://" + appURI.authority + "/";
		}
		
		private var roomChangeListenersAdded:Boolean = false;
		
		public function addRoomChangeListeners():void {
			if (roomChangeListenersAdded) { return; }
			roomChangeListenersAdded = true;
			NotificationCenter.addListener(RoomChangeNotification.ROOM_DELETED, handleRoomRemoved);
			NotificationCenter.addListener(RoomChangeNotification.ROOM_ADDED, handleRoomAdded);
			NotificationCenter.addListener(RoomChangeNotification.ROOM_UPDATED, handleRoomUpdated);
		}
		
		public function removeRoomChangeListeners():void {
			if (!roomChangeListenersAdded) { return; }
			NotificationCenter.removeListener(RoomChangeNotification.ROOM_DELETED, handleRoomRemoved);
			NotificationCenter.removeListener(RoomChangeNotification.ROOM_ADDED, handleRoomAdded);
			NotificationCenter.removeListener(RoomChangeNotification.ROOM_UPDATED, handleRoomUpdated);
		}
		
		private function handleRoomAdded(notification:RoomChangeNotification):void {
			if (notification.roomListEntry.worldGuid === guid) {
				roomList.rooms.addItem(notification.roomListEntry);
			}
		}
		
		private function handleRoomRemoved(notification:RoomChangeNotification):void {
			if (notification.worldGuid === guid) {
				roomList.removeRoomByGuid(notification.roomGuid);
			}
		}
		
		private function handleRoomUpdated(notification:RoomChangeNotification):void {
			if (notification.roomListEntry.worldGuid === guid) {
				roomList.updateRoom(notification.roomListEntry);
			}
		}
		
		public function load(worldGuid:String):void {
			if (worldGuid === null) { return; }

			state = STATE_LOADING;
			
			name = null;
			guid = worldGuid;
			
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send('/worlds/' + worldGuid + ".json", HTTPMethod.GET);
		}
		
		private function handleResult(event:WorlizeResultEvent):void {
			if (event.resultJSON.success) {
				name = event.resultJSON.data.name;
				guid = event.resultJSON.data.guid;
				ownerGuid = event.resultJSON.data.owner.guid;
				canCreateNewRoom = event.resultJSON.data.can_create_new_room;
				permalink = event.resultJSON.data.permalink;
				
				var client:InteractivityClient = InteractivityClient.getInstance();
				roomList.updateFromData(event.resultJSON.data.rooms);
				roomList.initFilter(client.currentUser, this);
				roomList.rooms.refresh();
				
				// Load user list
				userList.load(guid);
				
				state = STATE_READY;
				logger.info("Got worlz definition for " + this.name + " - " + this.guid);
			}
			else {
				reset();
				state = STATE_ERROR;
			}
		}
		private function handleFault(event:FaultEvent):void {
			reset();
			state = STATE_ERROR;
		}
		
		public function reset():void {
			name = null;
			canCreateNewRoom = false;
			permalink = null;
			ownerGuid = null;
		}
		
		public function clone():WorldDefinition {
			var w:WorldDefinition = new WorldDefinition();
			w.name = name;
			w.guid = guid;
			w.permalink = permalink;
			w.canCreateNewRoom = canCreateNewRoom;
			w.ownerGuid = ownerGuid;
			w.roomList = roomList.clone();
			w.userList = userList.clone();
			w.state = state;
			return w;
		}
		
		public function updateFromData(data:Object):void {
			name = data.name;
			guid = data.guid;
			ownerGuid = data.owner.guid;
			permalink = data.permalink;
			state = STATE_READY;
		}
	}
}