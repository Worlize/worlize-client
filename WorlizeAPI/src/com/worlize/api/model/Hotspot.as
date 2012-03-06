package com.worlize.api.model
{
	import com.worlize.worlize_internal;
	
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	public class Hotspot extends EventDispatcher
	{
		use namespace worlize_internal;
		
		private var _guid:String;
		private var _x:Number;
		private var _y:Number;
		private var _points:Vector.<Point>;
		
		public function toJSON():Object {
			var pointsArray:Array = [];
			for each (var point:Point in _points) {
				pointsArray.push({
					x: point.x,
					y: point.y
				});
			}
			return {
				guid: _guid,
				x: _x,
				y: _y,
				points: pointsArray
			};
		}
		
		worlize_internal static function fromData(data:Object):Hotspot {
			var hotspot:Hotspot = new Hotspot();
			
			return hotspot;
		}
	}
}