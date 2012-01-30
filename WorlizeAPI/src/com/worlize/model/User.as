package com.worlize.model
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	[Event(name="outgoingChat",type="com.worlize.event.ChatEvent")]
	public class User extends EventDispatcher
	{
		protected var _name:String;
		protected var _guid:String;
		protected var _x:int;
		protected var _y:int;
		protected var _face:int;
		protected var _color:int;
		protected var _avatarGuid:String;
		
		public function get name():String {
			return _name;
		}
		
		public function get guid():String {
			return _guid;
		}
		
		public function get x():int {
			return _x;
		}
		
		public function set x(newValue:int):void {
			// TODO: Implement
		}
		
		public function get y():int {
			return _y;
		}
		
		public function set y(newValue:int):void {
			// TODO: Implement
		}
		
		public function get face():int {
			return _face;
		}
		
		public function set face(newValue:int):void {
			// TODO: Implement
		}
		
		public function get color():int {
			return _color;
		}
		
		public function set color(newValue:int):void {
			// TODO: Implement
		}
		
		public function User(target:IEventDispatcher=null)
		{
			super(target);
		}
	}
}