package com.worlize.model
{
	import com.adobe.utils.DateUtil;
	import com.worlize.model.locker.Slots;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
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
		
		private var logger:ILogger = Log.getLogger("com.worlize.model.CurrentUser");
		
		public var guid:String;
		public var admin:Boolean;
		public var developer:Boolean;
		public var createdAt:Date;
		public var username:String;
		public var name:String;
		public var coins:int;
		public var bucks:int;
		public var slots:Slots = new Slots();
		public var twitter:String;
		public var twitterProfile:String;
		public var facebookProfile:String;
		public var facebookId:String;
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
		
		public function updateFromData(data:Object):void {
			admin = data.admin;
			developer = data.developer;
			slots.avatarSlots = data.avatar_slots;
			slots.backgroundSlots = data.background_slots;
			slots.inWorldObjectSlots = data.in_world_object_slots;
			slots.propSlots = data.prop_lots;
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
			facebookProfile = data.facebook_profile;
			twitterProfile = data.twitter_profile;
			facebookId = data.facebook_id;
			username = data.username;
			name = data.name;
			worldEntrance = data.world_entrance;
			worldName = data.world_name;
			worldGuid = data.world_guid;
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