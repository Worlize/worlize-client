package com.worlize.model
{
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	import mx.rpc.events.FaultEvent;
	
	public class Directory extends ArrayCollection
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_READY:String = "ready";
		public static const STATE_ERROR:String = "error";
		
		public var state:String = STATE_INIT;
		
		private var _showFullRooms:Boolean = true;
		private var _maxOccupancy:int = 20;
		
		public function Directory(source:Array = null) {
			super(source);
			updateFilter();
		}
		
		[Bindable(event="showFullRoomsChanged")]
		public function set showFullRooms(newValue:Boolean):void {
			if (_showFullRooms !== newValue) {
				_showFullRooms = newValue;
				updateFilter();
				dispatchEvent(new FlexEvent('showFullRoomsChanged'));
			}
		}
		public function get showFullRooms():Boolean {
			return _showFullRooms;
		}
		
		[Bindable(event="maxOccupancyChanged")]
		public function set maxOccupancy(newValue:int):void {
			if (_maxOccupancy !== newValue) {
				_maxOccupancy = newValue;
				refresh();
				dispatchEvent(new FlexEvent('maxOccupancyChanged'));
			}
		}
		public function get maxOccupancy():int {
			return _maxOccupancy;
		}
		
		protected function updateFilter():void {
			if (showFullRooms) {
				filterFunction = filterFunctionShowFullRooms;
			}
			else {
				filterFunction = filterFunctionHideFullRooms;
			}
			refresh();
		}
		
		private function filterFunctionShowFullRooms(item:Object):Boolean {
			return true;
		}
		
		private function filterFunctionHideFullRooms(item:Object):Boolean {
			if (item is DirectoryEntry) {
				return (item as DirectoryEntry).room.userCount < _maxOccupancy;				
			}
			return true;
		}
		
		public function load():void {
			state = STATE_LOADING;
			disableAutoUpdate();
			removeAll();
			enableAutoUpdate();
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleLoadResult);
			client.addEventListener(FaultEvent.FAULT, handleLoadFault);
			client.send("/rooms/directory.json", HTTPMethod.GET);
		}
		
		private function handleLoadResult(event:WorlizeResultEvent):void {
			if (event.resultJSON.success) {
				disableAutoUpdate();
				removeAll();
				for each (var entryData:Object in event.resultJSON.data.rooms) {
					addItem(DirectoryEntry.fromData(entryData));
				}
				enableAutoUpdate();
				state = STATE_READY;
			}
			else {
				disableAutoUpdate();
				removeAll();
				enableAutoUpdate();
				state = STATE_ERROR;
			}
		}
		
		private function handleLoadFault(event:FaultEvent):void {
			disableAutoUpdate();
			removeAll();
			enableAutoUpdate();
			state = STATE_ERROR;
		}
	}
}