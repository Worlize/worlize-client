package com.worlize.control
{
	import flash.external.ExternalInterface;

	public class VirtualCurrencyProducts
	{
		public static function show():void {
			ExternalInterface.call("openVirtualCurrencyProducts");
		}
		
		public static function hide():void {
			ExternalInterface.call("closeVirtualCurrencyProducts");
		}
	}
}