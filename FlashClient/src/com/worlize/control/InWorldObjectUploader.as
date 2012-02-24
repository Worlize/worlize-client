package com.worlize.control
{
	import com.worlize.event.NotificationCenter;
	import com.worlize.model.InWorldObjectInstance;
	import com.worlize.notification.InWorldObjectNotification;
	
	import flash.events.DataEvent;
	import flash.events.IEventDispatcher;
	import flash.net.FileFilter;
	
	public class InWorldObjectUploader extends Uploader
	{
		public function InWorldObjectUploader(target:IEventDispatcher=null)
		{
			super(target);
			url = "/locker/in_world_objects";
			var imageFilter:FileFilter = new FileFilter("Image Files (*.jpg, *.jpeg, *.png, *.gif)", "*.jpg;*.jpeg;*.png;*.gif");
			var flashFilter:FileFilter = new FileFilter("Flash Movie (*.swf)", "*.swf");
			fileTypeFilters = [imageFilter,flashFilter];
		}
		
		override protected function handleFileUploadComplete(event:DataEvent):void {
			super.handleFileUploadComplete(event);
			try {
				var response:Object = JSON.parse(event.data);
				if (response.success) {
					var data:Object = response.data;
					
					// The server now notifies us of any object instances added
					// to the locker via the interactivity server.
				}
			}
			catch(e:Error) {
				// do nothing
			}
		}
	}
}