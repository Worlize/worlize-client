package com.worlize.model
{
	import com.worlize.interactivity.model.Hotspot;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;

	public class RoomDefinition
	{
		public var name:String;
		public var guid:String;
		public var world:WorldDefinition;
		public var backgroundImageURL:String;
		public var hotspots:Vector.<Hotspot> = new Vector.<Hotspot>();
		public var objects:Array = [];
		
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
			if (data.objects) {
				room.objects = data.objects;
			}
			return room;
		}
		
		public function addObjectInstance(instanceData:Object, x:int, y:int):void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (!event.resultJSON.success) {
					Alert.show(event.resultJSON.description, "Error");
				}
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was an unknown error while adding the object.", "Error");
			});
			client.send("/rooms/" + guid + "/objects.json", HTTPMethod.POST, {
				"in_world_object_instance_guid": instanceData.guid,
				"x": x,
				"y": y
			});
		}
		
		public function moveObjectInstance(instanceGuid:String, x:int, y:int):void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (!event.resultJSON.success) {
					Alert.show(event.resultJSON.description, "Error");
				}
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was an unknown error while moving the object.", "Error");
			});
			client.send("/rooms/" + guid + "/objects/" + instanceGuid + ".json", HTTPMethod.PUT, {
				"x": x,
				"y": y
			});
		}
		
		public function setObjectInstanceDestination(instanceGuid:String, dest:String):void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (!event.resultJSON.success) {
					Alert.show(event.resultJSON.description, "Error");
				}
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was an unknown error while updating the object's destination.", "Error");
			});
			client.send("/rooms/" + guid + "/objects/" + instanceGuid + ".json", HTTPMethod.PUT, {
				"dest": dest
			});
		}
		
		public function deleteObjectInstance(instanceGuid:String):void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (!event.resultJSON.success) {
					Alert.show(event.resultJSON.description, "Error");
				}
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was an unknown error while moving the object.", "Error");
			});
			client.send("/rooms/" + guid + "/objects/" + instanceGuid + ".json", HTTPMethod.DELETE);
		}
	}
}