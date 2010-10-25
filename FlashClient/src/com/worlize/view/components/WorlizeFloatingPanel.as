package com.worlize.view.components
{
	import flash.display.Stage;
	
	import mx.core.FlexGlobals;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.TitleWindow;
	
	[Style(name="titleBarColor", type="uint", format="Color", inherit="no", theme="spark")]
	[Style(name="titleTextColor", type="uint", format="Color", inherit="no", theme="spark")]
	[Style(name="titleBarHeight", type="uint", inherit="no", theme="spark")]
	[Style(name="windowIcon", type="Class", inherit="no", theme="spark")]
	[Style(name="showCloseButton", type="Boolean", theme="spark")]
	
	public class WorlizeFloatingPanel extends TitleWindow
	{
		public function WorlizeFloatingPanel()
		{
			super();
		}
		
		[Bindable]
		public var resizable:Boolean = false;
		
		private static var classConstructed:Boolean = classConstruct();
		
		private static function classConstruct():Boolean {
			if (!FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("WorlizeFloatingPanel"))
			{
				var myStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
				myStyles.defaultFactory = function():void {
					this.titleBarColor = 0xCCCCCC;
					this.titleTextColor = 0x888888;
					this.titleBarHeight = 12;
				};
				FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("WorlizeFloatingPanel", myStyles, true);
			}
			return true;
		}
		
		public function boundsAreValid(x:int, y:int, width:int, height:int):Boolean {
			var stage:Stage = systemManager.getSandboxRoot().stage;
			if (x < 0 || y < 0 ||
				x + width > stage.stageWidth ||
				y + height > stage.stageHeight) {
				return false;
			}
			return true;
		}
		
	}
}