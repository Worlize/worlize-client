package com.worlize.api.data
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import com.worlize.worlize_internal;
	
	public class SharedArray extends EventDispatcher
	{
		use namespace worlize_internal;
		
		public function SharedArray(source:Array = null)
		{
			super(null);
			if (source !== null) {
				reset(source);
			}
		}
		
		public function reset(data:Array=null):void {
			
		}
		
		public function push(element:*, callback:Function=null):void {
			
		}
		
		public function pop(callback:Function):void {
			
		}
		
		public function shift(callback:Function):void {
			
		}
		
		public function unshift(element:*, callback:Function=null):void {
			
		}
	}
}