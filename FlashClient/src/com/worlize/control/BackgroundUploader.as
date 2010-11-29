package com.worlize.control
{
	import com.adobe.serialization.json.JSON;
	import com.worlize.event.NotificationCenter;
	import com.worlize.model.BackgroundImageInstance;
	import com.worlize.notification.BackgroundImageNotification;
	
	import flash.events.DataEvent;
	import flash.events.IEventDispatcher;
	import flash.net.FileFilter;
	
	public class BackgroundUploader extends Uploader
	{
		public function BackgroundUploader(target:IEventDispatcher=null)
		{
			super(target);
			url = "/locker/backgrounds";
			fileTypeFilter = new FileFilter("Image Files (*.jpg, *.jpeg, *.png, *.gif)", "*.jpg;*.jpeg;*.png;*.gif");
		}
		
		override protected function handleFileUploadComplete(event:DataEvent):void {
			super.handleFileUploadComplete(event);
			try {
				var response:Object = JSON.decode(event.data);
				if (response.success) {
					var data:Object = response.data;
					
					var backgroundInstance:BackgroundImageInstance = BackgroundImageInstance.fromData(data);
					
					var notification:BackgroundImageNotification = new BackgroundImageNotification(BackgroundImageNotification.BACKGROUND_UPLOADED);
					notification.backgroundInstance = backgroundInstance;
					NotificationCenter.postNotification(notification);
				}
			}
			catch(e:Error) {
				// do nothing
			}
		}

	}
}