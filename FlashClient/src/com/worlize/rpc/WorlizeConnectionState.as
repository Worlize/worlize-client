package com.worlize.rpc
{
	public final class WorlizeConnectionState
	{
		// Init state means we haven't attempted to connect yet.
		public static var INIT:String = "init";
		
		// Disconnected means that we were previously connected
		public static var DISCONNECTED:String = "disconnected";
		
		// Attempting to connect
		public static var CONNECTING:String = "connecting";
		
		// Connected and ready to go
		public static var CONNECTED:String = "connected";
	}
}