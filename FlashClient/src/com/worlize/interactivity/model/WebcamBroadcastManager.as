package com.worlize.interactivity.model
{
	import com.worlize.interactivity.event.WebcamBroadcastEvent;
	import com.worlize.video.control.NetConnectionManager;
	import com.worlize.video.events.NetConnectionManagerEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.StatusEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.SoundCodec;
	import flash.media.Video;
	import flash.net.NetStream;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	
	import mx.events.FlexEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;

	[Event(type="com.worlize.interactivity.event.WebcamBroadcastEvent", name="broadcastStart")]
	[Event(type="com.worlize.interactivity.event.WebcamBroadcastEvent", name="broadcastStop")]
	[Event(type="com.worlize.interactivity.event.WebcamBroadcastEvent", name="cameraPermissionRevoked")]
	public class WebcamBroadcastManager extends EventDispatcher
	{
		public static const MIC_MODE_OPEN:String = "micModeOpen";
		public static const MIC_MODE_PUSH_TO_TALK:String = "micModePushToTalk";
	
		private var logger:ILogger = Log.getLogger('com.worlize.interactivity.model.WebcamBroadcastManager');
		
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
		
		private var requestedStreamName:String;
		
		private var _streamName:String;
		private var _netConnectionManager:NetConnectionManager;
		
		[Bindable]
		public var dimAudioWhenTalking:Boolean = false;
		
		function WebcamBroadcastManager(target:IEventDispatcher=null) {
			microphone = Microphone.getMicrophone();
			if (microphone !== null) {
				microphone.codec = SoundCodec.SPEEX;
				microphone.setSilenceLevel(0);
				microphone.encodeQuality = 6;
				microphone.enableVAD = false;
				microphone.gain = 0;
			}
			
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
		
		public function isCameraAvailable():Boolean {
			if (Camera.getCamera()) {
				return true;
			}
			return false;
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
			var camera:Camera = Camera.getCamera();
			// If getCamera() returns null, there is no camera or it's in use
			// by another application.
			if (camera !== null) {
				if (camera.muted) {
					logger.info("Camera.muted = true, requesting access.");
					// User previously denied access to the camera.  Re-prompt.
					requestedStreamName = streamName;
					camera.addEventListener(StatusEvent.STATUS, function(event:StatusEvent):void {
						logger.debug("Status event: " + event.code);
					});
					camera.addEventListener(StatusEvent.STATUS, handleCameraStatusChange);
					Security.showSettings(SecurityPanel.PRIVACY);
				}
				else {
					// User granted access to the camera.. continue.
					logger.info("Camera.muted = false, continuing to start broadcast.");
					continueBroadcastCamera(streamName);
				}
			}
			else {
				requestedStreamName = null;
			}
		}
		
		private function handleCameraStatusChange(event:StatusEvent):void {
			logger.info("Handling camera StatusEvent - code: " + event.code);
			if (event.code === 'Camera.Unmuted') {
				// User granted access to the camera.. continue.
				if (requestedStreamName) {
					continueBroadcastCamera(requestedStreamName);
					requestedStreamName = null;
				}
			}
			else if (event.code === 'Camera.Muted') {
				// User denied access to the camera.  Stop any existing broadcast.
				if (broadcastEnabled) {
					logger.warn("Camera access was revoked while broadcasting");
					var revokedEvent:WebcamBroadcastEvent = new WebcamBroadcastEvent(WebcamBroadcastEvent.CAMERA_PERMISSION_REVOKED);
					dispatchEvent(revokedEvent);
					stopBroadcast();
				}
			}
			else {
				requestedStreamName = null;
			}
		}
		
		private function continueBroadcastCamera(streamName:String):void {
			if (broadcastEnabled && _streamName === streamName) {
				return;
			}
			
			// Already broadcasting but changing the stream name.
			if (broadcastEnabled && _streamName !== streamName) {
				logger.info("Already broadcasting but changing the stream name.");
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
			logger.info("Beginning broadcast '" + streamName + "'");
			
			if (micMode === MIC_MODE_PUSH_TO_TALK) {
				muteMic();
			}
			
			camera = Camera.getCamera();
			camera.setQuality(16*1024, 85);
			camera.setMode(160, 120, 24, true);
			
			netStream = new NetStream(netConnectionManager.netConnection);
			netStream.attachCamera(camera);
			if (microphone) {
				netStream.attachAudio(microphone);
			}
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
			logger.debug("InteractivityUser NetStream: " + event.info.code + " (" + event.info.description + ")");
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
					logger.warn("Unhandled NetStream NetStatus Event: " + event.info.code);
					break;
			}
		}
	}
}