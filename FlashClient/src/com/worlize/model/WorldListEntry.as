package com.worlize.model
{
	[Bindable]
	public class WorldListEntry
	{
		public var name:String;
		public var guid:String;
		public var entrance:String;
		public var population:int;
		
		public static function fromData(data:Object):WorldListEntry {
			var instance:WorldListEntry = new WorldListEntry();
			instance.name = data.name;
			instance.guid = data.guid;
			instance.entrance = data.entrance;
			instance.population = data.population;
			return instance;
		}
	}
}