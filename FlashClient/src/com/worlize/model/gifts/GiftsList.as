package com.worlize.model.gifts
{
	import com.worlize.event.NotificationCenter;
	import com.worlize.notification.GiftNotification;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.remoting.RemoteObject;
	
	public class GiftsList extends EventDispatcher
	{
		public static const STATE_READY:String = "ready";
		public static const STATE_LOADING:String = "loading";
		
		private static var _instance:GiftsList;
		
		[Bindable]
		public var giftsList:ArrayCollection = new ArrayCollection();

		private var _state:String = STATE_READY;
		
		[Bindable(event="stateChange")]
		public function set state(newValue:String):void {
			if (_state !== newValue) {
				_state = newValue;
				dispatchEvent(new FlexEvent('stateChange'));
			}
		}
		public function get state():String {
			return _state;
		}
		
		public static function getInstance():GiftsList {
			if (_instance === null) {
				_instance = new GiftsList();
			}
			return _instance;
		}
		
		public function GiftsList(target:IEventDispatcher=null)
		{
			super(target);
			if (_instance !== null) {
				throw new Error("You may only create one GiftsList instance.");
			}
			
			NotificationCenter.addListener(GiftNotification.GIFT_ACCEPTED, handleGiftAccepted);
			NotificationCenter.addListener(GiftNotification.GIFT_REJECTED, handleGiftRejected);
			
			load();
		}
		
		public function addGift(gift:Gift):void {
			giftsList.addItemAt(gift, 0);
		}
		
		public function load():void {
			state = STATE_LOADING;
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					giftsList.removeAll();
					for each (var giftData:Object in event.resultJSON.data) {
						var gift:Gift = Gift.fromData(giftData);
						giftsList.addItem(gift);
					}
				}
				else {
					Alert.show("There was an error while loading your gifts list: " + event.resultJSON.description, "Error");
				}
				state = STATE_READY;
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was a fault encountered while loading your gifts list.", "Error");
				state = STATE_READY;
			});
			client.send("/gifts.json", HTTPMethod.GET);
		}
		
		public function prune():void {
			for (var i:int=giftsList.length-1; i >= 0; i--) {
				var gift:Gift = (giftsList.getItemAt(i)) as Gift;
				if (gift.state !== Gift.STATE_NEW && gift.state !== Gift.STATE_LOADING) {
					giftsList.removeItemAt(i);
				}
			}
		}
		
		private function handleGiftAccepted(notification:GiftNotification):void {
			
		}
		
		private function handleGiftRejected(notification:GiftNotification):void {
			
		}
	}
}