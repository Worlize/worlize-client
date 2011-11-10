package com.worlize.video.control
{
	import com.worlize.video.events.NetConnectionManagerEvent;
	
	import flash.errors.IOError;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	import mx.controls.Text;
	import mx.events.FlexEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	[Event(type="com.worlize.video.events.NetConnectionManagerEvent", name="connecting")]
	[Event(type="com.worlize.video.events.NetConnectionManagerEvent", name="connected")]
	[Event(type="com.worlize.video.events.NetConnectionManagerEvent", name="disconnected")]
	[Event(type="com.worlize.video.events.NetConnectionManagerEvent", name="disconnecting")]
	[Event(type="com.worlize.video.events.NetConnectionManagerEvent", name="reconnecting")]
	public class NetConnectionManager extends EventDispatcher
	{
		public static const STATE_INIT:String = "init";
		public static const STATE_CONNECTING:String = "connecting";
		public static const STATE_CONNECTED:String = "connected";
		public static const STATE_DISCONNECTING:String = "disconnecting";
		public static const STATE_DISCONNECTED:String = "disconnected";
		
		private var logger:ILogger = Log.getLogger("com.worlize.video.control.NetConnectionManager");
		
		[Bindable]
		public var netConnection:NetConnection;
		public var reconnectOnLostConnection:Boolean = true;
		private var _state:String = STATE_INIT;
		protected var reconnectTimer:Timer;
		protected var secondStageConnectTimer:Timer;
		protected var connectArgs:Array;
		private var nextConnectWaiting:Boolean = false;
		
		public function NetConnectionManager(target:IEventDispatcher=null)
		{
			netConnection = new NetConnection();
			
			reconnectTimer = new Timer(1000, 1);
			reconnectTimer.addEventListener(TimerEvent.TIMER, handleReconnectTimer);
			
			secondStageConnectTimer = new Timer(1, 1);
			secondStageConnectTimer.addEventListener(TimerEvent.TIMER, handleSecondStageConnectTimer);
			
			netConnection.addEventListener(NetStatusEvent.NET_STATUS, handleNetStatus);
			netConnection.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityError);
			super(target);
		}
		
		[Bindable(event='stateChanged')]
		public function get state():String {
			return _state;
		}

		protected function setState(newValue:String):void {
			if (_state !== newValue) {
				_state = newValue;
				var event:FlexEvent = new FlexEvent('stateChanged');
				dispatchEvent(event);
			}
		}
		
		[Bindable(event='stateChanged')]
		public function get ready():Boolean {
			return _state === STATE_CONNECTED;
		}
		
		public function connect(...arguments):void {
			var message:String;
			if (netConnection.connected) {
				logger.info("NetConnection is already connected.  Disconnecting first.");
				nextConnectWaiting = true;
				connectArgs = arguments;
				setState(STATE_DISCONNECTING);
				netConnection.close();
				return;
			}
			try {
				netConnection.connect.apply(netConnection, arguments);
				setState(STATE_CONNECTING);
				var connectingEvent:NetConnectionManagerEvent =
					new NetConnectionManagerEvent(NetConnectionManagerEvent.CONNECTING);
				dispatchEvent(connectingEvent);
				// keep connect arguments around in case we need to reconnect
				connectArgs = arguments;
			}
			catch (securityError:SecurityError) {
				message = "There was a SecurityError while trying to connect to the streaming server." 
				logger.error(message + ": " + securityError.toString());
				Alert.show(message, "Stream Connection Error");
			}
			catch (ioError:IOError) {
				message = "There was an I/O Error while trying to connect to the streaming server.";
				logger.error(message + ": " + ioError.toString());
				Alert.show(message, "Stream Connection Error");
			}
		}
		
		protected function reconnect():void {
			if (_state === STATE_DISCONNECTED) {
				if (connectArgs && connectArgs.length > 0) {
					netConnection.connect.apply(netConnection, connectArgs);
					setState(STATE_CONNECTING);
					var reconnectingEvent:NetConnectionManagerEvent =
						new NetConnectionManagerEvent(NetConnectionManagerEvent.RECONNECTING);
					dispatchEvent(reconnectingEvent);
				}
			}
		}
		
		public function close():void {
			if (_state === STATE_CONNECTED) {
				netConnection.close();
				setState(STATE_DISCONNECTING);
				var disconnectingEvent:NetConnectionManagerEvent =
					new NetConnectionManagerEvent(NetConnectionManagerEvent.DISCONNECTING);
				dispatchEvent(disconnectingEvent);
			}
		}
		
		private function handleReconnectTimer(event:TimerEvent):void {
			reconnect();
		}
		
		protected function handleSecondStageConnectTimer(event:TimerEvent):void {
			connect.apply(this, connectArgs);
		}
		
		protected function handleNetStatus(event:NetStatusEvent):void {
			logger.debug("NetConnection NetStatus: " + event.info.level + " - " + event.info.code + " - " + event.info.description);
			
			var connectedEvent:NetConnectionManagerEvent;
			var disconnectedEvent:NetConnectionManagerEvent;
			
			switch(event.info.code) {
				case "NetConnection.Connect.Success":
					setState(STATE_CONNECTED);
					connectedEvent =
						new NetConnectionManagerEvent(NetConnectionManagerEvent.CONNECTED);
					dispatchEvent(connectedEvent);
					break;
					
				case "NetConnection.Connect.AppShutdown":
					disconnectedEvent =
						new NetConnectionManagerEvent(NetConnectionManagerEvent.DISCONNECTED);
					dispatchEvent(disconnectedEvent);
					break;
						
				case "NetConnection.Connect.Closed":
					if (nextConnectWaiting) {
						// Close expected, we now want to
						// make a new separate connection
						logger.info("Ok, previous NetConnection is closed, opening new one.");
						nextConnectWaiting = false;
						setState(STATE_DISCONNECTED);
						secondStageConnectTimer.reset();
						secondStageConnectTimer.start();
					}
					else if (_state === STATE_DISCONNECTING) {
						// Close expected, don't reconnect
						setState(STATE_DISCONNECTED);
						disconnectedEvent =
							new NetConnectionManagerEvent(NetConnectionManagerEvent.DISCONNECTED);
						dispatchEvent(disconnectedEvent);
					}
					else {
						// Unexpected close, reconnect.
						reconnectTimer.reset();
						reconnectTimer.start();
						setState(STATE_DISCONNECTED);
						disconnectedEvent =
							new NetConnectionManagerEvent(NetConnectionManagerEvent.DISCONNECTED);
						dispatchEvent(disconnectedEvent);
					}
					break;
					
				case "NetConnection.Connect.Failed":
					setState(STATE_DISCONNECTED);
					disconnectedEvent =
						new NetConnectionManagerEvent(NetConnectionManagerEvent.DISCONNECTED);
					dispatchEvent(disconnectedEvent);
					if (reconnectOnLostConnection) {
						reconnectTimer.reset();
						reconnectTimer.start();
					}
					break;
					
				case "NetConnection.Connect.IdleTimeout":
					setState(STATE_DISCONNECTED);
					disconnectedEvent =
					new NetConnectionManagerEvent(NetConnectionManagerEvent.DISCONNECTED);
					dispatchEvent(disconnectedEvent);
					if (reconnectOnLostConnection) {
						reconnectTimer.reset();
						reconnectTimer.start();
					}
					break;
					
				case "NetConnection.Connect.InvalidApp":
					setState(STATE_DISCONNECTED);
					disconnectedEvent =
						new NetConnectionManagerEvent(NetConnectionManagerEvent.DISCONNECTED);
					dispatchEvent(disconnectedEvent);
					Alert.show("The requested application is not available on the streaming server.", "Stream Connection Error");
					break;
					
				case "NetConnection.Connect.NetworkChange":
					/* Flash Player has detected a network change, for example,
					   a dropped wireless connection, a successful wireless
					   connection,or a network cable loss.
				       Use this event to check for a network interface change.
				       Don't use this event to implement your NetConnection
					   reconnect logic. Use "NetConnection.Connect.Closed" to
					   implement your NetConnection reconnect logic. */
					setState(STATE_DISCONNECTED);
					disconnectedEvent =
						new NetConnectionManagerEvent(NetConnectionManagerEvent.DISCONNECTED);
					dispatchEvent(disconnectedEvent);
					break;
					
				case "NetConnection.Connect.Rejected":
					setState(STATE_DISCONNECTING);
					disconnectedEvent =
						new NetConnectionManagerEvent(NetConnectionManagerEvent.DISCONNECTED);
					dispatchEvent(disconnectedEvent);
					Alert.show("The streaming server rejected the connection.", "Stream Connection Error");
					break;
					
				default:
					logger.warn("Unhandled NetStatus: " + event.info.code);
					break;
			}
		}
				
		protected function handleIOError(event:IOErrorEvent):void {
			Alert.show(event.text, "I/O Error Event");  
		}
		
		protected function handleSecurityError(event:SecurityErrorEvent):void {
			Alert.show(event.text, "Security Error Event");
		}
	}
}