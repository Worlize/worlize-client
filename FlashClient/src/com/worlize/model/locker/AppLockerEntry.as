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
	
	public class AppLockerEntry extends EventDispatcher
	{
		[Bindable]
		public var instances:ArrayCollection;
		
		protected var watchers:Vector.<ChangeWatcher>;
		
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
			watchers = new Vector.<ChangeWatcher>();
			var sort:Sort = new Sort();
			sort.compareFunction = function(a:Object, b:Object, fields:Array = null):int {
				var appA:AppInstance = AppInstance(a);
				var appB:AppInstance = AppInstance(b);
				if (appA.room !== null && appB.room === null) {
					return 1;
				}
				if (appA.room === null && appB.room !== null) {
					return -1;
				}
				return 0;
			};
			instances.sort = sort;
			instances.refresh();
			
			instanceRoomChangeWatcher = ChangeWatcher.watch(this, ['instances','room'], handleInstanceRoomChanged);
		}
		
		private function handleInstanceRoomChanged(event:PropertyChangeEvent):void {
			trace(event);
			updateCounts();
		}
		
		private function updateCounts():void {
			for each (var instance:AppInstance in instances) {
				if (instance.room) {
					instancesUsed ++;
				}
			}
			instancesAvailable = instances.length - instancesUsed;
		}
		
		public function addInstance(appInstance:AppInstance):void {
			if (app === null) {
				app = appInstance.app;
			}
			instances.addItem(appInstance);
			updateCounts();
		}
		
		public function removeInstance(appInstance:AppInstance):void {
			var index:int = instances.getItemIndex(appInstance);
			if (index !== -1) {
				instances.removeItemAt(index);
			}
			updateCounts();
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