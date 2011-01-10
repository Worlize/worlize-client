package com.worlize.control
{
	import com.google.analytics.GATracker;
	import com.google.analytics.v4.Configuration;
	
	import mx.managers.SystemManager;

	public class Analytics
	{
		public static const VISUAL_DEBUG:Boolean = false;
		
		public var tracker:GATracker;
		private static var instance:Analytics;
		
		public static function getInstance():Analytics {
			if (instance === null) {
				instance = new Analytics();
			}
			return instance;
		}
		
		function Analytics() {
			if (tracker !== null) {
				throw new Error("You can only create one instance of Analytics");
			}
			tracker = new GATracker(SystemManager.getSWFRoot(this), "window._flashtracker", "Bridge", VISUAL_DEBUG);
		}
	}
}