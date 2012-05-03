package com.worlize.model
{
	import com.adobe.utils.DateUtil;
	import com.worlize.model.locker.AvatarLocker;
	import com.worlize.model.locker.PropLocker;
	import com.worlize.model.locker.Slots;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import mx.collections.ArrayList;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;

	[Bindable]
	public class CurrentUser
	{
		private static var _instance:CurrentUser;
		
		private var logger:ILogger = Log.getLogger("com.worlize.model.CurrentUser");
		
		public var guid:String;
		public var admin:Boolean;
		public var developer:Boolean;
		public var createdAt:Date;
		public var passwordChangedAt:Date;
		public var username:String;
		public var name:String;
		public var coins:int;
		public var bucks:int;
		public var slots:Slots = new Slots();
		public var email:String;
		public var birthday:Date;
		public var state:String;
		public var worldEntrance:String;
		public var worldName:String;
		public var worldGuid:String;
		public var linkedProfiles:ArrayList;
		
		
		public function clone():CurrentUser {
			var u:CurrentUser = new CurrentUser();
			u.guid = guid;
			u.admin = admin;
			u.developer = developer;
			u.createdAt = createdAt;
			u.passwordChangedAt = passwordChangedAt;
			u.username = username;
			u.name = name;
			u.coins = coins;
			u.bucks = bucks;
			u.email = email;
			u.birthday = birthday;
			u.state = state;
			u.worldEntrance = worldEntrance;
			u.worldName = worldName;
			u.worldGuid = worldGuid;
			u.linkedProfiles = new ArrayList();
			for (var i:int = 0; i < linkedProfiles.length; i++) {
				var profile:LinkedProfile = LinkedProfile(linkedProfiles.getItemAt(i));
				u.linkedProfiles.addItem(profile.clone());
			}
			return u;
		}
		
		public static function getInstance():CurrentUser {
			if (_instance === null) {
				_instance = new CurrentUser();
			}
			return _instance;
		}
		
		public function addLinkedProfile(profile:LinkedProfile):void {
			linkedProfiles.addItem(profile);
		}
		
		public function removeLinkedProfile(provider:String):void {
			for (var i:int = 0; i < linkedProfiles.length; i ++) {
				var profile:LinkedProfile = LinkedProfile(linkedProfiles.getItemAt(i));
				if (profile.provider === provider) {
					linkedProfiles.removeItemAt(i);
					return;
				}
			}
		}

		public function load(guid:String):void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send('/me.json', HTTPMethod.GET);
		}
		
		public function updateFromData(data:Object):void {
			admin = data.admin;
			developer = data.developer;
			slots.avatarSlots = data.avatar_slots;
			slots.backgroundSlots = data.background_slots;
			slots.inWorldObjectSlots = data.in_world_object_slots;
			slots.propSlots = data.prop_slots;
			if (data.birthday) {
				birthday = new Date(Date.parse(data.birthday.replace(/-/g, '/')));					
			}
			if (data.password_changed_at) {
				passwordChangedAt = DateUtil.parseW3CDTF(data.password_changed_at);
			}
			bucks = data.bucks;
			coins = data.coins;
			createdAt = DateUtil.parseW3CDTF(data.created_at);
			email = data.email;
			guid = data.guid;
			state = data.state;
			username = data.username;
			name = data.name;
			worldEntrance = data.world_entrance;
			worldName = data.world_name;
			worldGuid = data.world_guid;
			linkedProfiles = new ArrayList();
			for each (var profileData:Object in data.authentications) {
				linkedProfiles.addItem(LinkedProfile.fromData(profileData));
			}
		}
		
		private function handleResult(event:WorlizeResultEvent):void {
			if (event.resultJSON.success) {
				updateFromData(event.resultJSON.data);
			}
		}
		
		private function handleFault(event:FaultEvent):void {
			logger.error("There was an error loading the user data.");
		}
	}
}