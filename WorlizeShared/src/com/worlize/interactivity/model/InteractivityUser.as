package com.worlize.interactivity.model
{
	import com.worlize.model.SimpleAvatar;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import com.worlize.interactivity.rpc.InteractivityClient;
	import com.worlize.interactivity.view.JellyImages;

	[Bindable]
	public class InteractivityUser extends EventDispatcher
	{
		public var isSelf:Boolean = false;
		public var id:String;
		public var name:String = "Uninitialized User";
		public var x:int;
		public var y:int;
		private var _face:int = 1;
		public var faceImage:Class = JellyImages.map[0];
		public var color:int = 2;
		public var simpleAvatar:SimpleAvatar;
		
		
		public var showFace:Boolean = true;
		
		[Bindable(event="faceChanged")]
		public function set face(newValue:int):void {
			if (newValue > 12) {
				newValue = 0;
			}
			newValue = Math.max(0, newValue);
			if (_face != newValue) {
				_face = newValue;
				faceImage = JellyImages.map[_face];
				dispatchEvent(new Event("faceChanged"));
			}
		}
		public function get face():int {
			return _face;
		}
		
		
		public function InteractivityUser() {
			
		}
		
		public function naked():void {
			
		}
		
	}
}