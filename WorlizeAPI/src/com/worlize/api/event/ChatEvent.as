package com.worlize.api.event
{
	import com.worlize.api.model.User;
	import com.worlize.worlize_internal;
	
	import flash.events.Event;
	
	/**
	 * Represents a chat event in the room.
	 * 
	 * @see com.worlize.api.model.ThisRoom#event:incomingChat
	 * @see com.worlize.api.model.ThisRoom#event:outgoingChat
	 * @author Brian McKelvey
	 * @productversion Worlize APIv.1
	 */	
	public class ChatEvent extends Event
	{
		use namespace worlize_internal;
		
		/**
		 *  The <code>ChatEvent.INCOMING_CHAT</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>incomingChat</code> event.
		 *
		 *  <p>The <code>text</code> property can be modified to change the chat text before it is
		 *  displayed on screen.</p>
		 * 
		 *  <p>This event is cancelable.  Call <code>preventDefault()</code> on the event object
		 *  to prevent the text from appearing on screen.</p>
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
		 *     <tr><td><code>isWhisper</code></td><td>True if the event represents a
		 *       private message</td></tr>
		 *     <tr><td><code>originalText</code></td><td>The original chat text, unmodified.
		 * 		 This value can be relied upon to contain the true chat text, as opposed to
		 *       the <code>text</code> property that may have been modified by another app or
		 *       event handler.</td></tr>
		 *     <tr><td><code>recipient</code></td><td>The user who is the recipient of a
		 *       whisper.  If the chat is not a whisper, will be set to <code>null</code>. 
		 *       See <code>com.worlize.api.model.User</code>.</td></tr>
		 *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
		 *       it is not always the Object listening for the event.
		 *       Use the <code>currentTarget</code> property to always access the
		 *       Object listening for the event.</td></tr>
		 *     <tr><td><code>text</code></td><td>The chat text.  Can be modified to affect
		 *       the actual message before it is displayed on screen.</td></tr>
		 *     <tr><td><code>user</code></td><td>The user who is sending the chat. See 
		 *       <code>com.worlize.api.model.User</code>.</td></tr>
		 *  </table>
		 *
		 *  @eventType incomingChat
		 *  @see com.worlize.api.model.User
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const INCOMING_CHAT:String = "incomingChat";
		
		
		/**
		 *  The <code>ChatEvent.OUTGOING_CHAT</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>outgoingChat</code> event.
		 *
		 *  <p>The <code>text</code> property can be modified to change the chat text before it is
		 *  sent.</p>
		 * 
		 *  <p>This event is cancelable.  Call <code>preventDefault()</code> on the event object
		 *  to prevent the chat message from being sent.</p>
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
		 *     <tr><td><code>isWhisper</code></td><td>True if the event represents a
		 *       private message</td></tr>
		 *     <tr><td><code>originalText</code></td><td>The original chat text, unmodified.
		 * 		 This value can be relied upon to contain the true chat text, as opposed to
		 *       the <code>text</code> property that may have been modified by another app or
		 *       event handler.</td></tr>
		 *     <tr><td><code>recipient</code></td><td>The user who is the recipient of a
		 *       whisper.  If the chat is not a whisper, will be set to <code>null</code>. 
		 *       See <code>com.worlize.api.model.User</code>.</td></tr>
		 *     <tr><td><code>target</code></td><td>The Object that dispatched the event;
		 *       it is not always the Object listening for the event.
		 *       Use the <code>currentTarget</code> property to always access the
		 *       Object listening for the event.</td></tr>
		 *     <tr><td><code>text</code></td><td>The chat text.  Can be modified to affect
		 *       the actual message that is sent.</td></tr>
		 *     <tr><td><code>user</code></td><td>The user who is sending the chat. See 
		 *       <code>com.worlize.api.model.User</code>.</td></tr>
		 *  </table>
		 *
		 *  @eventType outgoingChat
		 *  @see com.worlize.api.model.User
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const OUTGOING_CHAT:String = "outgoingChat";
		
		
		/**
		 * True if the chat represents a private message (whisper) to another user. 
		 */		
		public var isWhisper:Boolean;
		
		
		/**
		 * The recipient of the whisper, if this is a private message.
		 */
		public var recipient:User;
		
		
		/**
		 * The user who is chatting.
		 */		
		public var user:User;
		
		
		/**
		 * The chat text.
		 * 
		 * <p>Modify this to change the chat text in-flight.</p>
		 * 
		 * @see #originalText 
		 */
		public var text:String;
		
		
		/**
		 * The unmodified chat text.
		 * 
		 * <p>If another app or event handler has modified the <code>text</code>
		 * property, <code>originalText</code> is guaranteed to represent the
		 * original value of the <code>text</code> property without modifications.</p>
		 * 
		 * @see #text
		 */		
		public var originalText:String;
		
		/**
		 *  Constructor.
		 *
		 *  @param type The event type; indicates the action that caused the event.
		 *
		 *  @productversion Worlize API.v1
		 */
		public function ChatEvent(type:String) {
			super(type, false, true);
		}
		
		/**
		 * @private
		 */		
		override public function clone():Event {
			var event:ChatEvent = new ChatEvent(type);
			event.isWhisper = isWhisper;
			event.text = text;
			event.originalText = originalText;
			event.recipient = recipient;
			event.user = user;
			return event;
		}
	}
}