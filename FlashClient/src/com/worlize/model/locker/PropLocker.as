package com.worlize.model.locker
{
	import com.worlize.event.LockerEvent;
	import com.worlize.event.NotificationCenter;
	import com.worlize.model.CurrentUser;
	import com.worlize.model.Prop;
	import com.worlize.model.PropInstance;
	import com.worlize.model.gifts.Gift;
	import com.worlize.model.gifts.GiftType;
	import com.worlize.notification.GiftNotification;
	import com.worlize.notification.PropNotification;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;
	
	[Bindable]
	public class PropLocker extends EventDispatcher
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_READY:String = "ready";
		public static const STATE_ERROR:String = "error";
		
		private static var _instance:PropLocker;
		
		public var currentUser:CurrentUser = CurrentUser.getInstance();
		
		public var count:int = 0;
		public var emptySlots:int = 0;
		
		public var propInstances:ArrayCollection = new ArrayCollection();
		private var propInstanceMap:Object = {};
		
		public var state:String = STATE_INIT; 
		
		private var logger:ILogger = Log.getLogger("com.worlize.model.locker.PropLocker");
		
		public function PropLocker(target:IEventDispatcher=null)
		{
			super(target);
			if (_instance !== null) {
				throw new Error("You may only create one PropLocker instance.");
			}
			NotificationCenter.addListener(PropNotification.PROP_INSTANCE_DELETED, handlePropDeleted);
			NotificationCenter.addListener(PropNotification.PROP_INSTANCE_ADDED, handlePropInstanceAdded);
			
			currentUser.slots.addEventListener(LockerEvent.PROP_LOCKER_CAPACITY_CHANGED, handlePropsLockerCapacityChanged);
		}
		
		public static function getInstance():PropLocker {
			if (_instance === null) {
				_instance = new PropLocker();
			}
			return _instance;
		}
		
		public function hasPropGuid(guid:String):Boolean {
			for each (var propInstance:PropInstance in propInstances) {
				if (propInstance.emptySlot) { continue; }
				if (propInstance.prop.guid === guid) {
					return true;
				}
			}
			return false;
		}
		
		private function handlePropsLockerCapacityChanged(event:LockerEvent):void {
//			var oldCapacity:int = event.oldCapacity;
//			var newCapacity:int = event.newCapacity;
//			var i:int;
//			
//			if (isNaN(oldCapacity)) { oldCapacity = 0 };
//			
//			
//			propInstances.disableAutoUpdate();
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
//			propInstances.enableAutoUpdate();
			
			updateCount();
		}
		
		public function getPropInstanceByGuid(guid:String):PropInstance {
			for (var i:int = 0, len:int = propInstances.length; i < len; i++) {
				var instance:PropInstance = PropInstance(propInstances.getItemAt(i));
				if (instance.guid === guid) {
					return instance;
				}
			}
			return null;
		}
		
		private function handlePropDeleted(notification:PropNotification):void {
			for (var i:int = 0, len:int = propInstances.length; i < len; i++) {
				var instance:PropInstance = PropInstance(propInstances.getItemAt(i));
				if (instance.guid == notification.deletedInstanceGuid) {
					propInstances.removeItemAt(i);
					delete propInstanceMap[instance.guid];
//					addEmptySlot();
					updateCount();
					return;
				}
			}
		}
		
		private function handlePropInstanceAdded(notification:PropNotification):void {
			propInstanceMap[notification.propInstance.guid] = notification.propInstance;
//			for (var i:int = 0, len:int = propInstances.length; i < len; i++) {
//				var instance:PropInstance = PropInstance(propInstances.getItemAt(i));
//				if (instance.emptySlot) {
//					propInstances.removeItemAt(i);
//					delete propInstanceMap[instance.guid];
//					propInstances.addItemAt(notification.propInstance, 0);
//					updateCount();
//					return;
//				}
//			}
			propInstances.addItemAt(notification.propInstance, 0);
			updateCount();
		}
		
//		private function addEmptySlot():void {
//			var instance:PropInstance = new PropInstance();
//			instance.emptySlot = true;
//			propInstances.addItem(instance);
//		}
//		
//		private function removeEmptySlot():void {
//			for (var i:int = propInstances.length-1; i > 0; i--) {
//				var instance:PropInstance = PropInstance(propInstances.getItemAt(i));
//				if (instance.emptySlot) {
//					propInstances.removeItemAt(i);
//					return;
//				}
//			}
//			throw new Error("There are no empty slots to remove.");
//		}
		
		private function updateCount():void {
			var count:int = 0;
			for (var i:int = 0, len:int = propInstances.length; i < len; i++) {
				if (!PropInstance(propInstances.getItemAt(i)).emptySlot) {
					count ++;
				}
			}
			this.count = count;
			emptySlots = currentUser.slots.propSlots - this.count;
		}
		
		public function load():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleLoadResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send('/locker/props.json', HTTPMethod.GET);
			state = STATE_LOADING;
		}
		
		private function handleLoadResult(event:WorlizeResultEvent):void {
			if (event.resultJSON.success) {
				propInstances.removeAll();
				for each (var data:Object in event.resultJSON.data) {
					var propInstance:PropInstance = PropInstance.fromData(data);
					propInstances.addItem(propInstance);
				}
				var capacity:int = currentUser.slots.propSlots = event.resultJSON.capacity;
				count = event.resultJSON.count;
				emptySlots = capacity - count;
//				for (var i:int = 0; i < emptySlots; i++) {
//					addEmptySlot();
//				}
				state = STATE_READY;
			}
			else {
				state = STATE_ERROR;
			}
		}
		
		private function handleFault(event:FaultEvent):void {
			state = STATE_ERROR;
		}

		public function savePropFromRoom(propGuid:String):void {
			if (hasPropGuid(propGuid)) {
				Alert.show("You already have that prop in your locker.", "Save Prop");
				return;
			}
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleSaveToLockerResult);
			client.addEventListener(FaultEvent.FAULT, handleSaveToLockerFault);
			client.send("/props/" + propGuid + "/save_to_locker.json", HTTPMethod.POST);
		}
	
		private function handleSaveToLockerResult(event:WorlizeResultEvent):void {
			if (event.resultJSON.success) {
				// do nothing
			}
			else {
				Alert.show(event.resultJSON.description, "Error");
			}
		}
		
		private function handleSaveToLockerFault(event:FaultEvent):void {
			Alert.show("There was an unknown fault encountered while saving the prop to your locker.", "Error");
		}
	}
}