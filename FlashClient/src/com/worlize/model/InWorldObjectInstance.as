package com.worlize.model
{
	import com.worlize.event.NotificationCenter;
	import com.worlize.interactivity.event.RoomEvent;
	import com.worlize.interactivity.model.ILinkableRoomItem;
	import com.worlize.interactivity.model.IRoomItem;
	import com.worlize.interactivity.rpc.InteractivityClient;
	import com.worlize.notification.InWorldObjectNotification;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	
	import mx.events.FlexEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;
	import mx.utils.object_proxy;

	[Bindable]
	public class InWorldObjectInstance extends EventDispatcher implements ILinkableRoomItem
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_LOAD_ERROR:String = "loadError";
		public static const STATE_READY:String = "ready";
		public static const STATE_HANDSHAKING:String = "handshaking";
		public static const STATE_UNLOADING:String = "unloading";
		public static const STATE_UNLOADED:String = "unloaded";
		public static const STATE_BOMBED:String = "bombed";
		
		private var _state:String = STATE_INIT;
		public var inWorldObject:InWorldObject;
		public var guid:String;
		public var x:int;
		public var y:int;
		public var width:Number;
		public var height:Number;
		public var room:RoomListEntry;
		public var dest:String;
		public var emptySlot:Boolean = false;
		
		public var configData:Object;
		public var syncedData:Object;
		public var stateHistory:Array;
		
		public var editModeSupported:Boolean = false;
		private var _editModeEnabled:Boolean = false;
		
		public var sizeUnknown:Boolean = true;
		
		[Bindable(event="stateChanged")]
		public function get state():String {
			return _state;
		}
		public function set state(newValue:String):void {
			if (_state !== newValue) {
				_state = newValue;
				dispatchEvent(new FlexEvent('stateChanged'));
				var event:RoomEvent = new RoomEvent(RoomEvent.APP_STATE_CHANGED);
				event.roomObject = this;
				dispatchEvent(event);
			}
		}
		
		[Bindable(event="editModeEnabledChanged")]
		public function get editModeEnabled():Boolean {
			return _editModeEnabled;
		}
		public function set editModeEnabled(newValue:Boolean):void {
			if (_editModeEnabled !== newValue) {
				_editModeEnabled = newValue;
				dispatchEvent(new FlexEvent("editModeEnabledChanged"));
			}
		}
		
		public static function fromLockerData(data:Object):InWorldObjectInstance {
			var object:InWorldObjectInstance = new InWorldObjectInstance();
			object.guid = data.guid;
			object.inWorldObject = InWorldObject.fromData(data.in_world_object);
			if (data.room) {
				object.room = new RoomListEntry();
				object.room.name = data.room.name;
				object.room.guid = data.room.guid;
			}
			object.emptySlot = false;
			return object;
		}
		
		public function moveLocal(x:int, y:int):void {
			this.x = x;
			this.y = y;
			var event:RoomEvent = new RoomEvent(RoomEvent.APP_MOVED);
			event.roomObject = this;
			dispatchEvent(event);
		}
		
		public function resizeLocal(width:int, height:int):void {
			if (this.width !== width || this.height !== height) {
				this.width = width;
				this.height = height;
				var event:RoomEvent = new RoomEvent(RoomEvent.APP_RESIZED);
				event.roomObject = this;
				dispatchEvent(event);
			}
		}
		
		public function requestDelete():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleDeleteResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send("/locker/in_world_objects/" + guid + ".json", HTTPMethod.DELETE);
		}
		
		private function handleFault(event:FaultEvent):void {
			var logger:ILogger = Log.getLogger("com.worlize.model.InWorldObjectInstance");
			logger.error("Object Delete Failed. " + event);
		}
		
		private function handleDeleteResult(event:WorlizeResultEvent):void {
			var notification:InWorldObjectNotification = new InWorldObjectNotification(InWorldObjectNotification.IN_WORLD_OBJECT_INSTANCE_DELETED);
			notification.instanceGuid = guid;
			NotificationCenter.postNotification(notification);
		}

		public static function fromData(objectData:Object):InWorldObjectInstance {
			var inWorldObjectInstance:InWorldObjectInstance = new InWorldObjectInstance();
			inWorldObjectInstance.guid = objectData.guid;
			inWorldObjectInstance.x = objectData.x;
			inWorldObjectInstance.y = objectData.y;
			
			inWorldObjectInstance.inWorldObject = new InWorldObject();
			inWorldObjectInstance.inWorldObject.creatorGuid = objectData.creator;
			inWorldObjectInstance.inWorldObject.guid = objectData.object_guid;
			inWorldObjectInstance.inWorldObject.width = objectData.width;
			inWorldObjectInstance.inWorldObject.height = objectData.height;
			
			if (objectData.type === 'app') {
				inWorldObjectInstance.inWorldObject.kind = InWorldObject.KIND_APP;
				inWorldObjectInstance.inWorldObject.name = objectData.name;
				inWorldObjectInstance.inWorldObject.appURL = objectData.app_url;
				inWorldObjectInstance.inWorldObject.smallIconURL = objectData.small_icon;
				inWorldObjectInstance.configData = objectData.config;
				inWorldObjectInstance.syncedData = {};
				inWorldObjectInstance.stateHistory = [];
			}
			else {
				inWorldObjectInstance.inWorldObject.kind = InWorldObject.KIND_IMAGE;
				inWorldObjectInstance.dest = objectData.dest;
				inWorldObjectInstance.inWorldObject.thumbnailURL = objectData.thumbnail_url;
				inWorldObjectInstance.inWorldObject.fullsizeURL = objectData.fullsize_url;
			}
			
			return inWorldObjectInstance;
		}
	}
}