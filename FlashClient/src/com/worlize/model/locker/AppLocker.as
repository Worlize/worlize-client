package com.worlize.model.locker
{
	import com.worlize.event.LockerEvent;
	import com.worlize.event.NotificationCenter;
	import com.worlize.model.AppInstance;
	import com.worlize.model.CurrentUser;
	import com.worlize.notification.AppNotification;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;
	
	import spark.collections.Sort;
	
	[Bindable]
	public class AppLocker extends EventDispatcher
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_READY:String = "ready";
		public static const STATE_ERROR:String = "error";
		
		private var logger:ILogger = Log.getLogger('com.worlize.model.locker.AppLocker');
		
		public var currentUser:CurrentUser = CurrentUser.getInstance();
		
		public var instances:ArrayCollection = new ArrayCollection();
		private var instanceMap:Object = {};
		
		public var entries:ArrayCollection = new ArrayCollection();
		protected var entriesByAppGuid:Object;
		
		public var state:String = STATE_INIT;
		
		public function AppLocker(target:IEventDispatcher=null)
		{
			super(target);
			NotificationCenter.addListener(AppNotification.APP_INSTANCE_ADDED, handleAppInstanceAdded);
			NotificationCenter.addListener(AppNotification.APP_INSTANCE_DELETED, handleAppInstanceDeleted);
			NotificationCenter.addListener(AppNotification.APP_INSTANCE_ADDED_TO_ROOM, handleAppInstanceAddedToRoom);
			NotificationCenter.addListener(AppNotification.APP_INSTANCE_REMOVED_FROM_ROOM, handleAppInstanceRemovedFromRoom);
			
			var sort:Sort = new Sort();
			sort.compareFunction = function(a:Object, b:Object, items:Array=null):int {
				var entryA:AppLockerEntry = AppLockerEntry(a);
				var entryB:AppLockerEntry = AppLockerEntry(b);
				var nameA:String = (entryA.app && entryA.app.name) ? entryA.app.name.toLowerCase() : '';
				var nameB:String = (entryB.app && entryB.app.name) ? entryB.app.name.toLowerCase() : '';
				if (nameA < nameB) {
					return -1;
				}
				if (nameA > nameB) {
					return 1;
				}
				if (entryA.app.guid < entryB.app.guid) {
					return -1;
				}
				if (entryA.app.guid > entryB.app.guid) {
					return 1;
				}
				return 0;
			};
			entries.sort = sort;
			entries.refresh();
		}
		
		private function handleAppInstanceAddedToRoom(notification:AppNotification):void {
			var instance:AppInstance = instanceMap[notification.instanceGuid];
			if (instance) {
				instance.room = notification.room;
			}
		}
		
		private function handleAppInstanceRemovedFromRoom(notification:AppNotification):void {
			var instance:AppInstance = instanceMap[notification.instanceGuid];
			if (instance) {
				instance.room = null;
			}
		}
		
		private function handleAppInstanceDeleted(notification:AppNotification):void {
			for (var i:int = 0, len:int = instances.length; i < len; i++) {
				var instance:AppInstance = AppInstance(instances.getItemAt(i));
				if (instance.guid === notification.instanceGuid) {
					removeAppInstance(instance);
					return;
				}
			}
		}
		
		private function handleAppInstanceAdded(notification:AppNotification):void {
			instanceMap[notification.appInstance.guid] = notification.appInstance;
			addAppInstance(notification.appInstance);
			instances.addItemAt(notification.appInstance, 0);
		}
		
		private function addAppInstance(appInstance:AppInstance):void {
			instances.addItemAt(appInstance, 0);
			instanceMap[appInstance.guid] = appInstance;
			
			var entry:AppLockerEntry = getOrCreateAppLockerEntryByAppGuid(appInstance.app.guid);
			entry.addInstance(appInstance);
		}
		
		private function removeAppInstance(appInstance:AppInstance):void {
			var index:int = instances.getItemIndex(appInstance);
			if (index !== -1) {
				instances.removeItemAt(index);
			}
			delete instanceMap[appInstance.guid];
			
			var entry:AppLockerEntry = entriesByAppGuid[appInstance.app.guid];
			if (entry) {
				entry.removeInstance(appInstance);
			}
			
			if (entry.instances.length === 0) {
				removeAppLockerEntryByAppGuid(appInstance.app.guid);
			}
		}
		
		private function getOrCreateAppLockerEntryByAppGuid(appGuid:String):AppLockerEntry {
			var entry:AppLockerEntry = entriesByAppGuid[appGuid];
			if (entry === null) {
				entry = entriesByAppGuid[appGuid] = new AppLockerEntry();
				entries.addItem(entry);
			}
			return entry;
		}
		
		private function removeAppLockerEntryByAppGuid(appGuid:String):AppLockerEntry {
			var entry:AppLockerEntry = entriesByAppGuid[appGuid];
			if (entry) {
				var index:int = entries.getItemIndex(entry);
				if (index !== -1) {
					entries.removeItemAt(index);
				}
				delete entriesByAppGuid[appGuid];
			}
			return entry;
		}
		
		public function load():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleLoadResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send('/locker/apps.json', HTTPMethod.GET);
			state = STATE_LOADING;
		}
		
		private function handleLoadResult(event:WorlizeResultEvent):void {
			var result:Object = event.resultJSON;
			if (result.success) {
				logger.info("Success: Got " + result.count + " apps.");
				instances.removeAll();
				instanceMap = {};
				entries.removeAll();
				entriesByAppGuid = {};
				instances.disableAutoUpdate();
				entries.disableAutoUpdate();
				for each (var rawData:Object in result.data) {
					addAppInstance(AppInstance.fromLockerData(rawData));
				}
				instances.enableAutoUpdate();
				entries.enableAutoUpdate();
				state = STATE_READY;
			}
			else {
				logger.error("Failed to load app locker information.");
				state = STATE_ERROR;
			}
		}
		
		private function handleFault(event:FaultEvent):void {
			logger.error("Unable to load app locker. " + event);
			state = STATE_ERROR;
		}
	}
}