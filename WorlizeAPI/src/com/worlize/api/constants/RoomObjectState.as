package com.worlize.api.constants
{
	/**
	 * This class enumerates the possible states in the object (app) lifecycle
	 * 
	 * @author theturtle32
	 */	
	public final class RoomObjectState
	{
		/**
		 * An object's state before loading begins.
		 * 
		 * @productversion Worlize APIv.1
		 */
		public static const INIT:String = "init";
		
		/**
		 * An object's state while loading.
		 * 
		 * @productversion Worlize APIv.1
		 */
		public static const LOADING:String = "loading";
		
		/**
		 * An object's state after a loading error has occurred.
		 * 
		 * @productversion Worlize APIv.1
		 */
		public static const LOAD_ERROR:String = "loadError";
		
		/**
		 * An object's state when the object is ready.
		 * 
		 * @productversion Worlize APIv.1
		 */
		public static const READY:String = "ready";
		
		/**
		 * An object's state during the handshaking process.
		 * 
		 * @productversion Worlize APIv.1
		 */
		public static const HANDSHAKING:String = "handshaking";
		
		/**
		 * An object's state when unloading has begun.
		 * 
		 * @productversion Worlize APIv.1
		 */
		public static const UNLOADING:String = "unloading";
		
		/**
		 * An object's state after it has been unloaded.
		 * 
		 * @productversion Worlize APIv.1
		 */
		public static const UNLOADED:String = "unloaded";
		
		/**
		 * An object's state if a fatal error occurred in the app.
		 * 
		 * @productversion Worlize APIv.1
		 */
		public static const BOMBED:String = "bombed";
	}
}