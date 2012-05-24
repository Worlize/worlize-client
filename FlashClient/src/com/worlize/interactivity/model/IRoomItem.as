package com.worlize.interactivity.model
{
	public interface IRoomItem
	{
		function get guid():String;
		function set guid(newValue:String):void;
		function get x():int;
		function set x(newValue:int):void;
		function get y():int;
		function set y(newValue:int):void;
	}
}