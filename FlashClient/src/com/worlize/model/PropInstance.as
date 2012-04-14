package com.worlize.model
{
	import com.worlize.command.DeletePropInstanceCommand;

	[Bindable]
	public class PropInstance
	{
		public var guid:String;
		public var userGuid:String;
		public var gifter:UserListEntry;
		public var emptySlot:Boolean = false;
		public var prop:Prop;
		
		public static function fromData(data:Object):PropInstance {
			var pi:PropInstance = new PropInstance();
			pi.guid = data.guid;
			pi.userGuid = data.user_guid;
			if (data.gifter) {
				var gifter:UserListEntry = new UserListEntry();
				gifter.userGuid = data.gifter.guid;
				gifter.username = data.gifter.username;
				pi.gifter = gifter;
			}
			pi.prop = Prop.fromData(data.prop);
			return pi;
		}
		
		public function requestDelete():void {
			var command:DeletePropInstanceCommand = new DeletePropInstanceCommand();
			command.execute(guid);
		}
	}
}