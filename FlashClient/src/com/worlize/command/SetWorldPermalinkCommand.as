package com.worlize.command
{
	import com.worlize.model.WorldDefinition;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	public class SetWorldPermalinkCommand extends EventDispatcher
	{
		private var client:WorlizeServiceClient;
		
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_COMPLETE:String = "complete";
	
		[Bindable]
		public var state:String
		
		private var world:WorldDefinition;
		
		public function SetWorldPermalinkCommand(target:IEventDispatcher=null)
		{
			super(target);
			client = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
		}
		
		public function execute(world:WorldDefinition, requestedPermalink:String):void {
			this.world = world;
			state = STATE_LOADING;
			client.send("/worlds/" + world.guid + "/set_permalink.json", HTTPMethod.POST, {
				permalink: requestedPermalink
			});
		}
		
		private function handleResult(event:WorlizeResultEvent):void {
			state = STATE_COMPLETE;
			if (event.resultJSON.success) {
				world.permalink = event.resultJSON.permalink;
				dispatchEvent(event);
			}
			else {
				Alert.show(event.resultJSON.message, "Unable to set Permalink");
			}
		}
		
		private function handleFault(event:FaultEvent):void {
			state = STATE_COMPLETE;
			Alert.show("An error occurred while reserving your permalink.", "Error");
		}
	}
}