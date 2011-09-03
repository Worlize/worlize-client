package com.worlize.interactivity.event
{
	import flash.events.Event;
	
	public class WebcamBroadcastEvent extends Event
	{
		public static const BROADCAST_START:String = "broadcastStart";
		public static const BROADCAST_STOP:String = "broadcastStop";
		public static const CAMERA_PERMISSION_REVOKED:String = "cameraPermissionRevoked";
		
		public function WebcamBroadcastEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}