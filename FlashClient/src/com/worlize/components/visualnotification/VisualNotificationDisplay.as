package com.worlize.components.visualnotification
{
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import spark.components.Button;
	import spark.components.supportClasses.ButtonBase;
	import spark.components.supportClasses.TextBase;

	[Style(name="fillColor", type="uint", format="Color", inherit="yes", theme="spark")]
	[Style(name="outlineColor", type="uint", format="Color", inherit="yes", theme="spark")]
	[Style(name="titleColor", type="uint", format="Color", inherit="yes", theme="spark")]
	public class VisualNotificationDisplay extends Button
	{
		public function VisualNotificationDisplay()
		{
			super();
			addEventListener(MouseEvent.CLICK, handleClick);
		}
		
		[SkinPart(required="true")]
		public var titleTextDisplay:TextBase;
		
		[SkinPart(required="true")]
		public var textDisplay:TextBase;
		
		[SkinPart(required="false")]
		public var closeButton:ButtonBase;
		
		private var _notification:VisualNotification;
		
		[Bindable(event="notificationChange")]
		public function set notification(newValue:VisualNotification):void {
			if (_notification !== newValue) {
				_notification = newValue;
				dispatchEvent(new FlexEvent("notificationChange"));
			}
		}
		public function get notification():VisualNotification {
			return _notification;
		}
		
		private function handleClick(event:MouseEvent):void {
			if (_notification.clickCallback !== null) {
				_notification.clickCallback();
			}
		}
	}
}