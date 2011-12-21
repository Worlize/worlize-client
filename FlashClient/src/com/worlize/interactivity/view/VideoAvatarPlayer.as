package com.worlize.interactivity.view
{
	import com.worlize.interactivity.event.WebcamBroadcastEvent;
	import com.worlize.interactivity.event.WorlizeVideoEvent;
	import com.worlize.interactivity.model.WebcamBroadcastManager;
	import com.worlize.interactivity.rpc.InteractivityClient;
	import com.worlize.video.control.NetConnectionManager;
	import com.worlize.video.events.NetConnectionManagerEvent;
	
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.media.Camera;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	[Event(type="com.worlize.interactivity.event.WorlizeVideoEvent", name="stopped")]
	[Event(type="com.worlize.interactivity.event.WorlizeVideoEvent", name="started")]
	public class VideoAvatarPlayer extends UIComponent
	{
		private var logger:ILogger = Log.getLogger('com.worlize.interactivity.view.VideoAvatarPlayer');
		
		protected var netStream:NetStream;
		private var _streamName:String;
		private var _netConnectionManager:NetConnectionManager;
		protected var video:Video;
		private var listenersAdded:Boolean = false;
		protected var streamNotFoundTimer:Timer = new Timer(5000, 1);
		protected var streamNotFoundCount:int = 0;
		
		public var camera:Camera;
		
		private var _webcamBroadcastManager:WebcamBroadcastManager;
		
		[Bindable]
		public var playing:Boolean = false;
		
		public function VideoAvatarPlayer()
		{
			video = new Video(160, 120);
			addChild(video);
			
			streamNotFoundTimer.addEventListener(TimerEvent.TIMER, handleStreamNotFoundTimer);
			
			addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			super();
		}
		
		[Bindable(event="webcamBroadcastManagerChange")]
		public function set webcamBroadcastManager(newValue:WebcamBroadcastManager):void {
			if (_webcamBroadcastManager !== newValue) {
				if (_webcamBroadcastManager) {
					_webcamBroadcastManager.removeEventListener('micMutedChanged', handleMicMutedChange);
				}
				_webcamBroadcastManager = newValue;
				if (_webcamBroadcastManager) {
					_webcamBroadcastManager.addEventListener('micMutedChanged', handleMicMutedChange);
				}
				dispatchEvent(new FlexEvent('webcamBroadcastManagerChange'));
			}
		}
		public function get webcamBroadcastManager():WebcamBroadcastManager {
			return _webcamBroadcastManager;
		}
		
		[Bindable(event='streamNameChange')]
		public function get streamName():String {
			return _streamName;
		}
		public function set streamName(newValue:String):void {
			if (_streamName !== newValue) {
				if (_streamName) {
					stopStream();
				}
				_streamName = newValue;
				if (_streamName) {
					playStream();
				}
				dispatchEvent(new FlexEvent('streamNameChange'));
			}
		}

		[Bindable(event='netConnectionManagerChange')]
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
				if (_netConnectionManager) {
					playStream();
				}
				else {
					stopStream();
				}
				var event:FlexEvent = new FlexEvent('netConnectionManagerChange');
				dispatchEvent(event);
			}
		}
		
		protected function handleMicMutedChange(event:Event):void {
			if (netStream) {
				var transform:SoundTransform = new SoundTransform();
				if (_webcamBroadcastManager.micMuted && !_webcamBroadcastManager.dimAudioWhenTalking) {
					transform.volume = 1;
				}
				else {
					transform.volume = 0.5;
				}
				try {
					netStream.soundTransform = transform;
				}
				catch(e:Error) {
					logger.error(e.toString() + ": Stack trace if available: " + e.getStackTrace());
				}
			}
		}
		
		protected function handleRemovedFromStage(event:Event):void {
			removeNetConnectionManagerListeners();
			stopStream();
		}
		
		protected function handleAddedToStage(event:Event):void {
			addNetConnectionManagerListeners();
			playStream();
		}
		
		protected function removeNetConnectionManagerListeners():void {
			if (!listenersAdded || netConnectionManager === null) { return; }
			
			netConnectionManager.removeEventListener(NetConnectionManagerEvent.CONNECTED, handleNetConnectionManagerConnected);
			netConnectionManager.removeEventListener(NetConnectionManagerEvent.DISCONNECTED, handleNetConnectionManagerDisconnected);
			
			listenersAdded = false;
		}
		
		protected function addNetConnectionManagerListeners():void {
			if (listenersAdded || netConnectionManager === null) { return; }
			
			netConnectionManager.addEventListener(NetConnectionManagerEvent.CONNECTED, handleNetConnectionManagerConnected);
			netConnectionManager.addEventListener(NetConnectionManagerEvent.DISCONNECTED, handleNetConnectionManagerDisconnected);
			
			listenersAdded = true;
		}
		
		private function handleNetConnectionManagerConnected(event:NetConnectionManagerEvent):void {
			playStream();
		}
		
		private function handleNetConnectionManagerDisconnected(event:NetConnectionManagerEvent):void {
			stopStream();
		}
		
		protected function playStream():void {
			if (netConnectionManager === null) { return; }
			if (playing || !netConnectionManager.ready || streamName === null) { return; }
			
			if (streamName === '_local') {
				playLocalStream();
			}
			else {
				playRemoteStream();
			}
		}
		
		protected function playLocalStream():void {
			var camera:Camera = InteractivityClient.getInstance().webcamBroadcastManager.camera;
			if (camera) {
				video.scaleX = -1;
				video.x = 160;
				video.attachCamera(camera);
				playing = true;
			}
		}
		
		protected function playRemoteStream():void {
			netStream = new NetStream(netConnectionManager.netConnection);
			netStream.addEventListener(NetStatusEvent.NET_STATUS, handleNetStreamNetStatus, false, 0, true);
			netStream.play(streamName);				
		}
		
		protected function stopStream():void {
			if (streamName === '_local') {
				stopLocalStream();
			}
			else {
				stopRemoteStream();
			}
		}
		
		protected function stopLocalStream():void {
			video.attachCamera(null);
			video.attachNetStream(null);
			playing = false;
		}
		
		protected function stopRemoteStream():void {
			if (netStream) {
				netStream.receiveVideo(false);
				netStream.receiveAudio(false);
				netStream.close();
				netStream = null;
				video.attachNetStream(null);
				video.attachCamera(null);
				playing = false;
			}
		}
		
		private function handleNetStreamNetStatus(event:NetStatusEvent):void {
			logger.debug("NetStream NetStatusEvent: " + event.info.level + " - " + event.info.code);
			
			var startedEvent:WorlizeVideoEvent;
			var stoppedEvent:WorlizeVideoEvent;
			
			switch (event.info.code) {
				case 'NetStream.Play.Start':
					video.scaleX = 1;
					video.x = 0;
					video.attachNetStream(netStream);
					
					// If push-to-talk is enabled while a new video starts playing...
					if (_webcamBroadcastManager) {
						var transform:SoundTransform = new SoundTransform();
						if (_webcamBroadcastManager.micMuted) {
							transform.volume = 1; 
						}
						else {
							transform.volume = 0;
						}
						netStream.soundTransform = transform;						
					}
					
					playing = true;
					startedEvent = new WorlizeVideoEvent(WorlizeVideoEvent.STARTED);
					dispatchEvent(startedEvent);
					break;
				
				case 'NetStream.Play.Stop':
					playing = false;
					stoppedEvent = new WorlizeVideoEvent(WorlizeVideoEvent.STOPPED);
					dispatchEvent(stoppedEvent);
					break;
				
				case 'NetStream.Play.InsufficientBW':
					logger.error("Insufficient bandwidth to maintain stream.");
					break;
				
				case 'NetStream.Failed':
					logger.error("NetStream: Server error.");
					break;
				
				case 'NetStream.Play.StreamNotFound':
					logger.error("Stream " + streamName + " not found.");
					// Only retry three times on StreamNotFound.
					if (streamNotFoundCount < 2) {
						streamNotFoundTimer.reset();
						streamNotFoundTimer.start();
						streamNotFoundCount ++;
					}
					else {
						streamNotFoundCount = 0;
					}
					break;
				
				case 'NetStream.Play.UnpublishNotify':
					break;
				
				default:
					logger.warn("Unhandled NetStatus Event: " + event.info.code);
					break;
			}
		}
		
		private function handleStreamNotFoundTimer(event:TimerEvent):void {
			playStream();
		}
	}
}