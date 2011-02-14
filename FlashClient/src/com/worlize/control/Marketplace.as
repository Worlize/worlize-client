package com.worlize.control
{
	import flash.external.ExternalInterface;

	public class Marketplace
	{
		public static function open():void {
			ExternalInterface.call('openMarketplace');
		}
		
		public static function close():void {
			ExternalInterface.call('closeMarketplace');
		}
		
		[Bindable]
		public static var marketplaceEnabled:Boolean = true;
	}
}