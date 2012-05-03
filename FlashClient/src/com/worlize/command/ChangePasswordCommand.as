package com.worlize.command
{
	import com.adobe.utils.DateUtil;
	import com.worlize.model.CurrentUser;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	
	public class ChangePasswordCommand extends EventDispatcher
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_COMPLETE:String = "complete";
		
		private var client:WorlizeServiceClient;
		
		[Bindable]
		public var state:String

		public function ChangePasswordCommand(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function execute(newPassword:String):void {
			state = STATE_LOADING;
			client = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send("/me/change_password", HTTPMethod.POST, {
				password: newPassword
			});
		}
		
		private function handleResult(event:WorlizeResultEvent):void {
			state = STATE_COMPLETE;
			if (event.resultJSON.success) {
				CurrentUser.getInstance().passwordChangedAt = DateUtil.parseW3CDTF(event.resultJSON.password_changed_at);
				dispatchEvent(event);
			}
			else {
				Alert.show(event.resultJSON.message, "Error");
			}
		}
		
		private function handleFault(event:FaultEvent):void {
			state = STATE_COMPLETE;
		}
	}
}