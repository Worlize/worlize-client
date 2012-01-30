package com.worlize.model
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	[Event(name="incomingChat",type="com.worlize.event.ChatEvent")]
	[Event(name="userEnter",type="com.worlize.event.RoomEvent")]
	[Event(name="userLeave",type="com.worlize.event.RoomEvent")]
	public class Room extends EventDispatcher
	{
		private var _users:Vector.<User>;
		private var _name:String;
		private var _guid:String;
		private var _dimLevel:uint;
		
		public function get users():Vector.<User> {
			return _users;
		}
		
		public function get name():String {
			return _name;
		}
		
		public function get guid():String {
			return _guid;
		}
		
		public function get dimLevel():uint {
			return _dimLevel;
		}
		
		public function set dimLevel(newValue:uint):void {
			// TODO: Implement
		}		
		
		public function Room(target:IEventDispatcher=null)
		{
			super(target);
		}
	}
}