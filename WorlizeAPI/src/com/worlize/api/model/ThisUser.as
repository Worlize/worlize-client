package com.worlize.api.model
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.APIEvent;
	import com.worlize.worlize_internal;
	
	/**
	 * Represents the current user ("this" user).
	 * 
	 * <p>The current user is the user whose machine is currently executing
	 * the app code.</p>
	 * 
	 * <p>This class adds additional functionality to the <code>User</code>
	 * class to allow the app to manipulate and control the user's avatar.</p>
	 * 
	 * <p>Note that this class makes writable certain read-only properties of its
	 * <code>User</code> superclass:</p>
	 * <ul>
	 * 	 <li>balloonColor</li>
	 *   <li>color</li>
	 * </ul>
	 *   
	 * @author Brian McKelvey
	 * @productversion Worlize APIv.1
	 * @see com.worlize.api.model.ThisRoom
	 * @see com.worlize.api.model.User
	 */	
	public class ThisUser extends User
	{
		use namespace worlize_internal;
		
		/**
		 * Changes the user's avatar.
		 * 
		 * <p>Set to <code>null</code> to remove any avatar and revert back to
		 * the default "gummy" avatar.</p>
		 * 
		 * <p>Note that apps are not permitted to activate the user's webcam as
		 * their avatar.</p>
		 * 
		 * @param avatarOrGuid an Avatar instance or the desired avatar's String GUID
		 * @productversion Worlize APIv.1
		 * @example Change the user's avatar
		 * <listing version="3.0">
		 * 
		 * // Get a reference to this user
		 * var thisUser:ThisUser = WorlizeAPI.getInstance().thisUser;
		 * 
		 * // Change the user's avatar into a round, blue happyface.
		 * thisUser.setAvatar('97d7cb1d-86ee-2106-844d-099bf59c501c');
		 * 
		 * // Alternate method:
		 * var happyFaceAvatar:Avatar = new Avatar();
		 * happyFaceAvatar.guid = '97d7cb1d-86ee-2106-844d-099bf59c501c';
		 * thisUser.setAvatar(happyFaceAvatar);
		 * 
		 * 
		 * </listing>
		 */
		public function setAvatar(avatarOrGuid:Object):void {
			var avatarGuid:String;
			if (avatarOrGuid is Avatar) {
				avatarGuid = (avatarOrGuid as Avatar).guid;
			}
			else if (avatarOrGuid === null) {
				avatarOrGuid = null;
			}
			else if (avatarOrGuid is String) {
				avatarGuid = avatarOrGuid as String;
			}
			else {
				throw new ArgumentError("Invalid parameter passed to setAvatar.");
			}
			
			if (_avatar === null && avatarGuid === null) { return; };
			if (_avatar !== null && avatar.guid === avatarGuid) { return; }

			if (avatarGuid === null || avatarGuid.match(WorlizeAPI.GUID_REGEXP)) {
				var event:APIEvent = new APIEvent(APIEvent.SET_AVATAR);
				event.data = { guid: avatarGuid };
				WorlizeAPI.sharedEvents.dispatchEvent(event);
			}
			else {
				throw new ArgumentError("Invalid avatar guid: " + avatarGuid);
			}
		}
		
		/**
		 * Removes the user's avatar, resetting back to the default "gummy" avatar.
		 * 
		 * <p>Equivalent to <code>setAvatar(null)</code></p>  
		 * 
		 * @productversion Worlize APIv.1
		 */		
		public function removeAvatar():void {
			setAvatar(null);
		}
		
		/**
		 * @inheritDoc
		 */		
		public function set color(newValue:int):void {
			var event:APIEvent = new APIEvent(APIEvent.SET_USER_COLOR);
			event.data = { color: newValue };
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
	
		/**
		 * @inheritDoc
		 */		
		public function set balloonColor(newValue:int):void {
			var event:APIEvent = new APIEvent(APIEvent.SET_USER_BALLOON_COLOR);
			event.data = { color: newValue };
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		/**
		 * Move the user's avatar, relative to the room's coordinate space.
		 *  
		 * @param x horizontal position in pixels, in the room's coordinate space
		 * @param y vertical position in pixels, in the room's coordinate space
		 * @productversion Worlize APIv.1
		 */		
		public function moveTo(x:int, y:int):void {
			var event:APIEvent = new APIEvent(APIEvent.MOVE_USER);
			event.data = {
				x: x,
				y: y
			};
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		/**
		 * Make the user say or whisper the given chat text.
		 *  
		 * <p>Optionally specify a <code>User</code> instance as the second
		 * argument to make it a private message (whisper).</p>
		 * 
		 * @param text the chat text to say
		 * @param whisperTo (optional) the User to whisper to
		 * @productversion Worlize APIv.1
		 */		
		public function say(text:String, whisperTo:User=null):void {
			var event:APIEvent = new APIEvent(APIEvent.SEND_CHAT);
			event.data = {
				text: text
			};
			if (whisperTo) {
				event.data.whisperTo = whisperTo.guid
			}
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		/**
		 * Cause the user to go to another room, specified by GUID.
		 *  
		 * @param roomGuid the GUID of the destination room
		 * @productversion Worlize APIv.1
		 */		
		public function gotoRoom(roomGuid:String):void {
			var event:APIEvent = new APIEvent(APIEvent.GOTO_ROOM);
			event.data = {
				room: roomGuid
			};
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		/**
		 * @private
		 */		
		override public function toString():String {
			return "[ThisUser guid=" + _guid + " name=" + _name + "]";
		}
		
		/**
		 * @private
		 */		
		worlize_internal static function fromData(data:Object):ThisUser {
			var user:ThisUser = new ThisUser();
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