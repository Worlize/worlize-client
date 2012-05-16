package com.worlize.control
{
	import com.worlize.event.NotificationCenter;
	import com.worlize.model.CurrentUser;
	import com.worlize.model.InWorldObjectInstance;
	import com.worlize.notification.InWorldObjectNotification;
	
	import flash.events.DataEvent;
	import flash.events.IEventDispatcher;
	import flash.net.FileFilter;
	
	import mx.controls.Alert;
	
	public class AppUploader extends Uploader
	{
		public function AppUploader(target:IEventDispatcher=null)
		{
			super(target);
			url = "/locker/apps";
			var filters:Array = [];
			filters.push(new FileFilter("Worlize App (*.swf)", "*.swf"));
			fileTypeFilters = filters;
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
				else {
					Alert.show(response.description, "Unable to upload app");
				}
			}
			catch(e:Error) {
				// do nothing
			}
		}
	}
}