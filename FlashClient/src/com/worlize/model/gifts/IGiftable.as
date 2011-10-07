package com.worlize.model.gifts
{
	import com.worlize.model.friends.FriendsListEntry;

	public interface IGiftable
	{
		function sendAsGift(recipient:FriendsListEntry, callback:Function=null):void;
	}
}