package com.worlize.view.components
{
	import com.worlize.view.skins.NotificationBadgeLinkButtonSkin;
	
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.Button;
	
	[Style(name="backgroundColor", type="uint", format="Color", inherit="no", theme="spark")]
	[Style(name="backgroundOverColor", type="uint", format="Color", inherit="no", theme="spark")]
	[Style(name="backgroundDownColor", type="uint", format="Color", inherit="no", theme="spark")]
	
	[Style(name="badgeBackgroundColor", type="uint", format="Color", inherit="no", theme="spark")]
	[Style(name="badgeBackgroundOverColor", type="uint", format="Color", inherit="no", theme="spark")]
	[Style(name="badgeBackgroundDownColor", type="uint", format="Color", inherit="no", theme="spark")]
	[Style(name="badgeBackgroundDisabledColor", type="uint", format="Color", inherit="no", theme="spark")]
	[Style(name="badgeTextColor", type="uint", format="Color", inherit="no", theme="spark")]
	[Style(name="badgeTextOverColor", type="uint", format="Color", inherit="no", theme="spark")]
	[Style(name="badgeTextDownColor", type="uint", format="Color", inherit="no", theme="spark")]
	[Style(name="badgeTextDisabledColor", type="uint", format="Color", inherit="no", theme="spark")]
	[Style(name="badgeBorderRadius", type="uint", format="Number", inherit="no", theme="spark")]
	[Style(name="icon", type="Class", inherit="no", theme="spark")]
	
	public class NotificationBadgeLinkButton extends Button
	{
		
		
		private var _badgeNumber:int = 0;
		private var _showBadgeIfZero:Boolean = false;
		
		[Bindable(event='showBadgeChanged')]
		public function set showBadgeIfZero(newValue:Boolean):void {
			if (_showBadgeIfZero !== newValue) {
				_showBadgeIfZero = newValue;
				dispatchEvent(new FlexEvent('showBadgeChanged'));
			}
		}
		public function get showBadgeIfZero():Boolean {
			return _showBadgeIfZero;
		}
		
		[Bindable(event='showBadgeChanged')]
		public function get showBadge():Boolean {
			if (_showBadgeIfZero || _badgeNumber > 0) {
				return true;
			}
			return false;
		}
		
		[Bindable(event='badgeNumberChanged')]
		public function set badgeNumber(newValue:int):void {
			if (_badgeNumber !== newValue) {
				var oldBadgeNumber:int = _badgeNumber;
				_badgeNumber = newValue;
				dispatchEvent(new FlexEvent('badgeNumberChanged'));
				if (oldBadgeNumber === 0 || _badgeNumber === 0) {
					dispatchEvent(new FlexEvent('showBadgeChanged'));
				}
			}
		}
		public function get badgeNumber():int {
			return _badgeNumber;
		}
		
		private static var classConstructed:Boolean = classConstruct();
		
		private static function classConstruct():Boolean {
			if (!FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("NotificationBadgeLinkButton"))
			{
				var myStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
				myStyles.defaultFactory = function():void {
					this.badgeBackgroundColor = 0xAA0000;
					this.badgeBackgroundOverColor = 0xAA0000;
					this.badgeBackgroundDownColor = 0xAA0000;
					this.badgeBackgroundDisabledColor = 0xAA0000;
					this.badgeTextColor = 0xFFFFFF;
					this.badgeTextOverColor = 0xFFFFFF;
					this.badgeTextDownColor = 0xFFFFFF;
					this.badgeTextDisabledColor = 0xFFFFFF;
					this.skinClass = Class(NotificationBadgeLinkButtonSkin);
					this.icon = null;
				};
				FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("NotificationBadgeLinkButton", myStyles, true);
			}
			return true;
		}
		
		public function NotificationBadgeLinkButton()
		{
			super();
			setStyle('skinClass', NotificationBadgeLinkButtonSkin);
			buttonMode = true;
		}
		
		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			buttonMode = value;
		}
		
		override protected function getCurrentSkinState():String
		{
			var state:String = super.getCurrentSkinState();
			if (showBadge) {
				state += "WithBadge";
			}
			if (state.toLowerCase().indexOf('selected') != -1) {
				buttonMode=false;
			}
			else {
				buttonMode=true;
			}
			return state;
		}
	}
}