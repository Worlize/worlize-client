package com.worlize.api.model
{
	import com.worlize.worlize_internal;

	public class APIOptions {
		use namespace worlize_internal;
		
		worlize_internal var sizeUnknown:Boolean = true;
		public var fullSize:Boolean = false;
		public var nonVisual:Boolean = false;
		public var resizableByUser:Boolean = false;
		public var editModeSupported:Boolean = false;
		public var name:String = "Untitled App";
		private var _defaultWidth:int = 500;
		private var _defaultHeight:int = 375;
		
		public function set defaultWidth(newValue:int):void {
			_defaultWidth = newValue;
			sizeUnknown = false;
		}
		public function get defaultWidth():int {
			return _defaultWidth;
		}
		
		public function set defaultHeight(newValue:int):void {
			_defaultHeight = newValue;
			sizeUnknown = false;
		}
		public function get defaultHeight():int {
			return _defaultHeight;
		}
		
		public function toJSON():Object {
			return {
				fullSize: fullSize,
				nonVisual: nonVisual,
				resizableByUser: resizableByUser,
				editModeSupported: editModeSupported,
				name: name,
				defaultHeight: _defaultHeight,
				defaultWidth: _defaultWidth,
				sizeUnknown: sizeUnknown
			};
		}
	}
}