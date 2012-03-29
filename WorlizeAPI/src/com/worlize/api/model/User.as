package com.worlize.api.model
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.UserEvent;
	import com.worlize.worlize_internal;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * Dispatched after the user's avatar has moved.
	 * 
	 * @eventType com.worlize.api.event.UserEvent.USER_MOVED
	 * @productversion Worlize API.v1
	 */	
	[Event(name="userMoved",type="com.worlize.api.event.UserEvent")]
	
	/**
	 * Dispatched after the user's avatar has changed.
	 * 
	 * @eventType com.worlize.api.event.UserEvent.USER_AVATAR_CHANGED
	 * @productversion Worlize API.v1
	 */	
	[Event(name="userAvatarChanged",type="com.worlize.api.event.UserEvent")]
	
	/**
	 * Dispatched after the color of the user's default "gummy" avatar has changed.
	 * 
	 * @eventType com.worlize.api.event.UserEvent.USER_COLOR_CHANGED
	 * @productversion Worlize API.v1 
	 */	
	[Event(name="userColorChanged",type="com.worlize.api.event.UserEvent")]
	
	/**
	 * Dispatched after the user's text baloon background color has changed.
	 * 
	 * @eventType com.worlize.api.event.UserEvent.USER_BALLOON_COLOR_CHANGED 
	 * @productversion Worlize API.v1
	 */	
	[Event(name="userBalloonColorChanged",type="com.worlize.api.event.UserEvent")]
	
	/**
	 * Dispatched after the user's privileges have changed
	 * 
	 * @eventType com.worlize.api.event.UserEvent.USER_PRIVILEGES_CHANGED
	 * @productversion Worlize API.v1 
	 */	
	[Event(name="userPrivilegesChanged",type="com.worlize.api.event.UserEvent")]
	
	/**
	 * Represents a Worlize User
	 * 
	 * @author Brian McKelvey
	 * @productversion Worlize APIv.1
	 * @see com.worlize.api.model.ThisUser
	 */	
	public class User extends EventDispatcher
	{
		use namespace worlize_internal;
		
		/**
		 * @private 
		 */		
		protected var _name:String;
		
		/**
		 * @private 
		 */
		protected var _guid:String;
		
		/**
		 * @private 
		 */
		protected var _x:int;
		
		/**
		 * @private 
		 */
		protected var _y:int;
		
		/**
		 * @private 
		 */		
		protected var _color:int;
		
		/**
		 * @private 
		 */
		protected var _balloonColor:int;
		
		/**
		 * @private 
		 */
		protected var _avatar:Avatar;
		
		/**
		 * @private 
		 */
		protected var _privileges:Array;
		
		/**
		 * Constructor.
		 * 
		 * @productversion Worlize APIv.1 
		 */		
		public function User() {
			super(null);
		}
		
		/**
		 * The user's username. 
		 * 
		 * @return the user's username
		 * @productversion Worlize APIv.1
		 */		
		public function get name():String {
			return _name;
		}
		
		/**
		 * The user's Globally Unique Identifier
		 *  
		 * @return the user's GUID
		 * @productversion Worlize APIv.1
		 * @see http://en.wikipedia.org/wiki/GUID GUID on Wikipedia
		 */		
		public function get guid():String {
			return _guid;
		}
		
		/**
		 * The horizontal position of the user's avatar in the room's coordinate space.
		 *  
		 * @return the user's horizontal position
		 * @productversion Worlize APIv.1
		 */		
		public function get x():int {
			return _x;
		}
		
		/**
		 * The vertical position of the user's avatar in the room's coordinate space.
		 *  
		 * @return the user's vertical position
		 * @productversion Worlize APIv.1
		 */		
		public function get y():int {
			return _y;
		}
		
		/**
		 * The color index of the user's default "gummy" avatar.
		 * 
		 * <p>Valid values range from 0 to 12, inclusive</p> 
		 *  
		 * @return the color index as an integer from 0 through 12
		 * @productversion Worlize APIv.1 
		 */		
		public function get color():int {
			return _color;
		}
		
		/**
		 * The background color index of the user's chat baloons.
		 * 
		 * <p>Valid values range from 0 to 15, inclusive</p>
		 * 
		 * <p>The current colors are as follows, but subject to change:</p>
		 * <table class="innertable">
		 *   <tr><th>Index</th><th>Color</th></tr>
		 * 	 <tr><td>0</td><td>#FF9999 - Red</td></tr>
		 *   <tr><td>1</td><td>#FF9966 - Orange</td></tr>
		 *   <tr><td>2</td><td>#FFCC88 - Gold</td></tr>
		 *   <tr><td>3</td><td>#FFEE99 - Yellow</td></tr>
		 *   <tr><td>4</td><td>#D0F29F - Yellow-Green</td></tr>
		 *   <tr><td>5</td><td>#B9F29F - Green</td></tr>
		 *   <tr><td>6</td><td>#AFF2AE - Green 2</td></tr>
		 *   <tr><td>7</td><td>#C4F4DE - Green-Cyan</td></tr>
		 *   <tr><td>8</td><td>#A9EEF1 - Cyan</td></tr>
		 *   <tr><td>9</td><td>#8DD2FF - Cyan-Blue</td></tr>
		 *   <tr><td>10</td><td>#86ABFF - Blue</td></tr>
		 *   <tr><td>11</td><td>#8F86FF - Blue-Violet</td></tr>
		 *   <tr><td>12</td><td>#AB86FF - Violet</td></tr>
		 *   <tr><td>13</td><td>#EF86FF - Magenta</td></tr>
		 *   <tr><td>14</td><td>#FF86E4 - Magenta-Rose</td></tr>
		 *   <tr><td>15</td><td>#FF86B1 - Rose</td></tr>
		 * </table>
		 *  
		 * @return the color index as an integer from 0 through 15
		 * @productversion Worlize APIv.1
		 */		
		public function get balloonColor():int {
			return _balloonColor;
		}
		
		/**
		 * The user's current avatar 
		 * 
		 * @return an Avatar instance
		 * @productversion Worlize APIv.1
		 */		
		public function get avatar():Avatar {
			return _avatar;
		}
		
		/**
		 * True if the user has permission to author the current room.
		 *  
		 * @return whether the user can author
		 * @productversion Worlize APIv.1
		 */		
		public function get canAuthor():Boolean {
			return _privileges && _privileges.indexOf('canAuthor') !== -1;
		}
		
		/**
		 * A list of strings representing the user's current permissions.
		 *  
		 * @return an array of permissions
		 * @productversion Worlize APIv.1
		 */		
		public function get privileges():Array {
			return _privileges.slice(0);
		}
		
		/**
		 * @private 
		 */		
		worlize_internal function toJSON():Object {
			return {
				name: _name,
				guid: _guid,
				x: _x,
				y: _y,
				face: _color,
				color: _balloonColor,
				avatar: _avatar ? _avatar.toJSON() : null
			};
		}
		
		/**
		 * @private 
		 */		
		override public function toString():String {
			return "[User guid=" + _guid + " name=" + _name + "]";
		}
		
		/**
		 * @private 
		 */		
		worlize_internal function updatePosition(x:int, y:int):void {
			if (_x !== x || _y !== y) {
				_x = x;
				_y = y;
				var event:UserEvent = new UserEvent(UserEvent.USER_MOVED);
				event.user = this;
				dispatchEvent(event);
			}
		}
		
		/**
		 * @private
		 */	
		worlize_internal function updateAvatar(avatar:Avatar):void {
			if (_avatar !== avatar) {
				_avatar = avatar;
				var event:UserEvent = new UserEvent(UserEvent.USER_AVATAR_CHANGED);
				event.user = this;
				dispatchEvent(event);
			}
		}
		
		/**
		 * @private 
		 */
		worlize_internal function updateColor(newValue:uint):void {
			if (_color !== newValue) {
				_color = newValue;
				var event:UserEvent = new UserEvent(UserEvent.USER_COLOR_CHANGED);
				event.user = this;
				dispatchEvent(event);
			}
		}
		
		/**
		 * @private 
		 */
		worlize_internal function updateBalloonColor(newValue:uint):void {
			if (_balloonColor !== newValue) {
				_balloonColor = newValue;
				var event:UserEvent = new UserEvent(UserEvent.USER_BALLOON_COLOR_CHANGED);
				event.user = this;
				dispatchEvent(event);
			}
		}
		
		/**
		 *	@private 
		 */
		worlize_internal function updatePrivileges(newValue:Array):void {
			if (newValue === null) { return; }
			
			var valuesDiffer:Boolean = false;
			if (newValue.length === _privileges.length) {
				var sortedPrivileges:Array = newValue.sort();
				for (var i:int = 0; i < sortedPrivileges.length; i++) {
					if (sortedPrivileges[i] !==	_privileges[i]) {
						valuesDiffer = true;
						break;
					}
				}
			}
			else {
				valuesDiffer = true;
			}
			if (valuesDiffer) {
				_privileges = sortedPrivileges;
				var event:UserEvent = new UserEvent(UserEvent.USER_PRIVILEGES_CHANGED);
				event.user = this;
				dispatchEvent(event);
			}
		}
		
		/**
		 *	@private 
		 */
		worlize_internal static function fromData(data:Object):User {
			var user:User = new User();
			user._privileges = data.privileges.sort();
			user._guid = data.guid;
			user._name = data.name;
			user._x = data.x;
			user._y = data.y;
			user._color = data.face;
			user._balloonColor = data.color;
			user._avatar = Avatar.fromData(data.avatar);
			return user;
		}
	}
}