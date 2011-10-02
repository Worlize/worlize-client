package com.worlize.rpc
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class RoomConnection extends EventDispatcher
	{
		public function RoomConnection(target:IEventDispatcher=null)
		{
			super(target);
		}
	}
}