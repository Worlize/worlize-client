package com.worlize.control
{
	import com.worlize.event.NotificationCenter;
	import com.worlize.model.AvatarInstance;
	import com.worlize.model.SimpleAvatar;
	import com.worlize.notification.AvatarNotification;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import mx.controls.Alert;
	import mx.events.StateChangeEvent;
	
	import com.worlize.interactivity.view.Avatar;
	
	[Event(type="mx.events.StateChangeEvent",name="currentStateChange")]
	public class AvatarUploader extends Uploader
	{
		public function AvatarUploader(target:IEventDispatcher=null)
		{
			super(target);
			url = "/locker/avatars";
			var imageFilter:FileFilter = new FileFilter("Image Files (*.jpg, *.jpeg, *.png, *.gif)", "*.jpg;*.jpeg;*.png;*.gif");
			fileTypeFilters = [imageFilter];
		}
		
		override protected function handleFileUploadComplete(event:DataEvent):void {
			try {
				var response:Object = JSON.parse(event.data);
				if (response.success) {
					var data:Object = response.data;
					// We're notified of the new avatar via a message sent
					// through the interactivity server...
				}
			}
			catch(e:Error) {
				// do nothing
			}
		}
	}
}