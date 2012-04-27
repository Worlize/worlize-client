package com.worlize.rpc
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.AsyncToken;
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	[Event(name="result",type="com.worlize.rpc.WorlizeResultEvent")]
	[Event(name="fault",type="mx.rpc.events.FaultEvent")]
	public class WorlizeServiceClient extends EventDispatcher
	{
		private var logger:ILogger = Log.getLogger('com.worlize.rpc.WorlizeServiceClient');		
		
		private var service:HTTPService;
		public var lastResult:WorlizeResultEvent;
		public var loading:Boolean = false;
		
		public static var authenticityToken:String;
		public static var cookies:Object = {};
		
		public function WorlizeServiceClient(target:IEventDispatcher=null)
		{
			super(target);
			service = new HTTPService();
			service.addEventListener(ResultEvent.RESULT, handleResult);
			service.addEventListener(FaultEvent.FAULT, handleFault);
		}
		
		public function cancel():AsyncToken {
			logger.info("Cancel");
			return service.cancel();
		}
		
		public function send(url:String, method:String, params:Object = null):AsyncToken {
			logger.info("Send url: " + url + " method: " + method);
			if (params === null) {
				params = {};
			}
			if (method !== HTTPMethod.GET) {
				if (authenticityToken) {
					params['authenticity_token'] = authenticityToken;
				}
				if (method !== HTTPMethod.POST) {
					params['_method'] = method.toLowerCase();
					method = HTTPMethod.POST;
				}
			}
			service.headers['accept'] = "application/json";
			service.resultFormat = "text";
			service.url = url;
			service.method = method;
			var token:AsyncToken = service.send(params);
			loading = true;
			return token;
		}
		
		private function handleResult(event:ResultEvent):void {
			logger.info("Got result for url: " + service.url + " method: " + service.method);
			logger.debug("Result Data: " + event.result);
			loading = false;
			lastResult = new WorlizeResultEvent(WorlizeResultEvent.RESULT, event.bubbles, event.cancelable, event.result, event.token, event.message);
			try {
				lastResult.resultJSON = JSON.parse(String(event.result));
				dispatchEvent(lastResult);
			}
			catch(error:Error) {
				logger.error("JSON parsing error while decoding service result.");
				var fault:Fault = new Fault("JSONParseFault", "Cannot parse JSON response from server", error.message);
				var faultEvent:FaultEvent = new FaultEvent(FaultEvent.FAULT, event.bubbles, event.cancelable, fault, event.token, event.message);
				dispatchEvent(faultEvent);
			}
		}
		
		private function handleFault(event:FaultEvent):void {
			logger.warn("Fault: " + event.toString());
			loading = false;
			dispatchEvent(event.clone());
		}
	}
}