package com.worlize.interactivity.model
{
	import com.worlize.event.PreferencesEvent;
	import com.worlize.interactivity.event.IgnoredUserEvent;
	import com.worlize.model.PreferencesManager;
	
	import flash.events.EventDispatcher;
	
	import mx.logging.ILogger;
	import mx.logging.Log;

	[Event(name="userIgnored", type="com.worlize.interactivity.event.IgnoredUserEvent")]
	[Event(name="userUnignored", type="com.worlize.interactivity.event.IgnoredUserEvent")]
	
	public class IgnoredUserManager extends EventDispatcher
	{
		private var preferences:PreferencesManager;
		protected var logger:ILogger = Log.getLogger('com.worlize.interactivity.model.IgnoredUserManager');
		protected static var instance:IgnoredUserManager;
		
		protected var userGuidMap:Object = {};
		protected var userGuids:Vector.<String> = new Vector.<String>();
		
		public static function getInstance():IgnoredUserManager {
			if (instance) {
				return instance;
			}
			new IgnoredUserManager();
			return instance;
		}
		
		public function IgnoredUserManager()
		{
			if (instance) {
				throw new Error('Only one instance of IgnoredUserManager may be created');
			}
			preferences = PreferencesManager.getInstance()
			if (preferences.initialized) {
				handlePreferencesInitialized();
			}
			else {
				preferences.addEventListener(PreferencesEvent.PREFERENCES_INITIALIZED, handlePreferencesInitialized);
			}
			instance = this;
		}
		
		protected function handlePreferencesInitialized(event:PreferencesEvent=null):void {
			var blockedUsers:Array = preferences.getPreference('blockedUsers');
			if (blockedUsers) {
				for each (var guid:String in blockedUsers) {
					ignoreUser(guid, false);
				}
			}
		}
		
		public function ignoreUser(guid:String, autoSave:Boolean = true):void {
			if (isIgnored(guid)) { return; }
			guid = guid.toLowerCase();
			userGuidMap[guid] = true;
			userGuids.push(guid);
			if (autoSave) { save(); }
			var event:IgnoredUserEvent = new IgnoredUserEvent(IgnoredUserEvent.USER_IGNORED);
			event.userGuid = guid;
			dispatchEvent(event);
		}
		
		public function unignoreUser(guid:String, autoSave:Boolean = true):void {
			guid = guid.toLowerCase();
			var index:int = userGuids.indexOf(guid);
			if (index !== -1) {
				userGuids.splice(index, 1);
				delete userGuidMap[guid];
				if (autoSave) { save(); }
				var event:IgnoredUserEvent = new IgnoredUserEvent(IgnoredUserEvent.USER_UNIGNORED);
				event.userGuid = guid;
				dispatchEvent(event);
			}
		}
		
		public function isIgnored(guid:String):Boolean {
			if (userGuidMap[guid.toLowerCase()]) {
				return true;
			}
			return false;
		}
		
		protected function save():void {
			var guids:Array = [];
			for each (var guid:String in userGuids) {
				guids.push(guid);
			}
			preferences.setPreference('blockedUsers', guids);
		}
	}
}