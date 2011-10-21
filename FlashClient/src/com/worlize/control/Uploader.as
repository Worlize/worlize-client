package com.worlize.control
{
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
	
	import mx.controls.Alert;
	import mx.events.StateChangeEvent;
	
	[Event(type="mx.events.StateChangeEvent",name="currentStateChange")]
	[Event(type="flash.events.ProgressEvent",name="progress")]
	public class Uploader extends EventDispatcher
	{
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
		protected var fileTypeFilter:FileFilter;
		
		public var url:String;
		
		[Bindable]
		public var percentComplete:Number = 0;
		
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
			browsing = true;
			fileRef = new FileReference();
			fileRef.addEventListener(Event.SELECT, handleFileSelected);
			fileRef.addEventListener(Event.CANCEL, handleFileBrowseCancel);
			fileRef.addEventListener(IOErrorEvent.IO_ERROR, handleIOErrorEvent);
			fileRef.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityErrorEvent);
			if (fileTypeFilter) {
				fileRef.browse([fileTypeFilter]);
			}
			else {
				fileRef.browse();
			}
		}
		
		protected function handleFileSelected(event:Event):void {
			browsing = false;
			trace("File selected");
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
			request.data = params;
			
			fileRef.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, handleFileUploadComplete);
			fileRef.addEventListener(Event.COMPLETE, handleFileComplete);
			fileRef.addEventListener(Event.OPEN, handleUploadBegin);
			fileRef.addEventListener(ProgressEvent.PROGRESS, handleUploadProgress);
			fileRef.upload(request, 'filedata');
			
		}
		
		protected function handleFileBrowseCancel(event:Event):void {
			trace("Browse Canceled.");
			browsing = false;
		}
		
		protected function handleIOErrorEvent(event:IOErrorEvent):void {
			browsing = false;
			Alert.show("There was an IO Error while trying to upload the file.", "Error");
			fileRef = null;
		}
		
		protected function handleSecurityErrorEvent(event:SecurityErrorEvent):void {
			browsing = false;
			Alert.show("There was a Security Error while trying to upload the file.", "Error");
			fileRef = null;
		}
		
		protected function handleFileUploadComplete(event:DataEvent):void {
			trace("UploadComplete");
			state = STATE_READY;
		}
		
		protected function handleFileComplete(event:Event):void {
			trace("FileComplete");
			state = STATE_READY;
		}
		
		protected function handleUploadBegin(event:Event):void {
			trace("Uploading...");
			state = STATE_UPLOADING;
		}
		
		protected function handleUploadProgress(event:ProgressEvent):void {
			trace("Upload Progress. Total Bytes: " + event.bytesTotal + ", Uploaded Bytes: " + event.bytesLoaded);
			percentComplete = event.bytesLoaded / event.bytesTotal;
			dispatchEvent(event.clone())
			if (event.bytesLoaded == event.bytesTotal) {
				state = STATE_PROCESSING;
			}
		}
		
		protected function cancelUpload():void {
			trace("Upload Canceled");
			state = STATE_READY;
		}
	}
}