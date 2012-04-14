package com.worlize.control
{
	import flash.events.DataEvent;
	import flash.events.IEventDispatcher;
	import flash.net.FileFilter;
	
	import mx.controls.Alert;
	
	public class PropUploader extends Uploader
	{
		public function PropUploader(target:IEventDispatcher=null)
		{
			super(target);
			url = "/locker/props";
			var imageFilter:FileFilter = new FileFilter("Image Files (*.jpg, *.jpeg, *.png, *.gif)", "*.jpg;*.jpeg;*.png;*.gif");
			fileTypeFilters = [imageFilter];
			checkAnimatedGifs = true;
		}
		
		override protected function handleFileUploadComplete(event:DataEvent):void {
			try {
				var response:Object = JSON.parse(event.data);
				if (response.success) {
					var data:Object = response.data;
					// We're notified of the new avatar via a message sent
					// through the interactivity server...
				}
				else {
					Alert.show("We weren't able to process the file you uploaded.", "Oops!");
				}
			}
			catch(e:Error) {
				// do nothing
			}
		}
	}
}