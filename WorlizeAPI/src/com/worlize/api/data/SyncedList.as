package com.worlize.api.data
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	
	public class SyncedList extends Proxy implements IEventDispatcher
	{
		private var items:Array;
		private var eventDispatcher:EventDispatcher;
		
		public function SyncedList() {
			items = [];
			eventDispatcher = new EventDispatcher(this);
		}

		public function push(item:Object):void {
			// TODO: Implement
		}
		
		public function clear():void {
			// TODO: Implement
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
			if (index > items.length)
				return 0;
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