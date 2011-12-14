package com.worlize.model.locker
{
	import com.worlize.event.NotificationCenter;
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
	
	public class InWorldObjectLocker extends EventDispatcher
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_READY:String = "ready";
		public static const STATE_ERROR:String = "error";
		
		private var logger:ILogger = Log.getLogger('com.worlize.model.locker.InWorldObjectLocker');
		
		[Bindable]
		public var capacity:int;
		
		[Bindable]
		public var count:int;
		
		[Bindable]
		public var emptySlots:int;
		
		[Bindable]
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
				capacity = result.capacity;
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
			emptySlots = capacity - this.count;
		}
		
		private function addEmptySlot():void {
			var asset:InWorldObjectInstance = new InWorldObjectInstance();
			asset.emptySlot = true;
			instances.addItem(asset);
		}
		
		private function handleFault(event:FaultEvent):void {
			state = STATE_ERROR;
		}
	}
}