package com.worlize.api
{
	import com.worlize.api.data.StateHistory;
	import com.worlize.api.event.APIEvent;
	import com.worlize.api.event.AuthorEvent;
	import com.worlize.api.event.ChatEvent;
	import com.worlize.api.event.MessageEvent;
	import com.worlize.api.model.AppOptions;
	import com.worlize.api.model.RoomObject;
	import com.worlize.api.model.ThisRoom;
	import com.worlize.api.model.ThisRoomObject;
	import com.worlize.api.model.ThisUser;
	import com.worlize.api.model.User;
	import com.worlize.api.model.World;
	import com.worlize.worlize_internal;
	
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	[Event(name="mouseUp",type="flash.events.MouseEvent")]
	public class WorlizeAPI extends EventDispatcher
	{
		use namespace worlize_internal;
		
		public static const VERSION:int = 1;
		
		public static const GUID_REGEXP:RegExp =
			/^[\da-fA-F]{8}-[\da-fA-F]{4}-[\da-fA-F]{4}-[\da-fA-F]{4}-[\da-fA-F]{12}$/;
		
		private static var _initialized:Boolean = false;
		private static var _instance:WorlizeAPI;
		
		public static var options:AppOptions = new AppOptions();
		
		worlize_internal static var rootObject:DisplayObject;
		worlize_internal static var loaderInfo:LoaderInfo;
		worlize_internal static var sharedEvents:EventDispatcher;
		
		private var _thisWorld:World;
		private var _thisRoom:ThisRoom;
		private var _thisUser:ThisUser;
		private var _thisObject:ThisRoomObject;
		private var _authorMode:Boolean;
		
		private var _stateHistory:StateHistory;
		
		public function get thisWorld():World {
			return _thisWorld;
		}
		
		public function get thisRoom():ThisRoom {
			return _thisRoom;
		}

		public function get thisUser():ThisUser {
			return _thisUser;
		}
		
		public function get thisObject():ThisRoomObject {
			return _thisObject;
		}
		
		public function get authorMode():Boolean {
			return _authorMode;
		}
		
		public function get stateHistory():StateHistory {
			return _stateHistory;
		}
		
		public static function getInstance():WorlizeAPI {
			if (!_initialized) {
				throw new Error("Cannot get WorlizeAPI instance before calling WorlizeAPI.init()");
			}
			return _instance;
		}

		// Call this once to set up the communications plumbing between the
		// main worlize application and the embedded app.
		public static function init(rootObject:DisplayObject):WorlizeAPI {
			if (_initialized) { return _instance; }
			trace("Client initializing WorlizeAPI");
			new WorlizeAPI(rootObject);
			return _instance;
		}
		
		public function WorlizeAPI(rootObject:DisplayObject) {
			super(null);
			if (_instance !== null) {
				throw new Error("You may only create one EmbeddedAPI instance.");
			}
			
			WorlizeAPI.rootObject = rootObject;
			WorlizeAPI.loaderInfo = rootObject.loaderInfo;
			WorlizeAPI.sharedEvents = rootObject.loaderInfo.sharedEvents;
			
			addLoaderInfoListeners();
			
			handshake();
			
			initMouseUpNotifier();
			
			_instance = this;
		}
		
		public function log(text:String):void {
			var event:APIEvent = new APIEvent(APIEvent.LOG_MESSAGE);
			event.data = { text: text };
			sharedEvents.dispatchEvent(event);
		}
		
		public function saveConfig():void {
			
		}
		
		private function addLoaderInfoListeners():void {
			loaderInfo.addEventListener(Event.INIT, handleLoaderInfoInit);
			loaderInfo.addEventListener(Event.UNLOAD, handleLoaderUnload);
			loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, handleUncaughtError);
		}

		private function handshake():void {
			var event:APIEvent = new APIEvent(APIEvent.CLIENT_HANDSHAKE);
			var data:Object = {
				APIVersion: 1,
				appOptions: options.toJSON()
			};
			event.data = data;
			sharedEvents.dispatchEvent(event);
			
			if (!(data.thisUser && data.thisObject && data.thisWorld && data.thisRoom)) {
				// Create empty mock objects, we're not actually running inside a host app
				_thisUser = new ThisUser();
				_thisRoom = new ThisRoom();
				_thisWorld = new World();
				_thisObject = new ThisRoomObject();
				
				_initialized = true;
				return;
			}
			
			_thisUser = ThisUser.fromData(event.data.thisUser);
			_thisObject = ThisRoomObject.fromData(event.data.thisObject);
			_thisWorld = World.fromData(event.data.thisWorld);
			_thisRoom = ThisRoom.fromData(event.data.thisRoom, _thisUser, _thisObject);
			_authorMode = event.data.authorMode;
			
			_stateHistory = new StateHistory(event.data.stateHistory);
			
			addSharedEventHandlers();
			
			var finishHandshakeEvent:APIEvent = new APIEvent(APIEvent.CLIENT_FINISH_HANDSHAKE);
			sharedEvents.dispatchEvent(finishHandshakeEvent);
			
			_initialized = true;
		}
		
		private function initMouseUpNotifier():void {
			rootObject.addEventListener(MouseEvent.MOUSE_UP, handleRootObjectMouseUp);
		}
		
		private function handleRootObjectMouseUp(event:MouseEvent):void {
			sharedEvents.dispatchEvent(event);
		}
		
		private function addSharedEventHandlers():void {
			_thisRoom.addSharedEventHandlers(sharedEvents);
			sharedEvents.addEventListener("host_roomObjectMessageReceived", handleRoomObjectMessageReceived);
			sharedEvents.addEventListener("host_applicationMouseUp", handleApplicationMouseUp);
			sharedEvents.addEventListener("host_authorModeChanged", handleAuthorModeChanged);
		}
		
		private function handleRoomObjectMessageReceived(event:Event):void {
			var eo:Object = event;
			var fromObject:RoomObject = _thisRoom.getObjectByGuid(eo.data.fromApp);
			var fromUser:User = _thisRoom.getUserByGuid(eo.data.fromUser);
			if (fromObject && fromUser) {
				var msgEvent:MessageEvent = new MessageEvent(MessageEvent.MESSAGE_RECEIVED);
				msgEvent.fromObject = fromObject;
				msgEvent.fromUser = fromUser;
				if (eo.data.message is ByteArray) {
					try {
						var ba:ByteArray = eo.data.message as ByteArray;
						ba.position = 0;
						msgEvent.message = ba.readObject();
					}
					catch(e:Error) {
						log(thisObject.guid + " - Invalid AMF3 object data when decoding app broadcast message: " + e.toString());
						return;
					}
				}
				_thisObject.dispatchEvent(msgEvent);
			}
		}
		
		private function handleApplicationMouseUp(eo:Object):void {
			dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, false, false, 0, 0, null, eo.data.ctrlKey, eo.data.altKey, eo.data.shiftKey, false, 0));
		}
		
		private function handleAuthorModeChanged(event:Event):void {
			var newValue:Boolean = Boolean((event as Object).data);
			if (_authorMode !== newValue) {
				_authorMode = newValue;
				var type:String = _authorMode ? AuthorEvent.AUTHOR_MODE_ENABLED : AuthorEvent.AUTHOR_MODE_DISABLED;
				dispatchEvent(new AuthorEvent(type));
			}
		}
		
		private function handleLoaderInfoInit(event:Event):void {
			trace("Client: LoaderContentInfo INIT");
			
			var match:Array = loaderInfo.loaderURL.match(/^https?:\/\/(.*?)\/.*$/i);
			if (match) {
				trace("Calling Security.allowDomain(" + match[1] + ")");
				Security.allowDomain(match[1]);
			}
		}
		
		private function handleLoaderUnload(event:Event):void {
			trace("Worlize API Client Unloading");
		}
		
		private function handleUncaughtError(event:UncaughtErrorEvent):void {
			trace("Uncaught Error Inside Object " + thisObject.guid);
			var timer:Timer = new Timer(1,1);
			timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {
				var bombEvent:APIEvent = new APIEvent(APIEvent.REQUEST_BOMB);
				sharedEvents.dispatchEvent(bombEvent);
			});
			timer.start();
		}
	}
}


//			var match:Array = loaderInfo.loaderURL.match(/^(https?):\/\/(.*?)\/.*$/);
//			if (!match) {
//				throw new Error("Unable to determine loader url to allow.");
//			}

//			if (match[1] === 'http') {
//				Security.allowInsecureDomain(match[2]);
//			}
//			else {
//				Security.allowDomain(match[2]);
//			}
