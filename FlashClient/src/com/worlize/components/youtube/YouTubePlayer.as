package com.worlize.components.youtube
{
	import flash.events.Event;
	import flash.system.Security;
	
	import mx.controls.SWFLoader;
	import mx.events.FlexEvent;
	
	[Event(name="ready", type="com.worlize.components.youtube.YouTubePlayerEvent")]
	[Event(name="error", type="com.worlize.components.youtube.YouTubePlayerEvent")]
	[Event(name="stateChange", type="com.worlize.components.youtube.YouTubePlayerEvent")]
	[Event(name="qualityChange", type="com.worlize.components.youtube.YouTubePlayerEvent")]
	public class YouTubePlayer extends SWFLoader implements IYouTubePlayer
	{
		private var player:Object;
		
		private var _playerState:int = YouTubePlayerState.UNINITIALIZED;
		
		private static var youTubeURLRegExp:RegExp = /^http:\/\/(?:www\.)?youtube.com\/(watch_popup\?v=|watch\?v=|v\/)([_\-\w]{11,12})/;
		private static var youTubeVideoIdRegExp:RegExp = /[_\-\w]{11,12}/;
		
		public var lastPlayedVideoId:String;
		
		public function YouTubePlayer()
		{
			super();
			addEventListener(FlexEvent.INITIALIZE, handleInitialize);
		}
		
		private function handleInitialize(event:Event):void {
			Security.allowDomain("www.youtube.com");
			Security.allowInsecureDomain("www.youtube.com");
			load("http://www.youtube.com/apiplayer?version=3");
			addEventListener(Event.INIT, handleInit);
		}
		
		private function handleInit(event:Event):void {
			initPlayerObject();
		}
		
		private function initPlayerObject():void {
			player = content;
			player.addEventListener('onReady', handlePlayerReady);
			player.addEventListener('onError', handlePlayerError);
			player.addEventListener('onStateChange', handlePlayerStateChange);
			player.addEventListener('onPlaybackQualityChange', handlePlayerPlaybackQualityChange);
		}
		
		public function get playerObject():Object {
			return player;
		}
		
		[Bindable(event="stateChange")]
		public function get state():int {
			return _playerState;
		}
		
		private function handlePlayerReady(playerEvent:Object):void {
			var event:YouTubePlayerEvent = new YouTubePlayerEvent(YouTubePlayerEvent.READY);
			event.data = playerEvent.data;
			dispatchEvent(event);				
		}
		
		private function handlePlayerError(playerEvent:Object):void {
			var event:YouTubePlayerEvent = new YouTubePlayerEvent(YouTubePlayerEvent.ERROR);
			event.errorCode = int(playerEvent.data);
			dispatchEvent(event);
		}
		
		private function handlePlayerStateChange(playerEvent:Object):void {
			var event:YouTubePlayerEvent = new YouTubePlayerEvent(YouTubePlayerEvent.STATE_CHANGE);
			event.oldState = _playerState;
			event.newState = int(playerEvent.data);
			_playerState = event.newState;
			dispatchEvent(event);
		}
		
		private function handlePlayerPlaybackQualityChange(playerEvent:Object):void {
			var event:YouTubePlayerEvent = new YouTubePlayerEvent(YouTubePlayerEvent.QUALITY_CHANGE);
			event.quality = String(playerEvent.data);
			dispatchEvent(event);
		}
		
		public function getVideoIdFromUrl(url:String):String {
			if (youTubeURLRegExp.test(url)) {
				var match:Array = youTubeURLRegExp.exec(url);
				if (match) {
					return String(match[2]);
				}
				else {
					throw new Error("Unable to find the YouTube VideoId in the given URL");
				}
			}
			else {
				throw new Error("That is not a recognizable YouTube URL.");
			}
		}
		
		public function cueVideoById(videoId:String, startSeconds:Number=NaN, suggestedQuality:String=null):void {
			lastPlayedVideoId = videoId;
			player.cueVideoById(videoId, startSeconds, suggestedQuality);
		}
		
		public function loadVideoById(videoId:String, startSeconds:Number=NaN, suggestedQuality:String=null):void {
			lastPlayedVideoId = videoId;
			player.loadVideoById(videoId, startSeconds, suggestedQuality);
		}
		
		public function cueVideoByUrl(mediaContentUrl:String, startSeconds:Number=NaN, suggestedQuality:String=null):void {
			player.cueVideoByUrl(mediaContentUrl, startSeconds, suggestedQuality);
		}
		
		public function loadVideoByUrl(mediaContentUrl:String, startSeconds:Number=NaN, suggestedQuality:String=null):void {
			player.loadVideoByUrl(mediaContentUrl, startSeconds, suggestedQuality);
		}
		
		public function playVideo():void {
			player.playVideo();
		}
		
		public function pauseVideo():void {
			player.pauseVideo();
		}
		
		public function stopVideo():void {
			player.stopVideo();
		}
		
		public function seekTo(seconds:Number, allowedSeekAhead:Boolean=true):void {
			player.seekTo(seconds, allowedSeekAhead);
		}
		
		public function mute():void {
			player.mute();
		}
		
		public function unMute():void {
			player.unMute();
		}
		
		public function isMuted():Boolean {
			return Boolean(player.isMuted());
		}
		
		public function setVolume(volume:Number):void {
			player.setVolume(volume);
		}
		
		public function getVolume():Number {
			return Number(player.getVolume());
		}
		
		public function setSize(width:Number, height:Number):void {
			player.setSize(width, height);
		}
		
		public function getVideoBytesLoaded():Number {
			return Number(player.getVideoBytesLoaded());
		}
		
		public function getVideoBytesTotal():Number {
			return Number(player.getVideoBytesTotal());
		}
		
		public function getVideoStartBytes():Number {
			return Number(player.getVideoStartBytes());
		}
		
		public function getPlayerState():Number {
			return Number(player.getPlayerState());
		}
		
		public function getCurrentTime():Number {
			return Number(player.getCurrentTime());
		}
		
		public function getPlaybackQuality():String {
			return String(player.getPlaybackQuality());
		}
		
		public function setPlaybackQuality(quality:String):void {
			player.setPlaybackQuality(quality);
		}
		
		public function getAvailableQualityLevels():Array {
			return player.getAvailableQualityLevels() as Array;
		}
		
		public function getDuration():Number {
			return Number(player.getDuration());
		}
		
		public function getVideoUrl():String {
			return String(player.getVideoUrl());
		}
		
		public function getVideoEmbedCode():String {
			return String(player.getVideoEmbedCode());
		}
		
		public function destroy():void {
			player.destroy();
		}

	}
}