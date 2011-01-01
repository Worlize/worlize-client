package com.worlize.components.youtube
{
	public interface IYouTubePlayer
	{
		// Cueing functions
		function cueVideoById(videoId:String, startSeconds:Number=NaN, suggestedQuality:String=null):void;
		function loadVideoById(videoId:String, startSeconds:Number=NaN, suggestedQuality:String=null):void;
		function cueVideoByUrl(mediaContentUrl:String, startSeconds:Number=NaN, suggestedQuality:String=null):void;
		function loadVideoByUrl(mediaContentUrl:String, startSeconds:Number=NaN, suggestedQuality:String=null):void;
		
		// Playback Controls and Player Settings
		function playVideo():void;
		function pauseVideo():void;
		function stopVideo():void;
		function seekTo(seconds:Number, allowSeekAhead:Boolean=true):void;
		
		// Changing the player volume
		function mute():void;
		function unMute():void;
		function isMuted():Boolean;
		function setVolume(volume:Number):void;
		function getVolume():Number;
		
		// Setting the player size
		function setSize(width:Number, height:Number):void;
		
		// Playback Status
		function getVideoBytesLoaded():Number;
		function getVideoBytesTotal():Number;
		function getVideoStartBytes():Number;
		function getPlayerState():Number;
		function getCurrentTime():Number;
		
		// Playback Quality
		function getPlaybackQuality():String;
		function setPlaybackQuality(suggestedQuality:String):void;
		function getAvailableQualityLevels():Array;
		
		// Retrieving Video Information
		function getDuration():Number;
		function getVideoUrl():String;
		function getVideoEmbedCode():String;
		
		// Special functions
		function destroy():void;
	}
}