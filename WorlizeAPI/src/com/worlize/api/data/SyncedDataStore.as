package com.worlize.api.data
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.APIEvent;
	import com.worlize.api.event.ChangeEvent;
	import com.worlize.api.model.User;
	import com.worlize.worlize_internal;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	[Event(name="propertyChanged",type="com.worlize.api.event.ChangeEvent")]
	[Event(name="propertyDeleted",type="com.worlize.api.event.ChangeEvent")]
	public dynamic class SyncedDataStore extends Proxy implements IEventDispatcher
	{
		use namespace worlize_internal;
		
		protected var eventDispatcher:EventDispatcher;
		
		protected var keys:Array;
		
		worlize_internal var data:Object;
		
		public function SyncedDataStore(sourceData:Object = null) {
			super();
			eventDispatcher = new EventDispatcher(this);
			data = {};
			keys = [];
			
			if (sourceData) {
				for (var key:String in sourceData) {
					var ba:ByteArray = sourceData[key] as ByteArray;
					ba.position = 0;
					var value:* = ba.readObject();
					keys.push(key);
					data[key] = value;
				}
			}
			
			addSharedEventListeners();
		}
		
		protected function addSharedEventListeners():void {
			WorlizeAPI.sharedEvents.addEventListener("host_syncedDataSet", handleSyncedDataSet);
			WorlizeAPI.sharedEvents.addEventListener("host_syncedDataDelete", handleSyncedDataDelete);
		}
		
		public function get(key:String):* {
			return data[key];
		}

		public function set(key:String, value:*):void {
			var event:APIEvent = new APIEvent(APIEvent.SYNCED_DATA_SET);
			var ba:ByteArray = new ByteArray();
			ba.endian = Endian.BIG_ENDIAN;
			ba.writeObject(value);
			ba.position = 0;
			event.data = {
				key: key,
				value: ba
			};
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		public function remove(key:String):void {
			var event:APIEvent = new APIEvent(APIEvent.SYNCED_DATA_DELETE);
			event.data = {
				key: key
			};
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		protected function handleSyncedDataSet(event:Event):void {
			var eo:Object = event;
			var changedBy:User;
			if (eo.data.user) {
				changedBy = WorlizeAPI.getInstance().thisRoom.getUserByGuid(eo.data.user);
				if (!changedBy) {
					changedBy = User.fromData({
						name: "Unknown User",
						guid: eo.data.user,
						privileges: [],
						x: 0,
						y:0,
						face:0,
						color:0
					});
				}
			}
			var ba:ByteArray = eo.data.value;
			ba.position = 0;
			var value:* = ba.readObject();
			updateValue(eo.data.key, value, changedBy);				
		}
		
		protected function handleSyncedDataDelete(event:Event):void {
			var eo:Object = event;
			var changedBy:User;
			if (eo.data.user) {
				changedBy = WorlizeAPI.getInstance().thisRoom.getUserByGuid(eo.data.user);
				if (!changedBy) {
					changedBy = User.fromData({
						name: "Unknown User",
						guid: eo.data.user,
						privileges: [],
						x: 0,
						y:0,
						face:0,
						color:0
					});
				}
			}
			deleteValue(eo.data.key, changedBy);
		}
		
		worlize_internal function updateValue(key:String, newValue:*, changedBy:User = null):void {
			var oldValue:* = data[key];
			if (oldValue !== newValue) {
				if (!(key in data)) {
					keys.push(key);
				}
				data[key] = newValue;
				var event:ChangeEvent = new ChangeEvent(ChangeEvent.PROPERTY_CHANGED);
				event.name = key;
				event.oldValue = oldValue;
				event.newValue = newValue;
				event.changedBy = changedBy;
				eventDispatcher.dispatchEvent(event);
			}
		}
		
		worlize_internal function deleteValue(key:String, changedBy:User = null):void {
			if (key in data) {
				var oldValue:* = data[key];
				delete data[key];
				var keyIndex:int = keys.indexOf(key);
				if (keyIndex !== -1) {
					keys.splice(keyIndex, 1);
				}
				var event:ChangeEvent = new ChangeEvent(ChangeEvent.PROPERTY_DELETED);
				event.name = key;
				event.oldValue = oldValue;
				event.newValue = undefined;
				event.changedBy = changedBy;
				eventDispatcher.dispatchEvent(event);
			}
		}
		
		
		// flash.utils.Proxy methods
		
		override flash_proxy function getProperty(name:*):* {
			return data[name];
		}
		
		override flash_proxy function hasProperty(name:*):Boolean {
			return name in data;
		}
		
		override flash_proxy function nextNameIndex(index:int):int {
			if (index < keys.length) {
				return index + 1;
			}
			else {
				return 0;
			}
		}
		
		override flash_proxy function nextName(index:int):String {
			return keys[index - 1];
		}
		
		override flash_proxy function nextValue(index:int):* {
			return data[keys[index - 1]];
		}
		
		// EventDispatcher proxy methods
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
			eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function dispatchEvent(event:Event):Boolean {
			return eventDispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean {
			return eventDispatcher.hasEventListener(type);
		}
		
		public function willTrigger(type:String):Boolean {
			return eventDispatcher.willTrigger(type);
		}
	}
}