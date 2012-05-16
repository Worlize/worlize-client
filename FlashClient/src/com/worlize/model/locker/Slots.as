package com.worlize.model.locker
{
	import com.worlize.event.LockerEvent;
	import com.worlize.event.NotificationCenter;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.events.FlexEvent;
	import mx.rpc.events.FaultEvent;
	
	[Event(name="avatarLockerCapacityChanged", type="com.worlize.event.LockerEvent")]
	[Event(name="backgroundLockerCapacityChanged", type="com.worlize.event.LockerEvent")]
	[Event(name="inWorldObjectLockerCapacityChanged", type="com.worlize.event.LockerEvent")]
	[Event(name="propLockerCapacityChanged", type="com.worlize.event.LockerEvent")]
	public class Slots extends EventDispatcher
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_READY:String = "ready";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_ERROR:String = "error";
		
		[Bindable(event="stateChange")]
		private var _state:String = STATE_INIT;
		public function set state(newValue:String):void {
			if (_state !== newValue) {
				_state = newValue;
				trace("Setting state to " + newValue);
				dispatchEvent(new FlexEvent('stateChange'));
			}
		}
		public function get state():String {
			return _state;
		}
		
		[Bindable(event="pricingStateChange")]
		private var _pricingState:String = STATE_INIT;
		public function set pricingState(newValue:String):void {
			if (_pricingState !== newValue) {
				_pricingState = newValue;
				trace("Setting pricing state to " + newValue);
				dispatchEvent(new FlexEvent('pricingStateChange'));
			}
		}
		public function get pricingState():String {
			return _pricingState;
		}
		
		private var _avatarSlots:int;
		private var _backgroundSlots:int;
		private var _inWorldObjectSlots:int;
		private var _propSlots:int;
		private var _appSlots:int;
		
		[Bindable(event="avatarLockerCapacityChanged")]
		public function set avatarSlots(newValue:int):void {
			if (_avatarSlots !== newValue) {
				var oldValue:int = _avatarSlots;
				_avatarSlots = newValue;
				var event:LockerEvent = new LockerEvent(LockerEvent.AVATAR_LOCKER_CAPACTIY_CHANGED);
				event.oldCapacity = oldValue;
				event.newCapacity = newValue;
				dispatchEvent(event);
			}
		}
		public function get avatarSlots():int {
			return _avatarSlots;
		}
		
		[Bindable(event="backgroundLockerCapacityChanged")]
		public function set backgroundSlots(newValue:int):void {
			if (_backgroundSlots !== newValue) {
				var oldValue:int = _backgroundSlots;
				_backgroundSlots = newValue;
				var event:LockerEvent = new LockerEvent(LockerEvent.BACKGROUND_LOCKER_CAPACITY_CHANGED);
				event.oldCapacity = oldValue;
				event.newCapacity = newValue;
				dispatchEvent(event);
			}
		}
		public function get backgroundSlots():int {
			return _backgroundSlots;
		}
		
		[Bindable(event="inWorldObjectLockerCapacityChanged")]
		public function set inWorldObjectSlots(newValue:int):void {
			if (_inWorldObjectSlots !== newValue) {
				var oldValue:int = _inWorldObjectSlots;
				_inWorldObjectSlots = newValue;
				var event:LockerEvent = new LockerEvent(LockerEvent.IN_WORLD_OBJECT_LOCKER_CAPACITY_CHANGED);
				event.oldCapacity = oldValue;
				event.newCapacity = newValue;
				dispatchEvent(event);
			}
		}
		public function get inWorldObjectSlots():int {
			return _inWorldObjectSlots;
		}
		
		[Bindable(event="appLockerCapacityChanged")]
		public function set appSlots(newValue:int):void {
			if (_appSlots !== newValue) {
				var oldValue:int = _appSlots;
				_appSlots = newValue;
				var event:LockerEvent = new LockerEvent(LockerEvent.APP_LOCKER_CAPACITY_CHANGED);
				event.oldCapacity = oldValue;
				event.newCapacity = newValue;
				dispatchEvent(event);
			}
		}
		public function get appSlots():int {
			return _appSlots;
		}
		
		[Bindable(event="propLockerCapacityChanged")]
		public function set propSlots(newValue:int):void {
			if (_propSlots !== newValue) {
				var oldValue:int = _propSlots;
				_propSlots = newValue;
				var event:LockerEvent = new LockerEvent(LockerEvent.PROP_LOCKER_CAPACITY_CHANGED);
				event.oldCapacity = oldValue;
				event.newCapacity = newValue;
				dispatchEvent(event);
			}
		}
		public function get propSlots():int {
			return _propSlots;
		}
		
		[Bindable]
		public var avatarSlotPrice:int;
		
		[Bindable]
		public var backgroundSlotPrice:int;
		
		[Bindable]
		public var inWorldObjectSlotPrice:int;
		
		[Bindable]
		public var propSlotPrice:int;
		
		public function Slots(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function load():void {
			if (state === STATE_LOADING) {
				return;
			}
			state = STATE_LOADING;
			
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleLoadResult);
			client.addEventListener(FaultEvent.FAULT, handleLoadFault);
			client.send("/locker/slots", HTTPMethod.GET);
		}
		
		private function handleLoadResult(event:WorlizeResultEvent):void {
			if (event.resultJSON.success) {
				avatarSlots = event.resultJSON.avatar_slots;
				backgroundSlots = event.resultJSON.background_slots;
				inWorldObjectSlots = event.resultJSON.in_world_object_slots;
				propSlots = event.resultJSON.prop_slots;
			}
			else {
				state = STATE_ERROR;
			}
		}
		
		private function handleLoadFault(event:FaultEvent):void {
			state = STATE_ERROR;
		}
		
		public function loadPrices():void {
			if (pricingState === STATE_LOADING) {
				return;
			}
			pricingState = STATE_LOADING;
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handlePricingResult);
			client.addEventListener(FaultEvent.FAULT, handlePricingFault);
			client.send("/locker/slots/prices", HTTPMethod.GET);
		}
		
		public function handlePricingResult(event:WorlizeResultEvent):void {
			if (event.resultJSON.success) {
				var data:Object = event.resultJSON;
				avatarSlotPrice = data.avatar_slot_price;
				backgroundSlotPrice = data.background_slot_price;
				inWorldObjectSlotPrice = data.in_world_object_slot_price;
				propSlotPrice = data.prop_slot_price;
				pricingState = STATE_READY;
			}
			else {
				pricingState = STATE_ERROR;
			}
		}
		
		public function handlePricingFault(event:FaultEvent):void {
			pricingState = STATE_ERROR;
		}
		
		public function buySlots(slotKind:String, quantity:int, callback:Function=null):void {
			if (['avatar','background','prop','in_world_object'].indexOf(slotKind) === -1) {
				throw new Error("Invalid slot kind: " + slotKind);
			}
			if (quantity <= 0) {
				throw new Error("Invalid quantity requested.");
			}
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			var self:Slots = this;
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					var newSlotCounts:Object = event.resultJSON.new_slot_counts;
					self.avatarSlots = newSlotCounts.avatar_slots;
					self.backgroundSlots = newSlotCounts.background_slots;
					self.inWorldObjectSlots = newSlotCounts.in_world_object_slots;
					self.propSlots = newSlotCounts.prop_slots;
					if (callback !== null) {
						callback(null, event.resultJSON);
					}
				}
				else {
					if (callback !== null) {
						callback(event.resultJSON.message, event.resultJSON);
					}					
				}
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				if (callback !== null) {
					callback("A Fault was encountered while attempting to purchase more locker space.", null);
				}
			});
			client.send("/locker/slots/buy", HTTPMethod.POST, {
				quantity: quantity,
				slot_kind: slotKind
			});
		}
		
	}
}