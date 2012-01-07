package com.worlize.control
{
	import com.worlize.gif.GIFDecoder;
	import com.worlize.gif.events.AsyncDecodeErrorEvent;
	import com.worlize.gif.events.GIFDecoderEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.flash_proxy;
	
	import mx.controls.Alert;
	import mx.events.StateChangeEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	[Event(type="mx.events.StateChangeEvent",name="currentStateChange")]
	[Event(type="flash.events.ProgressEvent",name="progress")]
	public class Uploader extends EventDispatcher
	{
		private var logger:ILogger = Log.getLogger('com.worlize.control.Uploader');
		
		public function Uploader(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public static const STATE_READY:String = "ready";
		public static const STATE_UPLOADING:String = "uploading";
		public static const STATE_CANCELED:String = "canceled";
		public static const STATE_PROCESSING:String = "processing";
		
		protected var fileRef:FileReference;
		protected var browsing:Boolean = false;
		protected var _state:String = STATE_READY;
		protected var fileTypeFilters:Array;
		
		public var url:String;
		
		[Bindable]
		public var percentComplete:Number = 0;
		
		[Bindable]
		public var checkAnimatedGifs:Boolean = true;
		
		private var isAnimatedGif:Boolean = false;
		
		[Bindable(event="stateBindingChanged")]
		public function set state(newValue:String):void {
			if (_state != newValue) {
				var oldState:String = _state;
				_state = newValue;
				var event:StateChangeEvent = new StateChangeEvent(StateChangeEvent.CURRENT_STATE_CHANGE, false, false, oldState, _state);
				dispatchEvent(event);
				dispatchEvent(new Event('stateBindingChanged'));
			}
		}
		public function get state():String {
			return _state;
		}
		
		public function browse():void {
			if (browsing) { return; }
			isAnimatedGif = false;
			browsing = true;
			fileRef = new FileReference();
			fileRef.addEventListener(Event.SELECT, handleFileSelected);
			fileRef.addEventListener(Event.CANCEL, handleFileBrowseCancel);
			fileRef.addEventListener(IOErrorEvent.IO_ERROR, handleIOErrorEvent);
			fileRef.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityErrorEvent);
			if (fileTypeFilters) {
				fileRef.browse(fileTypeFilters);
			}
			else {
				fileRef.browse();
			}
		}
		
		protected function handleFileSelected(event:Event):void {
			browsing = false;
			logger.info("File selected: " + fileRef.name);
			
			if (checkAnimatedGifs && fileRef.name.match(/^.*\.gif$/i)) {
				checkAnimatedGif();
			}
			else {
				uploadData();
			}
		}
		
		protected function checkAnimatedGif():void {
			logger.info("Validating GIF: Loading GIF data into memory.");
			fileRef.addEventListener(Event.COMPLETE, handleGifLoadComplete);
			fileRef.load();
		}
		
		// Once the file is loaded we can verify the data
		protected function handleGifLoadComplete(event:Event):void {
			logger.info("GIF data loaded - " + fileRef.size + " bytes - " + fileRef.name);
			fileRef.removeEventListener(Event.COMPLETE, handleGifLoadComplete);
			
			function handleGifDecodeComplete(event:GIFDecoderEvent):void {
				isAnimatedGif = (gifDecoder.frameDecodedCount > 1);
				gifDecoder.cleanup();
				logger.info("Animated GIF: " + isAnimatedGif);
				uploadData();
			}
			
			function handleGifDecodeError(event:AsyncDecodeErrorEvent):void {
				logger.info("Unable to decode GIF file: " + event.text);
				Alert.show("The selected GIF file could not be decoded: " + event.text, "Aww, shucks!");
			}

			logger.info("Attempting to decode GIF file");
			var gifDecoder:GIFDecoder = new GIFDecoder();
			gifDecoder.addEventListener(GIFDecoderEvent.DECODE_COMPLETE, handleGifDecodeComplete);
			gifDecoder.addEventListener(AsyncDecodeErrorEvent.ASYNC_DECODE_ERROR, handleGifDecodeError);
			gifDecoder.decodeBytes(fileRef.data);
		}
		
		protected function uploadData():void {
			logger.info("Attempting to begin upload");
			
			// We have to manually do the URLRequest instead of going through
			// a WorlizeServiceClient subclass...
			var request:URLRequest = new URLRequest(url);
			request.method = URLRequestMethod.POST;
			var params:URLVariables = new URLVariables();
			params.authenticity_token = WorlizeServiceClient.authenticityToken;
			
			// Flash doesn't pass through the browser's cookies for file
			// uploads.  We have to provide the cookies ourself a different
			// way to make sure that uploads are authenticated.
			var cookieStrings:Array = [];
			for (var cookieKey:String in WorlizeServiceClient.cookies) {
				var cookieValue:String = WorlizeServiceClient.cookies[cookieKey];
				cookieStrings.push(encodeURIComponent(cookieKey) + "=" + encodeURIComponent(cookieValue));
			}
			params.cookie = cookieStrings.join("; ");
			if (checkAnimatedGifs) {
				params.animated_gif = isAnimatedGif;
			}
			request.data = params;
			
			fileRef.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, handleFileUploadComplete);
			fileRef.addEventListener(Event.COMPLETE, handleFileComplete);
			fileRef.addEventListener(Event.OPEN, handleUploadBegin);
			fileRef.addEventListener(ProgressEvent.PROGRESS, handleUploadProgress);
			fileRef.upload(request, 'filedata');
		}
		
		protected function handleFileBrowseCancel(event:Event):void {
			logger.info("Browse Canceled.");
			state = STATE_READY;
			browsing = false;
		}
		
		protected function handleIOErrorEvent(event:IOErrorEvent):void {
			logger.error("IOErrorEvent: " + event.toString());
			browsing = false;
			state = STATE_READY;
			Alert.show("There was an IO Error while trying to upload the file.  Your file may be too large.", "Error");
			fileRef = null;
		}
		
		protected function handleSecurityErrorEvent(event:SecurityErrorEvent):void {
			logger.error("Security Error: " + event.toString());
			browsing = false;
			Alert.show("There was a Security Error while trying to upload the file.", "Error");
			fileRef = null;
		}
		
		protected function handleFileUploadComplete(event:DataEvent):void {
			logger.info("Upload Complete");
			state = STATE_READY;
		}
		
		protected function handleFileComplete(event:Event):void {
			logger.info("File Complete");
			state = STATE_READY;
		}
		
		protected function handleUploadBegin(event:Event):void {
			logger.info("Uploading...");
			state = STATE_UPLOADING;
		}
		
		protected function handleUploadProgress(event:ProgressEvent):void {
			logger.debug("Upload Progress. Total Bytes: " + event.bytesTotal + ", Uploaded Bytes: " + event.bytesLoaded);
			percentComplete = event.bytesLoaded / event.bytesTotal;
			dispatchEvent(event.clone())
			if (event.bytesLoaded == event.bytesTotal) {
				state = STATE_PROCESSING;
			}
		}
		
		protected function cancelUpload():void {
			logger.info("Upload Canceled");
			state = STATE_READY;
		}
	}
}