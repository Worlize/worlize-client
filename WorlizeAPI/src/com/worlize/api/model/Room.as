package com.worlize.api.model
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.worlize_internal;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class Room extends EventDispatcher
	{
		use namespace worlize_internal;
		
		protected var _name:String;
		protected var _guid:String;
		
		public function Room() {
			super(null);
		}

		public function get name():String {
			return _name;
		}
		
		public function get guid():String {
			return _guid;
		}
		
		public function toJSON():Object {
			return {
				name: _name,
				guid: _guid
			};
		}
		
		override public function toString():String {
			return "[Room guid=" + _guid + " name=" + _name + "]";
		}
		
		worlize_internal static function fromData(data:Object):Room {
			var room:Room = new Room();
			room._guid = data.guid;
			room._name = data.name;
			return room;
		}
	}
}