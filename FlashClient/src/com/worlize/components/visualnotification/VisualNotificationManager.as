package com.worlize.components.visualnotification
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	[Event(name="showNotification",type="com.worlize.components.visualnotification.VisualNotificationEvent")]
	[Event(name="hideNotification",type="com.worlize.components.visualnotification.VisualNotificationEvent")]
	public class VisualNotificationManager extends EventDispatcher
	{
		private static var instance:VisualNotificationManager;
		
		private var activeNotifications:Array = [];
		
		public static function getInstance():VisualNotificationManager {
			if (instance === null) {
				instance = new VisualNotificationManager();
			}
			return instance;
		}
		
		function VisualNotificationManager(target:IEventDispatcher=null) {
			super(target);
			if (instance) {
				throw new Error("You may only create one instance of VisualNotificationManager");
			}
		}
		
		public function showNotification(notification:VisualNotification):void {
			activeNotifications.push(notification);
			notification.timer = new Timer(notification.duration, 1);
			notification.timer.addEventListener(TimerEvent.TIMER, function(event:TimerEvent):void {
				closeNotification(notification);
			});
			notification.timer.start();
			
			// Default to close the notification when clicked
			var originalClickCallback:Function = notification.clickCallback;
			notification.clickCallback = function():void {
				closeNotification(notification);
				if (originalClickCallback !== null) {
					originalClickCallback();
				}
			};
			
			var showEvent:VisualNotificationEvent = new VisualNotificationEvent(VisualNotificationEvent.SHOW_NOTIFICATION);
			showEvent.notification = notification;
			dispatchEvent(showEvent);
		}
		
		public function closeNotification(notification:VisualNotification):void {
			if (notification.closing) { return; }
			notification.closing = true;
			notification.timer.stop();
			var hideEvent:VisualNotificationEvent = new VisualNotificationEvent(VisualNotificationEvent.HIDE_NOTIFICATION);
			hideEvent.notification = notification;
			dispatchEvent(hideEvent);
			var index:int = activeNotifications.indexOf(notification);
			activeNotifications.splice(index, 1);	
		}
	}
}