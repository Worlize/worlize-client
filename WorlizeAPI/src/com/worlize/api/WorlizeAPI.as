package com.worlize.api
{
	import com.worlize.api.event.APIEvent;
	import com.worlize.api.event.ChatEvent;
	import com.worlize.api.model.ThisRoom;
	import com.worlize.api.model.ThisRoomObject;
	import com.worlize.api.model.ThisUser;
	import com.worlize.api.model.World;
	import com.worlize.worlize_internal;
	
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.system.Security;
	import flash.utils.Timer;
	
	public class WorlizeAPI extends EventDispatcher
	{
		use namespace worlize_internal;
		
		public static const VERSION:int = 1;
		
		public static const GUID_REGEXP:RegExp =
			/^[\da-fA-F]{8}-[\da-fA-F]{4}-[\da-fA-F]{4}-[\da-fA-F]{4}-[\da-fA-F]{12}$/;
		
		private static var _initialized:Boolean = false;
		private static var _instance:WorlizeAPI;
		
		worlize_internal static var rootObject:DisplayObject;
		worlize_internal static var loaderInfo:LoaderInfo;
		worlize_internal static var sharedEvents:EventDispatcher;
		
		private var _thisWorld:World;
		private var _thisRoom:ThisRoom;
		private var _thisUser:ThisUser;
		private var _thisObject:ThisRoomObject;
		
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
			_instance = new WorlizeAPI(rootObject);
			return _instance;
		}
		
		public function WorlizeAPI(rootObject:DisplayObject)
		{
			super(null);
			if (_instance !== null) {
				throw new Error("You may only create one EmbeddedAPI instance.");
			}
			
			WorlizeAPI.rootObject = rootObject;
			WorlizeAPI.loaderInfo = rootObject.loaderInfo;
			WorlizeAPI.sharedEvents = rootObject.loaderInfo.sharedEvents;
			
			addLoaderInfoListeners();
			
			handshake();
		}
		
		public function log(text:String):void {
			var event:APIEvent = new APIEvent(APIEvent.LOG_MESSAGE);
			event.data = { text: text };
			sharedEvents.dispatchEvent(event);
		}
		
		private function addLoaderInfoListeners():void {
			loaderInfo.addEventListener(Event.INIT, handleLoaderInfoInit);
			loaderInfo.addEventListener(Event.UNLOAD, handleLoaderUnload);
			loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, handleUncaughtError);
			
			loaderInfo.sharedEvents.addEventListener("test", function(event:Event):void {
				trace("Client: Got test event");
				var eo:Object = event;
				// eo.data.string = "String reset by client!";
				eo.data = { string: "Another string from client!" };
			});
		}

		private function handshake():void {
			var event:APIEvent = new APIEvent(APIEvent.CLIENT_HANDSHAKE);
			var data:Object = {
				APIVersion: 1
			};
			event.data = data;
			loaderInfo.sharedEvents.dispatchEvent(event);
			
			if (!(data.thisUser && data.thisObject && data.thisWorld && data.thisRoom)) {
				// Create empty mock objects, we're not actually running inside a host app
				_thisUser = new ThisUser();
				_thisRoom = new ThisRoom();
				_thisWorld = new World();
				_thisObject = new ThisRoomObject();
				return;
			}
			
			_thisUser = ThisUser.fromData(event.data.thisUser);
			_thisObject = ThisRoomObject.fromData(event.data.thisObject);
			_thisWorld = World.fromData(event.data.thisWorld);
			_thisRoom = ThisRoom.fromData(event.data.thisRoom);
			
			_thisRoom.setThisUser(_thisUser);
			
			addSharedEventHandlers();
			
//			rootObject.width = _thisObject.width;
//			rootObject.height = _thisObject.height;
			
			_initialized = true;
			
			trace("Loading initialization data complete.");
			trace("Current Room: " + thisRoom.guid + " " + thisRoom.name);
			trace("Current User: " + thisUser.guid + " " + thisUser.name);
			trace("Users in room: " + thisRoom.users.length);
		}
		
		private function addSharedEventHandlers():void {
			_thisRoom.addSharedEventHandlers(loaderInfo.sharedEvents);
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
				var moveEvent:APIEvent = new APIEvent(APIEvent.MOVE_USER);
				moveEvent.data = { x: 60, y: 60 };
				sharedEvents.dispatchEvent(moveEvent);
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
