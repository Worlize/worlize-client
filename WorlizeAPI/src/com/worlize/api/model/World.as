package com.worlize.api.model
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.worlize_internal;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * Represents a Worlize world.
	 * 
	 * @author Brian McKelvey
	 * @productversion Worlize APIv.1
	 */	
	public class World extends EventDispatcher
	{
		use namespace worlize_internal;
		
		/**
		 *	@private 
		 */
		protected var _guid:String;
		
		/**
		 *	@private 
		 */
		protected var _name:String;
		
		/**
		 * Constructor. 
		 */		
		public function World() {
			super(null);
		}
		
		/**
		 * The Gloabally Unique Identifier for the world.
		 * 
		 * @return the world's GUID 
		 * @productversion Worlize APIv.1
		 * @see http://en.wikipedia.org/wiki/GUID GUID on Wikipedia
		 */		
		public function get guid():String {
			return _guid;
		}
		
		/**
		 * The world's name.
		 *  
		 * @return the world's name
		 * @productversion Worlize APIv.1
		 */		
		public function get name():String {
			return _name;
		}
		
		/**
		 *	@private 
		 */
		worlize_internal static function fromData(data:Object):World {
			var world:World = new World();
			world._name = data.name;
			world._guid = data.guid;
			return world;
		}
	}
}