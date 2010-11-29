package com.worlize.model.locker
{
	import com.worlize.model.BackgroundImageAsset;
	import com.worlize.model.BackgroundImageInstance;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	
	[Bindable]
	public class BackgroundsLocker extends EventDispatcher
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_READY:String = "ready";
		public static const STATE_ERROR:String = "error";
		
		public var capacity:int;
		public var count:int;
		public var backgroundInstances:ArrayCollection = new ArrayCollection();
		
		public var state:String = STATE_INIT; 

		
		public function BackgroundsLocker(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function load():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleLoadResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send('/locker/backgrounds', HTTPMethod.GET);
			state = STATE_LOADING;
		}
		
		private function handleLoadResult(event:WorlizeResultEvent):void {
			var result:Object = event.resultJSON;
			if (result.success) {
				trace("Success: Got " + result.count + " backgrounds.");
				backgroundInstances.removeAll();
				for each (var rawData:Object in result.data) {
					var asset:BackgroundImageInstance = BackgroundImageInstance.fromData(rawData);
					backgroundInstances.addItem(asset);
				}
				capacity = result.capacity;
				count = result.count;
				state = STATE_READY;
			}
			else {
				trace("Failed to load background locker information.");
				state = STATE_ERROR;
			}
		}
		
		private function handleFault(event:FaultEvent):void {
			state = STATE_ERROR;
		}
	}
}