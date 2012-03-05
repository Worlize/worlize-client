package com.worlize.api.model
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.worlize_internal;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class World extends EventDispatcher
	{
		use namespace worlize_internal;
		
		worlize_internal var api:WorlizeAPI;
		
		protected var _guid:String;
		protected var _name:String;
		
		public function World() {
			super(null);
		}
		
		public function get guid():String {
			return _guid;
		}
		
		public function get name():String {
			return _name;
		}
		
		worlize_internal static function fromData(data:Object):World {
			var world:World = new World();
			world._name = data.name;
			world._guid = data.guid;
			return world;
		}
	}
}