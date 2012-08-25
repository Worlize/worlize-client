package com.worlize.command
{
	import com.worlize.interactivity.model.UserPermission;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	
	public class BlessUserAsModeratorCommand extends EventDispatcher
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_COMPLETE:String = "complete";
		
		[Bindable]
		public var state:String = STATE_INIT;
		
		private var client:WorlizeServiceClient;
		
		public function BlessUserAsModeratorCommand(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function execute(userGuid:String, worldGuid:String):void {
			if (state === STATE_LOADING) {
				throw new Error("Already executing");
			}
			
			client = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			
			var params:Object = {
				permissions: [
					UserPermission.CAN_ACCESS_MODERATION_DIALOG,
					UserPermission.CAN_GAG,
					UserPermission.CAN_PIN,
					UserPermission.CAN_BLOCK_AVATARS,
					UserPermission.CAN_BLOCK_PROPS,
					UserPermission.CAN_BLOCK_WEBCAMS,
					UserPermission.CAN_BAN,
					UserPermission.CAN_LENGTHEN_RESTRICTION_TIME,
					UserPermission.CAN_REDUCE_RESTRICTION_TIME
				]
			};
			
			client.send(
				'/worlds/' + worldGuid + "/moderators/" + userGuid,
				HTTPMethod.PUT,
				{ data: JSON.stringify(params) }
			);
			
			state = STATE_LOADING;
		}
		
		private function handleResult(event:WorlizeResultEvent):void {
			state = STATE_COMPLETE;
			if (!event.resultJSON.success) {
				Alert.show(event.resultJSON.error.message, "Moderation");
			}
		}
		
		private function handleFault(event:FaultEvent):void {
			state = STATE_COMPLETE;
		}
	}
}