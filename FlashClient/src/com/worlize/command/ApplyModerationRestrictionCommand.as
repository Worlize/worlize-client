package com.worlize.command
{
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	
	public class ApplyModerationRestrictionCommand extends EventDispatcher
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_COMPLETE:String = "complete";
		
		[Bindable]
		public var state:String = STATE_INIT;
		
		private var client:WorlizeServiceClient;
		
		public function ApplyModerationRestrictionCommand(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function execute(userGuid:String, name:String, durationMinutes:int, global:Boolean = false, worldGuid:String = null):void {
			if (state === STATE_LOADING) {
				throw new Error("Already executing");
			}
			client = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			
			var params:Object = {
				global: global ? 1 : 0,
				name: name,
				minutes: durationMinutes
			};
			
			if (!global) {
				params['world_guid'] = worldGuid;
			}

			client.send(
				'/users/' + userGuid + "/restrictions",
				HTTPMethod.POST,
				params
			);
			
			state = STATE_LOADING;
		}
		
		private function handleResult(event:WorlizeResultEvent):void {
			state = STATE_COMPLETE;
			if (!event.resultJSON.success) {
				Alert.show(event.resultJSON.errors.join('\n'), "Moderation");
			}
		}
		
		private function handleFault(event:FaultEvent):void {
			state = STATE_COMPLETE;
		}
	}
}