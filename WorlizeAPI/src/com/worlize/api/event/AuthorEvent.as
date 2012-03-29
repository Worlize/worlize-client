package com.worlize.api.event
{
	import flash.events.Event;
	
	/**
	 * Event representing a change to author mode.
	 * 
	 * @author Brian McKelvey
	 * @productversion Worlize APIv.1
	 */	
	public class AuthorEvent extends Event
	{
		/**
		 *  The <code>AuthorEvent.AUTHOR_MODE_ENABLED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>authorModeEnabled</code> event.
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
		 *  @eventType authorModeEnabled
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const AUTHOR_MODE_ENABLED:String = "authorModeEnabled";
		
		/**
		 *  The <code>AuthorEvent.AUTHOR_MODE_DISABLED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>authorModeDisabled</code> event.
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
		 *  @eventType authorModeDisabled
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const AUTHOR_MODE_DISABLED:String = "authorModeDisabled";
		
		/**
		 *  The <code>AuthorEvent.EDIT_MODE_ENABLED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>editModeEnabled</code> event.
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
		 *  @eventType editModeEnabled
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const EDIT_MODE_ENABLED:String = "editModeEnabled";
		
		/**
		 *  The <code>AuthorEvent.EDIT_MODE_DISABLED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>editModeDisabled</code> event.
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
		 *  @eventType editModeDisabled
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const EDIT_MODE_DISABLED:String = "editModeDisabled";
		
		public function AuthorEvent(type:String)
		{
			super(type, false, false);
		}
	}
}