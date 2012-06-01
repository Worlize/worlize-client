package com.worlize.model.locker
{
	import com.worlize.event.LockerEvent;
	import com.worlize.event.NotificationCenter;
	import com.worlize.model.AvatarInstance;
	import com.worlize.model.CurrentUser;
	import com.worlize.model.SimpleAvatar;
	import com.worlize.model.SimpleAvatarStore;
	import com.worlize.model.gifts.Gift;
	import com.worlize.model.gifts.GiftType;
	import com.worlize.notification.AvatarNotification;
	import com.worlize.notification.GiftNotification;
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
	public class AvatarLocker extends EventDispatcher
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_READY:String = "ready";
		public static const STATE_ERROR:String = "error";
		
		private static var _instance:AvatarLocker;
		
		public var currentUser:CurrentUser = CurrentUser.getInstance();
		
		public var count:int = 0;
		public var emptySlots:int = 0;

		public var avatarInstances:ArrayCollection = new ArrayCollection();
		private var avatarInstanceMap:Object = {};
		
		public var state:String = STATE_INIT; 
		
		private var logger:ILogger = Log.getLogger("com.worlize.model.locker.AvatarLocker");
		
		public function AvatarLocker(target:IEventDispatcher=null)
		{
			super(target);
			if (_instance !== null) {
				throw new Error("You may only create one AvatarLocker instance.");
			}
			NotificationCenter.addListener(AvatarNotification.AVATAR_INSTANCE_DELETED, handleAvatarDeleted);
			NotificationCenter.addListener(AvatarNotification.AVATAR_INSTANCE_ADDED, handleAvatarInstanceAdded);
			
			currentUser.slots.addEventListener(LockerEvent.AVATAR_LOCKER_CAPACTIY_CHANGED, handleAvatarLockerCapacityChanged);
		}
		
		public static function getInstance():AvatarLocker {
			if (_instance === null) {
				_instance = new AvatarLocker();
			}
			return _instance;
		}
		
		private function handleAvatarLockerCapacityChanged(event:LockerEvent):void {
//			var oldCapacity:int = event.oldCapacity;
//			var newCapacity:int = event.newCapacity;
//			var i:int;
//			
//			if (isNaN(oldCapacity)) { oldCapacity = 0 };
//			
//			
//			avatarInstances.disableAutoUpdate();
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
//			avatarInstances.enableAutoUpdate();
			updateCount();
		}
		
		public function getAvatarInstaceByGuid(guid:String):AvatarInstance {
			for (var i:int = 0, len:int = avatarInstances.length; i < len; i++) {
				var instance:AvatarInstance = AvatarInstance(avatarInstances.getItemAt(i));
				if (instance.guid === guid) {
					return instance;
				}
			}
			return null;
		}
		
		private function handleAvatarDeleted(notification:AvatarNotification):void {
			for (var i:int = 0, len:int = avatarInstances.length; i < len; i++) {
				var instance:AvatarInstance = AvatarInstance(avatarInstances.getItemAt(i));
				if (instance.guid == notification.deletedInstanceGuid) {
					avatarInstances.removeItemAt(i);
					delete avatarInstanceMap[instance.guid];
//					addEmptySlot();
					updateCount();
					return;
				}
			}
		}
		
		private function handleAvatarInstanceAdded(notification:AvatarNotification):void {
			avatarInstanceMap[notification.avatarInstance.guid] = notification.avatarInstance;
//			for (var i:int = 0, len:int = avatarInstances.length; i < len; i++) {
//				var instance:AvatarInstance = AvatarInstance(avatarInstances.getItemAt(i));
//				if (instance.emptySlot) {
//					avatarInstances.removeItemAt(i);
//					delete avatarInstanceMap[instance.guid];
//					avatarInstances.addItemAt(notification.avatarInstance, 0);
//					updateCount();
//					return;
//				}
//			}
			avatarInstances.addItemAt(notification.avatarInstance, 0);
			updateCount();
		}
		
//		private function addEmptySlot():void {
//			var instance:AvatarInstance = new AvatarInstance();
//			instance.emptySlot = true;
//			avatarInstances.addItem(instance);
//		}
		
//		private function removeEmptySlot():void {
//			for (var i:int = avatarInstances.length-1; i > 0; i--) {
//				var instance:AvatarInstance = AvatarInstance(avatarInstances.getItemAt(i));
//				if (instance.emptySlot) {
//					avatarInstances.removeItemAt(i);
//					return;
//				}
//			}
//			throw new Error("There are no empty slots to remove.");
//		}
		
		private function updateCount():void {
			var count:int = 0;
			for (var i:int = 0, len:int = avatarInstances.length; i < len; i++) {
				if (!AvatarInstance(avatarInstances.getItemAt(i)).emptySlot) {
					count ++;
				}
			}
			this.count = count;
			emptySlots = currentUser.slots.avatarSlots - this.count;
		}
		
		public function load():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleLoadResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send('/locker/avatars.json', HTTPMethod.GET);
			state = STATE_LOADING;
		}
		
		private function handleLoadResult(event:WorlizeResultEvent):void {
			var simpleAvatarStore:SimpleAvatarStore = SimpleAvatarStore.getInstance();
			if (event.resultJSON.success) {
				avatarInstances.removeAll();
				for each (var data:Object in event.resultJSON.data) {
					var avatarInstance:AvatarInstance = AvatarInstance.fromData(data);
					avatarInstances.addItem(avatarInstance);
					simpleAvatarStore.injectAvatar(avatarInstance.avatar);
				}
				var capacity:int = currentUser.slots.avatarSlots = event.resultJSON.capacity;
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
	}
}