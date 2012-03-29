package com.worlize.api.model
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.worlize_internal;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * Represents a Worlize Room.
	 *  
	 * @author Brian McKelvey
	 * @productversion Worlize APIv.1
	 */	
	public class Room extends EventDispatcher
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
		protected var _ownerGuid:String;
		
		/**
		 * @private 
		 */		
		protected var _locked:Boolean;
		
		/**
		 * Constructor. 
		 * 
		 * @productversion Worlize APIv.1
		 */		
		public function Room() {
			super(null);
		}

		/**
		 * The room's name.
		 *  
		 * @return the room's name
		 * @productversion Worlize APIv.1
		 */		
		public function get name():String {
			return _name;
		}
		
		/**
		 * The room's Global Unique Identifier
		 *  
		 * @return the room's GUID
		 * @productversion Worlize APIv.1
		 * @see http://en.wikipedia.org/wiki/GUID GUID on Wikipedia
		 */		
		public function get guid():String {
			return _guid;
		}
		
		/**
		 * The User GUID of the room's owner
		 *  
		 * @return a user GUID
		 * @productversion Worlize APIv.1
		 */		
		public function get ownerGuid():String {
			return _ownerGuid;
		}
		
		/**
		 * True if the room is locked
		 * 
		 * @return whether the room is locked 
		 * @productversion Worlize APIv.1
		 */		
		public function get locked():Boolean {
			return _locked;
		}
		
		/**
		 * @private
		 */		
		public function toJSON():Object {
			return {
				name: _name,
				guid: _guid,
				ownerGuid: _ownerGuid
			};
		}
		
		/**
		 * @private
		 */				
		override public function toString():String {
			return "[Room guid=" + _guid + " name=" + _name + "]";
		}
		
		/**
		 * Takes raw room data as an untyped Object and returns a <code>Room</code>
		 * instance.
		 * 
		 * @private 
		 * @param data
		 * @return A Room object.
		 */		
		worlize_internal static function fromData(data:Object):Room {
			var room:Room = new Room();
			room._guid = data.guid;
			room._name = data.name;
			room._locked = data.locked;
			room._ownerGuid = data.ownerGuid;
			return room;
		}
	}
}