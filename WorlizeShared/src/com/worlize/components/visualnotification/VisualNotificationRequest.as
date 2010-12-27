package com.worlize.components.visualnotification
{
	import flash.utils.Timer;

	public class VisualNotificationRequest
	{
		[Bindable]
		public var title:String;
		
		[Bindable]
		public var text:String;
		
		public var clickCallback:Function;
		
		public var duration:int;
		
		internal var timer:Timer;
		
		public function VisualNotificationRequest(text:String, title:String = null, callback:Function = null, duration:int = 5000)
		{
			this.title = title;
			this.text = text;
			this.clickCallback = callback;
			this.duration = duration;
		}
	}
}