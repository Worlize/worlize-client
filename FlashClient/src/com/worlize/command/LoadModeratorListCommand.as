package com.worlize.command
{
	import com.worlize.interactivity.model.InteractivityUser;
	import com.worlize.model.WorldDefinition;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	
	public class LoadModeratorListCommand extends EventDispatcher
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_COMPLETE:String = "complete";
		
		[Bindable]
		public var state:String = STATE_INIT;
		
		[Bindable]
		public var world:WorldDefinition;
				
		public function LoadModeratorListCommand(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function execute(world:WorldDefinition):void {
			if (state === STATE_LOADING) { return; }
			state = STATE_LOADING;
			this.world = world;
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send("/worlds/" + world.guid + "/moderators", HTTPMethod.GET);
		}
		
		private function handleResult(event:WorlizeResultEvent):void {
			state = STATE_COMPLETE;
			if (!event.resultJSON.success) {
				Alert.show("Unable to load moderator list: " + event.resultJSON.message, "Error");
				return;
			}
			world.moderators.disableAutoUpdate();
			world.moderators.removeAll();
			for each (var moderatorData:Object in event.resultJSON.moderators) {
				var moderator:InteractivityUser = new InteractivityUser();
				moderator.name = moderatorData.username;
				moderator.id = moderatorData.guid;
				moderator.globalPermissions = moderatorData.permissions.global;
				moderator.worldPermissions = moderatorData.permissions.world;
				moderator.appliedPermissions = moderatorData.permissions.applied;
				world.moderators.addItem(moderator);
			}
			world.moderators.enableAutoUpdate();
			dispatchEvent(event);
		}
		
		private function handleFault(event:FaultEvent):void {
			state = STATE_COMPLETE;
		}
	}
}