package com.worlize.model
{
	import com.worlize.event.AvatarEvent;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.rpc.events.FaultEvent;
	
	public class SimpleAvatarStore extends EventDispatcher
	{
		private var avatars:Object;
		
		private static var _instance:SimpleAvatarStore;
		
		public static function getInstance():SimpleAvatarStore {
			if (_instance == null) {
				_instance = new SimpleAvatarStore();
			}
			return _instance;
		}
		
		public function SimpleAvatarStore(target:IEventDispatcher=null)
		{
			super(target);
			if (_instance != null) {
				throw new Error("You may only create one instance of SimpleAvatarStore");
			}
			avatars = {};
		}
		
		public function getAvatar(guid:String):SimpleAvatar {
			var avatar:SimpleAvatar = avatars[guid];
			if (avatar == null) {
				avatar = new SimpleAvatar();
				avatar.guid = guid;
				avatars[guid] = avatar;
				loadAvatar(avatar);
			}
			return avatar;
		}
		
		public function injectAvatar(avatar:SimpleAvatar):void {
			avatars[avatar.guid] = avatar; 
		}
		
		public function removeAvatar(avatar:SimpleAvatar):void {
			delete avatars[avatar.guid];
		}
		
		private function loadAvatar(avatar:SimpleAvatar):void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT,
				function(event:WorlizeResultEvent):void {
					if (event.resultJSON.success) {
						var data:Object = event.resultJSON.data;
						avatar.fromData(data);
						var loadedEvent:AvatarEvent = new AvatarEvent(AvatarEvent.AVATAR_LOADED);
						avatar.dispatchEvent(loadedEvent);
					}
					else {
						avatar.error = true;
						var errorEvent:AvatarEvent = new AvatarEvent(AvatarEvent.AVATAR_ERROR);
						avatar.dispatchEvent(errorEvent);
						removeAvatar(avatar);
					}
				});
			client.addEventListener(FaultEvent.FAULT,
				function(event:FaultEvent):void {
					avatar.error = true;
					var errorEvent:AvatarEvent = new AvatarEvent(AvatarEvent.AVATAR_ERROR);
					avatar.dispatchEvent(errorEvent);
					removeAvatar(avatar);
				});
			client.send('/avatars/' + avatar.guid, HTTPMethod.GET);
		}
	}
}