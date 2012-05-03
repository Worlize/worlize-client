package com.worlize.model
{
	import com.worlize.interactivity.rpc.InteractivityClient;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.rpc.events.FaultEvent;
	
	public class UserList extends EventDispatcher
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_READY:String = "ready";
		public static const STATE_ERROR:String = "error";
		
		[Bindable]
		public var state:String = STATE_INIT;
		
		[Bindable]
		public var users:ArrayCollection = new ArrayCollection();
		
		[Bindable]
		public var worldGuid:String;
		
		public function UserList(target:IEventDispatcher=null)
		{
			super(target);
			var sort:Sort = new Sort();
			sort.fields = [
				new SortField('username', true, false)
			];
			users.sort = sort;
			users.refresh();
		}
		
		public function clone():UserList {
			var ul:UserList = new UserList();
			ul.state = state;
			ul.worldGuid = worldGuid;
			for each (var entry:UserListEntry in users) {
				ul.users.addItem(entry.clone());
			}
			return ul;
		}
		
		public function getUserByGuid(guid:String):UserListEntry {
			for each (var user:UserListEntry in users) {
				if (user.userGuid === guid) {
					return user;
				}
			}
			return null;
		}
		
		
		public function load(worldGuid:String=null):void {
			if (worldGuid) {
				this.worldGuid = worldGuid;
			}
			if (this.worldGuid === null || state === STATE_LOADING) { return; }
			state = STATE_LOADING;
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				var roomList:RoomList = InteractivityClient.getInstance().currentWorld.roomList;
				if (event.resultJSON.success) {
					users.disableAutoUpdate();
					users.removeAll();
					for each (var userListEntry:Object in event.resultJSON.data) {
						users.addItem(UserListEntry.fromData(userListEntry, roomList));
					}
					users.enableAutoUpdate();
					state = STATE_READY;
				}
				else {
					state = STATE_ERROR;
				}
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				state = STATE_ERROR;
			});
			client.send("/worlds/" + this.worldGuid + "/user_list.json", HTTPMethod.GET);
		}
	}
}