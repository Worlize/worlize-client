package com.worlize.event
{
	import mx.events.FlexEvent;
	
	public class LockerEvent extends FlexEvent
	{
		public static const AVATAR_LOCKER_CAPACTIY_CHANGED:String = "avatarLockerCapacityChanged";
		public static const BACKGROUND_LOCKER_CAPACITY_CHANGED:String = "backgroundLockerCapacityChanged";
		public static const IN_WORLD_OBJECT_LOCKER_CAPACITY_CHANGED:String = "inWorldObjectLockerCapacityChanged";
		public static const PROP_LOCKER_CAPACITY_CHANGED:String = "propLockerCapacityChanged";
		public static const APP_LOCKER_CAPACITY_CHANGED:String = "appLockerCapacityChanged";
		
		public var oldCapacity:int;
		public var newCapacity:int;
		
		public function LockerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}