package com.worlize
{
	import com.worlize.model.Room;
	import com.worlize.model.User;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class EmbeddedAPI extends EventDispatcher
	{
		private static var _instance:EmbeddedAPI;
		
		private var _room:Room;
		private var _currentUser:User;
		
		public function get room():Room {
			return _room;
		}
		
		public function get currentUser():User {
			return _currentUser;
		}
	
		public static function getInstance():EmbeddedAPI {
			if (_instance === null) {
				_instance = new EmbeddedAPI();
			}
			return _instance;
		}
		
		public function EmbeddedAPI(target:IEventDispatcher=null)
		{
			super(target);
			if (_instance !== null) {
				throw new Error("You may only create one EmbeddedAPI instance.");
			}
		}
	}
}