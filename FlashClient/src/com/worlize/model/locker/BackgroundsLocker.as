package com.worlize.model.locker
{
	import com.worlize.event.LockerEvent;
	import com.worlize.event.NotificationCenter;
	import com.worlize.model.BackgroundImageAsset;
	import com.worlize.model.BackgroundImageInstance;
	import com.worlize.model.CurrentUser;
	import com.worlize.notification.BackgroundImageNotification;
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
	public class BackgroundsLocker extends EventDispatcher
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_READY:String = "ready";
		public static const STATE_ERROR:String = "error";
		
		private var logger:ILogger = Log.getLogger('com.worlize.model.locker.BackgroundsLocker');
		
		public var currentUser:CurrentUser = CurrentUser.getInstance();
		
		public var count:int = 0;
		public var emptySlots:int = 0;
		
		public var backgroundInstances:ArrayCollection = new ArrayCollection();
		private var backgroundInstanceMap:Object = {};
		
		public var state:String = STATE_INIT; 

		public function BackgroundsLocker(target:IEventDispatcher=null)
		{
			super(target);
			NotificationCenter.addListener(BackgroundImageNotification.BACKGROUND_INSTANCE_ADDED, handleBackgroundInstanceAdded);
			NotificationCenter.addListener(BackgroundImageNotification.BACKGROUND_INSTANCE_DELETED, handleBackgroundDeleted);
			NotificationCenter.addListener(BackgroundImageNotification.BACKGROUND_INSTANCE_UPDATED, handleBackgroundInstanceUpdated);
			NotificationCenter.addListener(BackgroundImageNotification.BACKGROUND_INSTANCE_USED, handleBackgroundInstanceUsed);
			NotificationCenter.addListener(BackgroundImageNotification.BACKGROUND_INSTANCE_UNUSED, handleBackgroundInstanceUnused);
			
			currentUser.slots.addEventListener(LockerEvent.BACKGROUND_LOCKER_CAPACITY_CHANGED, handleBackgroundLockerCapacityChanged);
		}
		
		private function handleBackgroundLockerCapacityChanged(event:LockerEvent):void {
			var oldCapacity:int = event.oldCapacity;
			var newCapacity:int = event.newCapacity;
			var i:int;
			
			if (isNaN(oldCapacity)) { oldCapacity = 0 };
			
			
			backgroundInstances.disableAutoUpdate();
			if (newCapacity - oldCapacity > 0) {
				var slotsToAdd:int = newCapacity - oldCapacity;
				// if there were previously fewer slots than the user had avatars...
				if (emptySlots < 0) {
					slotsToAdd += emptySlots;
				}
				for (i = 0; i < slotsToAdd; i++) {
					addEmptySlot();
				}
			}
			else if (newCapacity - oldCapacity < 0) {
				var slotsToRemove:int = oldCapacity - newCapacity;
				for (i = 0; i < slotsToRemove; i++) {
					try {
						removeEmptySlot();
					}
					catch(e:Error) {
						// bail out
						logger.warn("Tried to remove an empty slot but there are none left to remove.");
						break;
					}
				}
			}
			backgroundInstances.enableAutoUpdate();
			
			updateCount();
		}
		
		private function handleBackgroundDeleted(notification:BackgroundImageNotification):void {
			removeBackgroundInstanceByGuid(notification.instanceGuid);
		}
		
		private function removeBackgroundInstanceByGuid(guid:String):void {
			for (var i:int = 0, len:int = backgroundInstances.length; i < len; i ++) {
				var instance:BackgroundImageInstance = BackgroundImageInstance(backgroundInstances.getItemAt(i));
				if (instance.guid === guid) {
					backgroundInstances.removeItemAt(i);
					delete backgroundInstanceMap[guid];
					addEmptySlot();
					updateCount();
					return;
				}
			}
		}
		
		private function handleBackgroundInstanceAdded(notification:BackgroundImageNotification):void {
			backgroundInstanceMap[notification.backgroundInstance.guid] = notification.backgroundInstance;
			for (var i:int = 0, len:int = backgroundInstances.length; i < len; i++) {
				var instance:BackgroundImageInstance = BackgroundImageInstance(backgroundInstances.getItemAt(i));
				if (instance.emptySlot) {
					backgroundInstances.removeItemAt(i);
					delete backgroundInstanceMap[instance.guid];
					backgroundInstances.addItemAt(notification.backgroundInstance, 0);
					updateCount();
					return;
				}
			}
			backgroundInstances.addItem(notification.backgroundInstance);
			updateCount();
		}
		
		private function handleBackgroundInstanceUpdated(notification:BackgroundImageNotification):void {
			var existingInstance:BackgroundImageInstance = backgroundInstanceMap[notification.updatedBackgroundInstanceGuid];
			if (existingInstance) {
				existingInstance.updateData(notification.updatedBackgroundInstanceData);				
			}
		}
		
		private function handleBackgroundInstanceUsed(notification:BackgroundImageNotification):void {
			var instance:BackgroundImageInstance = backgroundInstanceMap[notification.instanceGuid];
			if (instance) {
				instance.room = notification.room;
			}
		}
		
		private function handleBackgroundInstanceUnused(notification:BackgroundImageNotification):void {
			var instance:BackgroundImageInstance = backgroundInstanceMap[notification.instanceGuid];
			if (instance) {
				instance.room = null;
			}
		}
		
		public function load():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleLoadResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send('/locker/backgrounds.json', HTTPMethod.GET);
			state = STATE_LOADING;
		}
		
		public function updateItems(newItems:Array):void {
			for each (var newData:Object in newItems) {
				var instance:BackgroundImageInstance = backgroundInstanceMap[newData.guid];
				if (instance) {
					instance.updateData(newData); 
				}
			}
		}
		
		private function handleLoadResult(event:WorlizeResultEvent):void {
			var result:Object = event.resultJSON;
			var asset:BackgroundImageInstance;
			if (result.success) {
				logger.info("Success: Got " + result.count + " backgrounds.");
				backgroundInstances.removeAll();
				for each (var rawData:Object in result.data) {
					asset = BackgroundImageInstance.fromData(rawData);
					backgroundInstances.addItem(asset);
					backgroundInstanceMap[asset.guid] = asset;
				}
				var capacity:int = currentUser.slots.backgroundSlots = result.capacity;
				count = result.count;
				emptySlots = capacity - count;
				for (var i:int = 0; i < emptySlots; i++) {
					addEmptySlot();
				}
				state = STATE_READY;
			}
			else {
				logger.error("Failed to load background locker information.");
				state = STATE_ERROR;
			}
		}
		
		private function updateCount():void {
			var count:int = 0;
			for (var i:int = 0, len:int = backgroundInstances.length; i < len; i++) {
				if (!BackgroundImageInstance(backgroundInstances.getItemAt(i)).emptySlot) {
					count ++;
				}
			}
			this.count = count;
			emptySlots = currentUser.slots.backgroundSlots - this.count;
		}
		
		private function addEmptySlot():void {
			var asset:BackgroundImageInstance = new BackgroundImageInstance();
			asset.emptySlot = true;
			backgroundInstances.addItem(asset);
		}
		
		private function removeEmptySlot():void {
			for (var i:int = backgroundInstances.length-1; i > 0; i--) {
				var instance:BackgroundImageInstance = BackgroundImageInstance(backgroundInstances.getItemAt(i));
				if (instance.emptySlot) {
					backgroundInstances.removeItemAt(i);
					return;
				}
			}
			throw new Error("There are no empty slots to remove.");
		}
		
		private function handleFault(event:FaultEvent):void {
			state = STATE_ERROR;
		}
	}
}