package com.worlize.model
{
	[Bindable]
	public class RoomListEntry
	{
		public var name:String;
		public var userCount:int;
		public var guid:String;
		public var thumbnail:String;
		public var worldGuid:String;
		public var hidden:Boolean;
		public var maxOccupancy:uint;
		public var allowCascadeWhenFull:Boolean;
		public var moderatorsOnly:Boolean;
		public var noDirectEntry:Boolean;
		public var locked:Boolean;
		public var properties:RoomProperties;
		
		public static function fromData(data:Object):RoomListEntry {
			var obj:RoomListEntry = new RoomListEntry();
			obj.name = data.name;
			obj.userCount = data.user_count;
			obj.guid = data.guid;
			obj.worldGuid = data.world_guid;
			obj.hidden = data.hidden;
			obj.maxOccupancy = data.max_occupancy;
			obj.allowCascadeWhenFull = data.allow_cascade_when_full;
			obj.moderatorsOnly = data.moderators_only;
			obj.noDirectEntry = data.no_direct_entry;
			obj.locked = data.locked;
			obj.properties = RoomProperties.fromData(data.properties);
			if (data.thumbnail) {
				obj.thumbnail = data.thumbnail;				
			}
			return obj;
		}
		
		public function get full():Boolean {
			return userCount >= maxOccupancy;
		}
		
		public function clone():RoomListEntry {
			var e:RoomListEntry = new RoomListEntry();
			e.name = name;
			e.userCount = userCount;
			e.guid = guid;
			e.thumbnail = thumbnail;
			e.worldGuid = worldGuid;
			e.hidden = hidden;
			e.maxOccupancy = maxOccupancy;
			e.allowCascadeWhenFull = allowCascadeWhenFull;
			e.moderatorsOnly = moderatorsOnly;
			e.noDirectEntry = noDirectEntry;
			e.locked = locked;
			e.properties = properties.clone();
			return e;
		}
		
		public function toJSON(k:String):* {
			return {
				name: name,
				userCount: userCount,
				guid: guid,
				thumbnail: thumbnail,
				hidden: hidden,
				max_occupancy: maxOccupancy,
				allow_cascade_when_full: allowCascadeWhenFull,
				moderators_only: moderatorsOnly,
				no_direct_entry: noDirectEntry,
				locked: locked,
				properties: properties
			};
		}
	}
}