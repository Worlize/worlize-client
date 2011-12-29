package com.worlize.model.locker
{
	import com.worlize.event.LockerEvent;
	import com.worlize.event.NotificationCenter;
	import com.worlize.model.CurrentUser;
	import com.worlize.model.InWorldObjectInstance;
	import com.worlize.notification.InWorldObjectNotification;
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
	public class InWorldObjectLocker extends EventDispatcher
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_READY:String = "ready";
		public static const STATE_ERROR:String = "error";
		
		private var logger:ILogger = Log.getLogger('com.worlize.model.locker.InWorldObjectLocker');
		
		public var currentUser:CurrentUser = CurrentUser.getInstance();
		
		public var count:int;
		public var emptySlots:int;
		
		public var instances:ArrayCollection = new ArrayCollection();
		private var instanceMap:Object = {};
		
		public var state:String = STATE_INIT; 
		
		
		public function InWorldObjectLocker(target:IEventDispatcher=null)
		{
			super(target);
			NotificationCenter.addListener(InWorldObjectNotification.IN_WORLD_OBJECT_INSTANCE_ADDED, handleInWorldObjectAdded);
			NotificationCenter.addListener(InWorldObjectNotification.IN_WORLD_OBJECT_INSTANCE_DELETED, handleInWorldObjectDeleted);
			NotificationCenter.addListener(InWorldObjectNotification.IN_WORLD_OBJECT_ADDED_TO_ROOM, handleInWorldObjectAddedToRoom);
			NotificationCenter.addListener(InWorldObjectNotification.IN_WORLD_OBJECT_REMOVED_FROM_ROOM, handleInWorldObjectRemovedFromRoom);
			
			currentUser.slots.addEventListener(LockerEvent.IN_WORLD_OBJECT_LOCKER_CAPACITY_CHANGED, handleInWorldObjectLockerCapacityChanged);
		}
		
		private function handleInWorldObjectLockerCapacityChanged(event:LockerEvent):void {
			var oldCapacity:int = event.oldCapacity;
			var newCapacity:int = event.newCapacity;
			var i:int;
			
			if (isNaN(oldCapacity)) { oldCapacity = 0 };
			
			
			instances.disableAutoUpdate();
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
			instances.enableAutoUpdate();
			
			updateCount();
		}

		private function handleInWorldObjectAddedToRoom(notification:InWorldObjectNotification):void {
			var instance:InWorldObjectInstance = instanceMap[notification.instanceGuid];
			if (instance) {
				instance.room = notification.room;
			}
		}
		
		private function handleInWorldObjectRemovedFromRoom(notification:InWorldObjectNotification):void {
			var instance:InWorldObjectInstance = instanceMap[notification.instanceGuid];
			if (instance) {
				instance.room = null;
			}
		}
		
		private function handleInWorldObjectDeleted(notification:InWorldObjectNotification):void {
			for (var i:int = 0, len:int = instances.length; i < len; i++) {
				var instance:InWorldObjectInstance = InWorldObjectInstance(instances.getItemAt(i));
				if (instance.guid == notification.deletedInstanceGuid) {
					instances.removeItemAt(i);
					delete instanceMap[instance.guid];
					addEmptySlot();
					updateCount();
					return;
				}
			}
		}
		
		private function handleInWorldObjectAdded(notification:InWorldObjectNotification):void {
			instanceMap[notification.inWorldObjectInstance.guid] = notification.inWorldObjectInstance;
			for (var i:int = 0, len:int = instances.length; i < len; i++) {
				var instance:InWorldObjectInstance = InWorldObjectInstance(instances.getItemAt(i));
				if (instance.emptySlot) {
					instances.removeItemAt(i);
					delete instanceMap[instance.guid];
					instances.addItemAt(notification.inWorldObjectInstance, 0);
					updateCount();
					return;
				}
			}
			instances.addItem(notification.inWorldObjectInstance);
			updateCount();
		}
		
		public function load():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleLoadResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send('/locker/in_world_objects.json', HTTPMethod.GET);
			state = STATE_LOADING;
		}
		
		private function handleLoadResult(event:WorlizeResultEvent):void {
			var result:Object = event.resultJSON;
			var instance:InWorldObjectInstance;
			if (result.success) {
				logger.info("Success: Got " + result.count + " objects.");
				instances.removeAll();
				for each (var rawData:Object in result.data) {
					instance = InWorldObjectInstance.fromData(rawData);
					instances.addItem(instance);
					instanceMap[instance.guid] = instance;
				}
				var capacity:int = currentUser.slots.inWorldObjectSlots = result.capacity;
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
			for (var i:int = 0, len:int = instances.length; i < len; i++) {
				if (!InWorldObjectInstance(instances.getItemAt(i)).emptySlot) {
					count ++;
				}
			}
			this.count = count;
			emptySlots = currentUser.slots.inWorldObjectSlots - this.count;
		}
		
		private function addEmptySlot():void {
			var asset:InWorldObjectInstance = new InWorldObjectInstance();
			asset.emptySlot = true;
			instances.addItem(asset);
		}
		
		private function removeEmptySlot():void {
			for (var i:int = instances.length-1; i > 0; i--) {
				var instance:InWorldObjectInstance = InWorldObjectInstance(instances.getItemAt(i));
				if (instance.emptySlot) {
					instances.removeItemAt(i);
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