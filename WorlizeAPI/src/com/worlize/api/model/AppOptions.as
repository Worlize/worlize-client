package com.worlize.api.model
{
	public class AppOptions {
		public var fullSize:Boolean = false;
		public var nonVisual:Boolean = false;
		public var resizableByUser:Boolean = false;
		public var name:String = "My Great App";
		public var defaultWidth:int = 500;
		public var defaultHeight:int = 375;
		
		public function toJSON():Object {
			return {
				fullSize: fullSize,
				nonVisual: nonVisual,
				resizableByUser: resizableByUser,
				name: name,
				defaultHeight: defaultHeight,
				defaultWidth: defaultWidth
			};
		}
	}
}