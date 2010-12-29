package com.worlize.model.userSearch
{
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	import mx.rpc.events.FaultEvent;
	
	public class UserSearch extends EventDispatcher
	{
		public static const STATE_READY:String = "ready";
		public static const STATE_LOADING:String = "loading";
		
		[Bindable]
		public var results:ArrayCollection = new ArrayCollection();
		
		[Bindable]
		public var totalCount:int = 0;
		
		[Bindable]
		public var showingCount:int = 0;
				
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
		
		public function UserSearch(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function clearResults():void {
			results.removeAll();
		}
		
		public function search(query:String):void {
			state = STATE_LOADING;
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					totalCount = event.resultJSON.total;
					showingCount = event.resultJSON.count;
					results.removeAll();
					for each (var lineItem:Object in event.resultJSON.data) {
						results.addItem(UserSearchResultLineItem.fromData(lineItem));
					}
				}
				state = STATE_READY;
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				results.removeAll();
				state = STATE_READY;
			});
			client.send("/users/search.json", HTTPMethod.GET, {
				q: query
			});
		}
	}
}