package com.worlize.api.event
{
	import com.worlize.api.model.RoomObject;
	import com.worlize.api.model.User;
	
	import flash.events.Event;
	
	/**
	 * Represents inter-object messaging events.
	 * 
	 * @author Brian McKelvey
	 * @productversion Worlize APIv.1
	 */	
	public class MessageEvent extends Event
	{
		/**
		 *  The <code>MessageEvent.MESSAGE_RECEIVED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>messageReceived</code> event.
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
		 *     <tr><td><code>fromUser</code></td><td>The user who sent the message. See 
		 *       <code>com.worlize.api.model.User</code>.</td></tr>
		 *     <tr><td><code>fromObject</code></td><td>The object that sent the message. See 
		 *       <code>com.worlize.api.model.RoomObject</code>.</td></tr>
		 *     <tr><td><code>message</code></td><td>The message received.</td></tr>
		 *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
		 *       it is not always the Object listening for the event.
		 *       Use the <code>currentTarget</code> property to always access the
		 *       Object listening for the event.</td></tr>
		 *  </table>
		 *
		 *  @eventType messageReceived
		 *  @see com.worlize.api.model.RoomObject#sendMessage()
		 *  @see com.worlize.api.model.RoomObject#sendMessageLocal()
		 *  @see com.worlize.api.model.ThisRoom#broadcastMessage()
		 *  @see com.worlize.api.model.ThisRoom#broadcastMessageLocal()
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const MESSAGE_RECEIVED:String = "messageReceived";
		
		/**
		 * The AMF3-deserialized object received
		 * 
		 * @productversion Worlize API.v1  
		 */		
		public var message:Object;
		
		/**
		 * The object (app) that sent the message
		 * 
		 * @see com.worlize.api.model.RoomObject
		 * @productversion Worlize API.v1 
		 */		
		public var fromObject:RoomObject;
		
		/**
		 * The user who sent the message
		 * 
		 * @see com.worlize.api.model.User
		 * @productversion Worlize API.v1 
		 */		
		public var fromUser:User;
		
		/**
		 *  Constructor.
		 *
		 *  @param type The event type; indicates the action that caused the event.
		 *
		 *  @productversion Worlize API.v1
		 */
		public function MessageEvent(type:String)
		{
			super(type, false, false);
		}
		
		/**
		 * @private 
		 */		
		override public function clone():Event {
			var event:MessageEvent = new MessageEvent(type);
			event.message = message;
			event.fromObject = fromObject;
			event.fromUser = fromUser;
			return event;
		}
	}
}