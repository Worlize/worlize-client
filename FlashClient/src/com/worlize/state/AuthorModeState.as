package com.worlize.state
{
	import com.worlize.event.AuthorModeNotification;
	import com.worlize.event.NotificationCenter;
	import com.worlize.interactivity.model.Hotspot;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class AuthorModeState extends EventDispatcher
	{
		private static var _instance:AuthorModeState;
		
		private var _selectedItem:Object;
		
		[Bindable]
		public var enabled:Boolean = false;
		
		public function AuthorModeState() {
			if (_instance != null) {
				throw new Error("You can only have one instance of AuthorModeState");
			}
			NotificationCenter.addListener(AuthorModeNotification.AUTHOR_ENABLED, handleAuthorEnabled);
			NotificationCenter.addListener(AuthorModeNotification.AUTHOR_DISABLED, handleAuthorDisabled);
		}
		
		public static function getInstance():AuthorModeState {
			if (_instance === null) {
				_instance = new AuthorModeState();
			}
			return _instance;
		}
		
		public function enableAuthorMode():void {
			if (!enabled) {
				var notification:AuthorModeNotification = new AuthorModeNotification(AuthorModeNotification.AUTHOR_ENABLED);
				NotificationCenter.postNotification(notification);
			}
		}
		
		public function disableAuthorMode():void {
			if (enabled) {
				var notification:AuthorModeNotification = new AuthorModeNotification(AuthorModeNotification.AUTHOR_DISABLED);
				NotificationCenter.postNotification(notification);
			}
		}
		
		[Bindable(event="selectedItemChanged")]
		public function set selectedItem(newValue:Object):void {
			if (_selectedItem !== newValue) {
				var notification:AuthorModeNotification = new AuthorModeNotification(AuthorModeNotification.SELECTED_ITEM_CHANGED);
				notification.oldValue = _selectedItem;
				notification.newValue = newValue;
				
				_selectedItem = newValue;
				
				dispatchEvent(new Event('selectedItemChanged'));
				NotificationCenter.postNotification(notification);
			}
		}
		public function get selectedItem():Object {
			return _selectedItem;
		}
		
		
		private function handleAuthorEnabled(notification:AuthorModeNotification):void {
			enabled = true;
		}

		private function handleAuthorDisabled(notification:AuthorModeNotification):void {
			enabled = false;
			selectedItem = null;
		}
	}
}