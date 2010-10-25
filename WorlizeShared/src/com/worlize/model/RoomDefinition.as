package com.worlize.model
{
	import com.worlize.interactivity.model.Hotspot;

	public class RoomDefinition
	{
		public var name:String;
		public var guid:String;
		public var world:WorldDefinition;
		public var backgroundImageURL:String;
		public var objectInstances:Vector.<ObjectInstance> = new Vector.<ObjectInstance>();
		public var hotspots:Vector.<Hotspot> = new Vector.<Hotspot>();
		
		public function RoomDefinition()
		{
		}
		
		public static function fromData(data:Object):RoomDefinition {
			var room:RoomDefinition = new RoomDefinition();
			room.name = String(data.name);
			if (data.guid) {
				room.guid = String(data.guid);
			}
			room.world = new WorldDefinition();
			if (data.world_guid) {
				// load world data...
			}
			if (data.background) {
				room.backgroundImageURL = String(data.background);
			}
			if (data.hotspots) {
				for each(var hotspotData:Object in data.hotspots) {
					room.hotspots.push(Hotspot.fromData(hotspotData));
				}
			}
			return room;
		}
	}
}