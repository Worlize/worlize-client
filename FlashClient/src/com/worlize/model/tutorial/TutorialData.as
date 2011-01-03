package com.worlize.model.tutorial
{
	import com.worlize.event.PreferencesEvent;
	import com.worlize.event.TutorialEvent;
	import com.worlize.model.PreferencesManager;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;

	public class TutorialData extends EventDispatcher
	{
		private var preferences:PreferencesManager;
		
		public var slides:Vector.<TutorialSlideDefinition>;
		
		function TutorialData() {
			preferences = PreferencesManager.getInstance();
			if (preferences.initialized) {
				checkWhetherToLaunchTutorial();
			}
			else {
				preferences.addEventListener(PreferencesEvent.PREFERENCES_INITIALIZED, function(event:PreferencesEvent):void {
					checkWhetherToLaunchTutorial();
				});
			}
		}
		
		public function set skipTutorial(newValue:Boolean):void {
			if (preferences.getPreference('skipTutorial') != newValue) {
				preferences.setPreference('skipTutorial', newValue);
			}
		}
		public function get skipTutorial():Boolean {
			return preferences.getPreference('skipTutorial');
		}
		
		public function loadData():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				slides = new Vector.<TutorialSlideDefinition>();
				for each (var slideData:Object in event.resultJSON.slides) {
					var slide:TutorialSlideDefinition = TutorialSlideDefinition.fromData(slideData);
					slides.push(slide);
				}
				var launchEvent:TutorialEvent = new TutorialEvent(TutorialEvent.LAUNCH_TUTORIAL);
				dispatchEvent(launchEvent);
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("A fault was encountered while trying to load the tutorial.", "Error");
			});
			client.send("/tutorial/data.json", HTTPMethod.GET);
		}
		
		private function checkWhetherToLaunchTutorial():void {
			if (!skipTutorial) {
				loadData();
			}
		}
		
		public function closeTutorial():void {
			var event:TutorialEvent = new TutorialEvent(TutorialEvent.CLOSE_TUTORIAL);
			dispatchEvent(event);
		}
	}
}