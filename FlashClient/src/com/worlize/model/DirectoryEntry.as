package com.worlize.model
{
	import com.worlize.model.friends.FriendsListEntry;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;

	[Bindable]
	public class DirectoryEntry
	{
		public var room:RoomListEntry;
		public var world:WorldListEntry;
		public var friendsInRoom:ArrayList;
		
		public static function fromData(data:Object):DirectoryEntry {
			var instance:DirectoryEntry = new DirectoryEntry();
			instance.room = RoomListEntry.fromData(data.room);
			instance.world = WorldListEntry.fromData(data.world);
			instance.friendsInRoom = new ArrayList();
			for each (var friendData:Object in data.friends_in_room) {
				instance.friendsInRoom.addItem(FriendsListEntry.fromData(friendData));
			}
			return instance;
		}
	}
}