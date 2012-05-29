package com.worlize.interactivity.model
{
	import flash.events.IEventDispatcher;

	public interface IRoomItem extends IEventDispatcher
	{
		function get guid():String;
		function set guid(newValue:String):void;
		function get x():int;
		function set x(newValue:int):void;
		function get y():int;
		function set y(newValue:int):void;
		function get width():Number;
		function set width(newValue:Number):void;
		function get height():Number;
		function set height(newValue:Number):void;
	}
}