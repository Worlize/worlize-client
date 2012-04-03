package com.worlize.api.data
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.APIEvent;
	import com.worlize.api.event.ChangeEvent;
	import com.worlize.worlize_internal;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	import com.worlize.api.model.User;

	/**
	 * Dispatched after an object in the room has been resized.
	 * 
	 * @eventType com.worlize.api.event.ChangeEvent.PROPERTY_CHANGED
	 * @productversion Worlize API.v1 
	 */	
	[Event(name="propertyChanged",type="com.worlize.api.event.ChangeEvent")]
	
	/**
	 * Stores persistent configuration about the app instance.
	 * 
	 * <p>The contents of the <code>data</code> property are serialized
	 * to JSON format and saved on the Worlize servers.  The data is unique
	 * to the object instance and cannot be shared across multiple instances
	 * of the object or read by other objects.</p>
	 * 
	 * <p>All config data is cleared from the server when the object
	 * is removed from the room.</p>
	 * 
	 * <p><strong>NOTE:</strong> Only users with the <code>canAuthor</code>
	 * privilege may modify the persistent config data.</p>
	 * 
	 * @author Brian McKelvey
	 * 
	 * @example Save a property in the persistent config data
	 * <listing version="3.0">
	 * 
	 * var api:WorlizeAPI = WorlizeAPI.getInstance();
	 * api.config.data.backgroundColor = 0xFFAAAA;
	 * api.config.save();
	 * 
	 * </listing>
	 */	
	public class ConfigData extends EventDispatcher
	{
		use namespace worlize_internal;
		
		private static var instance:ConfigData;
		
		private var _data:Object = {};
		
		/**
		 * Constructor.
		 * 
		 * <p>The ConfigData instance is created and managed by
		 * the WorlizeAPI class.  You do not instantiate this object
		 * yourself.</p>
		 * 
		 * @productversion Worlize API.v1
		 * 
		 * @example How to get a reference to the ConfigData instance
		 * <listing version="3.0">
		 * 
		 * var api:WorlizeAPI = WorlizeAPI.getInstance();
		 * var config:ConfigData = api.config;
		 * 
		 * </listing> 
		 */		
		public function ConfigData(initialConfig:Object = null) {
			super(null);
			if (instance !== null) {
				throw new Error("The ConfigData class is created and managed by WorlizeAPI. " +
				                "You may not create your own instances of this class.");
			}
			_data = initialConfig || {};
			addSharedEventListeners();
			instance = this;
		}
		
		/**
		 * An object containing the config data that will be saved when you
		 * call <code>save()</code>.  It must be JSON-serializable.
		 * 
		 * @param newValue JSON-serializable configuration data 
		 * @productversion Worlize API.v1 
		 */		
		public function get data():Object {
			return _data;
		}

		/**
		 * @private
		 */		
		public function set data(newValue:Object):void {
			if (newValue === null) {
				throw new ArgumentError("data cannot be null.");
			}
		}
		
		/**
		 * Saves the current value of <code>data</code> to the server.
		 * 
		 * <p>This function will serialize the object stored in the
		 * <code>data</code> property to JSON format and send it to the server
		 * to be saved.</p>
		 * 
		 * @productversion Worlize API.v1 
		 */		
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
		
		/**
		 * @private
		 */		
		worlize_internal function addSharedEventListeners():void {
			WorlizeAPI.sharedEvents.addEventListener('host_configChanged', handleConfigChanged);
		}
		
		/**
		 * @private
		 */		
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