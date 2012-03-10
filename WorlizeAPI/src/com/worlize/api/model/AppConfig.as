package com.worlize.api.model
{
	public class AppConfig {
		public var fullSize:Boolean = false;
		public var nonVisual:Boolean = false;
		public var resizableByUser:Boolean = false;
		
		public function toJSON():Object {
			return {
				fullSize: fullSize,
				nonVisual: nonVisual,
				resizableByUser: resizableByUser
			};
		}
	}
}