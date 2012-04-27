package com.worlize.view.components
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.TitleWindow;
	
	[Style(name="titleBarColor", type="uint", format="Color", inherit="no", theme="spark")]
	[Style(name="titleTextColor", type="uint", format="Color", inherit="no", theme="spark")]
	[Style(name="titleBarHeight", type="uint", inherit="no", theme="spark")]
	[Style(name="windowIcon", type="Class", inherit="no", theme="spark")]
	
	public class WorlizeWindow extends TitleWindow
	{
		public function WorlizeWindow()
		{
			super();
		}
		
		override protected function initializationComplete():void {
			super.initializationComplete();
			addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
		}
		
		protected function handleKeyDown(event:KeyboardEvent):void {
			if (event.keyCode === Keyboard.ESCAPE) {
				var closeEvent:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
				dispatchEvent(closeEvent);
			}	
		}
		
		[Bindable]
		public var resizable:Boolean = true;
		
		private static var classConstructed:Boolean = classConstruct();
		
		private static function classConstruct():Boolean {
			if (!FlexGlobals.topLevelApplication.styleManager.getStyleDeclaration("WorlizeWindow"))
			{
				var myStyles:CSSStyleDeclaration = new CSSStyleDeclaration();
				myStyles.defaultFactory = function():void {
					this.titleBarColor = 0xCCCCCC;
					this.titleTextColor = 0x888888;
					this.titleBarHeight = 12;
				};
				FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration("WorlizeWindow", myStyles, true);
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