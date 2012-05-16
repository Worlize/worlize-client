package com.worlize.model
{
	import com.worlize.event.NotificationCenter;
	import com.worlize.interactivity.event.RoomEvent;
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
	public class AppInstance extends EventDispatcher implements IRoomItem
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_LOAD_ERROR:String = "loadError";
		public static const STATE_READY:String = "ready";
		public static const STATE_HANDSHAKING:String = "handshaking";
		public static const STATE_UNLOADING:String = "unloading";
		public static const STATE_UNLOADED:String = "unloaded";
		public static const STATE_BOMBED:String = "bombed";
		
		public static var logger:ILogger = Log.getLogger("com.worlize.model.AppInstance");
		
		private var _state:String = STATE_INIT;
		public var app:App;
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
				event.appInstance = this;
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
		
		public static function fromLockerData(data:Object):AppInstance {
			var appInstance:AppInstance = new AppInstance();
			appInstance.guid = data.guid;
			appInstance.app = App.fromData(data.app);
			if (data.room) {
				appInstance.room = new RoomListEntry();
				appInstance.room.name = data.room.name;
				appInstance.room.guid = data.room.guid;
			}
			return appInstance;
		}
		
		public function moveLocal(x:int, y:int):void {
			this.x = x;
			this.y = y;
			var event:RoomEvent = new RoomEvent(RoomEvent.APP_MOVED);
			event.appInstance = this;
			dispatchEvent(event);
		}
		
		public function resizeLocal(width:int, height:int):void {
			if (this.width !== width || this.height !== height) {
				this.width = width;
				this.height = height;
				var event:RoomEvent = new RoomEvent(RoomEvent.APP_RESIZED);
				event.appInstance = this;
				dispatchEvent(event);
			}
		}
		
		public function requestDelete():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleDeleteResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send("/locker/apps/" + guid + ".json", HTTPMethod.DELETE);
		}
		
		private function handleFault(event:FaultEvent):void {
			logger.error("App Instance " + guid + " delete failed. " + event);
		}
		
		private function handleDeleteResult(event:WorlizeResultEvent):void {
			logger.info("App Instance " + guid + " deleted successfully.");
			var notification:InWorldObjectNotification = new InWorldObjectNotification(InWorldObjectNotification.IN_WORLD_OBJECT_INSTANCE_DELETED);
			notification.instanceGuid = guid;
			NotificationCenter.postNotification(notification);
		}
		
		public static function fromData(objectData:Object):AppInstance {
			var appInstance:AppInstance = new AppInstance();
			appInstance.guid = objectData.guid;
			appInstance.x = objectData.x;
			appInstance.y = objectData.y;
			appInstance.app = new App();
			appInstance.app.creatorGuid = objectData.creator;
			appInstance.app.guid = objectData.app_guid;
			appInstance.app.width = objectData.width;
			appInstance.app.height = objectData.height;
			appInstance.app.name = objectData.name;
			appInstance.app.appURL = objectData.app_url;
			appInstance.app.smallIconURL = objectData.small_icon;
			appInstance.configData = objectData.config;
			appInstance.syncedData = {};
			appInstance.stateHistory = [];
			appInstance.dest = objectData.dest;
			return appInstance;
		}
	}
}