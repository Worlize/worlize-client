package com.worlize.model
{
	import com.worlize.interactivity.event.WorlizeYouTubeEvent;
	import com.worlize.interactivity.model.IRoomItem;
	import com.worlize.interactivity.rpc.InteractivityClient;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	
	import org.osmf.events.TimeEvent;

	[Event(name="loadVideoRequested", type="com.worlize.interactivity.event.WorlizeYouTubeEvent")]
	[Event(name="playRequested", type="com.worlize.interactivity.event.WorlizeYouTubeEvent")]
	[Event(name="stopRequested", type="com.worlize.interactivity.event.WorlizeYouTubeEvent")]
	[Event(name="pauseRequested", type="com.worlize.interactivity.event.WorlizeYouTubeEvent")]
	[Event(name="seekRequested", type="com.worlize.interactivity.event.WorlizeYouTubeEvent")]
	[Event(name="lockPlayerRequested", type="com.worlize.interactivity.event.WorlizeYouTubeEvent")]
	[Event(name="unlockPlayerRequested", type="com.worlize.interactivity.event.WorlizeYouTubeEvent")]
	
	[Bindable]
	public class YouTubePlayerDefinition extends EventDispatcher implements IRoomItem
	{
		public var guid:String;
		public var x:int;
		public var y:int;
		public var width:Number;
		public var height:Number;
		public var data:YouTubePlayerData;
		
		public var locked:Boolean = false;
		public var lockedBy:UserListEntry;
		
		public var lockTimer:Timer = new Timer(1000, 1);
		
		public var roomGuid:String;
		
		function YouTubePlayerDefinition() {
			lockTimer.addEventListener(TimerEvent.TIMER, handleLockTimer);
		}
		
		public static function fromData(data:Object):YouTubePlayerDefinition {
			var decodedData:Object;
			var instance:YouTubePlayerDefinition = new YouTubePlayerDefinition();
			instance.guid = data.guid;
			instance.x = data.x;
			instance.y = data.y;
			instance.width = data.width;
			instance.height = data.height;
			if (data.data) {
				instance.data = YouTubePlayerData.fromData(data.data);
			}
			else {
				instance.data = new YouTubePlayerData();
			}
			return instance;
		}
		
		public function setSize(width:int, height:int):void {
			if (this.width != width || this.height != height) {
				this.width = width;
				this.height = height;
			}
		}
		
		public function saveUpdatedPositionAndDimensions():void {
			var client:InteractivityClient = InteractivityClient.getInstance();
			client.moveItem(guid, x, y, width, height);
		}
		
		public function saveUpdatedData():void {
			var client:InteractivityClient = InteractivityClient.getInstance();
			client.updateYouTubePlayerData(guid, data);
		}
		
		public function removePlayer():void {
			var client:InteractivityClient = InteractivityClient.getInstance();
			client.removeItem(guid);
		}
		
		public function loadVideoRequested(videoId:String, title:String = "unknown", autoPlay:Boolean = true):void {
			var event:WorlizeYouTubeEvent = new WorlizeYouTubeEvent(WorlizeYouTubeEvent.LOAD_VIDEO_REQUESTED);
			event.videoId = videoId;
			event.autoPlay = autoPlay;
			event.title = title;
			dispatchEvent(event);
		}
		
		public function playRequested():void {
			var event:WorlizeYouTubeEvent = new WorlizeYouTubeEvent(WorlizeYouTubeEvent.PLAY_REQUESTED);
			dispatchEvent(event);
		}
		
		public function stopRequested():void {
			var event:WorlizeYouTubeEvent = new WorlizeYouTubeEvent(WorlizeYouTubeEvent.STOP_REQUESTED);
			dispatchEvent(event);
		}
		
		public function pauseRequested():void {
			var event:WorlizeYouTubeEvent = new WorlizeYouTubeEvent(WorlizeYouTubeEvent.PAUSE_REQUESTED);
			dispatchEvent(event);
		}
		
		public function lockPlayerRequested(requestedBy:UserListEntry, duration:int):void {
			var event:WorlizeYouTubeEvent = new WorlizeYouTubeEvent(WorlizeYouTubeEvent.PLAYER_LOCKED);
			event.lockRequestedBy = requestedBy;
			event.lockDurationSeconds = duration;
			lockTimer.stop();
			lockTimer.delay = duration * 1000;
			lockTimer.reset();
			lockTimer.start();
			dispatchEvent(event);
		}
		
		public function unlockPlayerRequested():void {
			locked = false;
			lockedBy = null;
			lockTimer.stop();
			var event:WorlizeYouTubeEvent = new WorlizeYouTubeEvent(WorlizeYouTubeEvent.PLAYER_UNLOCKED);
			dispatchEvent(event);
		}
		
		public function seekRequested(seekTo:int):void {
			var event:WorlizeYouTubeEvent = new WorlizeYouTubeEvent(WorlizeYouTubeEvent.SEEK_REQUESTED);
			event.seekTo = seekTo;
			dispatchEvent(event);
		}
		
		private function handleLockTimer(event:TimerEvent):void {
			unlockPlayerRequested();
		}
	}
}