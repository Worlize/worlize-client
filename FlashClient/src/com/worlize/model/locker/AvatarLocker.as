package com.worlize.model.locker
{
	import com.worlize.model.AvatarInstance;
	import com.worlize.model.SimpleAvatar;
	import com.worlize.model.SimpleAvatarStore;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	
	[Bindable]
	public class AvatarLocker extends EventDispatcher
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_READY:String = "ready";
		public static const STATE_ERROR:String = "error";
		
		public var avatarInstances:ArrayCollection = new ArrayCollection();
		
		public var state:String = STATE_INIT; 
		
		public function AvatarLocker(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function load():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleLoadResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send('/locker/avatars', HTTPMethod.GET);
			state = STATE_LOADING;
		}
		
		private function handleLoadResult(event:WorlizeResultEvent):void {
			var simpleAvatarStore:SimpleAvatarStore = SimpleAvatarStore.getInstance();
			if (event.resultJSON.success) {
				avatarInstances.removeAll();
				for each (var data:Object in event.resultJSON.data) {
					var avatarInstance:AvatarInstance = AvatarInstance.fromData(data);
					avatarInstances.addItem(avatarInstance);
					simpleAvatarStore.injectAvatar(avatarInstance.avatar);
				}
				state = STATE_READY;
			}
			else {
				state = STATE_ERROR;
			}
		}
		
		private function handleFault(event:FaultEvent):void {
			state = STATE_ERROR;
		}
	}
}