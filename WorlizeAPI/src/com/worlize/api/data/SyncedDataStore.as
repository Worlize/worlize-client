package com.worlize.api.data
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.APIEvent;
	import com.worlize.api.event.ChangeEvent;
	import com.worlize.api.model.User;
	import com.worlize.worlize_internal;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	/**
	 * Dispatched when a property is changed
	 * 
	 * @eventType com.worlize.api.event.ChangeEvent.PROPERTY_CHANGED
	 * @see #set()
	 * @productversion Worlize API.v1
	 */	
	[Event(name="propertyChanged",type="com.worlize.api.event.ChangeEvent")]

	/**
	 * Dispatched when a property is deleted
	 * 
	 * @eventType com.worlize.api.event.ChangeEvent.PROPERTY_DELETED
	 * @see #remove()
	 * @productversion Worlize API.v1
	 */	
	[Event(name="propertyDeleted",type="com.worlize.api.event.ChangeEvent")]
	
	
	/**
	 * Provides a synchronized key/value store, guaranteed to be in a
	 * consistent state across all connected clients.
	 * 
	 * <p>Use this class when you need to synchronize the current state
	 * across all connected clients and that state does not require keeping
	 * track of historical data.  For example, this would not be a good
	 * way to synchronize data about the lines drawn on a shared canvas
	 * because it would retransmit the entire canvas history with every
	 * update.  Use this class to keep smaller values up to date across
	 * clients and to trigger events based on the changing of those
	 * values.</p>
	 * 
	 * <p>Keys must be strings and values can be anything that is serializable
	 * in AMF3 format.</p> 
	 * 
	 * <p>Data values can be read using bracket notation such as
	 * <code>store['penColor']</code>, and can be used directly in a
	 * <code>for</code> loop or a <code>for each</code> loop.  However,
	 * values must be set by making a call to the <code>set()</code> method
	 * rather than assigning a value using bracket notation.</p>
	 * 
	 * @example Trace all keys and values currently stored
	 * <listing version="3.0">
	 * 
	 * var store:SyncedDataStore = WorlizeAPI.getInstance().syncedDataStore;
	 * for (var key:String in store) {
	 *     var value:* = store[key];
	 *     trace(key + ": " + value);
	 * }
	 * 
	 * </listing>
	 * 
	 * @author Brian McKelvey
	 * @productversion Worlize API.v1 
	 * 
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/operators.html#array_access [] (Array Access)
	 * @see http://en.wikipedia.org/wiki/Action_Message_Format Action Message Format on Wikipedia
	 */	
	public dynamic class SyncedDataStore extends Proxy implements IEventDispatcher
	{
		use namespace worlize_internal;
		
		/**
		 * @private 
		 */		
		protected var eventDispatcher:EventDispatcher;
		
		/**
		 * @private 
		 */		
		protected var keys:Array;
		
		/**
		 * @private 
		 */		
		worlize_internal var data:Object;
		
		/**
		 * Constructor.
		 * 
		 * <p>The <code>SyncedDataStore</code>instance is created and managed
		 * by the <code>WorlizeAPI</code> class.  You do not instantiate this
		 * object yourself.</p>
		 * 
		 * @productversion Worlize API.v1
		 * @see com.worlize.api.WorlizeAPI
		 * 
		 * @example How to get a reference to the SyncedDataStore instance
		 * <listing version="3.0">
		 * 
		 * var api:WorlizeAPI = WorlizeAPI.getInstance();
		 * var store:SyncedDataStore = api.syncedDataStore;
		 * 
		 * </listing> 
		 */	
		public function SyncedDataStore(sourceData:Object = null) {
			super();
			eventDispatcher = new EventDispatcher(this);
			data = {};
			keys = [];
			
			if (sourceData) {
				for (var key:String in sourceData) {
					var ba:ByteArray = sourceData[key] as ByteArray;
					ba.position = 0;
					var value:* = ba.readObject();
					keys.push(key);
					data[key] = value;
				}
			}
			
			addSharedEventListeners();
		}
		
		/**
		 * @private
		 */		
		protected function addSharedEventListeners():void {
			WorlizeAPI.sharedEvents.addEventListener("host_syncedDataSet", handleSyncedDataSet);
			WorlizeAPI.sharedEvents.addEventListener("host_syncedDataDelete", handleSyncedDataDelete);
		}
		
		/**
		 * Get the current value of the given key.
		 * 
		 * <p>Note that you can also use standard bracket notation to
		 * <i>retrieve</i> values, though you cannot use it to <i>set</i>
		 * values.</p>
		 * 
		 * @example Using bracket notation to retrieve values
		 * <listing verion="3.0">
		 * 
		 * // Get a reference to the data store..
		 * var api:WorlizeAPI = WorlizeAPI.getInstance();
		 * var dataStore:SyncedDataStore = api.syncedDataStore;
		 * 
		 * var userGuid:String = dataStore['player2'];
		 * var player2:User = api.thisRoom.getUserByGuid(userGuid);
		 * trace("Player 2 is: " + player2.name);
		 * 
		 * </listing>
		 * 
		 *  
		 * @param key the key name of the value to retrieve
		 * @return the value associated with the key
		 */		
		public function get(key:String):* {
			return data[key];
		}

		/**
		 * Requests the server to set a new value for the given key.
		 * 
		 * <p>The value can be any object that can be serialized to the AMF3
		 * format.</p>
		 * 
		 * <p><strong>Be aware:</strong> this does <strong><em>not</em>
		 * </strong> immediately change the value at the specified key in
		 * the local store.  Instead, it simply sends a message to the server
		 * requesting that it update the value and broadcast the update to
		 * all users in the room.  The value will be updated locally only once
		 * the server broadcasts the new value to all the connected clients.</p>
		 * 
		 * <p><strong>Also note</strong> that if a value contains an <code>Object</code> or
		 * <code>Array</code>, changes to child properties will not trigger an
		 * update through the server and will not cause a
		 * <code>propertyChanged</code> event to be dispatched.</p>
		 * 
		 * <p>It is recommended that you add a listener for the
		 * <code>propertyChanged</code> and <code>propertyDeleted</code> events
		 * and take action when a value you are interested in is changed.</p>
		 * 
		 * <p>Also be aware that while you can use bracket notation to read
		 * values from the data store, you cannot use bracket notation to set
		 * values.</p>
		 * 
		 * @param key the name of the key whose value you wish to set
		 * @param value an AMF3 serializable value to associate with the key
		 * 
		 * @see #event:propertyChanged
		 * @see http://en.wikipedia.org/wiki/Action_Message_Format
		 * @productversion Worlize APIv.1
		 * 
		 * @example Update a value
		 * <listing version="3.0">
		 * 
		 * var store:SyncedDataStore = WorlizeAPI.getInstance().syncedDataStore;
		 * 
		 * function onPropertyChanged(event:ChangeEvent):void {
		 *     if (event.name === 'color') {
		 *         trace("The color changed from " + event.oldValue +
		 *               " to " + event.newValue);
		 *     }
		 * }
		 * store.addEventListener(ChangeEvent.PROPERTY_CHANGED, onPropertyChanged);
		 * 
		 * store.set('color', 'red');
		 * store.set('color', 'blue');
		 * 
		 * // Trace output will be:
		 * // The color changed from undefined to red
		 * // The color changed from red to blue
		 * 
		 * </listing>
		 */
		public function set(key:String, value:*):void {
			var event:APIEvent = new APIEvent(APIEvent.SYNCED_DATA_SET);
			var ba:ByteArray = new ByteArray();
			ba.endian = Endian.BIG_ENDIAN;
			ba.writeObject(value);
			ba.position = 0;
			event.data = {
				key: key,
				value: ba
			};
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		/**
		 * Requests the server to delete the given key from the data store.
		 * 
		 * <p><strong>Be aware:</strong> this does <strong><em>not</em>
		 * </strong> immediately delete the value at the specified key in
		 * the local store.  Instead, it simply sends a message to the server
		 * requesting that it delete the value and broadcast the update to
		 * all users in the room.  The value will be deleted locally only once
		 * the server broadcasts the new value to all the connected clients.</p>
		 * 
		 * <p>It is recommended that you add a listener for the
		 * <code>propertyChanged</code> and <code>propertyDeleted</code> events
		 * and take action when a value you are interested in is changed.</p>
		 * 
		 * @param key the name of the key to delete
		 * 
		 * @see #event:propertyDeleted
		 * @productversion Worlize APIv.1
		 */		
		public function remove(key:String):void {
			var event:APIEvent = new APIEvent(APIEvent.SYNCED_DATA_DELETE);
			event.data = {
				key: key
			};
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		/**
		 * @private
		 */		
		protected function handleSyncedDataSet(event:Event):void {
			var eo:Object = event;
			var changedBy:User;
			if (eo.data.user) {
				changedBy = WorlizeAPI.getInstance().thisRoom.getUserByGuid(eo.data.user);
				if (!changedBy) {
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
			}
			var ba:ByteArray = eo.data.value;
			ba.position = 0;
			var value:* = ba.readObject();
			updateValue(eo.data.key, value, changedBy);				
		}
		
		/**
		 * @private
		 */		
		protected function handleSyncedDataDelete(event:Event):void {
			var eo:Object = event;
			var changedBy:User;
			if (eo.data.user) {
				changedBy = WorlizeAPI.getInstance().thisRoom.getUserByGuid(eo.data.user);
				if (!changedBy) {
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
			}
			deleteValue(eo.data.key, changedBy);
		}
		
		/**
		 * @private
		 */		
		worlize_internal function updateValue(key:String, newValue:*, changedBy:User = null):void {
			var oldValue:* = data[key];
			if (oldValue !== newValue) {
				if (!(key in data)) {
					keys.push(key);
				}
				data[key] = newValue;
				var event:ChangeEvent = new ChangeEvent(ChangeEvent.PROPERTY_CHANGED);
				event.name = key;
				event.oldValue = oldValue;
				event.newValue = newValue;
				event.changedBy = changedBy;
				eventDispatcher.dispatchEvent(event);
			}
		}
		
		/**
		 * @private
		 */		
		worlize_internal function deleteValue(key:String, changedBy:User = null):void {
			if (key in data) {
				var oldValue:* = data[key];
				delete data[key];
				var keyIndex:int = keys.indexOf(key);
				if (keyIndex !== -1) {
					keys.splice(keyIndex, 1);
				}
				var event:ChangeEvent = new ChangeEvent(ChangeEvent.PROPERTY_DELETED);
				event.name = key;
				event.oldValue = oldValue;
				event.newValue = undefined;
				event.changedBy = changedBy;
				eventDispatcher.dispatchEvent(event);
			}
		}
		
		
		// flash.utils.Proxy methods
		
		/**
		 * @private
		 */		
		override flash_proxy function getProperty(name:*):* {
			return data[name];
		}
		
		/**
		 * @private
		 */		
		override flash_proxy function hasProperty(name:*):Boolean {
			return name in data;
		}
		
		/**
		 * @private
		 */		
		override flash_proxy function nextNameIndex(index:int):int {
			if (index < keys.length) {
				return index + 1;
			}
			else {
				return 0;
			}
		}
		
		/**
		 * @private
		 */		
		override flash_proxy function nextName(index:int):String {
			return keys[index - 1];
		}
		
		/**
		 * @private
		 */		
		override flash_proxy function nextValue(index:int):* {
			return data[keys[index - 1]];
		}
		
		// EventDispatcher proxy methods

		/**
		 * Registers an event listener object with an EventDispatcher object
		 * so that the listener receives notification of an event.
		 * 
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/EventDispatcher.html#addEventListener() EventDispatcher#addEventListener()
		 */		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * Removes a listener from the EventDispatcher object. If there is no
		 * matching listener registered with the EventDispatcher object, a call
		 * to this method has no effect.
		 * 
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/EventDispatcher.html#removeEventListener() EventDispatcher#removeEventListener()
		 */		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
			eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * Dispatches an event into the event flow. The event target is the
		 * EventDispatcher object upon which the dispatchEvent() method is
		 * called.
		 * 
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/EventDispatcher.html#dispatchEvent() EventDispatcher#dispatchEvent()
		 */		
		public function dispatchEvent(event:Event):Boolean {
			return eventDispatcher.dispatchEvent(event);
		}
		
		/**
		 * Checks whether the EventDispatcher object has any listeners
		 * registered for a specific type of event.
		 * 
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/EventDispatcher.html#hasEventListener() EventDispatcher#hasEventListener()
		 */		
		public function hasEventListener(type:String):Boolean {
			return eventDispatcher.hasEventListener(type);
		}
		
		/**
		 * Checks whether an event listener is registered with this
		 * EventDispatcher object or any of its ancestors for the specified
		 * event type.
		 * 
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/EventDispatcher.html#willTrigger() EventDispatcher#willTrigger()
		 */		
		public function willTrigger(type:String):Boolean {
			return eventDispatcher.willTrigger(type);
		}
	}
}