package com.worlize.rpc
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	[Event(name='result',type='com.worlize.rpc.WorlizeResultEvent')]
	[Event(name='fault',type='mx.rpc.events.FaultEvent')]

	public class WorlizeServiceClient extends EventDispatcher
	{
		
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
		
		public function cancel():void {
			service.cancel();
		}
		
		public function send(url:String, method:String, params:Object = null):void {
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
			service.send(params);
			loading = true;
		}
		
		private function handleResult(event:ResultEvent):void {
			loading = false;
			lastResult = new WorlizeResultEvent(WorlizeResultEvent.RESULT, event.bubbles, event.cancelable, event.result, event.token, event.message);
			try {
				lastResult.resultJSON = JSON.decode(String(event.result));
				dispatchEvent(lastResult);
			}
			catch(error:Error) {
				var fault:Fault = new Fault("JSONParseFault", "Cannot parse JSON response from server", error.message);
				var faultEvent:FaultEvent = new FaultEvent(FaultEvent.FAULT, event.bubbles, event.cancelable, fault, event.token, event.message);
				dispatchEvent(faultEvent);
			}
		}
		
		private function handleFault(event:FaultEvent):void {
			loading = false;
			dispatchEvent(event.clone());
		}
	}
}