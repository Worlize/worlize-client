package com.worlize.components.visualnotification
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	
	[Event(name="showNotification",type="com.worlize.components.visualnotification.VisualNotificationEvent")]
	[Event(name="hideNotification",type="com.worlize.components.visualnotification.VisualNotificationEvent")]
	public class VisualNotificationManager extends EventDispatcher
	{
		private static var instance:VisualNotificationManager;
		
		private var activeNotifications:Array = [];
		
		public function get nativeSupported():Boolean {
			return Boolean(ExternalInterface.call("NotificationManager.isSupported"));
		}
		
		public function get nativeHasPermission():Boolean {
			return Boolean(ExternalInterface.call("NotificationManager.hasPermission"));
		}
		
		public function get appIsFocused():Boolean {
			return Boolean(ExternalInterface.call("checkIsFocused"));
		}
		
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
			if (nativeSupported && !nativeHasPermission) {
				ExternalInterface.call("NotificationManager.displayPermissionRequestDialog");
			}
		}
		
		
		public function showNotification(notification:VisualNotification):void {
			if (notification.onlyWhenInactive && appIsFocused) {
				trace("Skipping notification because the app is focused and the notification indicates that it should only show when the app is inactive.");
				return;
			}
			
			// Only show the notification if it has text to display
			if (notification.title) {
				if (nativeSupported && nativeHasPermission && (notification.useNativeWhenFocused || !appIsFocused)) {
					showNativeNotification(notification);
				}
				else if (!notification.onlyUseNative) {
					showInAppNotification(notification);
				}
			}
			
			// Blink the titlebar if we're not focused
			if (notification.titleFlashText && notification.titleFlashText.length > 0) {
				ExternalInterface.call('flashTitle', notification.titleFlashText, notification.titleFlashCount);
			}
		}
		
		private function showNativeNotification(notification:VisualNotification):void {
			notification.nativeNotificationId = ExternalInterface.call(
				"NotificationManager.displayNotification",
				{
					notificationType: "simple",
					title: notification.title,
					content: notification.text
				}
			);
		}
		
		private function showInAppNotification(notification:VisualNotification):void {
		
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
			if (notification.nativeNotificationId !== -1) {
				ExternalInterface.call(
					"NotificationManager.clearNotification",
					notification.nativeNotificationId
				);
				return;
			}
			notification.closing = true;
			notification.timer.stop();
			var hideEvent:VisualNotificationEvent = new VisualNotificationEvent(VisualNotificationEvent.HIDE_NOTIFICATION);
			hideEvent.notification = notification;
			dispatchEvent(hideEvent);
			var index:int = activeNotifications.indexOf(notification);
			activeNotifications.splice(index, 1);
			
//			if (notification.titleFlashText) {
//				ExternalInterface.call('cancelFlashTitle', notification.titleFlashText);
//			}
		}
	}
}