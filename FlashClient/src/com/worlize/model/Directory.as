package com.worlize.model
{
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	import mx.rpc.events.FaultEvent;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
	
	public class Directory extends ArrayCollection
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_READY:String = "ready";
		public static const STATE_ERROR:String = "error";
		
		[Bindable]
		public var state:String = STATE_INIT;
		
		[Bindable]
		public var population:int = 0;
		
		private var _showFullRooms:Boolean = true;
		
		public function Directory(source:Array = null) {
			super(source);
			var sort:Sort = new Sort();
			sort.fields = [
				new SortField('friendCount', true, true),
				new SortField('userCount', true, true),
				new SortField('roomName')
			];
			this.sort = sort;
			updateFilter();
			refresh();
		}
		
		[Bindable(event="showFullRoomsChanged")]
		public function set showFullRooms(newValue:Boolean):void {
			if (_showFullRooms !== newValue) {
				_showFullRooms = newValue;
				updateFilter();
				refresh();
				dispatchEvent(new FlexEvent('showFullRoomsChanged'));
			}
		}
		public function get showFullRooms():Boolean {
			return _showFullRooms;
		}
		
		protected function updateFilter():void {
			if (showFullRooms) {
				filterFunction = filterFunctionShowFullRooms;
			}
			else {
				filterFunction = filterFunctionHideFullRooms;
			}
		}
		
		private function filterFunctionShowFullRooms(item:Object):Boolean {
			return true;
		}
		
		private function filterFunctionHideFullRooms(item:Object):Boolean {
			if (item is DirectoryEntry) {
				return !(item as DirectoryEntry).roomFull;				
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
				population = event.resultJSON.data.population;
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