package com.worlize.api.event
{
	import com.worlize.api.model.User;
	
	import flash.events.Event;
	
	/**
	 * Represents events that relate to a user in the current room.
	 * 
	 * @author Brian McKelvey
	 * @productversion Worlize APIv.1
	 */	
	public class UserEvent extends Event
	{
		/**
		 *  The <code>UserEvent.USER_MOVED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>userMoved</code> event.
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
		 *  @eventType userMoved
		 *  @see com.worlize.api.model.User
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const USER_MOVED:String = "userMoved";
		
		/**
		 *  The <code>UserEvent.USER_AVATAR_CHANGED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>userAvatarChanged</code> event.
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
		 *  @eventType userAvatarChanged
		 *  @see com.worlize.api.model.User
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const USER_AVATAR_CHANGED:String = "userAvatarChanged";
		
		/**
		 *  The <code>UserEvent.USER_COLOR_CHANGED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>userColorChanged</code> event.
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
		 *  @eventType userColorChanged
		 *  @see com.worlize.api.model.User
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const USER_COLOR_CHANGED:String = "userColorChanged";
		
		/**
		 *  The <code>UserEvent.USER_BALLOON_COLOR_CHANGED</code> constant
		 *  defines the value of the <code>type</code> property of the event
		 *  object for a <code>userBalloonColorChanged</code> event.
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
		 *  @eventType userBalloonColorChanged
		 *  @see com.worlize.api.model.User
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const USER_BALLOON_COLOR_CHANGED:String = "userBalloonColorChanged";
		
		/**
		 *  The <code>UserEvent.USER_PRIVILEGES_CHANGED</code> constant defines the value of the
		 *  <code>type</code> property of the event object for a <code>userPrivilegesChanged</code> event.
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
		 *  @eventType userPrivilegesChanged
		 *  @see com.worlize.api.model.User
		 *  
		 *  @productversion Worlize APIv.1
		 */
		public static const USER_PRIVILEGES_CHANGED:String = "userPrivilegesChanged";
		
		/**
		 * The user associated with the current event.
		 * 
		 * @see com.worlize.api.model.User 
		 * @productversion Worlize API.v1
		 */
		public var user:User;
		
		/**
		 *  Constructor.
		 *
		 *  @param type The event type; indicates the action that caused the event.
		 *
		 *  @productversion Worlize API.v1
		 */
		public function UserEvent(type:String)
		{
			super(type, false, false);
		}
		
		/**
		 * @private 
		 */		
		override public function clone():Event {
			var e:UserEvent = new UserEvent(type);
			e.user = user;
			return e;
		}
		
		/**
		 * @private 
		 */		
		override public function toString():String {
			return "[UserEvent type=" + type + " target=" + target + " user: " + user + "]";
		}
	}
}