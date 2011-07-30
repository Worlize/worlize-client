package com.worlize.interactivity.view
{
	import com.worlize.interactivity.event.WorlizeVideoEvent;
	import com.worlize.video.control.NetConnectionManager;
	import com.worlize.video.events.NetConnectionManagerEvent;
	
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	[Event(type="com.worlize.interactivity.event.WorlizeVideoEvent", name="stopped")]
	[Event(type="com.worlize.interactivity.event.WorlizeVideoEvent", name="started")]
	public class VideoAvatarPlayer extends UIComponent
	{
		protected var netStream:NetStream;
		private var _streamName:String;
		private var _netConnectionManager:NetConnectionManager;
		protected var video:Video;
		private var listenersAdded:Boolean = false;
		protected var streamNotFoundTimer:Timer = new Timer(5000, 1);
		protected var streamNotFoundCount:int = 0;
		
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
			
			netStream = new NetStream(netConnectionManager.netConnection);
			netStream.addEventListener(NetStatusEvent.NET_STATUS, handleNetStreamNetStatus, false, 0, true);
			netStream.play(streamName);
		}
		
		protected function stopStream():void {
			if (netStream) {
				netStream.receiveVideo(false);
				netStream.receiveAudio(false);
				netStream.close();
				netStream = null;
				playing = false;
			}
		}
		
		private function handleNetStreamNetStatus(event:NetStatusEvent):void {
			trace("NetStream NetStatusEvent: " + event.info.level + " - " + event.info.code);
			
			var startedEvent:WorlizeVideoEvent;
			var stoppedEvent:WorlizeVideoEvent;
			
			switch (event.info.code) {
				case 'NetStream.Play.Start':
					video.attachNetStream(netStream);
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
					trace("Insufficient bandwidth to maintain stream.");
					break;
				
				case 'NetStream.Failed':
					trace("NetStream: Server error.");
					break;
				
				case 'NetStream.Play.StreamNotFound':
					trace("Stream " + streamName + " not found.");
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
					trace("Unhandled NetStatus Event: " + event.info.code);
					break;
			}
		}
		
		private function handleStreamNotFoundTimer(event:TimerEvent):void {
			playStream();
		}
	}
}