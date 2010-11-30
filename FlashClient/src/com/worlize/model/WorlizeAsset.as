package com.worlize.model
{
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	
	// TODO: Build subclasses for different asset types.
	
	[Bindable]
	public class WorlizeAsset extends EventDispatcher
	{
		public var name:String;
		public var description:String;
		public var guid:String;
		public var saleCoins:uint;
		public var saleBucks:uint;
		public var imageURL:ImageURL;
		public var kind:String;
		
		public function WorlizeAsset(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function buy():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			var keyword:String;
			switch (kind) {
				case WorlizeAssetKind.BACKGROUND:
					keyword = "backgrounds";
					break;
				default:
					throw new Error("Unhandled asset type " + kind);
					break;
			}
			var url:String = "/marketplace/" + keyword + "/" + guid + "/buy.json";
			client.addEventListener(WorlizeResultEvent.RESULT, handleBuyResult);
			client.addEventListener(FaultEvent.FAULT, handleBuyFault);
			client.send(url, HTTPMethod.POST);
		}
		
		private function handleBuyResult(event:WorlizeResultEvent):void {
			if (event.resultJSON.success) {
				Alert.show("You successfully purchased " + name + "!");
			}
			else {
				Alert.show(event.resultJSON.description);
			}
			trace(event.result);
		}
		
		private function handleBuyFault(event:FaultEvent):void {
			
		}
		
		public static function fromData(data:Object, kind:String):WorlizeAsset {
			var o:WorlizeAsset = new WorlizeAsset();
			o.name = data.name;
			if (data.description) {
				o.description = data.description;
			}
			else {
				o.description = "No description available.";
			}
			o.guid = data.guid;
			o.saleCoins = data.sale_coins; 
			o.saleBucks = data.sale_bucks;
			o.imageURL = new ImageURL();
			o.imageURL.fullsize = data.fullsize;
			o.imageURL.medium = data.medium;
			o.imageURL.thumbnail = data.thumbnail;
			o.kind = kind;
			return o;
		}
	}
}