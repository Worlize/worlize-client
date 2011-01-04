package com.worlize.model
{
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	
	[Bindable]
	public class PublicWorldsList extends EventDispatcher
	{
		private static var instance:PublicWorldsList;
		
		public static const STATE_LOADING:String = "loading";
		public static const STATE_READY:String = "ready";
		
		public var state:String = STATE_READY;
		
		public var list:ArrayCollection = new ArrayCollection();
		
		public function PublicWorldsList(target:IEventDispatcher=null)
		{
			super(target);
			if (instance !== null) {
				throw new Error("You may only create one instance of PublicWorldsList");
			}
			load();
		}
		
		public static function getInstance():PublicWorldsList {
			if (instance === null) {
				instance = new PublicWorldsList();
			}
			return instance;
		}
		
		public function load():void {
			state = STATE_LOADING;
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					list.removeAll();
					for each (var worldData:Object in event.resultJSON.data) {
						var world:WorldListEntry = WorldListEntry.fromData(worldData);
						list.addItem(world);
					}
				}
				else {
					Alert.show(event.resultJSON.description, "Error");
				}
				state = STATE_READY;
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was a fault encountered while trying to load the list of public worlz.", "Error");
				state = STATE_READY;
			});
			client.send("/public_worlds.json", HTTPMethod.GET);
		}
	}
}