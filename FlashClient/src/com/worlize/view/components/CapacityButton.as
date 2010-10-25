package com.worlize.view.components
{
	import flash.events.Event;
	
	import spark.components.Button;
	import spark.components.supportClasses.TextBase;
	
	[Style(name="fillColor", type="uint", format="Color", inherit="yes", theme="spark")]
	public class CapacityButton extends Button
	{
		
		[SkinPart(required="false")]
		
		/**
		 *  A skin part that defines the label of line1 of the button. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var line1Display:TextBase;
		
		[SkinPart(required="false")]
		
		/**
		 *  A skin part that defines the label of line2 of the button. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var line2Display:TextBase;
		
		private var _line1:String = "";
		private var _line2:String = "";

		[Bindable(event="line1Changed")]
		public function set line1(newValue:String):void {
			if (newValue !== _line1) {
				_line1 = newValue;
				if (line1Display) {
					line1Display.text = _line1;
				}
				dispatchEvent(new Event('line1Changed'));
			}
		}
		public function get line1():String {
			return _line1;
		}
		
		[Bindable(event="line2Changed")]
		public function set line2(newValue:String):void {
			if (newValue !== _line2) {
				_line2 = newValue;
				if (line2Display) {
					line2Display.text = _line2;
				}
				dispatchEvent(new Event('line2Changed'));
			}
		}
		public function get line2():String {
			return _line2;
		}
		
		public function CapacityButton()
		{
			super();
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == line1Display) {
				if (_line1 !== null)
					line1Display.text = _line1;
			}
			
			if (instance == line2Display) {
				if (_line2 !== null) {
					line2Display.text = _line2;
				}
			}
		}
		
	}
}