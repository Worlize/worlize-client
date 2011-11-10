package com.worlize.logging
{
	import mx.logging.targets.LineFormattedTarget;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	public class ArrayLogTarget extends LineFormattedTarget
	{
		private var logEntries:Array;
		
		public var maxLogEntries:uint = 250;
		
		public function ArrayLogTarget()
		{
			super();
			logEntries = [];
		}
		
		public function getLogText():String {
			return logEntries.join("\n");
		}
		
		/**
		 *  @private
		 *  This method outputs the specified message directly to 
		 *  <code>trace()</code>.
		 *  All output will be directed to flashlog.txt by default.
		 *
		 *  @param message String containing preprocessed log message which may
		 *  include time, date, category, etc. based on property settings,
		 *  such as <code>includeDate</code>, <code>includeCategory</code>, etc.
		 */
		override mx_internal function internalLog(message:String):void
		{
			logEntries.push(message);
			if (logEntries.length > maxLogEntries) {
				logEntries.shift();
			}
		}
	}
}