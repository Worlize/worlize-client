package com.worlize.event
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class NotificationCenter extends EventDispatcher
	{
		private static var _instance:NotificationCenter;
		
		public function NotificationCenter(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public static function getInstance():NotificationCenter {
			if (_instance === null) {
				_instance = new NotificationCenter;
			}
			return _instance;
		}
		
		public static function postNotification(notification:Event):void {
			getInstance().dispatchEvent(notification);
		}
		public static function addListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			getInstance().addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		public static function removeListener(type:String, listener:Function=null, useCapture:Boolean=false):void {
			getInstance().removeEventListener(type, listener, useCapture);
		}
	}
}