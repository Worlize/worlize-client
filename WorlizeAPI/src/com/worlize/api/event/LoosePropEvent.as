package com.worlize.api.event
{
	import com.worlize.api.model.LooseProp;
	
	import flash.events.Event;
	
	/**
	 * Represents a change to one or more loose props in the room.
	 *  
	 * @author Brian McKelvey
	 * @productversion Worlize APIv.2
	 */	
	public class LoosePropEvent extends Event
	{
		/**
		 *  The <code>LoosePropEvent.PROP_ADDED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>propAdded</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
		 *     <tr><td><code>cancelable</code></td><td>true</td></tr>
		 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
		 *       event listener that handles the event. For example, if you use
		 *       <code>myButton.addEventListener()</code> to register an event listener,
		 *       myButton is the value of the <code>currentTarget</code>. </td></tr>
		 *     <tr><td><code>looseProp</code></td><td>A LooseProp instance representing
		 *       the new loose prop that was added.</td></tr>
		 *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
		 *       it is not always the Object listening for the event.
		 *       Use the <code>currentTarget</code> property to always access the
		 *       Object listening for the event.</td></tr>
		 *  </table>
		 *
		 *  @eventType propAdded
		 *  @see com.worlize.api.model.LooseProp
		 *  
		 *  @productversion Worlize APIv.2
		 */
		public static const PROP_ADDED:String = "propAdded";
		
		/**
		 *  The <code>LoosePropEvent.PROP_REMOVED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>propRemoved</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
		 *     <tr><td><code>cancelable</code></td><td>true</td></tr>
		 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
		 *       event listener that handles the event. For example, if you use
		 *       <code>myButton.addEventListener()</code> to register an event listener,
		 *       myButton is the value of the <code>currentTarget</code>. </td></tr>
		 *     <tr><td><code>looseProp</code></td><td>A LooseProp instance representing
		 *       the loose prop that was removed.</td></tr>
		 *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
		 *       it is not always the Object listening for the event.
		 *       Use the <code>currentTarget</code> property to always access the
		 *       Object listening for the event.</td></tr>
		 *  </table>
		 *
		 *  @eventType propRemoved
		 *  @see com.worlize.api.model.LooseProp
		 *  
		 *  @productversion Worlize APIv.2
		 */
		public static const PROP_REMOVED:String = "propRemoved";
		
		/**
		 *  The <code>LoosePropEvent.PROP_MOVED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>propMoved</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
		 *     <tr><td><code>cancelable</code></td><td>true</td></tr>
		 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
		 *       event listener that handles the event. For example, if you use
		 *       <code>myButton.addEventListener()</code> to register an event listener,
		 *       myButton is the value of the <code>currentTarget</code>. </td></tr>
		 *     <tr><td><code>looseProp</code></td><td>A LooseProp instance representing
		 *       the loose prop that was moved.</td></tr>
		 *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
		 *       it is not always the Object listening for the event.
		 *       Use the <code>currentTarget</code> property to always access the
		 *       Object listening for the event.</td></tr>
		 *  </table>
		 *
		 *  @eventType propMoved
		 *  @see com.worlize.api.model.LooseProp
		 *  
		 *  @productversion Worlize APIv.2
		 */
		public static const PROP_MOVED:String = "propMoved";
		
		/**
		 *  The <code>LoosePropEvent.PROP_LAYER_CHANGED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>propLayerChanged</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
		 *     <tr><td><code>cancelable</code></td><td>true</td></tr>
		 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
		 *       event listener that handles the event. For example, if you use
		 *       <code>myButton.addEventListener()</code> to register an event listener,
		 *       myButton is the value of the <code>currentTarget</code>. </td></tr>
		 *     <tr><td><code>looseProp</code></td><td>A LooseProp instance representing
		 *       the loose prop that was moved in the stacking order.</td></tr>
		 *     <tr><td><code>oldIndex</code></td><td>The LooseProp's previous
		 *       position in the stacking order.</td></tr>
		 *     <tr><td><code>newIndex</code></td><td>The LooseProp's new
		 *       position in the stacking order.</td></tr>
		 *     <tr><td><code>delta</code></td><td>The change between the
		 *       LooseProp's old and new position in the stacking order. Will
		 *       be a positive integer when the prop is brought forward and
		 *       a negative integer when sent backward.</td></tr>
		 *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
		 *       it is not always the Object listening for the event.
		 *       Use the <code>currentTarget</code> property to always access the
		 *       Object listening for the event.</td></tr>
		 *  </table>
		 *
		 *  @eventType propLayerChanged
		 *  @see com.worlize.api.model.LooseProp
		 *  
		 *  @productversion Worlize APIv.2
		 */
		public static const PROP_LAYER_CHANGED:String = "propLayerChanged";
		
		/**
		 *  The <code>LoosePropEvent.PROPS_CLEARED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>propsCleared</code> event.
		 *
		 *  <p>The properties of the event object have the following values:</p>
		 *  <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
		 *     <tr><td><code>cancelable</code></td><td>true</td></tr>
		 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the
		 *       event listener that handles the event. For example, if you use
		 *       <code>myButton.addEventListener()</code> to register an event listener,
		 *       myButton is the value of the <code>currentTarget</code>. </td></tr>
		 *     <tr><td><code>looseProp</code></td><td>A LooseProp instance representing
		 *       the loose prop that was moved.</td></tr>
		 *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
		 *       it is not always the Object listening for the event.
		 *       Use the <code>currentTarget</code> property to always access the
		 *       Object listening for the event.</td></tr>
		 *  </table>
		 *
		 *  @eventType propsCleared
		 *  @see com.worlize.api.model.LooseProp
		 *  
		 *  @productversion Worlize APIv.2
		 */
		public static const PROPS_CLEARED:String = "propsCleared";
		
		/**
		 * The loose prop that is being affected.
		 * 
		 * @propductversion Worlize APIv.2 
		 */		
		public var looseProp:LooseProp;
		
		/**
		 * The loose prop's previous position in the stacking order.
		 * 
		 * @productversion Worlize APIv.2
		 */		
		public var oldIndex:int;
		
		/**
		 * The loose prop's new position in the stacking order.
		 * 
		 * @productversion Worlize APIv.2 
		 */		
		public var newIndex:int;
		
		/**
		 * The difference between the new and previous positions in the
		 * stacking order.
		 * 
		 * @productversion Worlize APIv.2 
		 */		
		public var delta:int;
		
		/**
		 * Constructor.
		 *  
		 * @param type The event type; indicates the action that caused the
		 * event.
		 * 
		 * @param cancelable Whether or not the default behavior can be
		 * prevented.
		 * 
		 * @productversion Worlize APIv.2
		 */		
		public function LoosePropEvent(type:String, cancelable:Boolean = false) {
			super(type, false, cancelable);
		}
		
		/**
		 * @private
		 */		
		override public function clone():Event {
			var event:LoosePropEvent = new LoosePropEvent(type, cancelable);
			event.looseProp = looseProp;
			event.oldIndex = oldIndex;
			event.newIndex = newIndex;
			event.delta = delta;
			return event;
		}
	}
}