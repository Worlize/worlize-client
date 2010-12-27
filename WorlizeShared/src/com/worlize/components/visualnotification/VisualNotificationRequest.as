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
		
		internal var closing:Boolean = false;
		
		public function VisualNotificationRequest(text:String = null, title:String = null, callback:Function = null, duration:int = 6000)
		{
			this.title = title;
			this.text = text;
			this.clickCallback = callback;
			this.duration = duration;
		}
	}
}