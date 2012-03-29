package com.worlize.api.data
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.APIEvent;
	import com.worlize.worlize_internal;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import com.worlize.api.event.StateHistoryEvent;
	
	/**
	 * Dispatched when a new state history entry is added.
	 * 
	 * @eventType com.worlize.api.event.StateHistoryEvent.ENTRY_ADDED
	 * @productversion Worlize API.v1
	 */	
	[Event(name="entryAdded",type="com.worlize.api.event.StateHistoryEvent")]
	
	/**
	 * Dispatched when a state history entry is removed.
	 * 
	 * @eventType com.worlize.api.event.StateHistoryEvent.ENTRY_REMOVED
	 * @productversion Worlize API.v1
	 */	
	[Event(name="entryRemoved",type="com.worlize.api.event.StateHistoryEvent")]
	
	/**
	 * Dispatched when the state history is cleared.
	 * 
	 * @eventType com.worlize.api.event.StateHistoryEvent.CLEARED
	 * @productversion Worlize API.v1
	 */	
	[Event(name="cleared",type="com.worlize.api.event.StateHistoryEvent")]
	
	/**
	 * Synchronizes the app's state across all connected clients.
	 *
	 * <p>The <code>StateHistory</code> class provides a list of objects, each
	 * of which make up a single entry in a list of past actions that can be
	 * used to reconstitute the application's current state.</p>
	 * 
	 * <p>This class subclasses <code>flash.utils.Proxy</code> so
	 * you can access state history entries directly using bracket notation
	 * like <code>stateHistory[4]</code> or use it in <code>for</code> or
	 * <code>for each</code> loops.</p> 
	 * 
	 * <p>This class facilitates the app's ability to reconstitute the current
	 * app state based on a history of sequential events for new users who
	 * enter the room.</p>
	 * 
	 * <p>Imagine, for example, that you're writing an app that allows multiple
	 * users to draw on a shared canvas.  You want new lines to appear in real
	 * time as they are being drawn, and new users who come into the room
	 * should see the same drawing as those who have already been interacting
	 * with the app for a while.</p>
	 * 
	 * <p>You could broadcast new line segments using the message broadcasting
	 * facilities provided by methods like
	 * <code>api.thisObject.sendMessage()</code>
	 * but when a new user entered the room, they would see a blank canvas
	 * because they would be missing the data about all the existing lines that
	 * have already been drawn.  Instead, it is better to push each line
	 * segment into the app's SharedHistory instance and listen for the
	 * <code>itemAdded</code> events that it emits to do the actual drawing.
	 * </p>
	 * 
	 * <p>The <code>StateHistory</code> class guarantees the following:
	 * <ul>
	 *   <li>State entries will always be in the same consistent order
	 *       across all connected clients.</li>
	 * 	 <li>New users will receive the complete state history before the app
	 *       initializes.</li>
	 *   <li>Events will be emitted when any user adds or removes a state
	 *       entry using the <code>push()</code> and <code>unshift()</code>
	 *       methods, or clears the list with the <code>clear()</code>
	 *       method.</li>
	 * </ul>
	 * Because of this, it's the perfect way to synchronize application state
	 * that is derived from a history of events.</p>
	 * 
	 * <p>When a user does something in the application that should be
	 * reflected on all connected clients, it's best to just <code>push()</code>
	 * information about the action to your app's <code>StateHistory</code>
	 * instead of updating the display directly.  Then listen for the
	 * <code>itemAdded</code> event and handle the display updates there, based
	 * on the state history data that was received.  In this way, the display
	 * updates are tied to the state history and will be consistent across all
	 * connected clients.</p> 
	 * 
	 * @author Brian McKelvey
	 * @productversion Worlize APIv.1 
	 * @see com.worlize.api.event.StateHistoryEvent
	 * @see com.worlize.api.data.SyncedDataStore
	 */	
	public dynamic class StateHistory extends Proxy implements IEventDispatcher
	{
		use namespace worlize_internal;
		
		private static var instance:StateHistory;
		private var items:Array;
		
		/**
		 * @private 
		 */		
		protected var eventDispatcher:EventDispatcher;
		
		/**
		 * Constructor.
		 * 
		 * <p>The <code>StateHistory</code> instance is created and managed by
		 * the <code>WorlizeAPI</code> class.  You do not instantiate this
		 * object yourself.</p>
		 * 
		 * @productversion Worlize API.v1
		 * @see com.worlize.api.event.StateHistoryEvent
		 * @see com.worlize.api.WorlizeAPI
		 * 
		 * @example How to get a reference to the StateHistory instance
		 * <listing version="3.0">
		 * 
		 * var api:WorlizeAPI = WorlizeAPI.getInstance();
		 * var history:StateHistory = api.stateHistory;
		 * 
		 * </listing> 
		 */	
		public function StateHistory(sourceItems:Array=null) {
			if (instance !== null) {
				throw new Error("You may only create one instance of StateHistory");
			}
			
			eventDispatcher = new EventDispatcher(this);
			
			resetFromSource(sourceItems);
			
			addSharedEventListeners();
			instance = this;
		}

		/**
		 * @private
		 */		
		worlize_internal function resetFromSource(sourceItems:Array):void {
			items = [];
			dispatchEvent(new StateHistoryEvent(StateHistoryEvent.CLEARED));
			if (sourceItems) {
				for each (var item:ByteArray in sourceItems) {
					item.position = 0;
					items.push(item.readObject());
				}
			}
		}
		
		/**
		 * @private
		 */		
		protected function addSharedEventListeners():void {
			WorlizeAPI.sharedEvents.addEventListener('host_stateHistoryPush', handleStateHistoryPush);
			WorlizeAPI.sharedEvents.addEventListener('host_stateHistoryShift', handleStateHistoryShift);
			WorlizeAPI.sharedEvents.addEventListener('host_stateHistoryClear', handleStateHistoryClear);
		}
		
		/**
		 * @private
		 */		
		protected function handleStateHistoryPush(event:Event):void { 
			var eo:Object = event;
			var item:Object;
			if (eo.data.data is ByteArray) {
				var ba:ByteArray = eo.data.data as ByteArray;
				ba.position = 0;
				item = ba.readObject();
			}
			items.push(item);
			var historyEvent:StateHistoryEvent = new StateHistoryEvent(StateHistoryEvent.ENTRY_ADDED);
			historyEvent.index = items.length-1;
			historyEvent.entry = item;
			dispatchEvent(historyEvent);
		}
		
		/**
		 * @private
		 */				
		protected function handleStateHistoryShift(event:Event):void {
			if (items.length > 0) {
				var eo:Object = event;
				var historyEvent:StateHistoryEvent = new StateHistoryEvent(StateHistoryEvent.ENTRY_REMOVED);
				historyEvent.index = 0;
				historyEvent.entry = items.unshift();
				dispatchEvent(historyEvent);
			}
		}
		
		/**
		 * @private
		 */		
		protected function handleStateHistoryClear(event:Event):void {
			items = [];
			var historyEvent:StateHistoryEvent = new StateHistoryEvent(StateHistoryEvent.CLEARED);
			dispatchEvent(historyEvent);
		}

		/**
		 * Adds a new state history entry.
		 * 
		 * <p>This method does not immediately add the new entry to the local
		 * copy of the list, but simply sends it to the server.  The entry will
		 * be added to the local copy when the server sends back confirmation
		 * that the update has been broadcast to all connected clients.</p>
		 * 
		 * <p>Therefore, you cannot immediately access the newly pushed item until
		 * its corresponding <code>itemAdded</code> event.</p>
		 * 
		 * @param item an AMF3 serializable object representing the new state
		 * history entry to add
		 * 
		 * @see #event:itemAdded
		 * @productversion Worlize APIv.1
		 */		
		public function push(item:Object):void {
			if (item === null) {
				return;
			}
			var event:APIEvent = new APIEvent(APIEvent.STATE_HISTORY_PUSH);
			var ba:ByteArray = new ByteArray();
			ba.writeObject(item);
			ba.position = 0;
			if (ba.length > 0xFFFF) {
				throw new Error("Serialized size of state data cannot exceed 65535 bytes");
			}
			event.data = ba;
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		/**
		 * Clears the state history.
		 *
		 * <p>This method does not immediately clear the local copy of the
		 * state history, but rather just sends a request to the server to
		 * clear the history.  The local copy will be cleared when the server
		 * broadcasts the update to all connected clients.</p>
		 * 
		 * <p>Therefore, you cannot count on the list to be emptied immediately
		 * after calling this method.  You must wit for the corresponding
		 * <code>cleared</code> event.</p>
		 * 
		 * <p>You can optionally specify a value for the
		 * <code>initialItem</code> property to atomically add an initial entry
		 * to the newly cleared list.  This may be useful for consolidating
		 * long state histories into a single composite entry to save space
		 * and bandwidth for new users entering the room if the history becomes
		 * long through extended usage of the app by other users in the room
		 * </p>
		 * 
		 * @param initialItem an AMF3 serializable object representing the
		 * first state entry to add immediately after clearing the list.
		 * 
		 * @see #event:cleared
		 * @productversion Worlize APIv.1
		 */		
		public function clear(initialItem:Object = null):void {
			var event:APIEvent = new APIEvent(APIEvent.STATE_HISTORY_CLEAR);
			if (initialItem !== null) {
				var ba:ByteArray = new ByteArray();
				ba.endian = Endian.BIG_ENDIAN;
				ba.writeObject(initialItem);
				ba.position = 0;
				if (ba.length > 0xFFFF) {
					throw new Error("Serialized size of state data cannot exceed 65535 bytes");
				}
				event.data = ba;
			}
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		/**
		 * Removes the oldest state history.
		 * 
		 * <p>This method does not immediately remove the old entry from the
		 * local copy of the list, but simply sends the request to the server.
		 * The entry will be removed from the local copy when the server sends
		 * back confirmation that the update has been broadcast to all
		 * connected clients.</p>
		 * 
		 * <p>Therefore, you cannot rely upon the local list to be updated
		 * until the corresponding <code>itemRemoved</code> event.</p>
		 * 
		 * @see #event:itemRemoved
		 * @productversion Worlize APIv.1
		 */
		public function shift():void {
			WorlizeAPI.sharedEvents.dispatchEvent(new APIEvent(APIEvent.STATE_HISTORY_SHIFT));
		}
		
		/**
		 * Get the number of entries in the state history list. 
		 * @return entry count
		 * 
		 * @productversion Worlize APIv.1 
		 */		
		public function get length():uint {
			return items.length;
		}
		
		/**
		 * Get the state history entry at <code>index</code>.
		 * 
		 * <p>Alternatively, you can use bracket notation as you would with a
		 * normal <code>Array</code>.</p>
		 * 
		 * @param index the index of the entry to retrieve
		 * @return a state entry object
		 * 
		 * @productversion Worlize APIv.1
		 * @example Get the third item in the state history list
		 * <listing version="3.0">
		 * 
		 * var api:WorlizeAPI = WorlizeAPI.getInstance();
		 * 
		 * var item:* = api.stateHistory.getItemAt(2);
		 * 
		 * // Equivalently:
		 * var item:* = api.stateHistory[2];
		 * 
		 * </listing>
		 */		
		public function getItemAt(index:int):* {
			return items[index];
		}
		
		/**
		 * @private
		 */		
		override flash_proxy function getProperty(name:*):* {
			return items[name];
		}
		
		/**
		 * @private
		 */		
		override flash_proxy function hasProperty(name:*):Boolean {
			return name in items;
		}
		
		/**
		 * @private
		 */		
		override flash_proxy function nextNameIndex(index:int):int {
			if (index >= items.length) {
				return 0;
			}
			return index + 1;
		}
		
		/**
		 * @private
		 */		
		override flash_proxy function nextName(index:int):String {
			return String(index - 1);
		}
		
		/**
		 * @private
		 */		
		override flash_proxy function nextValue(index:int):* {
			return items[index - 1];
		}
		
		
		/* EventDispatcher Proxy Functions */
		/**
		 * Registers an event listener object with an EventDispatcher object
		 * so that the listener receives notification of an event.
		 * 
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/EventDispatcher.html#addEventListener()
		 */		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		/**
		 * Removes a listener from the EventDispatcher object. If there is no
		 * matching listener registered with the EventDispatcher object, a call
		 * to this method has no effect.
		 * 
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/EventDispatcher.html#removeEventListener()
		 */		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
			eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		/**
		 * Dispatches an event into the event flow. The event target is the
		 * EventDispatcher object upon which the dispatchEvent() method is
		 * called.
		 * 
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/EventDispatcher.html#dispatchEvent()
		 */		
		public function dispatchEvent(event:Event):Boolean {
			return eventDispatcher.dispatchEvent(event);
		}
		
		/**
		 * Checks whether the EventDispatcher object has any listeners
		 * registered for a specific type of event.
		 * 
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/EventDispatcher.html#hasEventListener()
		 */		
		public function hasEventListener(type:String):Boolean {
			return eventDispatcher.hasEventListener(type);
		}
		
		/**
		 * Checks whether an event listener is registered with this
		 * EventDispatcher object or any of its ancestors for the specified
		 * event type.
		 * 
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/EventDispatcher.html#willTrigger()
		 */		
		public function willTrigger(type:String):Boolean {
			return eventDispatcher.willTrigger(type);
		}
	}
}