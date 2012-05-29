package com.worlize.interactivity.api
{
	import com.worlize.interactivity.api.adapter.IAPIClientAdapter;
	import com.worlize.interactivity.api.event.AppLoaderEvent;
	import com.worlize.interactivity.api.event.ClientValidationErrorEvent;
	import com.worlize.interactivity.rpc.InteractivityClient;
	import com.worlize.model.AppInstance;
	import com.worlize.model.InWorldObject;
	import com.worlize.model.AppInstance;
	
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.UncaughtErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	import mx.controls.SWFLoader;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	[Event(name="handshakeComplete",type="com.worlize.interactivity.api.event.AppLoaderEvent")]
	[Event(name="appBombed",type="com.worlize.interactivity.api.event.AppLoaderEvent")]
	[Event(name="validationError",type="com.worlize.interactivity.api.event.ClientValidationErrorEvent")]
	public class AppLoader extends SWFLoader
	{
		use namespace mx_internal;
		
		private var interactivityClient:InteractivityClient = InteractivityClient.getInstance();
		protected var _appInstance:AppInstance;
		protected var _adapter:IAPIClientAdapter;
		
		private var _hasError:Boolean = false;
		
		[Bindable(event="hasErrorChanged")]
		public function get hasError():Boolean {
			return _hasError;
		}
		
		private var logger:ILogger = Log.getLogger("com.worlize.interactivity.api.AppLoader");
		
		public function get appInstance():AppInstance {
			return _appInstance;
		}
		
		public function get appGuid():String {
			return _appInstance.guid;
		}
		
		public function get clientAdapter():IAPIClientAdapter {
			return _adapter;
		}
		
		override public function set autoLoad(newValue:Boolean):void {
			throw new Error("autoLoad is not supported on AppLoader");
		}
		
		public function AppLoader()
		{
			super();
			scaleContent = false;
			loadForCompatibility = true;
			trustContent = false;
			var context:LoaderContext = new LoaderContext();
			context.allowCodeImport = false;
			context.checkPolicyFile = true;
			context.applicationDomain = new ApplicationDomain(null);
			loaderContext = context;
			super.autoLoad = false;
			logger = Log.getLogger("com.worlize.interactivity.api.AppLoader" + uid);
		}
		
		override public function load(url:Object = null):void {
			if (url === null) {
				super.load(null);
				return;
			}
			
			if (!(url is AppInstance)) {
				throw new Error("A AppLoader instance can only attempt to load instances of AppInstance");
			}
			_appInstance = url as AppInstance;
			
			_appInstance.state = AppInstance.STATE_LOADING;
			
			logger.info("Loading app \"" + _appInstance.app.name + "\"");
			super.load(_appInstance.app.appURL + "?cb=" + Math.round((Math.random()*0xFFFFFFFF)).toString(16));
			addClientInitListeners();
		}
		
		protected function addClientInitListeners():void {
			if (contentHolder is Loader) {
				var loader:Loader = contentHolder as Loader;
				loader.contentLoaderInfo.addEventListener(Event.INIT, handleContentLoaderInfoInit);
				loader.contentLoaderInfo.addEventListener(Event.UNLOAD, handleContentLoaderInfoUnload);
				logger.info("Adding UNCAUGHT_ERROR handler");
				loader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, handleUncaughtErrorEvent);
				loader.contentLoaderInfo.sharedEvents.addEventListener('client_handshake', handleClientHandshake);
			}
			else {
				_appInstance.state = AppInstance.STATE_LOAD_ERROR;
				throw new Error("AppLoader must load a SWF file as an API client.");
			}
		}
		
		protected function handleClientHandshake(event:Event):void {
			var e:Object = event;
			logger.info("API Client handshake starting");
			if ('data' in e) {
				if ('APIVersion' in e.data) {
					_adapter = interactivityClient.apiController.getClientAdapterForVersion(e.data.APIVersion);
					if (_adapter === null) {
						logger.error("Unable to get API Client Adapter during handshake.");
						bombApp();
						return;
					}
					try {
						_adapter.attachClient(this);
						_adapter.attachHost(interactivityClient.apiController);
						_adapter.handshakeClient(e.data);
					}
					catch(error:Error) {
						interactivityClient.apiController.logMessage(
							"Error while handshaking with app " + appGuid + ": " +
							error.toString() + "\n" + error.getStackTrace()
						);
						bombApp();
						return;
					}
					dispatchEvent(new AppLoaderEvent(AppLoaderEvent.HANDSHAKE_COMPLETE));
					return;
				}
			}
			logger.error("Invalid client_handshake event received from API client!");
			bombApp();
		}
		
		protected function handleContentLoaderInfoInit(event:Event):void {
			logger.info("API Client Content INIT");
			var loader:Loader = contentHolder as Loader;
			if (!loader) {
				logger.fatal("Cannot access loader during contentLoaderInfo INIT event.  This should be impossible?!");
				return;
			}
			
			var errorEvent:ClientValidationErrorEvent;
			var validationError:Boolean = false;
			var validationMessage:String;
			
			if (appInstance.sizeUnknown) {
				appInstance.resizeLocal(loader.contentLoaderInfo.width, loader.contentLoaderInfo.height);
			}
			
			if (loader.contentLoaderInfo.contentType !== "application/x-shockwave-flash") {
				validationError = true;
				validationMessage = "AppLoader is only designed to load SWF client applications written against the Worlize API";
			}
			else if (loader.contentLoaderInfo.actionScriptVersion !== 3) {
				validationError = true;
				validationMessage = "Worlize API client applications must be written in ActionScript 3";
			}
//			else if (_adapter === null || _adapter.state !== AppInstance.STATE_READY) {
//				validationError = true;
//				validationMessage = "Client SWF must initialize the Worlize API in the main constructor function";
//			}
			
			if (validationError) {
				bombApp();
				logger.error("API Client Validation error: " + validationMessage);
				errorEvent = new ClientValidationErrorEvent(ClientValidationErrorEvent.VALIDATION_ERROR);
				errorEvent.text = validationMessage;
				dispatchEvent(errorEvent);
				return;
			}
		}
		
		protected function handleContentLoaderInfoUnload(event:Event):void {
			if (contentHolder is Loader) {
				logger.info("Removing uncaught error handler for unloaded content");
				var loader:Loader = contentHolder as Loader;
				loader.uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, handleUncaughtErrorEvent);
			}
			
			if (_adapter) {
				logger.info("Setting _adapter to null.");
				_adapter = null;
			}
			if (_appInstance) {
				logger.info("_appInstance set to null.  App \"" + _appInstance.app.name + "\" unloaded.");
				_appInstance.state = AppInstance.STATE_UNLOADED;
				_appInstance = null;
			}
			else {
				logger.info("Unknown app unloaded.");
			}
		}
		
		protected function handleUncaughtErrorEvent(event:UncaughtErrorEvent):void {
			if (_adapter) {
				logger.error("Uncaught error in embedded SWF, passing to the adapter to handle it.");
				_adapter.handleUncaughtError(event);
			}
			else if (appInstance) {
				logger.error("Uncaught error in embedded SWF, but no clientAdapter available to handle it!");
				if (event.error is Error) {
					var error:Error = event.error as Error;
					logger.error(
						"Uncaught error from app " + appInstance.app.guid + ": " +
						"ErrorID: " + error.errorID + " " + error.name + " " + error.message + " " + error.getStackTrace()
					);
				}
				else if (event.error is ErrorEvent) {
					var errorEvent:ErrorEvent = event.error as ErrorEvent;
					logger.error(
						"Unhandled error event from app " + appInstance.app.guid + ": " +
						"ErrorID: " + errorEvent.errorID + " Type: " + errorEvent.type + " Text: " + errorEvent.text
					);
				}
			}
			else {
				logger.error("We don't even have an appInstance when receiving this error event!  How is this possible??!");
			}
			event.preventDefault();
			event.stopPropagation();
			
			bombApp();
		}
		
		public function bombApp():void {
			logger.error("Bombing app: Unloading child SWF file.");
			_hasError = true;
			_appInstance.state = AppInstance.STATE_BOMBED;
			if (appInstance.width < 64) {
				appInstance.width = 64;
			}
			if (appInstance.height < 64) {
				appInstance.height = 64;
			}
			dispatchEvent(new FlexEvent('hasErrorChanged'));
			var bombEvent:AppLoaderEvent = new AppLoaderEvent(AppLoaderEvent.APP_BOMBED);
			dispatchEvent(bombEvent);
			unloadAndStop();
		}
	}
}