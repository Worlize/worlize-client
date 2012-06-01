package com.worlize.model
{
	import com.worlize.command.GetAnotherAppCopyCommand;
	import com.worlize.event.NotificationCenter;
	import com.worlize.notification.AppNotification;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;

	[Bindable]
	public class App
	{
		public var guid:String;
		public var creatorGuid:String;
		public var name:String;
		public var description:String;
		public var tagline:String;
		public var help:String;
		public var iconURL:String;
		public var mediumIconURL:String;
		public var smallIconURL:String;
		public var appURL:String;
		public var width:uint;
		public var height:uint;
		
		private static var logger:ILogger = Log.getLogger("com.worlize.model.App"); 
		
		public function requestDelete():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, handleDeleteResult);
			client.addEventListener(FaultEvent.FAULT, handleFault);
			client.send("/locker/apps/" + guid + "/destroy_all_copies.json", HTTPMethod.POST);
		}
		
		private function handleDeleteResult(event:WorlizeResultEvent):void {
			if (event.resultJSON.success) {
				for each (var guid:String in event.resultJSON.instances) {
					var notification:AppNotification = new AppNotification(AppNotification.APP_INSTANCE_DELETED);
					notification.instanceGuid = guid;
					NotificationCenter.postNotification(notification);
				}
			}
		}
		
		private function handleFault(event:FaultEvent):void {
			logger.error("App " + guid + " delete all instances failed. " + event);
		}
		
		public function requestAnotherCopy():void {
			(new GetAnotherAppCopyCommand()).execute(this);
		}
		
		public static function fromData(data:Object):App {
			var app:App = new App();
			app.guid = data.guid;
			app.creatorGuid = data.creator;
			app.name = data.name;
			app.description = data.description;
			app.tagline = data.tagline;
			app.help = data.help;
			app.appURL = data.app_url;
			app.iconURL = data.icon;
			app.mediumIconURL = data.medium_icon;
			app.smallIconURL = data.small_icon;
			return app;
		}
	}
}