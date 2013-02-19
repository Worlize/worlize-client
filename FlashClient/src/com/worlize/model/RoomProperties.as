package com.worlize.model
{
	[Bindable]	
	public class RoomProperties
	{
		public var snowEnabled:Boolean;
		public var noWebcams:Boolean;
		public var noAvatars:Boolean;
		public var noProps:Boolean;
		
		public static function fromData(data:Object):RoomProperties {
			var o:RoomProperties = new RoomProperties();
			if (data === null) { return o; }
			o.snowEnabled = Boolean(data.snowEnabled);
			o.noWebcams = Boolean(data.noWebcams);
			o.noAvatars = Boolean(data.noAvatars);
			o.noProps = Boolean(data.noProps);
			return o;
		}
		
		public function clone():RoomProperties {
			var o:RoomProperties = new RoomProperties();
			o.snowEnabled = snowEnabled;
			o.noWebcams = noWebcams;
			o.noAvatars = noAvatars;
			o.noProps = noProps;
			return o;
		}
		
		public function toJSON(k:String):* {
			return {
				snowEnabled: snowEnabled,
				noWebcams: noWebcams,
				noAvatars: noAvatars,
				noProps: noProps
			};
		}
	}
}