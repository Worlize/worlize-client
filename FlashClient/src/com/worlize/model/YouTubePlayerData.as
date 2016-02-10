package com.worlize.model
{
	import flash.events.EventDispatcher;
	
	import mx.events.FlexEvent;

	[Bindable]
	public class YouTubePlayerData extends EventDispatcher
	{
		public var allowUsersToShare:Boolean = true;
		private var _videoId:String;
		private var _videoURL:String;
		public var autoPlay:Boolean = true;
		
		private static var youTubeURLRegExp:RegExp = /^(?:https?:\/\/)?(?:www\.)?youtube.com\/(watch_popup\?v=|watch\?v=|v\/)([_\-\w]{11,12})/i;
		private static var shortYouTubeUrlRegExp:RegExp = /^(?:https?:\/\/)?youtu\.be\/([_\-\w]{11,12}).*$/i;
		private static var youTubeVideoIdRegExp:RegExp = /^[_\-\w]{11,12}$/;
		
		public function updateData(data:Object):void {
			if (data.videoId) {
				try {
					videoId = data.videoId;
				}
				catch(e:Error) {
					// do nothing
				}
			}
			if (data.videoURL) {
				try {
					videoURL = data.videoURL;
				}
				catch(e:Error) {
					// do nothing
				}
			}
			if (data.autoPlay != null && data.autoPlay != undefined) {
				autoPlay = data.autoPlay;
			}
			if (data.allowUsersToShare != null && data.allowUsersToShare != undefined) {
				allowUsersToShare = data.allowUsersToShare;
			}
		}
		
		public static function fromData(data:Object):YouTubePlayerData {
			var instance:YouTubePlayerData = new YouTubePlayerData();
			if (data.videoId) {
				instance.videoId = data.videoId;
			}
			if (data.videoURL) {
				instance._videoURL = data.videoURL;
			}
			if (data.autoPlay != null && data.autoPlay != undefined) {
				instance.autoPlay = Boolean(data.autoPlay);
			}
			if (data.allowUsersToShare != null && data.allowUsersToShare != undefined) {
				instance.allowUsersToShare = data.allowUsersToShare
			}
			return instance;
		}
		
		[Bindable(event="videoIdChange")]
		public function set videoId(newValue:String):void {
			if (_videoId !== newValue) {
				if (youTubeVideoIdRegExp.test(newValue)) {
					_videoId = newValue;
					_videoURL = "http://youtu.be/" + _videoId;
					dispatchEvent(new FlexEvent("videoIdChange"));
				}
				else {
					throw new Error("That is not a valid YouTube videoId.");
				}
			}
		}
		public function get videoId():String {
			return _videoId;
		}
		
		[Bindable(event="videoURLChange")]
		public function set videoURL(newValue:String):void {
			var match:Array;
			if (_videoURL !== newValue) {
				if (newValue == null || newValue.length == 0) {
					_videoURL = null;
					_videoId = null;
					dispatchEvent(new FlexEvent("videoURLChange"));
					dispatchEvent(new FlexEvent("videoIdChange"));
				}
				else if (youTubeURLRegExp.test(newValue)) {
					match = youTubeURLRegExp.exec(newValue);
					if (match) {
						_videoId = match[2];
						_videoURL = newValue;
						dispatchEvent(new FlexEvent("videoURLChange"));
						dispatchEvent(new FlexEvent("videoIdChange"));
					}
					else {
						throw new Error("Unable to find the YouTube VideoId in the given URL");
					}
				}
				else if (shortYouTubeUrlRegExp.test(newValue)) {
					match = shortYouTubeUrlRegExp.exec(newValue);
					if (match) {
						_videoId = match[1];
						_videoURL = newValue;
						dispatchEvent(new FlexEvent("videoURLChange"));
						dispatchEvent(new FlexEvent("videoIdChange"));
					}
					else {
						throw new Error("Unable to find the YouTube VideoId in the given short URL");
					}
				}
				else {
					throw new Error("That is not a recognizable YouTube URL.");
				}
			}
		}
		public function get videoURL():String {
			return _videoURL;
		}
	}
}