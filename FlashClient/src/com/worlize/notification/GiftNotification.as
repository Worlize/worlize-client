package com.worlize.notification
{
	import com.worlize.model.UserListEntry;
	import com.worlize.model.gifts.Gift;
	
	import flash.events.Event;

	public class GiftNotification extends Event
	{
		public static const GIFT_ACCEPTED:String = "giftAccepted";
		public static const GIFT_REJECTED:String = "giftRejected";
		public static const GIFT_RECEIVED:String = "giftReceived";
		
		public var gift:Gift;
		public var sender:UserListEntry;
		
		public function GiftNotification(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}