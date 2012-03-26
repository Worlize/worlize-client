package com.worlize.api.event
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	public class APIEvent extends Event
	{
		public static const CLIENT_HANDSHAKE:String = "client_handshake";
		public static const CLIENT_FINISH_HANDSHAKE:String = "client_finishHandshake";
		
		public static const MOVE_OBJECT:String = "client_moveRoomObject";
		public static const RESIZE_OBJECT:String = "client_resizeRoomObject";
		public static const SEND_APP_MESSAGE:String = "client_sendAppMessage";
		public static const SEND_APP_MESSAGE_LOCAL:String = "client_sendAppMessageLocal";
		
		public static const MOVE_USER:String = "client_moveUser";
		public static const SET_USER_FACE:String = "client_setUserFace";
		public static const SET_USER_COLOR:String = "client_setUserColor";
		
		public static const SEND_CHAT:String = "client_sendChat";
		public static const SET_AVATAR:String = "client_setAvatar";
		
		public static const LOG_MESSAGE:String = "client_logMessage";
		public static const ROOM_LOCAL_ANNOUNCE_MESSAGE:String = "client_roomLocalAnnouncement";
		public static const ROOM_ANNOUNCE_MESSAGE:String = "client_roomAnnouncement";
		
		public static const SET_ROOM_DIMLEVEL:String = "client_setRoomDimlevel";
		
		public static const GET_ROOM_MOUSE_COORDS:String = "client_getRoomMouseCoords";
		
		public static const STATE_HISTORY_PUSH:String = "client_stateHistoryPush";
		public static const STATE_HISTORY_CLEAR:String = "client_stateHistoryClear";
		public static const STATE_HISTORY_SHIFT:String = "client_stateHistoryShift";
		
		public static const SYNCED_DATA_SET:String = "client_syncedDataSet";
		public static const SYNCED_DATA_DELETE:String = "client_syncedDataDelete";
		
		public static const LOCK_ROOM:String = "client_lockRoom";
		public static const UNLOCK_ROOM:String = "client_unlockRoom";
		
		public static const SAVE_CONFIG:String = "client_saveConfig";
		
		// For when something goes wrong inside the client and we want to be shutdown and unloaded
		public static const REQUEST_BOMB:String = "client_requestBomb";
		
		public var data:Object;
		
		public var requestor:IEventDispatcher;
		
		public function APIEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, requestor:IEventDispatcher=null, data:Object=null)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
		
		public function marshal(event:Event):APIEvent {
			var eventObj:Object = event;
			return new APIEvent(eventObj.type,
				eventObj.bubbles,
				eventObj.cancelable,
				eventObj.requestor,
				eventObj.data);
		}
		
		override public function clone():Event {
			var e:APIEvent = new APIEvent(this.type, this.bubbles, this.cancelable);
			e.data = this.data;
			return e;
		}
	}
}