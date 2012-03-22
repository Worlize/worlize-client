package com.worlize.api.model
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.APIEvent;
	import com.worlize.api.event.ChangeEvent;
	import com.worlize.worlize_internal;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	
	[Event(name="propertyChanged",type="com.worlize.api.event.ChangeEvent")]
	public class ConfigData extends EventDispatcher
	{
		use namespace worlize_internal;
		
		private var _data:Object = {};
		
		public function ConfigData(initialConfig:Object) {
			super(null);
			_data = initialConfig;
			addSharedEventListeners();
		}
		
		public function set data(newValue:Object):void {
			if (newValue === null) {
				throw new ArgumentError("data cannot be null.");
			}
		}
		
		public function get data():Object {
			return _data;
		}
		
		public function save():void {
			if (!WorlizeAPI.getInstance().thisUser.canAuthor) {
				throw new Error("Only users with the 'canAuthor' permission are allowed to save config data.");
			}
			
			try {
				var stringForm:String = JSON.stringify(_data);
			}
			catch(error:Error) {
				throw new Error("data must be JSON serializable to save: Error: " + error.toString());
			}
			
			// Make sure the saved length is less than 64KiB...
			// ...writeUTF will throw an error if the serialized size is larger
			// than 65535 bytes.
			var ba:ByteArray = new ByteArray();
			ba.writeUTF(stringForm);
			
			var event:APIEvent = new APIEvent(APIEvent.SAVE_CONFIG);
			event.data = _data;
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		worlize_internal function addSharedEventListeners():void {
			WorlizeAPI.sharedEvents.addEventListener('host_configChanged', handleConfigChanged);
		}
		
		protected function handleConfigChanged(event:Event):void {
			var eo:Object = event;
			var changedBy:User = WorlizeAPI.getInstance().thisRoom.getUserByGuid(eo.data.user);
			if (changedBy === null) {
				changedBy = User.fromData({
					name: "Unknown User",
					guid: eo.data.user,
					privileges: [],
					x: 0,
					y:0,
					face:0,
					color:0
				});				
			}
			
			var changeEvent:ChangeEvent = new ChangeEvent(ChangeEvent.PROPERTY_CHANGED)
			changeEvent.name = "data";
			changeEvent.changedBy = changedBy;
			changeEvent.oldValue = _data;
			_data = eo.data.config;
			changeEvent.newValue = _data;
			dispatchEvent(changeEvent);	
		}
	}
}