package com.worlize.api.event
{
	import com.worlize.api.model.RoomObject;
	
	import flash.events.Event;
	
	/**
	 * Represents events relating to an object (app) in the current room.
	 * 
	 * @author Brian McKelvey
	 * @productversion Worlize APIv.1
	 */	
	public class RoomObjectEvent extends Event
	{
		/**
		 *  The <code>RoomObjectEvent.OBJECT_MOVED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>objectMoved</code> event.
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
		 *     <tr><td><code>roomObject</code></td><td>The object associated with the
		 * 		 event. See <code>com.worlize.api.model.RoomObject</code>.</td></tr>
		 *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
		 *       it is not always the Object listening for the event.
		 *       Use the <code>currentTarget</code> property to always access the
		 *       Object listening for the event.</td></tr>
		 *  </table>
		 *
		 *  @eventType objectMoved
		 *  @see com.worlize.api.model.RoomObject
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const OBJECT_MOVED:String = "objectMoved";
		
		/**
		 *  The <code>RoomObjectEvent.OBJECT_RESIZED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>objectResized</code> event.
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
		 *     <tr><td><code>roomObject</code></td><td>The object associated with the
		 * 		 event. See <code>com.worlize.api.model.RoomObject</code>.</td></tr>
		 *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
		 *       it is not always the Object listening for the event.
		 *       Use the <code>currentTarget</code> property to always access the
		 *       Object listening for the event.</td></tr>
		 *  </table>
		 *
		 *  @eventType objectResized
		 *  @see com.worlize.api.model.RoomObject
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const OBJECT_RESIZED:String = "objectResized";
		
		/**
		 *  The <code>RoomObjectEvent.OBJECT_STATE_CHANGED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>objectStateChanged</code> event.
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
		 *     <tr><td><code>roomObject</code></td><td>The object associated with the
		 * 		 event. See <code>com.worlize.api.model.RoomObject</code>.</td></tr>
		 *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
		 *       it is not always the Object listening for the event.
		 *       Use the <code>currentTarget</code> property to always access the
		 *       Object listening for the event.</td></tr>
		 *  </table>
		 *
		 *  @productversion Worlize APIv.1
		 *  @eventType objectStateChanged
		 *  @see com.worlize.api.model.RoomObject
		 *  @see com.worlize.api.model.RoomObject#state
		 *  @see com.worlize.api.constants.RoomObjectState
		 */
		public static const OBJECT_STATE_CHANGED:String = "objectStateChanged";
		
		/**
		 * The object instance associated with the event.
		 * 
		 * @productversion Worlize API.v1 
		 * @see com.worlize.api.model.RoomObject 
		 */		
		public var roomObject:RoomObject;
		
		/**
		 *  Constructor.
		 *
		 *  @param type The event type; indicates the action that caused the event.
		 *
		 *  @productversion Worlize API.v1
		 */
		public function RoomObjectEvent(type:String)
		{
			super(type, false, false);
		}
		
		/**
		 * @private 
		 */		
		override public function clone():Event {
			var event:RoomObjectEvent = new RoomObjectEvent(type);
			event.roomObject = roomObject;
			return event;
		}
	}
}