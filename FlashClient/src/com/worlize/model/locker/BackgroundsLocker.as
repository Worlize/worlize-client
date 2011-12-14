package com.worlize.model.locker
{
	import com.worlize.event.NotificationCenter;
	import com.worlize.model.BackgroundImageAsset;
	import com.worlize.model.BackgroundImageInstance;
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
		
		public var capacity:int;
		public var count:int;
		public var emptySlots:int;
		public var backgroundInstances:ArrayCollection = new ArrayCollection();
		private var backgroundInstanceMap:Object = {};
		
		public var state:String = STATE_INIT; 

		
		public function BackgroundsLocker(target:IEventDispatcher=null)
		{
			super(target);
			NotificationCenter.addListener(BackgroundImageNotification.BACKGROUND_INSTANCE_ADDED, handleBackgroundInstanceAdded);
			NotificationCenter.addListener(BackgroundImageNotification.BACKGROUND_INSTANCE_DELETED, handleBackgroundDeleted);
		}
		
		private function handleBackgroundDeleted(notification:BackgroundImageNotification):void {
			for (var i:int = 0, len:int = backgroundInstances.length; i < len; i++) {
				var instance:BackgroundImageInstance = BackgroundImageInstance(backgroundInstances.getItemAt(i));
				if (instance.guid == notification.deletedInstanceGuid) {
					backgroundInstances.removeItemAt(i);
					delete backgroundInstanceMap[instance.guid];
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
			for (var i:int = 0, len:int = backgroundInstances.length; i < len; i++) {
				if (!BackgroundImageInstance(backgroundInstances.getItemAt(i)).emptySlot) {
					count ++;
				}
			}
			this.count = count;
			emptySlots = capacity - this.count;
		}
		
		private function addEmptySlot():void {
			var asset:BackgroundImageInstance = new BackgroundImageInstance();
			asset.emptySlot = true;
			backgroundInstances.addItem(asset);
		}
		
		private function handleFault(event:FaultEvent):void {
			state = STATE_ERROR;
		}
	}
}