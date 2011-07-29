package com.worlize.interactivity.model
{
	import com.worlize.interactivity.rpc.InteractivityClient;
	import com.worlize.interactivity.view.JellyImages;
	import com.worlize.model.SimpleAvatar;
	import com.worlize.model.VideoAvatar;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import mx.collections.ArrayCollection;

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
		public var videoAvatar:VideoAvatar;
		public var showFace:Boolean = true;
		
		private var netStream:NetStream;
		public var video:Video;
		private var camera:Camera;
		
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
		
		public function naked():void {
			
		}
		
		public function broadcastCamera(netConnection:NetConnection):void {
			camera = Camera.getCamera();
			camera.setQuality(16*1024, 0);
			camera.setMode(160, 120, 24, false);
			
			netStream = new NetStream(netConnection);
			netStream.attachCamera(camera);
			netStream.bufferTime = 0;
			
			netStream.addEventListener(NetStatusEvent.NET_STATUS, handleNetStreamNetStatus);
			
			netStream.publish(id, 'live');
		}
		
		public function stopBroadcastingCamera():void {
			if (netStream) {
				netStream.close();
				camera = null;
				netStream = null;
			}
		}
		
		private function handleNetStreamNetStatus(event:NetStatusEvent):void {
			trace("InteractivityUser NetStream: " + event.info.code + " (" + event.info.description + ")");
			if (event.info.code === 'NetStream.Publish.Start') {
				dispatchEvent(new Event('cameraPublishSuccess'));
			}
		}
		
	}
}