package com.worlize.control
{
	import com.adobe.serialization.json.JSON;
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
			fileTypeFilter = new FileFilter("Image Files (*.jpg, *.jpeg, *.png, *.gif)", "*.jpg;*.jpeg;*.png;*.gif");
		}
		
		override protected function handleFileUploadComplete(event:DataEvent):void {
			super.handleFileUploadComplete(event);
			try {
				var response:Object = JSON.decode(event.data);
				if (response.success) {
					var data:Object = response.data;
					
					var inWorldObjectInstance:InWorldObjectInstance = InWorldObjectInstance.fromData(data);
					
					var notification:InWorldObjectNotification = new InWorldObjectNotification(InWorldObjectNotification.IN_WORLD_OBJECT_UPLOADED);
					notification.inWorldObjectInstance = inWorldObjectInstance;
					NotificationCenter.postNotification(notification);
				}
			}
			catch(e:Error) {
				// do nothing
			}
		}
	}
}