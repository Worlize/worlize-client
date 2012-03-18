package com.worlize.api.data
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.APIEvent;
	import com.worlize.worlize_internal;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	[Event(name="itemAdded",type="com.worlize.api.data.StateHistoryEvent")]
	[Event(name="itemRemoved",type="com.worlize.api.data.StateHistoryEvent")]
	[Event(name="cleared",type="com.worlize.api.data.StateHistoryEvent")]
	public class StateHistory extends Proxy implements IEventDispatcher
	{
		use namespace worlize_internal;
		
		private static var instance:StateHistory;
		
		private var items:Array;
		private var eventDispatcher:EventDispatcher;
		
		public function StateHistory(sourceItems:Array=null) {
			if (instance !== null) {
				throw new Error("You may only create one instance of StateHistory");
			}
			
			eventDispatcher = new EventDispatcher(this);
			
			resetFromSource(sourceItems);
			
			addSharedEventListeners();
			instance = this;
		}
		
		worlize_internal function resetFromSource(sourceItems:Array):void {
			items = [];
			dispatchEvent(new StateHistoryEvent(StateHistoryEvent.CLEARED));
			if (sourceItems) {
				for each (var item:Object in sourceItems) {
					if (item is StateHistoryEntry) {
						items.push(item);
					}
					else {
						var historyEntryItem:StateHistoryEntry = new StateHistoryEntry();
						if (item.data is ByteArray) {
							historyEntryItem.data = (item.data as ByteArray).readObject();
						}
						historyEntryItem.userGuid = item.userGuid;
						items.push(historyEntryItem);
					}
				}
			}
		}
		
		protected function addSharedEventListeners():void {
			WorlizeAPI.sharedEvents.addEventListener('host_stateHistoryPush', handleStateHistoryPush);
			WorlizeAPI.sharedEvents.addEventListener('host_stateHistoryShift', handleStateHistoryShift);
			WorlizeAPI.sharedEvents.addEventListener('host_stateHistoryClear', handleStateHistoryClear);
		}
		
		protected function handleStateHistoryPush(event:Event):void { 
			var eo:Object = event;
			var item:StateHistoryEntry = new StateHistoryEntry();
			item.userGuid = eo.data.user;
			if (eo.data.data is ByteArray) {
				var ba:ByteArray = eo.data.data as ByteArray;
				ba.position = 0;
				item.data = ba.readObject();
			}
			items.push(item);
			var historyEvent:StateHistoryEvent = new StateHistoryEvent(StateHistoryEvent.ITEM_ADDED);
			historyEvent.index = items.length-1;
			historyEvent.item = item;
			dispatchEvent(historyEvent);
		}
		
		protected function handleStateHistoryShift(event:Event):void {
			if (items.length > 0) {
				var eo:Object = event;
				var removedItem:StateHistoryEntry = items.shift() as StateHistoryEntry;
				var historyEvent:StateHistoryEvent = new StateHistoryEvent(StateHistoryEvent.ITEM_REMOVED);
				historyEvent.index = 0;
				historyEvent.item = removedItem;
				historyEvent.userGuid = eo.data.user;
				dispatchEvent(historyEvent);
			}
		}
		
		protected function handleStateHistoryClear(event:Event):void {
			items = [];
			var historyEvent:StateHistoryEvent = new StateHistoryEvent(StateHistoryEvent.CLEARED);
			historyEvent.userGuid = (event as Object).data.user;
			dispatchEvent(historyEvent);
		}

		public function push(item:Object):void {
			var event:APIEvent = new APIEvent(APIEvent.STATE_HISTORY_PUSH);
			var ba:ByteArray = new ByteArray();
			ba.writeObject(item);
			ba.position = 0;
			event.data = ba;
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		public function clear():void {
			WorlizeAPI.sharedEvents.dispatchEvent(new APIEvent(APIEvent.STATE_HISTORY_CLEAR));
		}
		
		public function shift():void {
			WorlizeAPI.sharedEvents.dispatchEvent(new APIEvent(APIEvent.STATE_HISTORY_SHIFT));
		}
		
		public function get length():uint {
			return items.length;
		}
		
		public function getItemAt(index:int):* {
			return items[index];
		}
		
		override flash_proxy function getProperty(name:*):* {
			return items[name];
		}
		
		override flash_proxy function hasProperty(name:*):Boolean {
			return name in items;
		}
		
		override flash_proxy function nextNameIndex(index:int):int {
			if (index > items.length) {
				return 0;
			}
			return index + 1;
		}
		
		override flash_proxy function nextName(index:int):String {
			return String(index - 1);
		}
		
		override flash_proxy function nextValue(index:int):* {
			return items[index - 1];
		}
		
		
		/* EventDispatcher Proxy Functions */
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