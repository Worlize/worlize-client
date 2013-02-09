package com.worlize.rpc
{
	import com.worlize.command.GotoRoomCommand;
	import com.worlize.event.GotoRoomResultEvent;
	import com.worlize.interactivity.event.WorlizeCommEvent;
	import com.worlize.model.WorlizeConfig;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;
	
	[Event(type="com.worlize.interactivity.event.WorlizeCommEvent",name="message")]
	[Event(type="com.worlize.interactivity.event.WorlizeCommEvent",name="connected")]
	[Event(type="com.worlize.interactivity.event.WorlizeCommEvent",name="disconnected")]
	[Event(type="com.worlize.interactivity.event.WorlizeCommEvent",name="connectionFail")]
	public class ConnectionManager extends EventDispatcher
	{
		// In case we are asked to send a message while we are reconnecting or
		// going to a new room, we have to buffer the messages until the new
		// connection is available.
		private var sendQueue:Array = [];
		
		// References to the individual connections
		private var roomConnection:RoomConnection;
		private var presenceConnection:PresenceConnection;
		
		// Are we connecting to a new room?  This will drive whether or not to
		// consider a disconnection on the room connection a failure or not.
		private var connectingToNewRoom:Boolean = false;
		
		// Keep the last known state so we can make sure to only dispatch a
		// stateChange event if the aggregate state actually changed.
		private var previousState:String = WorlizeConnectionState.INIT;
		
		// We keep a reference to the goto room command so we can cancel it
		// if another goto room request comes in before its completed
		private var gotoRoomCommand:GotoRoomCommand;
		
		protected var config:WorlizeConfig = WorlizeConfig.getInstance();
		
		private var logger:ILogger = Log.getLogger('com.worlize.rpc.ConnectionManager');
		
		public function ConnectionManager(target:IEventDispatcher=null) {
			super(target);
			
			roomConnection = new RoomConnection();
			roomConnection.addEventListener(WorlizeCommEvent.STATE_CHANGE, handleRoomConnectionStateChange);
			roomConnection.addEventListener(WorlizeCommEvent.CONNECTION_FAIL, handleRoomConnectionFail);
			roomConnection.addEventListener(WorlizeCommEvent.MESSAGE, handleMessage);
			
			presenceConnection = new PresenceConnection();
			presenceConnection.addEventListener(WorlizeCommEvent.STATE_CHANGE, handlePresenceConnectionStateChange);
			presenceConnection.addEventListener(WorlizeCommEvent.CONNECTION_FAIL, handlePresenceConnectionFail);
			presenceConnection.addEventListener(WorlizeCommEvent.MESSAGE, handleMessage);
		}

		
		[Bindable(event="stateChange")]
		public function get state():String {
			// If both connections are established we're good to go
			if (roomConnection.state === WorlizeConnectionState.CONNECTED &&
				presenceConnection.state === WorlizeConnectionState.CONNECTED) {
				return WorlizeConnectionState.CONNECTED;
			}
			
			// If the presence connection is established and the room
			// connection is reconnecting, then we should still pretend
			// to be fully connected
			if (connectingToNewRoom &&
				presenceConnection.state === WorlizeConnectionState.CONNECTED) {
				return WorlizeConnectionState.CONNECTED;
			}
			
			// If both connections are in STATE_INIT, then we're in
			// STATE_INIT.
			if (roomConnection.state === WorlizeConnectionState.INIT &&
				presenceConnection.state === WorlizeConnectionState.INIT) {
				return WorlizeConnectionState.INIT;
			}
			
			// If either connection is in one of the following states
			// then we're considered to be in that state overall.
			var states:Array = [roomConnection.state, presenceConnection.state];
			if (states.indexOf(WorlizeConnectionState.CONNECTING) !== -1) {
				return WorlizeConnectionState.CONNECTING;
			}
			if (states.indexOf(WorlizeConnectionState.DISCONNECTED) !== -1) {
				return WorlizeConnectionState.DISCONNECTED;
			}
			
			// We shouldn't ever get to here but we have to have an
			// unconditional return for the compiler to be happy.
			// If we *do* get here for some reason, we should log it and return
			// that we're disconnected so that nothing bad happens.
			logger.fatal("Unable to correctly determine our aggregate connection state!!!!");
			
			// For good measure, let's actually disconnect if this happens.
			roomConnection.disconnect();
			presenceConnection.disconnect();
			
			return WorlizeConnectionState.DISCONNECTED;
		}
		
		// Only true if the presence connection has been established and
		// the room connection is either established or is in the process of
		// connecting to a new room.
		[Bindable(event="stateChange")]
		public function get connected():Boolean {
			return state === WorlizeConnectionState.CONNECTED;
		}
		
		protected function checkStateChange():void {
			var newState:String = state;
			if (previousState !== newState) {
				var event:WorlizeCommEvent = new WorlizeCommEvent(WorlizeCommEvent.STATE_CHANGE);
				event.previousState = previousState;
				event.newState = newState;
				previousState = newState;
				dispatchEvent(event);
				
				switch (newState) {
					case WorlizeConnectionState.CONNECTING:
						dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.CONNECTING));
						break;
					case WorlizeConnectionState.CONNECTED:
						dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.CONNECTED));
						break;
					case WorlizeConnectionState.DISCONNECTED:
						dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.DISCONNECTED));
						break;
					default:
						break;
				}
			}
		}
		
		// Connects both presence and room connections
		public function connect():void {
			if (!(roomConnection.state === WorlizeConnectionState.CONNECTED ||
				  roomConnection.state === WorlizeConnectionState.CONNECTING))
			{
				roomConnection.connect();
			}
			
			if (!(presenceConnection.state === WorlizeConnectionState.CONNECTED ||
				presenceConnection.state === WorlizeConnectionState.CONNECTING))
			{
				presenceConnection.connect();
			}
		}
		
		// Disconnects both presence and room connections
		public function disconnect():void {
			roomConnection.disconnect();
			presenceConnection.disconnect();
		}
		
		/* Begins the process of going to a new room.
			1.) HTTP POST to /rooms/<guid>/enter.json
			2.) Get updated response with new interactivity session
		    3.) If room entry was allowed, disconnect from current room server
		       a.) Otherwise emit an event indicating access denied and abort
			4.) Reconnect to the new room server
		
			During this entire process, this class's client is blissfully
			unaware of all the complexity here, and does not know that a 
		    connection is closed and a new one opened, etc.  From the app's
		    point of view, we've remained connected and merely went to a new
		    room.
		
		    That means that we may have to queue up outgoing messages while
			we're in the process of connecting to a new server.
		*/
		public function gotoRoom(roomGuid:String, usingHotSpot:Boolean):void {
			if (gotoRoomCommand && !gotoRoomCommand.complete) {
				gotoRoomCommand.cancel();
			}
			gotoRoomCommand = new GotoRoomCommand();
			gotoRoomCommand.addEventListener(GotoRoomResultEvent.GOTO_ROOM_RESULT, function(event:GotoRoomResultEvent):void {
				var commEvent:WorlizeCommEvent;
				
				if (!event.success) {
					connectingToNewRoom = false;
					
					var message:String;
					
					switch (event.failureReason) {
						case "room_locked":
							message = "Sorry, the room is locked."
							break;
						case "no_direct_entry":
							message = "Sorry, you can only get into that room by going through a door.";
							break;
						case "moderators_only":
							message = "Sorry, only moderators can enter that room.";
							break;
						case "room_full":
							message = "Sorry, the room is full.";
							break;
						default:
							message = "Unable to enter room: " + event.failureReason;
							break;
					}
					
					// Notify client that the room is locked
					commEvent = new WorlizeCommEvent(WorlizeCommEvent.MESSAGE);
					commEvent.message = {
						msg: 'room_entry_denied',
						data: {
							message: message
						}
					};
					dispatchEvent(commEvent);
					return;
				}
				
				config.interactivitySession = event.interactivitySession;
				
				// Notify client that room entry was granted
				commEvent = new WorlizeCommEvent(WorlizeCommEvent.MESSAGE);
				commEvent.message = {
					msg: 'room_entry_granted',
					data: {
						roomGuid: config.interactivitySession.roomGuid,
						worldGuid: config.interactivitySession.worldGuid
					}
				};
				dispatchEvent(commEvent);
				
				if (roomConnection.state === WorlizeConnectionState.CONNECTED ||
				    roomConnection.state === WorlizeConnectionState.CONNECTING)
				{
					connectingToNewRoom = true;
					roomConnection.disconnect();
				}
				else {
					connect();
				}
			});
			gotoRoomCommand.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				connectingToNewRoom = false;
				
				// Notify client that the room does not exist
				var commEvent:WorlizeCommEvent = new WorlizeCommEvent(WorlizeCommEvent.MESSAGE);
				commEvent.message = {
					msg: 'room_entry_denied',
					data: {
						message: "The requested room does not exist."
					}
				};
				dispatchEvent(commEvent);
			});
			gotoRoomCommand.execute(roomGuid, usingHotSpot);
		}
		
		// Throws an error if we are not connected.
		// We only send messages to the room server, not the presence server,
		// at least at this point.  The presence connection is meant to be a
		// persistent connection that can be relied upon to recieve pubsub
		// event notifications and presence updates throughout the duration
		// of the user's session.
		public function send(message:Object, doNotQueue:Boolean = false):void {
			if (roomConnection.connected) {
				roomConnection.send(message);
				return;
			}
			if (connectingToNewRoom && !doNotQueue) {
				sendQueue.push(message);
			}
		}
		
		// Sends out all the queued messages to the newly connected room server
		// connection.
		public function flushSendQueue():void {
			while (sendQueue.length > 0 && roomConnection.connected) {
				roomConnection.send(sendQueue.shift());
			}
		}
		
		// Event handlers:
		protected function handleMessage(event:WorlizeCommEvent):void {
			dispatchEvent(event);
		}
		
		protected function handleRoomConnectionStateChange(event:WorlizeCommEvent):void {
			logger.info("Room Connection State Changed To: " + event.newState);
			switch (event.newState) {
				case WorlizeConnectionState.CONNECTING:
					break;
				case WorlizeConnectionState.CONNECTED:
					if (connectingToNewRoom) {
						connectingToNewRoom = false;
					}
					flushSendQueue();
					break;
				case WorlizeConnectionState.DISCONNECTED:
					if (connectingToNewRoom) {
						// Disconnected from old room, reconnect to new one.
						roomConnection.connect();
					}
					break;
				default:
					break;
			}
			checkStateChange();
		}
		
		protected function handlePresenceConnectionStateChange(event:WorlizeCommEvent):void {
			switch (event.newState) {
				case WorlizeConnectionState.CONNECTING:
					break;
				case WorlizeConnectionState.CONNECTED:
					break;
				case WorlizeConnectionState.DISCONNECTED:
					// We never expect the presence connection to disconnect,
					// So we disconnect the room connection too.  When the user
					// chooses to reconnect, both connections will be
					// re-established.
					roomConnection.disconnect();
					break;
				default:
					break;
			}
			checkStateChange();
		}
		
		protected function handleRoomConnectionFail(event:WorlizeCommEvent):void {
			connectingToNewRoom = false;
			presenceConnection.disconnect();
			dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.CONNECTION_FAIL));
		}
		
		protected function handlePresenceConnectionFail(event:WorlizeCommEvent):void {
			roomConnection.disconnect();
			dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.CONNECTION_FAIL));
		}
		
	}
}