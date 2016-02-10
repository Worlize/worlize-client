package com.worlize.util
{
	public class ISO8601Duration
	{
		private static const names:Array = ['years', 'months', 'days', 'hours', 'minutes', 'seconds'];
		private static const thresholds:Array = [false, 12, false, 24, 60, 60];
		
		private var hasWeeks:Boolean = false;
		public var weeks:Number = 0;
		public var years:Number = 0;
		public var months:Number = 0;
		public var days:Number = 0;
		public var hours:Number = 0;
		public var minutes:Number = 0;
		public var seconds:Number = 0;
		
		public static function invert(duration:ISO8601Duration):Object {
			var ret:ISO8601Duration = new ISO8601Duration();
			
			if (duration.hasWeeks) {
				ret.weeks = -duration.weeks;
			}
			else {
				ret.years = -duration.years;
				ret.months = -duration.months;
				ret.days = -duration.days;
				ret.hours = -duration.hours;
				ret.minutes = -duration.minutes;
				ret.seconds = -duration.seconds;
			}
			
			return ret;
		}
		
		public static function parse(str:String):ISO8601Duration {
			var ret:ISO8601Duration = new ISO8601Duration();
			
			str = str.replace(/,/g, '.');
			var weekMatches:Array = str.match(/^P(\d+(?:\.\d+)?)W$/);
			if (weekMatches) {
				ret.weeks = parseInt(weekMatches[1], 10);
				ret.hasWeeks = true;
				return ret;
			}
			
			var parts:Array = [];
			for each (var name:String in ISO8601Duration.names) {
				parts.push('(?:(\\d+(?:\\.\\d+)?)' + name.charAt(0).toUpperCase() + ')?');
			}
			
			var pattern:String = '^P' + parts.slice(0,3).join('') + '(?:T' +
								 parts.slice(3).join('') + ')?\$';
			
			var matches:Array = str.match(pattern);
			
			if (!matches) {
				throw new Error(str + ' is not a valid ISO 8601 duration');
			}
			
			matches = matches.slice(1);
			for (var i:int=0; i < matches.length; i ++) { 
				matches[i] = parseInt(matches[i], 10);
			}
			
			for (i=0; i < ISO8601Duration.names.length; i ++) {
				var match:Number = matches[i];
				name = ISO8601Duration.names[i];
				
				if (!isNaN(match)) {
					ret[name] = match;
				}
			}
			
			return ret;
		}
		
		function ISO8601Duration() {
		}
		
		public function clone():ISO8601Duration {
			var copy:ISO8601Duration = new ISO8601Duration();
			copy.years = this.years;
			copy.months = this.months;
			copy.days = this.days;
			copy.hours = this.hours;
			copy.minutes = this.minutes;
			copy.seconds = this.seconds;
			copy.hasWeeks = this.hasWeeks;
			
			return copy;
		}
		
		public function toString():String {
			if (this.hasWeeks) {
				return 'P' + this.weeks.toString() + 'W';
			}
			
			var ret:String = 'P';
			for (var name:String in ISO8601Duration.names) {
				if (name === 'hours') {
					ret += 'T';
				}
				if (this[name] !== -1) {
					ret += this[name].toString() + name.charAt(0).toUpperCase();
				}
			}
			
			if (ret === 'PT') {
				return 'PT0S';
			}
			
			return ret;
		}
		
		public function valueOf():Number {
			if (this.hasWeeks) {
				return this.weeks * 7 * 24 * 60 * 60;
			}
			if (this.years || this.months) {
				throw new Error("can only cast durations of less than P1M to number");
			}
			return ((this.days * 24 + this.hours) * 60 + this.minutes) * 60 + this.seconds;
		}
	}
}