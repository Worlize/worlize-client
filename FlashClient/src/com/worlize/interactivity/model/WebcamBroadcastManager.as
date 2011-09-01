package com.worlize.interactivity.model
{
	import com.worlize.interactivity.event.WebcamBroadcastEvent;
	import com.worlize.video.control.NetConnectionManager;
	import com.worlize.video.events.NetConnectionManagerEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.SoundCodec;
	import flash.media.Video;
	import flash.net.NetStream;
	
	import mx.events.FlexEvent;

	[Event(type="com.worlize.interactivity.event.WebcamBroadcastEvent", name="broadcastStart")]
	[Event(type="com.worlize.interactivity.event.WebcamBroadcastEvent", name="broadcastStop")]
	public class WebcamBroadcastManager extends EventDispatcher
	{
		public static const MIC_MODE_OPEN:String = "micModeOpen";
		public static const MIC_MODE_PUSH_TO_TALK:String = "micModePushToTalk";
		
		protected var netStream:NetStream;
		public var video:Video;
		public var microphone:Microphone;
		public var camera:Camera;
		protected var broadcastEnabled:Boolean = false;
		private var _broadcasting:Boolean = false;
		private var _micMode:String = MIC_MODE_PUSH_TO_TALK;
		
		private var _micMuted:Boolean = true;
		
		[Bindable]
		protected var videoMuted:Boolean = false;
		
		private var _streamName:String;
		private var _netConnectionManager:NetConnectionManager;
		
		function WebcamBroadcastManager(target:IEventDispatcher=null) {
			microphone = Microphone.getMicrophone();
			microphone.codec = SoundCodec.SPEEX;
			microphone.setSilenceLevel(0);
			microphone.encodeQuality = 6;
			microphone.enableVAD = true;
			microphone.gain = 0;
			super(target);
		}
		
		[Bindable(event="micMutedChanged")]
		public function get micMuted():Boolean {
			return _micMuted;
		}
		
		protected function setMicMuted(newValue:Boolean):void {
			if (_micMuted !== newValue) {
				_micMuted = newValue;
				dispatchEvent(new FlexEvent('micMutedChanged'));
			}
		}
		
		[Bindable(event="broadcastingChanged")]
		public function get broadcasting():Boolean {
			return _broadcasting;
		}
		
		protected function setBroadcasting(newValue:Boolean):void {
			if (_broadcasting !== newValue) {
				_broadcasting = newValue;
				dispatchEvent(new FlexEvent('broadcastingChanged'));
			}
		}
		
		public function get streamName():String {
			return _streamName;
		}
		
		[Bindable(event="micModeChanged")]
		public function get micMode():String {
			return _micMode;
		}
		public function set micMode(newValue:String):void {
			if (_micMode !== newValue) {
				_micMode = newValue;
				dispatchEvent(new FlexEvent('micModeChanged'));
			}
		}
		
		public function muteMic():void {
			if (!_micMuted && microphone) {
				setMicMuted(true);
				microphone.gain = 0;
			}
		}
		
		public function unmuteMic():void {
			if (_micMuted && microphone) {
				setMicMuted(false);
				microphone.gain = 50;
			}
		}
		
		public function muteVideo():void {
			
		}
		
		public function unmuteVideo():void {
			
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
			netStream.attachAudio(microphone);
			netStream.bufferTime = 0;
			netStream.addEventListener(NetStatusEvent.NET_STATUS, handleNetStreamNetStatus);
			
			netStream.publish(streamName, 'live');
		}
		
		public function stopBroadcast():void {
			broadcastEnabled = false;
			if (netStream) {
				netStream.close();
				setBroadcasting(false);
				camera = null;
				netStream = null;
			}
		}
		
		private function handleNetStreamNetStatus(event:NetStatusEvent):void {
			trace("InteractivityUser NetStream: " + event.info.code + " (" + event.info.description + ")");
			switch (event.info.code) {
				case "NetStream.Publish.Start":
					setBroadcasting(true);
					dispatchEvent(new WebcamBroadcastEvent(WebcamBroadcastEvent.BROADCAST_START));
					break;
				
				case "NetStream.Failed":
					setBroadcasting(false);
					broadcastEnabled = false;
					dispatchEvent(new WebcamBroadcastEvent(WebcamBroadcastEvent.BROADCAST_STOP));
					break;
				
				case "NetStream.Publish.BadName":
					setBroadcasting(false);
					broadcastEnabled = false;
					dispatchEvent(new WebcamBroadcastEvent(WebcamBroadcastEvent.BROADCAST_STOP));
					break;
				
				case "NetStream.Unpublish.Success":
					setBroadcasting(false);
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