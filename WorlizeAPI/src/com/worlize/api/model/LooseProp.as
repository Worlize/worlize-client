package com.worlize.api.model
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.APIEvent;
	import com.worlize.api.event.LoosePropEvent;
	import com.worlize.worlize_internal;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * Dispatched after the prop has been moved in the room.
	 * @eventType com.worlize.api.event.LoosePropEvent.PROP_MOVED
	 * @productversion Worlize API.v2 
	 */	
	[Event(name="propMoved", type="com.worlize.api.event.LoosePropEvent")]
	
	/**
	 * Dispatched after the prop has changed position in the stacking order. 
 	 * @eventType com.worlize.api.event.LoosePropEvent.PROP_LAYER_CHANGED
	 * @productversion Worlize API.v2
	 */	
	[Event(name="propLayerChanged", type="com.worlize.api.event.LoosePropEvent")]
	
	/**
	 * Represents an instance of a Prop image in the room.
	 * 
	 * <p>Props can be placed in and moved around the room by anyone as a way
	 * temporararily decorate the room or perhaps to virtually give your friend
	 * a cup of coffee by placing it next to them in the room.</p>
	 * 
	 * <p>To add loose props to the room, use the <code>addLooseProp</code>
	 * method of the <code>ThisRoom</code> instance.</p>
	 * 
	 * <p>All loose props will be removed from the room once it becomes empty
	 * to prevent abuse.</p>
	 * 
	 * @see com.worlize.api.model.ThisRoom#addLooseProp()
	 * ThisRoom.addLooseProp()
	 * 
	 * @author Brian McKelvey
	 * @productversion Worlize APIv.2
	 */	
	public class LooseProp extends EventDispatcher
	{
		use namespace worlize_internal;
		
		/**
		 * @private 
		 */		
		protected var _prop:Prop;
		
		/**
		 * @private 
		 */		
		protected var _id:uint;
		
		/**
		 * @private 
		 */		
		protected var _x:int;
		
		/**
		 * @private 
		 */		
		protected var _y:int;
		
		/**
		 * The <code>Prop</code> associated with this <code>LooseProp</code>
		 * instance.
		 * 
		 * <p>The <code>Prop</code> class defines the image that is displayed
		 * while the LooseProp identifies a particular instance of that
		 * <code>Prop</code> in the room.</p>
		 *  
		 * @return a <code>Prop</code> instance 
		 * 
		 * @see com.worlize.api.model.Prop
		 * 
		 * @productversion Worlize APIv.2
		 */		
		public function get prop():Prop {
			return _prop;
		}
		
		/**
		 * A unique identifier for this specific <code>LooseProp</code>
		 * instance.
		 *  
		 * @return an id number
		 * 
		 * @see com.worlize.model.ThisRoom#getPropById()
		 * 
		 * @productversion Worlize APIv.2
		 */
		public function get id():uint {
			return _id;
		}
		
		/**
		 * The horizontal position in pixels of the center point of the prop
		 * relative to the room's coordinate space.
		 *  
		 * @return horizontal position in pixels
		 * @productversion Worlize APIv.2
		 */		
		public function get x():int {
			return _x;
		}
		
		/**
		 * The vertical position in pixels of the center point of the prop
		 * relative to the room's coordinate space.
		 *  
		 * @return vertical position in pixels.
		 * @productversion Worlize APIv.2 
		 */
		public function get y():int {
			return _y;
		}
		
		/**
		 * Move the prop to a different location in the room
		 *  
		 * @param x the horizontal position for the prop's center
		 * @param y the vertical position for the prop's center
		 * 
		 * @see #event:propMoved propMoved event
		 * 
		 * @productversion Worlize APIv.2
		 */		
		public function moveTo(x:int, y:int):void {
			var event:APIEvent = new APIEvent(APIEvent.MOVE_LOOSE_PROP);
			event.data = {
				id: _id,
				x: x,
				y: y
			};
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		/**
		 * Bring the prop forward in the stacking order.
		 * 
		 * <p>This does not immediately affect the stacking order, but rather
		 * sends a request to the server to update the stacking order.  The
		 * actual stacking order will be updated when the confirmation response
		 * is received from the server, and a
		 * <code>LoosePropEvent.PROP_LAYER_CHANGED</code> event will be
		 * dispatched.</p>
		 * 
		 * <p><code>bringToFront</code> uses this method internally, passing
		 * the largest possible integer <code>0x7FFFFFFF</code> as the
		 * layerCount parameter.</p>
		 *  
		 * @param layerCount how many layers to bring the prop forward
		 * 
		 * @see #event:propLayerChanged propLayerChanged event
		 * 
		 * @productversion Worlize APIv.2
		 */
		public function bringForward(layerCount:int):void {
			var event:APIEvent = new APIEvent(APIEvent.BRING_LOOSE_PROP_FORWARD);
			event.data = {
				id: _id,
				layerCount: layerCount
			};
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		/**
		 * Send the prop backward in the stacking order.
		 * 
		 * <p>This does not immediately affect the stacking order, but rather
		 * sends a request to the server to update the stacking order.  The
		 * actual stacking order will be updated when the confirmation response
		 * is received from the server, and a
		 * <code>LoosePropEvent.PROP_LAYER_CHANGED</code> event will be
		 * dispatched.</p>
		 * 
		 * <p><code>sendToBack</code> uses this method internally, passing
		 * the largest possible integer <code>0x7FFFFFFF</code> as the
		 * layerCount parameter.</p>
		 *  
		 * @param layerCount how many layers to send the prop backward
		 * 
		 * @see #event:propLayerChanged propLayerChanged event
		 * 
		 * @productversion Worlize APIv.2
		 */
		public function sendBackward(layerCount:int):void {
			var event:APIEvent = new APIEvent(APIEvent.SEND_LOOSE_PROP_BACKWARD);
			event.data = {
				id: _id,
				layerCount: layerCount
			};
			WorlizeAPI.sharedEvents.dispatchEvent(event); 
		}
		
		/**
		 * Bring the prop all the way forward in the stacking order.
		 * 
		 * <p>This does not immediately affect the stacking order, but rather
		 * sends a request to the server to update the stacking order.  The
		 * actual stacking order will be updated when the confirmation response
		 * is received from the server, and a
		 * <code>LoosePropEvent.PROP_LAYER_CHANGED</code> event will be
		 * dispatched.</p>
		 * 
		 * <p>Internally calls <code>sendForward()</code>, passing
		 * the largest possible integer <code>0x7FFFFFFF</code> as the
		 * layerCount parameter.</p>
		 * 
		 * @see #event:propLayerChanged propLayerChanged event
		 * 
		 * @productversion Worlize APIv.2
		 */
		public function bringToFront():void {
			bringForward(0x7FFFFFFF);
		}
		
		/**
		 * Send the prop all the way backward in the stacking order.
		 * 
		 * <p>This does not immediately affect the stacking order, but rather
		 * sends a request to the server to update the stacking order.  The
		 * actual stacking order will be updated when the confirmation response
		 * is received from the server, and a
		 * <code>LoosePropEvent.PROP_LAYER_CHANGED</code> event will be
		 * dispatched.</p>
		 * 
		 * <p>Internally calls <code>sendBackward()</code>, passing
		 * the largest possible integer <code>0x7FFFFFFF</code> as the
		 * layerCount parameter.</p>
		 *  
		 * @see #event:propLayerChanged propLayerChanged event
		 * 
		 * @productversion Worlize APIv.2
		 */
		public function sendToBack():void {
			sendBackward(0x7FFFFFFF);
		}
		
		/**
		 * Remove the loose prop from the room.
		 * 
		 * <p>This does not immediately remove the prop from the room, but
		 * rather sends the request to have the prop removed to the server.
		 * Once the server processes the request and broadcasts the update
		 * to all the connected clients, then the prop will be removed and a
		 * <code>LoosePropEvent.PROP_REMOVED</code> will be dispatched.</p> 
		 * 
		 * @see com.worlize.api.model.ThisRoom#event:propRemoved propRemoved
		 * event
		 * @see com.worlize.api.model.ThisRoom#addLooseProp()
	 	 * ThisRoom.addLooseProp()
	 	 * 
		 * @productversion Worlize APIv.2
		 */		
		public function remove():void {
			var event:APIEvent = new APIEvent(APIEvent.REMOVE_LOOSE_PROP);
			event.data = _id;
			WorlizeAPI.sharedEvents.dispatchEvent(event);
		}
		
		/**
		 * Constructor.
		 * 
		 * <p>Not meant to be instantiated manually, <code>LooseProp</code>
		 * instances are created internally by the Worlize API</p>
		 *
		 * @productversion Worlize APIv.2 
		 */		
		public function LooseProp() {
			super(null);
		}
		
		/**
		 * @private
		 */		
		override public function toString():String {
			return "[LooseProp id=" + _id + " propGuid=" + _prop.guid + "]";
		}
		
		/**
		 * @private
		 */		
		worlize_internal function updatePosition(x:int, y:int):void {
			_x = x;
			_y = y;
			var event:LoosePropEvent = new LoosePropEvent(LoosePropEvent.PROP_MOVED);
			event.looseProp = this;
			dispatchEvent(event);
		}
		
		/**
		 * @private
		 */		
		worlize_internal static function fromData(data:Object):LooseProp {
			var looseProp:LooseProp = new LooseProp();
			looseProp._id = data.id;
			looseProp._x = data.x;
			looseProp._y = data.y;
			looseProp._prop = Prop.fromData(data.prop);
			return looseProp;
		}
	}
}