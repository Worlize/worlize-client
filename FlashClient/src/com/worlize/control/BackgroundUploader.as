package com.worlize.control
{
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
			var imageFilter:FileFilter = new FileFilter("Image Files (*.jpg, *.jpeg, *.png, *.gif)", "*.jpg;*.jpeg;*.png;*.gif");
			fileTypeFilters = [imageFilter];
		}
		
		override protected function handleFileUploadComplete(event:DataEvent):void {
			super.handleFileUploadComplete(event);
			try {
				var response:Object = JSON.parse(event.data);
				if (response.success) {
					var data:Object = response.data;
					
//					var backgroundInstance:BackgroundImageInstance = BackgroundImageInstance.fromData(data);

					// We're now relying on the notification of a new instance
					// added to the locker to come from the interactivity server. 
					
//					var notification:BackgroundImageNotification = new BackgroundImageNotification(BackgroundImageNotification.BACKGROUND_INSTANCE_ADDED);
//					notification.backgroundInstance = backgroundInstance;
//					NotificationCenter.postNotification(notification);
				}
			}
			catch(e:Error) {
				// do nothing
			}
		}

	}
}