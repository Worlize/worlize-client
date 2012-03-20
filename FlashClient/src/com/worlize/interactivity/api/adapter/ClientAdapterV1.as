package com.worlize.interactivity.api.adapter
{
	import com.worlize.interactivity.api.APIController;
	import com.worlize.interactivity.api.AppLoader;
	import com.worlize.interactivity.api.event.APIBridgeEvent;
	import com.worlize.interactivity.model.CurrentRoom;
	import com.worlize.interactivity.model.InteractivityUser;
	import com.worlize.interactivity.record.ChatRecord;
	import com.worlize.model.InWorldObject;
	import com.worlize.model.InWorldObjectInstance;
	import com.worlize.model.WorldDefinition;
	import com.worlize.state.AuthorModeState;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.core.mx_internal;
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class ClientAdapterV1 implements IAPIClientAdapter
	{
		use namespace mx_internal;
		
		protected var client:AppLoader;
		protected var host:APIController;
		
		protected var sharedEvents:EventDispatcher;
		
		private var logger:ILogger = Log.getLogger('com.worlize.interactivity.api.adapter.ClientAdapterV1');
		
		private var _appGuid:String;
		
		public function ClientAdapterV1() {
			
		}
		
		public function get state():String {
			if (client) {
				return client.inWorldObjectInstance.state;
			}
			return InWorldObjectInstance.STATE_INIT;
		}
		
		public function get appInstanceGuid():String {
			return _appGuid;
		}
		
		public function attachClient(client:AppLoader):void {
			if (this.client && this.client !== client) { throw new Error("Client already attached"); }
			client.addEventListener(Event.UNLOAD, handleClientUnload);
			_appGuid = client.appGuid;
			this.client = client;
		}
		
		public function attachHost(host:APIController):void {
			if (this.host && this.host !== host) { throw new Error("Host already attached"); }
			this.host = host;
			host.addClientAdapter(this);
		}
		
		public function handshakeClient(data:Object):void {
			if (data.APIVersion !== 1) {
				var errorMessage:String = "ClientAdapterV1 unable to handshake with version " + data.APIVersion + " API client.";
				logger.error(errorMessage);
				if (host) {
					host.addErrorToLog(errorMessage);
				}
				client.inWorldObjectInstance.state = InWorldObjectInstance.STATE_LOAD_ERROR;
				throw new Error(errorMessage);
			}
			
			addSharedEventListeners();
			
			var thisUser:InteractivityUser = host.thisUser;
			var thisRoom:CurrentRoom = host.thisRoom;
			var thisWorld:WorldDefinition = host.thisWorld;
			var thisObject:InWorldObjectInstance = client.inWorldObjectInstance;
			
			var options:Object = data.appOptions;
			
			thisObject.width = options.defaultWidth;
			thisObject.height = options.defaultHeight;
						
			if (thisUser === null) {
				thisObject.state = InWorldObjectInstance.STATE_LOAD_ERROR;
				removeSharedEventListeners();
				throw new Error("Unable to initialize client without a current user");
				return;
			}
			
			thisObject.state = InWorldObjectInstance.STATE_HANDSHAKING;
			
			data.thisUser = userToObject(thisUser);
			data.thisUser.canAuthor = thisUser.id === thisRoom.ownerGuid;
			data.thisRoom = currentRoomToObject(thisRoom);
			data.thisWorld = worldDefinitionToObject(thisWorld);
			data.thisObject = inWorldObjectInstanceToObject(thisObject);
			data.stateHistory = thisObject.stateHistory;
			
			data.authorMode = host.authorMode;
		}
		
		protected function handleClientFinishHandshake(event:Event):void {
			if (state === InWorldObjectInstance.STATE_HANDSHAKING) {
				client.inWorldObjectInstance.state = InWorldObjectInstance.STATE_READY;
			}
		}
		
		protected function handleClientUnload(event:Event):void {
			if (sharedEvents) {
				removeSharedEventListeners();
				sharedEvents = null;
			}
			if (client) {
				client.inWorldObjectInstance.state = InWorldObjectInstance.STATE_UNLOADED;
				client = null;
			}
			if (host) {
				host.removeClientAdapter(this);
				host = null;
			}
			_appGuid = null;
		}
		
		public function unload():void {
			if (client) {
				client.unloadAndStop();
				client.inWorldObjectInstance.state = InWorldObjectInstance.STATE_UNLOADING;
			}
		}
		
		protected function addSharedEventListeners():void {
			var loader:Loader = client.contentHolder as Loader;
			sharedEvents = loader.contentLoaderInfo.sharedEvents;
			
			sharedEvents.addEventListener("client_finishHandshake", handleClientFinishHandshake);
			sharedEvents.addEventListener("client_requestBomb", handleClientRequestBomb);
			sharedEvents.addEventListener("client_moveUser", handleClientMoveUser);
			sharedEvents.addEventListener("client_setUserFace", handleClientSetUserFace);
			sharedEvents.addEventListener("client_setUserColor", handleClientSetUserColor);
			sharedEvents.addEventListener("client_setAvatar", handleClientSetAvatar);
			sharedEvents.addEventListener("client_sendChat", handleClientSendChat);
			sharedEvents.addEventListener("client_setRoomDimLevel", handleClientSetRoomDimLevel);
			sharedEvents.addEventListener("client_moveRoomObject", handleClientMoveRoomObject);
			sharedEvents.addEventListener("client_resizeRoomObject", handleClientResizeRoomObject);
			sharedEvents.addEventListener("client_logMessage", handleClientLogMessage);
			sharedEvents.addEventListener("client_roomAnnouncement", handleClientRoomAnnouncement);
			sharedEvents.addEventListener("client_roomLocalAnnouncement", handleClientRoomLocalAnnouncement);
			sharedEvents.addEventListener("client_sendAppMessage", handleClientSendAppMessage);
			sharedEvents.addEventListener("client_sendAppMessageLocal", handleClientSendAppMessageLocal);
			sharedEvents.addEventListener("client_getRoomMouseCoords", handleClientGetRoomMouseCoords);
			sharedEvents.addEventListener("client_stateHistoryPush", handleClientStateHistoryPush);
			sharedEvents.addEventListener("client_stateHistoryShift", handleClientStateHistoryShift);
			sharedEvents.addEventListener("client_stateHistoryClear", handleClientStateHistoryClear);
			sharedEvents.addEventListener(MouseEvent.MOUSE_UP, handleClientMouseUp);
		}
		
		protected function removeSharedEventListeners():void {
			sharedEvents.removeEventListener("client_finishHandshake", handleClientFinishHandshake);
			sharedEvents.removeEventListener("client_requestBomb", handleClientRequestBomb);
			sharedEvents.removeEventListener("client_moveUser", handleClientMoveUser);
			sharedEvents.removeEventListener("client_setUserFace", handleClientSetUserFace);
			sharedEvents.removeEventListener("client_setUserColor", handleClientSetUserColor);
			sharedEvents.removeEventListener("client_setAvatar", handleClientSetAvatar);
			sharedEvents.removeEventListener("client_sendChat", handleClientSendChat);
			sharedEvents.removeEventListener("client_setRoomDimLevel", handleClientSetRoomDimLevel);
			sharedEvents.removeEventListener("client_moveObject", handleClientMoveRoomObject);
			sharedEvents.removeEventListener("client_resizeObject", handleClientResizeRoomObject);
			sharedEvents.removeEventListener("client_logMessage", handleClientLogMessage);
			sharedEvents.removeEventListener("client_roomAnnouncement", handleClientRoomAnnouncement);
			sharedEvents.removeEventListener("client_roomLocalAnnouncement", handleClientRoomLocalAnnouncement);
			sharedEvents.removeEventListener("client_sendAppMessage", handleClientSendAppMessage);
			sharedEvents.removeEventListener("client_sendAppMessageLocal", handleClientSendAppMessageLocal);
			sharedEvents.removeEventListener("client_getRoomMouseCoords", handleClientGetRoomMouseCoords);
			sharedEvents.removeEventListener("client_stateHistoryPush", handleClientStateHistoryPush);
			sharedEvents.removeEventListener("client_stateHistoryShift", handleClientStateHistoryShift);
			sharedEvents.removeEventListener("client_stateHistoryClear", handleClientStateHistoryClear);
			sharedEvents.removeEventListener(MouseEvent.MOUSE_UP, handleClientMouseUp);
		}
		
		private function handleClientRequestBomb(event:Event):void {
			var clientName:String = "unknown";
			if (client && client.inWorldObjectInstance) {
				clientName = client.inWorldObjectInstance.inWorldObject.guid;
			}
			logger.info("Client app " + clientName + " requested to be bombed.");
			client.bombApp();
		}
		
		private function handleClientMoveUser(event:Event):void {
			var eo:Object = event;
			if (eo.data && eo.data.x is int && eo.data.y is int) {
				host.moveThisUser(eo.data.x, eo.data.y);
			}
		}
		
		private function handleClientSetUserFace(event:Event):void {
			var eo:Object = event;
			if (eo.data && eo.data.face is int) {
				host.setThisUserFace(eo.data.face);
			}
		}
		
		private function handleClientSetUserColor(event:Event):void {
			var eo:Object = event;
			if (eo.data && eo.data.color is int) {
				host.setThisUserColor(eo.data.color);
			}
		}
		
		private function handleClientSetAvatar(event:Event):void {
			var eo:Object = event;
			if (eo.data) {
				if (eo.data.guid === null) {
					host.setThisUserNaked();
				}
				if (eo.data.guid is String) {
					host.setThisUserAvatar(eo.data.guid);
				}
			}
		}
		
		private function handleClientSendChat(event:Event):void {
			var eo:Object = event;
			if (eo.data && eo.data.text is String) {
				host.say(eo.data.text, eo.data.whisperToGuid);
			}
		}
		
		private function handleClientSetRoomDimLevel(event:Event):void {
			var eo:Object = event;
			if (eo.data && eo.data.dimLevel is int) {
				host.dimRoom(eo.data.dimLevel);
			}
		}
		
		private function handleClientMoveRoomObject(event:Event):void {
			var eo:Object = event;
			if (eo.data && eo.data.x is Number && eo.data.y is Number) {
				client.inWorldObjectInstance.moveLocal(eo.data.x, eo.data.y);
			}
		}
		
		private function handleClientResizeRoomObject(event:Event):void {
			var eo:Object = event;
			if (eo.data && eo.data.width is Number && eo.data.height is Number) {
				client.inWorldObjectInstance.sizedByScript = true;
				client.inWorldObjectInstance.resizeLocal(eo.data.width, eo.data.height);
			}
		}
		
		private function handleClientLogMessage(event:Event):void {
			var eo:Object = event;
			if (eo.data && eo.data.text) {
				host.logMessage(eo.data.text);
			}
		}
		
		private function handleClientRoomAnnouncement(event:Event):void {
			var eo:Object = event;
			if (eo.data && eo.data.text) {
				host.roomMessage(eo.data.text);
			}
		}
		
		private function handleClientRoomLocalAnnouncement(event:Event):void {
			var eo:Object = event;
			if (eo.data && eo.data.text) {
				host.localMessage(eo.data.text);
			}
		}
		
		private function handleClientSendAppMessage(event:Event):void {
			if (client === null) { return; }
			var eo:Object = event;
			if (eo.data && eo.data.message is ByteArray) {
				if (eo.data.toUserGuids is Array) {
					host.sendObjectMessage(
						client.inWorldObjectInstance.guid,
						eo.data.message,
						eo.data.toAppInstanceGuid,
						eo.data.toUserGuids
					);
					return;
				}
				host.sendObjectMessage(
					client.inWorldObjectInstance.guid,
					eo.data.message,
					eo.data.toAppInstanceGuid
				);
			}
		}
		
		private function handleClientSendAppMessageLocal(event:Event):void {
			if (client === null) { return; }
			var eo:Object = event;
			if (eo.data && eo.data.message is ByteArray) {
				host.sendObjectMessageLocal(client.inWorldObjectInstance.guid, eo.data.message, eo.data.toAppInstanceGuid, host.thisUser.id);
			}
		}
		
		private function handleClientGetRoomMouseCoords(event:Event):void {
			var eo:Object = event;
			eo.data = {
				mouseX: Math.max(Math.min(host.thisRoom.roomView.mouseX, 950), 0),
				mouseY: Math.max(Math.min(host.thisRoom.roomView.mouseY, 570), 0)
			};
		}
		
		private function handleClientStateHistoryPush(event:Event):void {
			var eo:Object = event;
			if (eo.data is ByteArray) {
				host.stateHistoryPush(appInstanceGuid, eo.data as ByteArray);
			}
		}
				
		private function handleClientStateHistoryShift(event:Event):void {
			host.stateHistoryShift(appInstanceGuid);
		}
		
		private function handleClientStateHistoryClear(event:Event):void {
			var eo:Object = event;
			host.stateHistoryClear(appInstanceGuid, eo.data);
		}
		
		private function handleClientMouseUp(event:Event):void {
			if (client) {
				client.dispatchEvent(event);
			}
		}
		
		
		
		public function authorModeChanged(authorMode:Boolean):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_authorModeChanged");
			event.data = authorMode;
			sharedEvents.dispatchEvent(event);
		}
		
		public function processChat(record:ChatRecord):void {
			if (sharedEvents === null) { return; }
			if (state !== InWorldObjectInstance.STATE_READY) { return; }
			
			var type:String = (record.direction === ChatRecord.INCHAT) ? "incomingChat" : "outgoingChat";
			
			var event:APIBridgeEvent = new APIBridgeEvent("host_chatEvent", false, true);
			event.data = {
				type: type,
				isWhisper: record.whisper,
				recipient: record.whotarget,
				user: record.whochat,
				text: record.chatstr
			};
			record.canceled = !sharedEvents.dispatchEvent(event) || record.canceled;
			
			if (event.data.text is String) {
				if (record.chatstr !== event.data.text) {
					record.chatstr = event.data.text;
					record.modified = true;
				}
			}
		}

		public function userEntered(user:InteractivityUser):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_userEntered");
			event.data = { user: userToObject(user) };
			sharedEvents.dispatchEvent(event);
		}
		
		public function userLeft(user:InteractivityUser):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_userLeft");
			event.data = { userGuid: user.id };
			sharedEvents.dispatchEvent(event);
		}
		
		public function allUsersLeft():void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_allUsersLeft");
			sharedEvents.dispatchEvent(event);
		}
		
		public function objectAdded(roomObject:InWorldObjectInstance):void {
			if (sharedEvents === null) { return; }
			if (roomObject.inWorldObject.kind !== InWorldObject.KIND_APP) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_roomObjectAdded");
			event.data = { roomObject: inWorldObjectInstanceToObject(roomObject) };
			sharedEvents.dispatchEvent(event);
		}
		
		public function objectRemoved(roomObject:InWorldObjectInstance):void {
			if (sharedEvents === null) { return; }
			if (roomObject.inWorldObject.kind !== InWorldObject.KIND_APP) { return; }			
			var event:APIBridgeEvent = new APIBridgeEvent("host_roomObjectRemoved");
			event.data = {
				guid: roomObject.guid
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function objectMoved(roomObject:InWorldObjectInstance):void {
			if (sharedEvents === null) { return; }
			if (roomObject.inWorldObject.kind !== InWorldObject.KIND_APP) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_roomObjectMoved");
			event.data = {
				guid: roomObject.guid,
				x: roomObject.x,
				y: roomObject.y
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function objectResized(roomObject:InWorldObjectInstance):void {
			if (sharedEvents === null) { return; }
			if (roomObject.inWorldObject.kind !== InWorldObject.KIND_APP) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_roomObjectResized");
			event.data = {
				guid: roomObject.guid,
				width: roomObject.width,
				height: roomObject.height
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function objectStateChanged(roomObject:InWorldObjectInstance):void {
			if (sharedEvents === null) { return; }
			if (roomObject.inWorldObject.kind !== InWorldObject.KIND_APP) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_roomObjectStateChanged");
			event.data = {
				guid: roomObject.guid,
				state: roomObject.state
			};
			logger.info("Object " + roomObject.guid + " state changed to : " + roomObject.state);
			sharedEvents.dispatchEvent(event);
		}
		
		public function userMoved(user:InteractivityUser):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_userMoved");
			event.data = {
				userGuid: user.id,
				x: user.x,
				y: user.y
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function userFaceChanged(user:InteractivityUser):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_userFaceChanged");
			event.data = {
				userGuid: user.id,
				face: user.face
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function userColorChanged(user:InteractivityUser):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_userColorChanged");
			event.data = {
				userGuid: user.id,
				color: user.color
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function userAvatarChanged(user:InteractivityUser):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_userAvatarChanged");
			
			var obj:Object = userToObject(user);
			
			event.data = {
				userGuid: user.id,
				avatar: userToAvatarObject(user)
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function roomDimLevelChanged(dimLevel:int):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_roomDimLevelChanged");
			event.data = { dimLevel: dimLevel };
			sharedEvents.dispatchEvent(event);
		}
		
		public function receiveMessage(message:ByteArray, fromAppInstanceGuid:String, fromUserGuid:String):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_roomObjectMessageReceived");
			event.data = {
				message: message,
				fromApp: fromAppInstanceGuid,
				fromUser: fromUserGuid
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function receiveStateHistoryPush(data:ByteArray):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_stateHistoryPush");
			event.data = {
				data: data
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function receiveStateHistoryShift():void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_stateHistoryShift");
			sharedEvents.dispatchEvent(event);
		}
		
		public function receiveStateHistoryClear():void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_stateHistoryClear");
			sharedEvents.dispatchEvent(event);	
		}
		
		public function applicationMouseUp(mouseEvent:MouseEvent):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_applicationMouseUp");
			event.data = {
				altKey: mouseEvent.altKey,
				ctrlKey: mouseEvent.ctrlKey,
				shiftKey: mouseEvent.shiftKey
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function roomMouseMove(mouseEvent:MouseEvent):void {
			if (sharedEvents === null) { return; }
			var currentTarget:DisplayObject = mouseEvent.currentTarget as DisplayObject;
			var event:APIBridgeEvent = new APIBridgeEvent("host_roomMouseMove");
			event.data = {
				localX: currentTarget.mouseX,
				localY: currentTarget.mouseY,
				altKey: mouseEvent.altKey,
				buttonDown: mouseEvent.buttonDown,
				ctrlKey: mouseEvent.ctrlKey,
				shiftKey: mouseEvent.shiftKey
			};
			sharedEvents.dispatchEvent(event);
		}
		
		
		
		
		public function handleUncaughtError(event:UncaughtErrorEvent):void {
			var message:String;
			if (event.error is Error) {
				var error:Error = event.error as Error;
				message =
					"***************************" +
					"\nAn error has occurred in app \"" + client.inWorldObjectInstance.inWorldObject.name + "\":" +
					"\nErrorID: " + error.errorID +
					"\nName: " + error.name +
					"\nMessage: " + error.message;
				if (Capabilities.isDebugger) {
					message += "\nStack Trace:\n" + error.getStackTrace();
				}
				else {
					message += "\nIf you are the developer of this object, install the Flash Debug Player " +
						       "from http://www.adobe.com/support/flashplayer/downloads.html to be able to " +
							   "see a stack trace here.";
				}
				message += "\n***************************";
			}
			else if (event.error is ErrorEvent) {
				var errorEvent:ErrorEvent = event.error as ErrorEvent;
				message =
					"***************************" +
					"\nAn error event has occurred in app \"" + client.inWorldObjectInstance.inWorldObject.name + "\":" +
					"\nErrorID: " + errorEvent.errorID +
					"\nType: " + errorEvent.type +
					"\nText: " + errorEvent.text +
					"\n***************************";
			}
			
			logger.error(message);
			host.addErrorToLog(message);
			event.preventDefault();
		}
		
		protected function currentRoomToObject(room:CurrentRoom):Object {
			var obj:Object = {
				guid: room.id,
				name: room.name,
				ownerGuid: room.ownerGuid,
				users: [],
				objects: [],
				width: 950,
				height: 570
			};
			
			for each (var objInst:InWorldObjectInstance in room.inWorldObjects) {
				if (objInst.inWorldObject.kind === InWorldObject.KIND_APP) {
					obj.objects.push(inWorldObjectInstanceToObject(objInst));
				}
			}
			for each (var user:InteractivityUser in room.users) {
				obj.users.push(userToObject(user));
			}
			
			return obj;
		}
		
		protected function worldDefinitionToObject(world:WorldDefinition):Object {
			return {
				name: world.name,
				guid: world.guid
			};
		}
		
		protected function inWorldObjectInstanceToObject(instance:InWorldObjectInstance):Object {
			var obj:Object = {
				state: instance.state,
				instanceGuid: instance.guid,
				guid: instance.inWorldObject.guid,
				name: instance.inWorldObject.name,
				creatorGuid: instance.inWorldObject.creatorGuid,
				identifier: "",
				x: instance.x,
				y: instance.y,
				width: instance.width ? instance.width : 0,
				height: instance.height ? instance.height : 0,
				icon: instance.inWorldObject.iconURL
			};
			return obj;
		}
		
		protected function userToObject(user:InteractivityUser):Object {
			var data:Object = {
				guid: user.id,
				name: user.name,
				x: user.x,
				y: user.y,
				face: user.face,
				color: user.color,
				avatar: userToAvatarObject(user)
			};
			
			return data;
		}
		
		protected function userToAvatarObject(user:InteractivityUser):Object {
			if (user.simpleAvatar) {
				return {
					type: "image",
					guid: user.simpleAvatar.guid,
					thumbnailURL: user.simpleAvatar.thumbnailURL
				};
			}
			else if (user.videoAvatarStreamName) {
				return {
					type: "webcam"
				};
			}
			return {
				type: "default"
			};
		}
	}
}