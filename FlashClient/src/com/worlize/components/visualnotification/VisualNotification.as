package com.worlize.components.visualnotification
{
	import flash.utils.Timer;

	public class VisualNotification
	{
		[Bindable]
		public var title:String;
		
		[Bindable]
		public var text:String;
		
		public var clickCallback:Function;
		
		public var duration:int;
		
		public var titleFlashText:String;
		
		public var titleFlashCount:uint = 0xFFFFFFFF;
		
		public var onlyWhenInactive:Boolean = false;
		
		public var onlyUseNative:Boolean = false;
		
		public var useNativeWhenFocused:Boolean = false;
		
		public var nativeNotificationId:int = -1;
		
		internal var timer:Timer;
		
		internal var closing:Boolean = false;
		
		public function VisualNotification(text:String = null,
										   title:String = null,
										   titleFlashText:String = null,
										   titleFlashCount:uint = 0xFFFFFFFF,
										   onlyWhenInactive:Boolean = false,
										   callback:Function = null,
										   duration:int = 6000)
		{
			this.title = title;
			this.text = text;
			this.titleFlashText = titleFlashText;
			this.titleFlashCount = titleFlashCount;
			this.onlyWhenInactive = onlyWhenInactive;
			this.clickCallback = callback;
			this.duration = duration;
		}
		
		public function show():void {
			VisualNotificationManager.getInstance().showNotification(this);
		}
	}
}