package com.worlize.model.locker
{
	import com.worlize.model.App;
	import com.worlize.model.AppInstance;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.events.PropertyChangeEvent;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
	
	public class AppLockerEntry extends EventDispatcher
	{
		[Bindable]
		public var instances:ArrayCollection;
		
		private var orderIndexCounter:int = 0;
		
		protected var watchers:Object;
		
		[Bindable]
		public var app:App;
		
		[Bindable]
		public var instancesAvailable:int = 0;
		
		[Bindable]
		public var instancesUsed:int = 0;
		
		[Bindable]
		public var viewExpanded:Boolean = false;
		
		protected var instanceRoomChangeWatcher:ChangeWatcher;
		
		public function AppLockerEntry(target:IEventDispatcher=null)
		{
			super(target);
			instances = new ArrayCollection();
			watchers = {};
			var sort:Sort = new Sort();
			sort.fields = [
				new SortField('manualOrderIndex', false, true)
			];
			instances.sort = sort;
			instances.refresh();
		}
		
		private function handleInstanceRoomChanged(event:PropertyChangeEvent):void {
			trace(event);
			updateCounts();
		}
		
		private function updateCounts():void {
			var used:int = 0;
			for each (var instance:AppInstance in instances) {
				if (instance.room) {
					used ++;
				}
			}
			instancesUsed = used;
			instancesAvailable = instances.length - instancesUsed;
		}
		
		public function addInstance(appInstance:AppInstance):void {
			if (app === null) {
				app = appInstance.app;
			}
			appInstance.manualOrderIndex = orderIndexCounter++;
			instances.addItem(appInstance);
			watchers[appInstance.guid] = ChangeWatcher.watch(appInstance, ['room'], handleInstanceRoomChanged);
			updateCounts();
		}
		
		public function removeInstance(appInstance:AppInstance):void {
			var index:int = instances.getItemIndex(appInstance);
			if (index !== -1) {
				instances.removeItemAt(index);
			}
			appInstance.manualOrderIndex = 0;
			var watcher:ChangeWatcher = watchers[appInstance.guid];
			if (watcher) {
				watcher.unwatch();
				delete watchers[appInstance.guid];
			}
			updateCounts();
		}
		
		public function removeAll():void {
			instances.removeAll();
			for each (var watcher:ChangeWatcher in watchers) {
				watcher.unwatch();
			}
			watchers = {};
		}
		
		public function get unusedInstanceAvailable():Boolean {
			return (unusedInstance !== null);
		}
		
		public function get unusedInstance():AppInstance {
			for each (var instance:AppInstance in instances) {
				if (instance.room === null) {
					return instance;
				}
			}
			return null;
		}
	}
}