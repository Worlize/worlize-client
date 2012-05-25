package com.worlize.interactivity.model
{
	public interface ILinkableRoomItem extends IRoomItem
	{
		function get dest():String;
		function set dest(newValue:String):void;
	}
}