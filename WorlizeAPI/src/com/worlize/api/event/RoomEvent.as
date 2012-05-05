package com.worlize.api.event
{
	import com.worlize.api.model.RoomObject;
	import com.worlize.api.model.User;
	
	import flash.events.Event;
	
	/**
	 * Represents a variety of possible events that take place in the current
	 * room.
	 *  
	 * @author Brian McKelvey
	 * @productversion Worlize APIv.1 
	 */	
	public class RoomEvent extends Event
	{
		/**
		 *  The <code>RoomEvent.USER_ENTERED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>userEntered</code> event.
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
		 *     <tr><td><code>user</code></td><td>The user associated with the event. See 
		 *       <code>com.worlize.api.model.User</code>.</td></tr>
		 *  </table>
		 *
		 *  @eventType userEntered
		 *  @see com.worlize.api.model.User
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const USER_ENTERED:String = "userEntered";
		
		/**
		 *  The <code>RoomEvent.NAME_CHANGED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>nameChanged</code> event.
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
		 *  @eventType nameChanged
		 *  @see com.worlize.api.model.User
		 *  
		 *  @productversion Worlize APIv.3
		 */
		public static const NAME_CHANGED:String = "nameChanged";
		
		/**
		 *  The <code>RoomEvent.USER_LEFT</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>userLeft</code> event.
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
		 *     <tr><td><code>user</code></td><td>The user associated with the event. See 
		 *       <code>com.worlize.api.model.User</code>.</td></tr>
		 *  </table>
		 *
		 *  @eventType userLeft
		 *  @see com.worlize.api.model.User
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const USER_LEFT:String = "userLeft";
		
		/**
		 *  The <code>RoomEvent.OBJECT_ADDED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>objectAdded</code> event.
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
		 *  @eventType objectAdded
		 *  @see com.worlize.api.model.RoomObject
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const OBJECT_ADDED:String = "objectAdded";
		
		/**
		 *  The <code>RoomEvent.OBJECT_REMOVED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>objectRemoved</code> event.
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
		 *  @eventType objectRemoved
		 *  @see com.worlize.api.model.RoomObject
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const OBJECT_REMOVED:String = "objectRemoved";
		
		/**
		 *  The <code>RoomEvent.LOCKED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>locked</code> event.
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
 		 *     <tr><td><code>user</code></td><td>The user that locked the room. See 
		 *       <code>com.worlize.api.model.User</code>.</td></tr>
		 *  </table>
		 *
		 *  @eventType locked
		 *  @see com.worlize.api.model.User
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const LOCKED:String = "locked";
		
		/**
		 *  The <code>RoomEvent.UNLOCKED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>unlocked</code> event.
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
		 *     <tr><td><code>user</code></td><td>The user that unlocked the room. See 
		 *       <code>com.worlize.api.model.User</code>.</td></tr>
		 *  </table>
		 *
		 *  @eventType unlocked
		 *  @see com.worlize.api.model.User
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const UNLOCKED:String = "unlocked";
		
		/**
		 * The Worlize user associated with the event.
		 * 
		 * @productversion Worlize API.v1
		 * @see com.worlize.api.model.User  
		 */		
		public var user:User;

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
		public function RoomEvent(type:String) {
			super(type, false, false);
		}
		
		/**
		 * @private
		 */		
		override public function clone():Event {
			var event:RoomEvent = new RoomEvent(type);
			event.user = user;
			return event;
		}
		
		/**
		 * @private 
		 */		
		override public function toString():String {
			return "[RoomEvent type=" + type + " target=" + target + " user: " + user + "]";
		}
	}
}