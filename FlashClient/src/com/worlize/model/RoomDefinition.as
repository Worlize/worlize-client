package com.worlize.model
{
	import com.worlize.interactivity.model.Hotspot;
	import com.worlize.interactivity.model.IRoomItem;
	import com.worlize.interactivity.rpc.InteractivityClient;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import mx.controls.Alert;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;

	public class RoomDefinition
	{
		public var name:String;
		public var guid:String;
		public var locked:Boolean;
		public var ownerGuid:String;
		public var world:WorldDefinition;
		public var backgroundImageURL:String;
		public var items:Vector.<IRoomItem> = new Vector.<IRoomItem>;
		public var properties:Object = {};
		
		private static var logger:ILogger = Log.getLogger("com.worlize.model.RoomDefinition");
		
		public function RoomDefinition()
		{
		}
		
		public static function fromData(data:Object):RoomDefinition {
			var room:RoomDefinition = new RoomDefinition();
			room.name = String(data.name);
			room.ownerGuid = data.owner_guid;
			if (data.guid) {
				room.guid = String(data.guid);
			}
			room.locked = Boolean(data.locked);
			room.world = new WorldDefinition();
			if (data.world_guid) {
				// load world data...
			}
			if (data.background) {
				room.backgroundImageURL = String(data.background);
			}
			if (data.items) {
				for each (var itemData:Object in data.items) {
					switch (itemData.type) {
						case "hotspot":
							room.items.push(Hotspot.fromData(itemData));
							break;
						case "app":
						case "object":
							var inWorldObjectInstance:InWorldObjectInstance = InWorldObjectInstance.fromData(itemData);
							var roomListEntry:RoomListEntry = new RoomListEntry();
							roomListEntry.guid = room.guid;
							roomListEntry.name = room.name;
							inWorldObjectInstance.room = roomListEntry;
							room.items.push(inWorldObjectInstance);
							break;
						case "youtubePlayer":
							var youTubePlayerDefinition:YouTubePlayerDefinition = 
								YouTubePlayerDefinition.fromData(itemData);
							youTubePlayerDefinition.roomGuid = room.guid;
							room.items.push(youTubePlayerDefinition);
							break;
						default:
							logger.error("Unsupported room item type: " + itemData.type);
							break;
					}
				}
			}
			if (data.properties) {
				room.properties = data.properties;
			}
			return room;
		}
		
		public function addObjectInstance(instanceData:Object, x:int, y:int):void {
			var client:InteractivityClient = InteractivityClient.getInstance();
			client.addObjectInstance(instanceData.guid, x, y);
		}
		
		public function moveObjectInstance(instanceGuid:String, x:int, y:int):void {
			var client:InteractivityClient = InteractivityClient.getInstance();
			client.moveObjectInstance(instanceGuid, x, y);
		}
		
		public function setObjectInstanceDestination(instanceGuid:String, dest:String):void {
			var client:InteractivityClient = InteractivityClient.getInstance();
			client.setObjectInstanceDest(instanceGuid, dest);
		}
		
		public function deleteObjectInstance(instanceGuid:String):void {
			var client:InteractivityClient = InteractivityClient.getInstance();
			client.removeObjectInstance(instanceGuid);
		}
	}
}