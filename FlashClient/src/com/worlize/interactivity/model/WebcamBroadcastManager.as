package com.worlize.interactivity.model
{
	import com.worlize.interactivity.event.WebcamBroadcastEvent;
	import com.worlize.video.control.NetConnectionManager;
	import com.worlize.video.events.NetConnectionManagerEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.NetStream;
	
	import mx.events.FlexEvent;

	[Event(type="com.worlize.interactivity.event.WebcamBroadcastEvent", name="broadcastStart")]
	[Event(type="com.worlize.interactivity.event.WebcamBroadcastEvent", name="broadcastStop")]
	public class WebcamBroadcastManager extends EventDispatcher
	{
		protected var netStream:NetStream;
		public var video:Video;
		protected var camera:Camera;
		protected var broadcastEnabled:Boolean = false;
		protected var broadcasting:Boolean = false;
		
		private var _streamName:String;
		private var _netConnectionManager:NetConnectionManager;
		
		public function get streamName():String {
			return _streamName;
		}
		
		[Bindable(event="netConnectionManagerChanged")]
		public function get netConnectionManager():NetConnectionManager {
			return _netConnectionManager;
		}
		public function set netConnectionManager(newValue:NetConnectionManager):void {
			if (_netConnectionManager !== newValue) {
				if (_netConnectionManager) {
					removeNetConnectionManagerListeners();
				}
				_netConnectionManager = newValue;
				addNetConnectionManagerListeners();
				var event:FlexEvent = new FlexEvent('netConnectionManagerChanged');
				dispatchEvent(event);
			}
		}
		
		private function removeNetConnectionManagerListeners():void {
			_netConnectionManager.removeEventListener(NetConnectionManagerEvent.CONNECTED, handleNetConnectionManagerConnected);
			_netConnectionManager.removeEventListener(NetConnectionManagerEvent.DISCONNECTED, handleNetConnectionManagerDisconnected);
		}
		
		private function addNetConnectionManagerListeners():void {
			_netConnectionManager.addEventListener(NetConnectionManagerEvent.CONNECTED, handleNetConnectionManagerConnected);
			_netConnectionManager.addEventListener(NetConnectionManagerEvent.DISCONNECTED, handleNetConnectionManagerDisconnected);
		}
		
		private function handleNetConnectionManagerConnected(event:NetConnectionManagerEvent):void {
			if (broadcastEnabled) {
				startBroadcast();
			}
		}
		
		private function handleNetConnectionManagerDisconnected(event:NetConnectionManagerEvent):void {
			
		}
		
		public function broadcastCamera(streamName:String):void {
			if (broadcastEnabled && _streamName === streamName) {
				return;
			}
			
			// Already broadcasting but changing the stream name.
			if (broadcastEnabled && _streamName !== streamName) {
				trace("Already broadcasting but changing the stream name.");
				stopBroadcast();
			}
			
			_streamName = streamName;
			
			broadcastEnabled = true;
			
			// If our connection is already established, start broadcasting
			// immediately.  Otherwise, wait for the CONNECTED event.
			if (netConnectionManager.ready) {
				startBroadcast();
			}
		}
		
		protected function startBroadcast():void {
			trace("Beginning broadcast '" + streamName + "'");
			
			camera = Camera.getCamera();
			camera.setQuality(16*1024, 85);
			camera.setMode(160, 120, 24, false);
			
			netStream = new NetStream(netConnectionManager.netConnection);
			netStream.attachCamera(camera);
			netStream.bufferTime = 0;
			netStream.addEventListener(NetStatusEvent.NET_STATUS, handleNetStreamNetStatus);
			
			netStream.publish(streamName, 'live');
		}
		
		public function stopBroadcast():void {
			broadcastEnabled = false;
			if (netStream) {
				netStream.close();
				camera = null;
				netStream = null;
			}
		}
		
		private function handleNetStreamNetStatus(event:NetStatusEvent):void {
			trace("InteractivityUser NetStream: " + event.info.code + " (" + event.info.description + ")");
			switch (event.info.code) {
				case "NetStream.Publish.Start":
					broadcasting = true;
					dispatchEvent(new WebcamBroadcastEvent(WebcamBroadcastEvent.BROADCAST_START));
					break;
				
				case "NetStream.Failed":
					broadcasting = false;
					broadcastEnabled = false;
					dispatchEvent(new WebcamBroadcastEvent(WebcamBroadcastEvent.BROADCAST_STOP));
					break;
				
				case "NetStream.Publish.BadName":
					broadcasting = false;
					broadcastEnabled = false;
					dispatchEvent(new WebcamBroadcastEvent(WebcamBroadcastEvent.BROADCAST_STOP));
					break;
				
				case "NetStream.Unpublish.Success":
					broadcasting = false;
					broadcastEnabled = false;
					dispatchEvent(new WebcamBroadcastEvent(WebcamBroadcastEvent.BROADCAST_STOP));
					break;
						
				default:
					trace("Unhandled NetStream NetStatus Event: " + event.info.code);
					break;
			}
		}
	}
}