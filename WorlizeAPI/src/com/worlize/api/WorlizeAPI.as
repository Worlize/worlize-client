package com.worlize.api
{
	import com.worlize.api.data.ConfigData;
	import com.worlize.api.data.StateHistory;
	import com.worlize.api.data.SyncedDataStore;
	import com.worlize.api.event.APIEvent;
	import com.worlize.api.event.AuthorEvent;
	import com.worlize.api.event.ChatEvent;
	import com.worlize.api.event.MessageEvent;
	import com.worlize.api.model.Room;
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
	
	/**
	 * Dispatched after author mode mode has been enabled by the user.
	 * 
	 * @eventType com.worlize.api.event.AuthorEvent.AUTHOR_MODE_ENABLED
	 * @productversion Worlize API.v1 
	 */
	[Event(name="authorModeEnabled",type="com.worlize.api.event.AuthorEvent")]
	
	/**
	 * Dispatched after author mode has been disabled by the user.
	 * 
	 * @eventType com.worlize.api.event.AuthorEvent.AUTHOR_MODE_DISABLED
	 * @productversion Worlize API.v1 
	 */
	[Event(name="authorModeDisabled",type="com.worlize.api.event.AuthorEvent")]

	/**
	 * Dispatched after the app's edit mode has been enabled by the user.
	 * 
	 * @eventType com.worlize.api.event.AuthorEvent.EDIT_MODE_ENABLED
	 * @productversion Worlize API.v1 
	 */
	[Event(name="editModeEnabled",type="com.worlize.api.event.AuthorEvent")]
	
	/**
	 * Dispatched after the app's edit mode has been disabled by the user.
	 * 
	 * @eventType com.worlize.api.event.AuthorEvent.EDIT_MODE_DISABLED
	 * @productversion Worlize API.v1 
	 */	
	[Event(name="editModeDisabled",type="com.worlize.api.event.AuthorEvent")]
	
	/**
	 * Dispatched when the user releases the mouse button anywhere on the
	 * screen.
	 *  
	 * <p>Since embedded apps don't have access to the screen area outside
	 * the boundaries of their own rectangle, listen to this event to track
	 * mouseUp events that occur outside the app's boundaries.</p>
	 * 
	 * <p>Traditionally, ActionScript 3 components like a Button would listen
	 * for a mouseUp event on the stage.  However, since embedded apps are
	 * sandboxed and attempting to listen to mouse events on the stage will
	 * throw a SecurityError, the Worlize API provides this equivalent event
	 * proxied through the sandbox boundaries.</p>
	 * 
	 * @eventType flash.events.MouseEvent
	 * @productversion Worlize API.v1 
	 */	
	[Event(name="mouseUp",type="flash.events.MouseEvent")]
	
	/**
	 * The entry point into the Worlize API functionality.
	 * 
	 * <p>The WorlizeAPI class must be initialized before your app will become
	 * active and visible to users.  If your app does not call the static
	 * <code>WorlizeAPI.init()</code> function within 30 seconds of your SWF's
	 * constructor executing, your app will be terminated.</p>
	 * 
	 * <p>Once the API is initialized, you can get a reference to the singleton
	 * instance by calling the static <code>WorlizeAPI.getInstance()</code>
	 * method.  The instance is also returned when you call
	 * <code>WorlizeAPI.init()</code>.</p>
	 * 
	 * @author Brian McKelvey
	 * @productversion Worlize APIv.1
	 */	
	public class WorlizeAPI extends EventDispatcher
	{
		use namespace worlize_internal;
		
		/**
		 * A constant indicating the version of the Worlize API.  The Worlize
		 * API version is an integer, which means that there is no major or
		 * minor revision number.  It increments by one every time there is a
		 * released change to the API.
		 * 
		 * @productversion Worlize APIv.1 
		 */
		public static const VERSION:int = 3;
		
		/**
		 * @private
		 */		
		worlize_internal static const GUID_REGEXP:RegExp =
			/^[\da-fA-F]{8}-[\da-fA-F]{4}-[\da-fA-F]{4}-[\da-fA-F]{4}-[\da-fA-F]{12}$/;
		
		private static var _initialized:Boolean = false;
		private static var _instance:WorlizeAPI;
		
		/**
		 * The <code>APIOptions</code> instance that defines the app's API
		 * settings.
		 * 
		 * @productversion Worlize APIv.1  
		 */		
		public static var options:APIOptions = new APIOptions();
		
		/**
		 * @private
		 */		
		worlize_internal static var rootObject:DisplayObject;

		/**
		 * @private
		 */		
		worlize_internal static var loaderInfo:LoaderInfo;
		
		/**
		 * @private
		 */		
		worlize_internal static var sharedEvents:EventDispatcher;
		
		private var _thisWorld:World;
		private var _thisRoom:ThisRoom;
		private var _thisUser:ThisUser;
		private var _thisObject:ThisRoomObject;
		private var _authorMode:Boolean;
		private var _editMode:Boolean;
		private var _config:ConfigData;
		private var _stateHistory:StateHistory;
		private var _syncedDataStore:SyncedDataStore;

		/**
		 * An object describing the current world. 
		 * @return 
		 * 
		 */		
		public function get thisWorld():World {
			return _thisWorld;
		}
		
		/**
		 * An object representing the current room.
		 * 
		 * <p>This is the entry point to much of the API functionality,
		 * since the <code>ThisRoom</code> instance provides access to the
		 * list of users in the room, other objects (apps) in the room,
		 * etc..  It also dispatches crucial events, such as
		 * <code>incomingChat</code>, <code>outgoingChat</code>, and
		 * <code>userMoved</code>.</p>
		 * 
		 * @return the current room 
		 * @productversion Worlize APIv.1
		 */		
		public function get thisRoom():ThisRoom {
			return _thisRoom;
		}

		/**
		 * An object representing the current user.
		 * 
		 * <p>Use this object to control the user's avatar, move the user
		 * on screen, cause the user to say things, etc.</p>
		 *  
		 * @see com.worlize.api.model.ThisUser#moveTo()
		 * @see com.worlize.api.model.ThisUser#say()
		 * @see com.worlize.api.model.ThisUser#avatar
		 * @return the current user
		 * @productversion Worlize APIv.1
		 */		
		public function get thisUser():ThisUser {
			return _thisUser;
		}
		
		/**
		 * An object representing the current object (app).
		 * 
		 * <p>Use this object to control aspects of this app's execution, such
		 * as its size and position, and to listen for broadcast messages
		 * from this or other apps.</p>
		 * 
		 * @see com.worlize.api.model.ThisObject#event:messageReceived
		 * @see com.worlize.api.model.ThisObject#setSize()
		 * @see com.worlize.api.model.ThisObject#moveTo()
		 * @return the current app
		 * @productversion Worlize APIv.1
		 */		
		public function get thisObject():ThisRoomObject {
			return _thisObject;
		}
		
		/**
		 * True if the current user has enabled author mode.
		 * 
		 * <p>Only users with the <code>canAuthor</code> privilege will be
		 * able to author the room, and this property can only be true when
		 * the app is running on a computer where the user has access to author
		 * mode.</p>
		 *  
		 * @return author mode enabled
		 * @productversion Worlize APIv.1
		 */		
		public function get authorMode():Boolean {
			return _authorMode;
		}
		
		/**
		 * True if the edit mode is active within author mode.
		 * 
		 * <p>This becomes active when the user selects the "Edit Settings..."
		 * option from the Object Properties dialog for this object within
		 * author mode.</p>
		 * 
		 * <p>Can only be true if the current user has the
		 * <code>canAuthor</code> privilege and the
		 * <code>editModeSupported</code> API option is <code>true</code>.</p>
		 * 
		 * @see com.worlize.api.APIOptions#editModeSupported
		 *      APIOptions.editModeSupported
		 * @return whether edit mode is enabled
		 * @productversion Worlize APIv.1
		 */		
		public function get editMode():Boolean {
			return _editMode;
		}
		
		/**
		 * Stores this app instance's persistent configuration data.
		 * 
		 * @see com.worlize.api.data.ConfigData 
		 * @return the app's persistent config datastore.
		 * @productversion Worlize APIv.1
		 */		
		public function get config():ConfigData {
			return _config;
		}
		
		/**
		 * Use the StateHistory object to synchronize state across all
		 * connected users in the room.
		 *  
		 * @see com.worlize.api.data.StateHistory
		 * @return the app's state history object
		 * @productversion Worlize APIv.1
		 */		
		public function get stateHistory():StateHistory {
			return _stateHistory;
		}
		
		/**
		 * Use the SyncedDataStore object to synchronize key/value pairs across
		 * all connected users in the room.
		 * 
		 * @see com.worlize.api.data.SyncedDataStore
		 * @return the app's synchronized key/value store
		 * @productversion Worlize APIv.1
		 */		
		public function get syncedDataStore():SyncedDataStore {
			return _syncedDataStore;
		}
		
		/**
		 * Returns a reference to the WorlizeAPI singleton instance.
		 * 
		 * <p>Use this throughout your app to gain access to the Worlize API
		 * functionality.</p>
		 * 
		 * @return the WorlizeAPI singleton instance
		 * @throws Error if the API has not yet been initialized.
		 * @see #init()
		 * @productversion Worlize APIv.1
		 */		
		public static function getInstance():WorlizeAPI {
			if (!_initialized) {
				throw new Error("Cannot get WorlizeAPI instance before calling WorlizeAPI.init()");
			}
			return _instance;
		}

		/**
		 * Initializes the Worlize API;  Must be called before the API is
		 * available for use.
		 * 
		 * <p>Call this as soon as possible in your app's lifecycle, preferably
		 * in your constructor function.  This method will create the WorlizeAPI
		 * singleton instance and set up communications with the main Worlize
		 * application across the sandbox bridge.</p>
		 * 
		 * <p>When calling <code>init</code> you must pass your root
		 * <code>DisplayObject</code> as the <code>rootObject</code> parameter.
		 * </p>
		 * 
		 * <p><strong>NOTE:</strong> If you are building a Flex app, your top-
		 * level application class does not contain a handy reference to the
		 * SWF's LoaderInfo instance, and you must pass it separately as the
		 * <code>loaderInfo</code> parameter.  If you are building a standard
		 * Flash application and have easy access to the true top-level
		 * <code>DisplayObject</code> instance, just omit the
		 * <code>loaderInfo</code> parameter.</p>
		 * 
		 * 
		 * @param rootObject the top level <code>DisplayObject</code> for your
		 * application.
		 * @param loaderInfo (optional) the main LoaderInfo instance for your
		 * application, if not available from the provided
		 * <code>rootObject</code>.
		 * @see #getInstance()
		 * @see APIOptions
		 * @return the WorlizeAPI singleton instance
		 */		
		public static function init(rootObject:DisplayObject, loaderInfo:LoaderInfo=null):WorlizeAPI {
			if (_initialized) { return _instance; }
			trace("Initializing WorlizeAPI client version " + VERSION);
			new WorlizeAPI(rootObject, loaderInfo);
			return _instance;
		}

		/**
		 * Constructor.
		 * 
		 * <p>You may not instantiate the <code>WorlizeAPI</code> class
		 * directly.  WorlizeAPI is a Singleton class, and as such, you must
		 * gain access to its singleton instance by calling
		 * <code>getInstance()</code>, which will construct the instance
		 * internally if necessary.</p>
		 *  
		 * @see #getInstance()
		 * @throws Error if you try to instantiate more than one copy of
		 * WorlizeAPI
		 * @productversion Worlize APIv.1
		 */		
		public function WorlizeAPI(rootObject:DisplayObject, loaderInfo:LoaderInfo=null) {
			super(null);
			if (_instance !== null) {
				throw new Error("You may only create one EmbeddedAPI instance.");
			}
			
			WorlizeAPI.rootObject = rootObject;
			if (loaderInfo === null) {
				WorlizeAPI.loaderInfo = rootObject.loaderInfo;
			}
			else {
				WorlizeAPI.loaderInfo = loaderInfo;
			}
			WorlizeAPI.sharedEvents = WorlizeAPI.loaderInfo.sharedEvents;
			
			addLoaderInfoListeners();
			
			handshake();
			
			initMouseUpNotifier();
			
			_instance = this;
		}
		
		/**
		 * Write arbitrary text into the chat log. 
		 * 
		 * @param text the text to log
		 * @see com.worlize.api.model.ThisRoom#announceLocal()
		 * @productversion Worlize APIv.1
		 */		
		public function log(text:String):void {
			var event:APIEvent = new APIEvent(APIEvent.LOG_MESSAGE);
			event.data = { text: text };
			sharedEvents.dispatchEvent(event);
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
				_stateHistory = new StateHistory();
				_syncedDataStore = new SyncedDataStore();
				_config = new ConfigData();
				
				_initialized = true;
				return;
			}
			
			_thisUser = ThisUser.fromData(event.data.thisUser);
			_thisObject = ThisRoomObject.fromData(event.data.thisObject);
			_thisWorld = World.fromData(event.data.thisWorld);
			_thisRoom = ThisRoom.fromData(event.data.thisRoom, _thisUser, _thisObject);
			_authorMode = event.data.authorMode;
			_editMode = false;
			
			_stateHistory = new StateHistory(event.data.stateHistory);
			_syncedDataStore = new SyncedDataStore(event.data.syncedData);
			_config = new ConfigData(event.data.config);
			
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
			sharedEvents.addEventListener("host_editModeChanged", handleEditModeChanged);
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
		
		private function handleEditModeChanged(event:Event):void {
			var newValue:Boolean = Boolean((event as Object).data);
			if (_editMode !== newValue) {
				_editMode = newValue;
				var type:String = _editMode ? AuthorEvent.EDIT_MODE_ENABLED : AuthorEvent.EDIT_MODE_DISABLED;
				dispatchEvent(new AuthorEvent(type));
			}	
		}
		
		private function handleLoaderInfoInit(event:Event):void {
			var match:Array = loaderInfo.loaderURL.match(/^https?:\/\/(.*?)\/.*$/i);
			if (match) {
				Security.allowDomain(match[1]);
			}
		}
		
		private function handleLoaderUnload(event:Event):void {
			trace("Worlize API Client Version " + VERSION + " Unloading");
		}
		
		private function handleUncaughtError(event:UncaughtErrorEvent):void {
			trace("Uncaught Error Inside Object " + thisObject.instanceGuid);
			var timer:Timer = new Timer(1,1);
			timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {
				var bombEvent:APIEvent = new APIEvent(APIEvent.REQUEST_BOMB);
				sharedEvents.dispatchEvent(bombEvent);
			});
			timer.start();
		}
	}
}