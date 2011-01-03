package com.worlize.model.tutorial
{
	import mx.controls.Image;
	
	public class TutorialSlideDefinition
	{
		public var imageURL:String;
		
		[Bindable]
		public var text:String;
		
		public static function fromData(data:Object):TutorialSlideDefinition {
			var instance:TutorialSlideDefinition = new TutorialSlideDefinition();
			instance.imageURL = data.image_url;
			instance.text = data.text;
			return instance;
		}
	}
}