package com.worlize.api.model
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.APIEvent;
	import com.worlize.worlize_internal;
	
	/**
	 * Dispatched when a message is received from an object (app)
	 * 
	 * @eventType com.worlize.api.event.MessageEvent.MESSAGE_RECEIVED
	 * @see RoomObject#sendMessage()
	 * @see RoomObject#sendMessageLocal()
	 * @see ThisRoom#broadcastMessage()
	 * @see ThisRoom#broadcastMessageLocal()
	 * @productversion Worlize API.v1
	 */	
	[Event(name="messageReceived",type="com.worlize.api.event.MessageEvent")]
	
	/**
	 * Represents the currently executing object (app).
	 * 
	 * <p>This class adds additional functionality to its
	 * <code>RoomObject</code> superclass, including making a few read-only
	 * properties writable including:</p>
	 * <ul>
	 *   <li>x</li>
	 *   <li>y</li>
	 *   <li>width</li>
	 *   <li>height</li>
	 * </ul>
	 * 
	 * @author Brian McKelvey
	 * @see com.worlize.model.RoomObject
	 * @productversion Worlize API.v1 
	 */	
	public class ThisRoomObject extends RoomObject
	{
		use namespace worlize_internal;
		
		/**
		 * @inheritDoc
		 */			
		public function set x(newValue:Number):void {
			moveTo(newValue, _y);
		}
		
		/**
		 * @inheritDoc
		 */			
		public function set y(newValue:Number):void {
			moveTo(_x, newValue);
		}
		
		/**
		 * @inheritDoc
		 */			
		public function set width(newValue:Number):void {
			setSize(newValue, _height);
		}
		
		/**
		 * @inheritDoc
		 */					
		public function set height(newValue:Number):void {
			setSize(_width, newValue);
		}
		
		/**
		 * Moves the object (app) to the specified coordinates locally.
		 * 
		 * <p>The coordinates are of the top-left corner of the object (app)
		 * and are relative to the room's coordinate space.</p>
		 *  
		 * <p><strong>NOTE:</strong> This will only move the app for the current
		 * user on the local machine.  This does not broadcast an event through
		 * the server and other users will not see the app move.</p>
		 * 
		 * @param x the horizontal position of the object in pixels
		 * @param y the vertical position of the object in pixels
		 * @productversion Worlize API.v1
		 */		
		public function moveTo(x:Number, y:Number):void {
			var event:APIEvent = new APIEvent(APIEvent.MOVE_OBJECT);
			event.data = {
				x: x,
				y: y
			};
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		/**
		 * Changes the visible drawing area of the current object (app) locally.
		 * 
		 * <p>The visible area of an app is clipped to the specified dimensions.
		 * Apps cannot draw outside their specified boundaries, so if you need
		 * to you can use a combination of the setSize() and moveTo() methods.
		 * </p>
		 * 
		 * <p><strong>NOTE:</strong> This will only resize the app for the
		 * current user on the local machine.  This does not broadcast an event
		 * through the server and other users will not see the app change size.
		 * </p>
		 * 
		 * @param width the desired width in pixels
		 * @param height the desired height in pixels
		 * @productversion Worlize API.v1
		 */		
		public function setSize(width:Number, height:Number):void {
			if (_width !== width || _height !== height) {
				var event:APIEvent = new APIEvent(APIEvent.RESIZE_OBJECT);
				event.data = {
					width: width,
					height: height
				};
				WorlizeAPI.sharedEvents.dispatchEvent(event);
			}
		}
		
		/**
		 * @private
		 */		
		worlize_internal static function fromData(data:Object):ThisRoomObject {
			var obj:ThisRoomObject = new ThisRoomObject();
			obj._instanceGuid = data.instanceGuid;
			obj._state = data.state;
			obj._guid = data.guid;
			obj._name = data.name;
			obj._identifier = data.identifier;
//			obj._creatorGuid = data.creatorGuid;
			obj._width = data.width;
			obj._height = data.height;
			obj._x = data.x;
			obj._y = data.y;
			return obj;
		}
	}
}