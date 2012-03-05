package com.worlize.api.model
{
	import com.worlize.worlize_internal;
	
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	public class Hotspot extends EventDispatcher
	{
		use namespace worlize_internal;
		
		private var _x:Number;
		private var _y:Number;
		private var _points:Vector.<Point>;
		
		worlize_internal static function fromData(data:Object):Hotspot {
			var hotspot:Hotspot = new Hotspot();
			
			return hotspot;
		}
	}
}