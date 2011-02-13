package com.worlize.notification
{
	import flash.events.Event;
	
	public class FinancialNotification extends Event
	{
		public static const FINANCIAL_BALANCE_CHANGE:String = "financialBalanceChange";
		
		public var coins:int;
		public var bucks:int;
		
		public function FinancialNotification(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}