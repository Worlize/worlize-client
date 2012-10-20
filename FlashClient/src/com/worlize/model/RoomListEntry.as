package com.worlize.model
{
	import mx.utils.ObjectProxy;

	[Bindable]
	public class RoomListEntry
	{
		public var name:String;
		public var userCount:int;
		public var guid:String;
		public var thumbnail:String;
		public var worldGuid:String;
		public var hidden:Boolean;
		public var noDirectEntry:Boolean;
		public var locked:Boolean;
		public var properties:ObjectProxy;
		
		public static function fromData(data:Object):RoomListEntry {
			var obj:RoomListEntry = new RoomListEntry();
			obj.name = data.name;
			obj.userCount = data.user_count;
			obj.guid = data.guid;
			obj.worldGuid = data.world_guid;
			obj.hidden = data.hidden;
			obj.noDirectEntry = data.no_direct_entry;
			obj.locked = data.locked;
			obj.properties = new ObjectProxy(data.properties);
			if (data.thumbnail) {
				obj.thumbnail = data.thumbnail;				
			}
			return obj;
		}
		
		public function clone():RoomListEntry {
			var e:RoomListEntry = new RoomListEntry();
			e.name = name;
			e.userCount = userCount;
			e.guid = guid;
			e.thumbnail = thumbnail;
			e.worldGuid = worldGuid;
			e.hidden = hidden;
			e.noDirectEntry = noDirectEntry;
			e.locked = locked;
			e.properties = new ObjectProxy();
			for (var key:String in properties) {
				e.properties[key] = properties[key];
			}
			return e;
		}
		
		public function toJSON(k:String):* {
			var props:Object = {};
			for (var key:String in properties) {
				props[key] = properties[key];
			}
			return {
				name: name,
				userCount: userCount,
				guid: guid,
				thumbnail: thumbnail,
				hidden: hidden,
				no_direct_entry: noDirectEntry,
				locked: locked,
				properties: props
			};
		}
	}
}