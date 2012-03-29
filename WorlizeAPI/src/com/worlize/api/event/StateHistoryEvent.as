package com.worlize.api.event
{
	
	import flash.events.Event;
	
	/**
	 * Event representing a change to the object's state history.
	 *  
	 * @author Brian McKelvey
	 * @productversion Worlize APIv.1
	 * @see com.worlize.api.data.StateHistory
	 */	
	public class StateHistoryEvent extends Event
	{
		/**
		 *  The <code>StateHistoryEvent.ENTRY_ADDED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>entryAdded</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
		 *     <tr><td><code>cancelable</code></td><td>false</td></tr>
		 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
		 *       event listener that handles the event. For example, if you use
		 *       <code>myButton.addEventListener()</code> to register an event listener,
		 *       myButton is the value of the <code>currentTarget</code>. </td></tr>
		 *     <tr><td><code>entry</code></td><td>The object representing the state data
		 *       being added.</td></tr>
		 *     <tr><td><code>index</code></td><td>An integer indicating the zero-based
		 *       position of the state data being added.</td></tr>
		 *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
		 *       it is not always the Object listening for the event.
		 *       Use the <code>currentTarget</code> property to always access the
		 *       Object listening for the event.</td></tr>
		 *  </table>
		 *
		 *  @eventType entryAdded
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const ENTRY_ADDED:String = "entryAdded";
		
		/**
		 *  The <code>StateHistoryEvent.ENTRY_REMOVED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>entryRemoved</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
		 *     <tr><td><code>cancelable</code></td><td>false</td></tr>
		 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
		 *       event listener that handles the event. For example, if you use
		 *       <code>myButton.addEventListener()</code> to register an event listener,
		 *       myButton is the value of the <code>currentTarget</code>. </td></tr>
		 *     <tr><td><code>entry</code></td><td>The object representing the state data
		 *       being removed.</td></tr>
		 *     <tr><td><code>index</code></td><td>An integer indicating the zero-based
		 *       position of the state data being removed.</td></tr>
		 *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
		 *       it is not always the Object listening for the event.
		 *       Use the <code>currentTarget</code> property to always access the
		 *       Object listening for the event.</td></tr>
		 *  </table>
		 *
		 *  @eventType entryRemoved
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const ENTRY_REMOVED:String = "entryRemoved";

		
		/**
		 *  The <code>StateHistoryEvent.CLEARED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>cleared</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
		 *     <tr><td><code>cancelable</code></td><td>false</td></tr>
		 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
		 *       event listener that handles the event. For example, if you use
		 *       <code>myButton.addEventListener()</code> to register an event listener,
		 *       myButton is the value of the <code>currentTarget</code>. </td></tr>
		 *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
		 *       it is not always the Object listening for the event.
		 *       Use the <code>currentTarget</code> property to always access the
		 *       Object listening for the event.</td></tr>
		 *  </table>
		 *
		 *  @eventType cleared
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const CLEARED:String = "cleared";
		
		/**
		 * The state data being added or removed.
		 * 
		 * @productversion Worlize API.v1
		 */		
		public var entry:Object;
		
		/**
		 * The <code>entry</code> object's zero-based index in the list of
		 * state history entries.
		 * 
		 * @productversion Worlize API.v1 
		 */		
		public var index:int;
		
		/**
		 *  Constructor.
		 *
		 *  @param type The event type; indicates the action that caused the event.
		 *  @productversion Worlize API.v1
		 */
		public function StateHistoryEvent(type:String)
		{
			super(type, false, false);
		}
	}
}