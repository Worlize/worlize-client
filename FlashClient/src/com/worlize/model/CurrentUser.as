package com.worlize.model
{
	import com.adobe.utils.DateUtil;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import mx.rpc.events.FaultEvent;

	[Bindable]
	public class CurrentUser
	{
		public function CurrentUser()
		{
			if (_instance !== null) {
				throw new Error("You can only create one instance of CurrentUser");
			}
		}
		
		private static var _instance:CurrentUser;
		
		public var guid:String;
		public var admin:Boolean;
		public var createdAt:Date;
		public var username:String;
		public var firstName:String;
		public var lastName:String;
		public var coins:int;
		public var bucks:int;
		public var backgroundSlots:int;
		public var avatarSlots:int;
		public var propSlots:int;
		public var inWorldObjectSlots:int;
		public var twitter:String;
		public var email:String;
		public var birthday:Date;
		public var state:String;
		public var worldEntrance:String;
		public var worldName:String;
		public var worldGuid:String;
		
		public static function getInstance():CurrentUser {
			if (_instance === null) {
				_instance = new CurrentUser();
			}
			return _instance;
		}

		public function load(guid:String):void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send('/users/' + guid + ".json", HTTPMethod.GET);
		}
		
		private function handleResult(event:WorlizeResultEvent):void {
			if (event.resultJSON.success) {
				var data:Object = event.resultJSON.data;
				admin = data.admin;
				avatarSlots = data.avatar_slots;
				backgroundSlots = data.background_slots;
				inWorldObjectSlots = data.in_world_object_slots;
				propSlots = data.prop_lots;
				if (data.birthday) {
					birthday = new Date(Date.parse(data.birthday.replace(/-/g, '/')));					
				}
				bucks = data.bucks;
				coins = data.coins;
				createdAt = DateUtil.parseW3CDTF(data.created_at);
				email = data.email;
				guid = data.guid;
				state = data.state;
				twitter = data.twitter;
				username = data.username;
				firstName = data.first_name;
				lastName = data.last_name;
				worldEntrance = data.world_entrance;
				worldName = data.world_name;
				worldGuid = data.world_guid;
			}
		}
		
		private function handleFault(event:FaultEvent):void {
			trace("There was an error loading the user data.");
		}
	}
}