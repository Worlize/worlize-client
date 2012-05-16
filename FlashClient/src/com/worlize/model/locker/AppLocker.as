package com.worlize.model.locker
{
	import com.worlize.event.LockerEvent;
	import com.worlize.event.NotificationCenter;
	import com.worlize.model.CurrentUser;
	import com.worlize.model.AppInstance;
	import com.worlize.notification.AppNotification;
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
	
	[Bindable]
	public class AppLocker extends EventDispatcher
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_READY:String = "ready";
		public static const STATE_ERROR:String = "error";
		
		private var logger:ILogger = Log.getLogger('com.worlize.model.locker.AppLocker');
		
		public var currentUser:CurrentUser = CurrentUser.getInstance();
		
		public var count:int;
		public var emptySlots:int;
		
		public var instances:ArrayCollection = new ArrayCollection();
		private var instanceMap:Object = {};
		
		public var state:String = STATE_INIT;
		
		public function AppLocker(target:IEventDispatcher=null)
		{
			super(target);
			NotificationCenter.addListener(AppNotification.APP_INSTANCE_ADDED, handleAppInstanceAdded);
			NotificationCenter.addListener(AppNotification.APP_INSTANCE_DELETED, handleAppInstanceDeleted);
			NotificationCenter.addListener(AppNotification.APP_INSTANCE_ADDED_TO_ROOM, handleAppInstanceAddedToRoom);
			NotificationCenter.addListener(AppNotification.APP_INSTANCE_REMOVED_FROM_ROOM, handleAppInstanceRemovedFromRoom);
			
			currentUser.slots.addEventListener(LockerEvent.APP_LOCKER_CAPACITY_CHANGED, handleAppLockerCapacityChanged);
		}
		
		private function handleAppLockerCapacityChanged(event:LockerEvent):void {
//			var oldCapacity:int = event.oldCapacity;
//			var newCapacity:int = event.newCapacity;
//			var i:int;
//			
//			if (isNaN(oldCapacity)) { oldCapacity = 0 };
//			instances.disableAutoUpdate();
//			if (newCapacity - oldCapacity > 0) {
//				var slotsToAdd:int = newCapacity - oldCapacity;
//				// if there were previously fewer slots than the user had avatars...
//				if (emptySlots < 0) {
//					slotsToAdd += emptySlots;
//				}
//				for (i = 0; i < slotsToAdd; i++) {
//					addEmptySlot();
//				}
//			}
//			else if (newCapacity - oldCapacity < 0) {
//				var slotsToRemove:int = oldCapacity - newCapacity;
//				for (i = 0; i < slotsToRemove; i++) {
//					try {
//						removeEmptySlot();
//					}
//					catch(e:Error) {
//						// bail out
//						logger.warn("Tried to remove an empty slot but there are none left to remove.");
//						break;
//					}
//				}
//			}
//			instances.enableAutoUpdate();
			updateCount();
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
				if (instance.guid == notification.instanceGuid) {
					instances.removeItemAt(i);
					delete instanceMap[instance.guid];
//					addEmptySlot();
					updateCount();
					return;
				}
			}
		}
		
		private function handleAppInstanceAdded(notification:AppNotification):void {
			instanceMap[notification.appInstance.guid] = notification.appInstance;
//			for (var i:int = 0, len:int = instances.length; i < len; i++) {
//				var instance:AppInstance = AppInstance(instances.getItemAt(i));
//				if (instance.emptySlot) {
//					instances.removeItemAt(i);
//					delete instanceMap[instance.guid];
//					instances.addItemAt(notification.appInstance, 0);
//					updateCount();
//					return;
//				}
//			}
			instances.addItem(notification.appInstance);
			updateCount();
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
			var instance:AppInstance;
			if (result.success) {
				logger.info("Success: Got " + result.count + " apps.");
				instances.removeAll();
				for each (var rawData:Object in result.data) {
					instance = AppInstance.fromLockerData(rawData);
					instances.addItem(instance);
					instanceMap[instance.guid] = instance;
				}
				var capacity:int = currentUser.slots.appSlots = result.capacity;
				count = result.count;
				emptySlots = capacity - count;
//				for (var i:int = 0; i < emptySlots; i++) {
//					addEmptySlot();
//				}
				state = STATE_READY;
			}
			else {
				logger.error("Failed to load app locker information.");
				state = STATE_ERROR;
			}
		}
		
		private function updateCount():void {
//			var count:int = 0;
//			for (var i:int = 0, len:int = instances.length; i < len; i++) {
//				if (!AppInstance(instances.getItemAt(i)).emptySlot) {
//					count ++;
//				}
//			}
//			this.count = count;
			this.count = instances.length;
			emptySlots = currentUser.slots.appSlots - this.count;
		}
		
//		private function addEmptySlot():void {
//			var asset:AppInstance = new AppInstance();
//			asset.emptySlot = true;
//			instances.addItem(asset);
//		}
		
//		private function removeEmptySlot():void {
//			for (var i:int = instances.length-1; i > 0; i--) {
//				var instance:AppInstance = AppInstance(instances.getItemAt(i));
//				if (instance.emptySlot) {
//					instances.removeItemAt(i);
//					return;
//				}
//			}
//			throw new Error("There are no empty slots to remove.");
//		}
		
		private function handleFault(event:FaultEvent):void {
			logger.error("Unable to load app locker. " + event);
			state = STATE_ERROR;
		}
	}
}