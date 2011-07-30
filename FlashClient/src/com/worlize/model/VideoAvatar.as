package com.worlize.model
{
	import com.worlize.interactivity.rpc.InteractivityClient;
	
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;
	
	import mx.events.FlexEvent;

	[Bindable]
	public class VideoAvatar
	{
		public var streamName:String = null;
		public var state:String = "init";
		public var muted:Boolean = false;
//		public var netStream:NetStream;
//		
//		public function play(streamName:String=null):void {
//			if (streamName !== null) {
//				this.streamName = streamName;
//			}
//			if (this.streamName === null) {
//				throw new Error("You must specify a stream name to connect to.");
//			}
//			if (netStream) {
//				netStream.close();					
//			}
//			netStream = new NetStream(InteractivityClient.getInstance().currentRoom.netConnection);
//			netStream.addEventListener(NetStatusEvent.NET_STATUS, handleNetStreamNetStatus);
//			netStream.play(this.streamName);
//			trace("Attempting to subscribe to stream " + this.streamName);
//		}
//		
//		public function stop():void {
//			if (netStream) {
//				netStream.close();
//				state = 'stopped';
//			}
//		}
//		
//		private function handleNetStreamNetStatus(event:NetStatusEvent):void {
//			trace("NetConnection: " + event.info.code + " (" + event.info.description + ")");
//			if (event.info.code === 'NetStream.Play.Start') {
//				state = 'playing';
//			}
//		}
	}
}