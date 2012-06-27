package com.worlize.state
{
	import com.worlize.event.AuthorModeNotification;
	import com.worlize.event.NotificationCenter;
	import com.worlize.interactivity.model.Hotspot;
	import com.worlize.interactivity.model.IRoomItem;
	import com.worlize.model.AppInstance;
	import com.worlize.model.InWorldObjectInstance;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.events.FlexEvent;

	public class AuthorModeState extends EventDispatcher
	{
		private static var _instance:AuthorModeState;
		
		private var _selectedItem:Object;
		
		[Bindable]
		public var enabled:Boolean = false;
		
		[Bindable]
		public var editMode:Boolean = false;
		
		public function AuthorModeState() {
			if (_instance != null) {
				throw new Error("You can only have one instance of AuthorModeState");
			}
			NotificationCenter.addListener(AuthorModeNotification.AUTHOR_ENABLED, handleAuthorEnabled, false, 0x7FFFFFFF);
			NotificationCenter.addListener(AuthorModeNotification.AUTHOR_DISABLED, handleAuthorDisabled, false, 0x7FFFFFFF);
			NotificationCenter.addListener(AuthorModeNotification.EDIT_MODE_ENABLED, handleEditModeEnabled, false, 0x7FFFFFFF);
			NotificationCenter.addListener(AuthorModeNotification.EDIT_MODE_DISABLED, handleEditModeDisabled, false, 0x7FFFFFFF);
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
		
		public function disableEditMode():void {
			if (editMode) {
				var notification:AuthorModeNotification = new AuthorModeNotification(AuthorModeNotification.EDIT_MODE_DISABLED);
				notification.roomItem = _selectedItem as IRoomItem;
				NotificationCenter.postNotification(notification);
			}
		}
		
		public function enableEditMode():void {
			if (enabled) {
				// You can only enable edit mode if author mode is enabled
				if (_selectedItem && _selectedItem is AppInstance) {
					var notification:AuthorModeNotification = new AuthorModeNotification(AuthorModeNotification.EDIT_MODE_ENABLED);
					notification.roomItem = _selectedItem as AppInstance;
					NotificationCenter.postNotification(notification);
				}
			}
		}
		
		[Bindable(event="selectedItemChanged")]
		public function set selectedItem(newValue:Object):void {
			if (_selectedItem !== newValue) {
				disableEditMode();
				
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
		
		private function handleEditModeEnabled(notification:AuthorModeNotification):void {
			if (enabled) {
				if (_selectedItem && _selectedItem is AppInstance) {
					var app:AppInstance = _selectedItem as AppInstance;
					if (app.editModeSupported) {
						app.editModeEnabled = true;
						editMode = true;
						return;
					}
				}
			}
			notification.stopImmediatePropagation();
		}
		
		private function handleEditModeDisabled(notification:AuthorModeNotification):void {
			if (editMode) {
				var app:AppInstance = _selectedItem as AppInstance;
				app.editModeEnabled = false;
				editMode = false;
				return;
			}
			notification.stopImmediatePropagation();
		}
		
		private function handleAuthorEnabled(notification:AuthorModeNotification):void {
			enabled = true;
		}

		private function handleAuthorDisabled(notification:AuthorModeNotification):void {
			if (editMode) {
				disableEditMode();
			}
			enabled = false;
			selectedItem = null;
		}
	}
}