package
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;

	public class Preferences extends EventDispatcher
	{
		private var sharedObject:SharedObject;
		
		private static var _instance:Preferences;
		
		public static function getInstance():Preferences {
			if (!_instance) {
				_instance = new Preferences();
			}
			return _instance;
		}
		
		public function Preferences()
		{
			if (_instance) {
				throw new Error("You can only create one Preferences instance");
			}
			sharedObject = SharedObject.getLocal("OpenPalaceBrowserPreferences");
		}
		
		[Bindable(event="hostNameChanged")]
		public function set hostName(newValue:String):void {
			sharedObject.data.hostName = newValue;
			sharedObject.flush();
			dispatchEvent(new Event('hostNameChanged'));
		}
		public function get hostName():String {
			var returnValue:String = sharedObject.data.hostName;
			if (!returnValue) {
				sharedObject.data.hostName = returnValue = "openpalace.org";
				sharedObject.flush();
			}
			return returnValue;
		}
		
		[Bindable(event="portChanged")]
		public function set port(newValue:String):void {
			sharedObject.data.port = newValue;
			sharedObject.flush();
			dispatchEvent(new Event('portChanged'));
		}
		public function get port():String {
			var returnValue:String = sharedObject.data.port;
			if (!returnValue) {
				sharedObject.data.port = returnValue = "9998";
				sharedObject.flush();
			}
			return returnValue;
		}
		
		[Bindable(event="userNameChanged")]
		public function set userName(newValue:String):void {
			sharedObject.data.userName = newValue;
			sharedObject.flush();
			dispatchEvent(new Event('userNameChanged'));
		}
		public function get userName():String {
			var returnValue:String = sharedObject.data.userName;
			if (!returnValue) {
				sharedObject.data.userName = returnValue = "OpenPalace User";
				sharedObject.flush();
			}
			return returnValue;
		}
		
		[Bindable(event="cyborgChanged")]
		public function set cyborg(newValue:String):void {
			sharedObject.data.cyborg = newValue;
			sharedObject.flush();
			dispatchEvent(new Event('cyborgChanged'));
		}
		public function get cyborg():String {
			var returnValue:String = sharedObject.data.cyborg;
			if (!returnValue) {
				sharedObject.data.cyborg = returnValue = "";
				sharedObject.flush();
			}
			return returnValue;
		}
		
		private function get schemaVersion():uint {
			return sharedObject.data.schemaVersion ? sharedObject.data.schemaVersion : 0;
		}
		private function set schemaVersion(newValue:uint):void {
			sharedObject.data.schemaVersion = newValue;
			sharedObject.flush();
		}
		
	}
}