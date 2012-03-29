package com.worlize.api.event
{
	import com.worlize.api.model.User;
	
	import flash.events.Event;
	
	/**
	 * Event representing that a piece of data changed.
	 *  
	 * @author Brian McKelvey
	 * @productversion Worlize APIv.1
	 */	
	public class ChangeEvent extends Event
	{
		/**
		 *  The <code>ChangeEvent.PROPERTY_CHANGED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>propertyChanged</code> event.
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
		 *     <tr><td><code>name</code></td><td>The name of the property that changed
		 *       on the <code>target</code> object.</td></tr>
		 *     <tr><td><code>changedBy</code></td><td>A <code>User</code> instance that
		 *       represents the Worlize user who changed the property, if available
		 * 	   </td></tr>
		 *     <tr><td><code>newValue</code></td><td>The new value of the property</td></tr>
 		 *     <tr><td><code>oldValue</code></td><td>The old value of the property,
		 *       as it was before it was changed.</td></tr>
		 *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
		 *       it is not always the Object listening for the event.
		 *       Use the <code>currentTarget</code> property to always access the
		 *       Object listening for the event.</td></tr>
		 *  </table>
		 *
		 *  @eventType propertyChanged
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const PROPERTY_CHANGED:String = "propertyChanged";
		
		/**
		 *  The <code>ChangeEvent.PROPERTY_DELETED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>propertyDeleted</code> event.
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
		 *     <tr><td><code>name</code></td><td>The name of the property that changed
		 *       on the <code>target</code> object.</td></tr>
		 *     <tr><td><code>changedBy</code></td><td>A <code>User</code> instance that
		 *       represents the Worlize user who deleted the property, if available
		 * 	   </td></tr>
		 *     <tr><td><code>newValue</code></td><td><code>undefined</code></td></tr>
		 *     <tr><td><code>oldValue</code></td><td>The old value of the property,
		 *       as it was before it was deleted.</td></tr>
		 *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
		 *       it is not always the Object listening for the event.
		 *       Use the <code>currentTarget</code> property to always access the
		 *       Object listening for the event.</td></tr>
		 *  </table>
		 *
		 *  @eventType propertyDeleted
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const PROPERTY_DELETED:String = "propertyDeleted";
		
		/**
		 * The name of the property that was changed
		 * 
		 * @productversion Worlize API.v1 
		 */
		public var name:String;
		
		/**
		 * A <code>User</code> instance representing the Worlize user who
		 * changed the property.
		 * 
		 * @productversion Worlize API.v1
		 */		
		public var changedBy:User;
		
		/**
		 * The new value of the property.
		 * 
		 * @productversion Worlize API.v1 
		 */		
		public var newValue:*;
		
		/**
		 * The old value of the property, before the change.
		 * 
		 * @productversion Worlize API.v1 
		 */		
		public var oldValue:*;
		
		/**
		 *  Constructor.
		 *
		 *  @param type The event type; indicates the action that caused the event.
		 *
		 *  @productversion Worlize API.v1
		 */
		public function ChangeEvent(type:String)
		{
			super(type, false, false);
		}
	}
}