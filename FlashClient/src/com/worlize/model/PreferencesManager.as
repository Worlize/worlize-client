package com.worlize.model
{
	import com.adobe.serialization.json.JSON;
	import com.worlize.event.NotificationCenter;
	import com.worlize.event.PreferencesEvent;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.utils.Timer;
	
	import mx.rpc.events.FaultEvent;
	
	import org.osmf.events.TimeEvent;
	
	public class PreferencesManager extends EventDispatcher
	{
		private static var _instance:PreferencesManager;
		private var _initialized:Boolean = false;
		private var prefs:Object = {};
		private var timer:Timer = new Timer(100, 1);
		
		public function PreferencesManager()
		{
			if (_instance) {
				throw new Error("You may only create one instance of PreferencesManager");
			}
			timer.addEventListener(TimerEvent.TIMER, handleTimer);
			load();
		}
		
		public function get initialized():Boolean { 
			return _initialized;
		}
		
		public static function getInstance():PreferencesManager {
			if (!_instance) {
				_instance = new PreferencesManager();
			}
			return _instance;		
		}
		
		public function getPreference(name:String):Object {
			return prefs[name];
		}
		public function setPreference(name:String, value:Object):void {
			prefs[name] = value;
			save();
		}
		
		public function preferenceDefined(name:String):Boolean {
			return (name in prefs);
		}
		
		public function load():void {
			var service:WorlizeServiceClient = new WorlizeServiceClient();
			service.addEventListener(WorlizeResultEvent.RESULT, handleLoadResult);
			service.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void { });
			service.send('/preferences', HTTPMethod.GET);
		}
		
		public function save():void {
			timer.stop();
			timer.reset();
			timer.start();
		}
		
		private function handleTimer(event:TimerEvent):void {
			actuallySave();
		}
		
		public function actuallySave():void {
			var service:WorlizeServiceClient = new WorlizeServiceClient();
			service.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				var saveEvent:PreferencesEvent = new PreferencesEvent(PreferencesEvent.PREFERENCES_SAVED);
				dispatchEvent(saveEvent);
			});
			service.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				// do nothing
			});
			service.send('/preferences', HTTPMethod.PUT, { data: JSON.encode(prefs) } );
		}
		
		private function handleLoadResult(event:WorlizeResultEvent):void {
			prefs = event.resultJSON;
			if (!_initialized) {
				_initialized = true;
				var initEvent:PreferencesEvent = new PreferencesEvent(PreferencesEvent.PREFERENCES_INITIALIZED);
				dispatchEvent(initEvent);
			}
			var loadEvent:PreferencesEvent = new PreferencesEvent(PreferencesEvent.PREFERENCES_LOADED);
			dispatchEvent(loadEvent);
		}
	}
}