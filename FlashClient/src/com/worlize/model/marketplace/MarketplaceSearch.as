package com.worlize.model.marketplace
{
	import com.worlize.model.WorlizeAsset;
	import com.worlize.model.WorlizeAssetKind;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;

	public class MarketplaceSearch extends EventDispatcher
	{
		public static const STATE_IDLE:String = "idle";
		public static const STATE_LOADING:String = "loading";
		public static const STATE_HAVE_RESULTS:String = "haveResults";
		public static const STATE_ERROR:String = "error";
		
		[Bindable]
		public var state:String = STATE_IDLE;
		
		[Bindable]
		public var results:ArrayCollection;
		
		private var lastQuery:String;
		
		private var client:WorlizeServiceClient;
		
		public function MarketplaceSearch() {
			client = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleSearchResult);
			client.addEventListener(FaultEvent.FAULT, handleSearchFault);
		}
		
		public function search(query:String, assetKind:String = 'background'):void {
			if (query.length == 0) {
				query = "featured";
			}
			var thisQuery:String = query + "___" + assetKind;
			if (lastQuery == thisQuery) {
				return;
			}
			
			lastQuery = thisQuery;
			
			if (client.loading) {
				client.cancel();
			}
			var url:String;
			switch (assetKind) {
				case WorlizeAssetKind.BACKGROUND:
					url = "/marketplace/backgrounds";
					break;
				default:
					throw new Error("Unknown Asset Kind");
					break;
			}
			
			client.send(url, HTTPMethod.GET, {
				q: query
			});
			state = STATE_LOADING;
		}
		
		private function handleSearchResult(event:WorlizeResultEvent):void {
			var e:MarketplaceEvent;
			state = STATE_HAVE_RESULTS;
			var newResults:ArrayCollection = new ArrayCollection();
			if (event.resultJSON.success) {
				for each (var rawData:Object in event.resultJSON.data) {
					var item:WorlizeAsset = WorlizeAsset.fromData(rawData, WorlizeAssetKind.BACKGROUND);
					newResults.addItem(item);
				}
				results = newResults;
				e = new MarketplaceEvent(MarketplaceEvent.RESULT);
				e.result = newResults;
				dispatchEvent(e);
				return;
			}
			else {
				e = new MarketplaceEvent(MarketplaceEvent.FAULT);
				dispatchEvent(e);
			}
		}
		private function handleSearchFault(event:FaultEvent):void {
			var e:MarketplaceEvent;
			state = STATE_ERROR;
			e = new MarketplaceEvent(MarketplaceEvent.FAULT);
			dispatchEvent(e);
		}
	}
}