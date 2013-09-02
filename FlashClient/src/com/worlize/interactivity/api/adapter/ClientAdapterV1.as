package com.worlize.interactivity.api.adapter
{
	import com.worlize.interactivity.api.APIController;
	import com.worlize.interactivity.api.AppLoader;
	import com.worlize.interactivity.api.event.APIBridgeEvent;
	import com.worlize.interactivity.model.CurrentRoom;
	import com.worlize.interactivity.model.ILinkableRoomItem;
	import com.worlize.interactivity.model.IRoomItem;
	import com.worlize.interactivity.model.InteractivityUser;
	import com.worlize.interactivity.model.LooseProp;
	import com.worlize.interactivity.record.ChatRecord;
	import com.worlize.model.AppInstance;
	import com.worlize.model.Permission;
	import com.worlize.model.Prop;
	import com.worlize.model.WorldDefinition;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	
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
		
		private var _connectedClientVersion:uint;
		
		public function get connectedClientVersion():uint {
			return _connectedClientVersion;
		}
		
		public function ClientAdapterV1() {
			
		}
		
		public function get state():String {
			if (client) {
				return client.appInstance.state;
			}
			return AppInstance.STATE_INIT;
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
		
		public function canHandleClientVersion(version:int):Boolean {
			return (version > 0 && version <= 6);
		}
		
		public function handshakeClient(data:Object):void {
			data.success = false;
			if (!canHandleClientVersion(data.APIVersion)) {
				var errorMessage:String = "ClientAdapterV1 unable to handshake with version " + data.APIVersion + " API client.";
				logger.error(errorMessage);
				if (host) {
					host.addErrorToLog(errorMessage);
				}
				client.appInstance.state = AppInstance.STATE_LOAD_ERROR;
				throw new Error(errorMessage);
			}
			
			_connectedClientVersion = data.APIVersion;
			
			addSharedEventListeners();
			
			var thisUser:InteractivityUser = host.thisUser;
			var thisRoom:CurrentRoom = host.thisRoom;
			var thisWorld:WorldDefinition = host.thisWorld;
			var thisObject:AppInstance = client.appInstance;
			
			var options:Object = data.appOptions;
			
			thisObject.sizeUnknown = options.sizeUnknown;
			thisObject.width = options.defaultWidth;
			thisObject.height = options.defaultHeight;
			thisObject.editModeSupported = options.editModeSupported;
			thisObject.editModeEnabled = false;
						
			if (thisUser === null) {
				thisObject.state = AppInstance.STATE_LOAD_ERROR;
				removeSharedEventListeners();
				throw new Error("Unable to initialize client without a current user");
				return;
			}
			
			thisObject.state = AppInstance.STATE_HANDSHAKING;
			
			data.thisUser = userToObject(thisUser);
			data.thisRoom = currentRoomToObject(thisRoom);
			data.thisWorld = worldDefinitionToObject(thisWorld);
			data.thisObject = appInstanceToObject(thisObject);
			data.stateHistory = thisObject.stateHistory;
			data.syncedData = thisObject.syncedData;
			data.config = thisObject.configData;
			
			data.authorMode = host.authorMode;
			
			data.success = true;
		}
		
		protected function handleClientFinishHandshake(event:Event):void {
			if (state === AppInstance.STATE_HANDSHAKING) {
				client.appInstance.state = AppInstance.STATE_READY;
			}
			else {
				logger.error("Received client_finishHandshake event from app " +
							 client.appInstance.guid + " outside the handshake process.");
				client.bombApp();
			}
		}
		
		protected function handleClientUnload(event:Event):void {
			if (sharedEvents) {
				removeSharedEventListeners();
				sharedEvents = null;
			}
			if (client) {
				client.appInstance.state = AppInstance.STATE_UNLOADED;
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
				client.appInstance.state = AppInstance.STATE_UNLOADING;
			}
		}
		
		protected function addSharedEventListeners():void {
			var loader:Loader = client.contentHolder as Loader;
			sharedEvents = loader.contentLoaderInfo.sharedEvents;
			
			sharedEvents.addEventListener("client_finishHandshake", handleClientFinishHandshake);
			sharedEvents.addEventListener("client_requestBomb", handleClientRequestBomb);
			sharedEvents.addEventListener("client_moveUser", handleClientMoveUser);
			sharedEvents.addEventListener("client_setUserColor", handleClientSetUserColor);
			sharedEvents.addEventListener("client_setUserBalloonColor", handleClientSetUserBalloonColor);
			sharedEvents.addEventListener("client_setAvatar", handleClientSetAvatar);
			sharedEvents.addEventListener("client_gotoRoom", handleClientGotoRoom);
			sharedEvents.addEventListener("client_sendChat", handleClientSendChat);
			sharedEvents.addEventListener("client_setRoomDimLevel", handleClientSetRoomDimLevel);
			sharedEvents.addEventListener("client_lockRoom", handleClientLockRoom);
			sharedEvents.addEventListener("client_unlockRoom", handleClientUnlockRoom);
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
			sharedEvents.addEventListener("client_syncedDataSet", handleClientSyncedDataSet);
			sharedEvents.addEventListener("client_syncedDataDelete", handleClientSyncedDataDelete);
			sharedEvents.addEventListener("client_saveConfig", handleClientSaveConfig);
			sharedEvents.addEventListener("client_addLooseProp", handleClientAddLooseProp);
			sharedEvents.addEventListener("client_removeLooseProp", handleClientRemoveLooseProp);
			sharedEvents.addEventListener("client_moveLooseProp", handleClientMoveLooseProp);
			sharedEvents.addEventListener("client_clearLooseProps", handleClientClearLooseProps);
			sharedEvents.addEventListener("client_bringLoosePropForward", handleClientBringLoosePropForward);
			sharedEvents.addEventListener("client_sendLoosePropBackward", handleClientSendLoosePropBackward);
			sharedEvents.addEventListener(MouseEvent.MOUSE_UP, handleClientMouseUp);
		}
		
		protected function removeSharedEventListeners():void {
			sharedEvents.removeEventListener("client_finishHandshake", handleClientFinishHandshake);
			sharedEvents.removeEventListener("client_requestBomb", handleClientRequestBomb);
			sharedEvents.removeEventListener("client_moveUser", handleClientMoveUser);
			sharedEvents.removeEventListener("client_setUserColor", handleClientSetUserColor);
			sharedEvents.removeEventListener("client_setUserBalloonColor", handleClientSetUserBalloonColor);
			sharedEvents.removeEventListener("client_setAvatar", handleClientSetAvatar);
			sharedEvents.removeEventListener("client_gotoRoom", handleClientGotoRoom);
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
			sharedEvents.removeEventListener("client_syncedDataSet", handleClientSyncedDataSet);
			sharedEvents.removeEventListener("client_syncedDataDelete", handleClientSyncedDataDelete);
			sharedEvents.removeEventListener("client_saveConfig", handleClientSaveConfig);
			sharedEvents.removeEventListener("client_addLooseProp", handleClientAddLooseProp);
			sharedEvents.removeEventListener("client_removeLooseProp", handleClientRemoveLooseProp);
			sharedEvents.removeEventListener("client_moveLooseProp", handleClientMoveLooseProp);
			sharedEvents.removeEventListener("client_clearLooseProps", handleClientClearLooseProps);
			sharedEvents.removeEventListener("client_bringLoosePropForward", handleClientBringLoosePropForward);
			sharedEvents.removeEventListener("client_sendLoosePropBackward", handleClientSendLoosePropBackward);
			sharedEvents.removeEventListener(MouseEvent.MOUSE_UP, handleClientMouseUp);
		}
		
		private function handleClientRequestBomb(event:Event):void {
			var clientName:String = "unknown";
			if (client && client.appInstance) {
				clientName = client.appInstance.app.guid;
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
		
		private function handleClientSetUserColor(event:Event):void {
			var eo:Object = event;
			if (eo.data && eo.data.color is int) {
				var color:int = eo.data.color;
				host.setThisUserColor(color);
			}
		}
		
		private function handleClientSetUserBalloonColor(event:Event):void {
			var eo:Object = event;
			if (eo.data && eo.data.color is int) {
				host.setThisUserBalloonColor(eo.data.color);
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
		
		private function handleClientGotoRoom(event:Event):void {
			var data:Object = event['data'];
			if (data && data.room is String) {
				var insertHistory:Boolean = data.insertHistory !== false;
				host.gotoRoom(data.room, insertHistory);
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
			if (eo.data && eo.data.dimLevel is uint) {
				host.dimRoom(eo.data.dimLevel);
			}
		}
		
		private function handleClientLockRoom(event:Event):void {
			host.lockRoom();
		}
		
		private function handleClientUnlockRoom(event:Event):void {
			host.unlockRoom();
		}
		
		private function handleClientMoveRoomObject(event:Event):void {
			var eo:Object = event;
			if (eo.data && eo.data.x is Number && eo.data.y is Number) {
				client.appInstance.moveLocal(eo.data.x, eo.data.y);
			}
		}
		
		private function handleClientResizeRoomObject(event:Event):void {
			var eo:Object = event;
			if (eo.data && eo.data.width is Number && eo.data.height is Number) {
				client.appInstance.sizeUnknown = false;
				client.appInstance.resizeLocal(eo.data.width, eo.data.height);
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
					host.sendAppMessage(
						client.appInstance.guid,
						eo.data.message,
						eo.data.toAppInstanceGuid,
						eo.data.toUserGuids
					);
					return;
				}
				host.sendAppMessage(
					client.appInstance.guid,
					eo.data.message,
					eo.data.toAppInstanceGuid
				);
			}
		}
		
		private function handleClientSendAppMessageLocal(event:Event):void {
			if (client === null) { return; }
			var eo:Object = event;
			if (eo.data && eo.data.message is ByteArray) {
				host.sendAppMessageLocal(client.appInstance.guid, eo.data.message, eo.data.toAppInstanceGuid, host.thisUser.id);
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
		
		private function handleClientSyncedDataSet(event:Event):void {
			var eo:Object = event;
			if (eo.data && eo.data.key is String && eo.data.value is ByteArray) {
				host.syncedDataSet(appInstanceGuid, eo.data.key, eo.data.value);
			}
		}
		
		private function handleClientSyncedDataDelete(event:Event):void {
			var eo:Object = event;
			if (eo.data && eo.data.key is String) {
				host.syncedDataDelete(appInstanceGuid, eo.data.key);
			}
		}
		
		private function handleClientSaveConfig(event:Event):void {
			var eo:Object = event;
			host.saveAppConfig(appInstanceGuid, eo.data);
		}
		
		private function handleClientAddLooseProp(event:Event):void {
			var eo:Object = event;
			if (eo.data && eo.data.guid && eo.data.x is Number && eo.data.y is Number) {
				host.addLooseProp(eo.data.guid, eo.data.x, eo.data.y);
			}
		}
		
		private function handleClientRemoveLooseProp(event:Event):void {
			var eo:Object = event;
			if (eo.data is Number) {
				host.removeLooseProp(eo.data);
			}
		}
		
		private function handleClientMoveLooseProp(event:Event):void {
			var eo:Object = event;
			if (eo.data && eo.data.id is Number && eo.data.x is Number && eo.data.y is Number) {
				host.moveLooseProp(eo.data.id, eo.data.x, eo.data.y);
			}
		}
		
		private function handleClientClearLooseProps(event:Event):void {
			host.clearLooseProps();
		}
		
		private function handleClientBringLoosePropForward(event:Event):void {
			var eo:Object = event;
			if (eo.data && eo.data.id is Number && eo.data.layerCount is Number) {
				host.bringLoosePropForward(eo.data.id, eo.data.layerCount);
			}
		}
		
		private function handleClientSendLoosePropBackward(event:Event):void {
			var eo:Object = event;
			if (eo.data && eo.data.id is Number && eo.data.layerCount is Number) {
				host.sendLoosePropBackward(eo.data.id, eo.data.layerCount);
			}
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
		
		public function editModeChanged(editMode:Boolean):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_editModeChanged");
			event.data = editMode;
			sharedEvents.dispatchEvent(event);
		}
		
		public function processChat(record:ChatRecord):void {
			if (sharedEvents === null) { return; }
			if (state !== AppInstance.STATE_READY) { return; }
			
			var type:String = (record.direction === ChatRecord.INCHAT) ? "incomingChat" : "outgoingChat";
			
			var event:APIBridgeEvent = new APIBridgeEvent("host_chatEvent", false, true);
			event.data = {
				type: type,
				isWhisper: record.whisper,
				recipient: record.whotarget,
				user: record.whochat,
				text: record.chatstr,
				originalText: record.originalChatstr
			};
			record.canceled = !sharedEvents.dispatchEvent(event) || record.canceled;
			
			if (event.data.text is String) {
				record.chatstr = event.data.text;
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
		
		public function itemAdded(item:IRoomItem):void {
			if (sharedEvents === null) { return; }
			if (!(item is AppInstance)) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_roomObjectAdded");
			event.data = { roomObject: appInstanceToObject(item as AppInstance) };
			sharedEvents.dispatchEvent(event);
		}
		
		public function itemRemoved(item:IRoomItem):void {
			if (sharedEvents === null) { return; }
			if (!(item is AppInstance)) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_roomObjectRemoved");
			event.data = {
				guid: item.guid
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function itemMoved(item:IRoomItem):void {
			if (sharedEvents === null) { return; }
			if (!(item is AppInstance)) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_roomObjectMoved");
			event.data = {
				guid: item.guid,
				x: item.x,
				y: item.y
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function itemResized(item:IRoomItem):void {
			if (sharedEvents === null) { return; }
			if (!(item is AppInstance)) { return; }
			var appInstance:AppInstance = item as AppInstance;
			var event:APIBridgeEvent = new APIBridgeEvent("host_roomObjectResized");
			event.data = {
				guid: item.guid,
				width: appInstance.width,
				height: appInstance.height
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function itemDestChanged(item:ILinkableRoomItem):void {
			// do nothing
		}
		
		public function appStateChanged(appInstance:AppInstance):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_roomObjectStateChanged");
			event.data = {
				guid: appInstance.guid,
				state: appInstance.state
			};
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
		
		public function userColorChanged(user:InteractivityUser):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_userColorChanged");
			event.data = {
				userGuid: user.id,
				color: user.face
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function userBalloonColorChanged(user:InteractivityUser):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_userBalloonColorChanged");
			event.data = {
				userGuid: user.id,
				color: user.color
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function userAvatarChanged(user:InteractivityUser):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_userAvatarChanged");
			
			event.data = {
				userGuid: user.id,
				avatar: userToAvatarObject(user)
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function userPermissionsChanged(user:InteractivityUser):void {
			if (sharedEvents === null) { return; }
			
			// The userPrivilegesChanged event handler in client adapter
			// versions 3 and earlier is broken, so they can't use this event.
			// In any case, we are renaming privileges to permissions for
			// consistency across the board.
			if (_connectedClientVersion < 4) { return; }
			
			var event:APIBridgeEvent = new APIBridgeEvent("host_userPermissionsChanged");
			var permissions:Array = user.appliedPermissions.slice();
						
			event.data = {
				userGuid: user.id,
				permissions: permissions.slice() 
			};
			
			sharedEvents.dispatchEvent(event);
		}
		
		public function userRestrictionsChanged(user:InteractivityUser):void {
			if (sharedEvents === null) { return; }
			
			var event:APIBridgeEvent = new APIBridgeEvent("host_userRestrictionsChanged");
			trace("TODO: Implement restrictions in Worlize SDK");
		}
		
		public function roomDimLevelChanged(dimLevel:uint):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_roomDimLevelChanged");
			event.data = { dimLevel: dimLevel };
			sharedEvents.dispatchEvent(event);
		}
		
		public function roomNameChanged(guid:String, name:String):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_roomNameChanged");
			event.data = {
				guid: guid,
				name: name
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function roomLocked(lockedByUserGuid:String):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_roomLockedChanged");
			event.data = {
				locked: true,
				user: lockedByUserGuid
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function roomUnlocked(unlockedByUserGuid:String):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_roomLockedChanged");
			event.data = {
				locked: false,
				user: unlockedByUserGuid
			};
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
		
		public function receiveSyncedDataSet(key:String, value:ByteArray):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_syncedDataSet");
			event.data = {
				key: key,
				value: value
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function receiveSyncedDataDelete(key:String):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_syncedDataDelete");
			event.data = {
				key: key
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function receiveSaveAppConfig(changedByUserGuid:String, config:Object):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_configChanged");
			event.data = {
				user: changedByUserGuid,
				config: config
			};
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
		
		public function loosePropAdded(looseProp:LooseProp):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_loosePropAdded");
			event.data = loosePropToObject(looseProp);
			sharedEvents.dispatchEvent(event);
		}
		
		public function loosePropMoved(id:uint, x:int, y:int):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_loosePropMoved");
			event.data = {
				id: id,
				x: x,
				y: y
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function loosePropRemoved(id:uint):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_loosePropRemoved");
			event.data = id;
			sharedEvents.dispatchEvent(event);
		}
		
		public function loosePropsReset():void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_loosePropsReset");
			sharedEvents.dispatchEvent(event);
		}
		
		public function loosePropBroughtForward(id:uint, layerCount:int):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_loosePropBroughtForward");
			event.data = {
				id: id,
				layerCount: layerCount
			};
			sharedEvents.dispatchEvent(event);
		}
		
		public function loosePropSentBackward(id:uint, layerCount:int):void {
			if (sharedEvents === null) { return; }
			var event:APIBridgeEvent = new APIBridgeEvent("host_loosePropSentBackward");
			event.data = {
				id: id,
				layerCount: layerCount
			};
			sharedEvents.dispatchEvent(event);
		}
		
		
		
		public function handleUncaughtError(event:UncaughtErrorEvent):void {
			var message:String;
			if (event.error is Error) {
				var error:Error = event.error as Error;
				message =
					"***************************" +
					"\nAn error has occurred in app \"" + client.appInstance.app.name + "\":" +
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
					"\nAn error event has occurred in app \"" + client.appInstance.app.name + "\":" +
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
				locked: room.locked,
				dimLevel: Math.floor(room.dimLevel * 100),
				ownerGuid: room.ownerGuid,
				users: [],
				objects: [],
				looseProps: [],
				width: 950,
				height: 570
			};
			
			for each (var item:IRoomItem in room.items) {
				if (!(item is AppInstance)) { continue; }
				var appInstance:AppInstance = AppInstance(item);
				obj.objects.push(appInstanceToObject(appInstance));
			}
			for each (var user:InteractivityUser in room.users) {
				obj.users.push(userToObject(user));
			}
			for each (var looseProp:LooseProp in room.loosePropList.props) {
				obj.looseProps.push(loosePropToObject(looseProp));
			}
			
			return obj;
		}
		
		protected function propToObject(prop:Prop):Object {
			return {
				name: prop.name,
				guid: prop.guid,
				thumbnailURL: prop.thumbnailURL,
				creatorGuid: prop.creatorGuid
			};
		}
		
		protected function loosePropToObject(looseProp:LooseProp):Object {
			return {
				prop: propToObject(looseProp.prop),
				id: looseProp.id,
				x: looseProp.x,
				y: looseProp.y
			};
		}
		
		protected function worldDefinitionToObject(world:WorldDefinition):Object {
			return {
				name: world.name,
				guid: world.guid
			};
		}
		
		protected function appInstanceToObject(instance:AppInstance):Object {
			var obj:Object = {
				state: instance.state,
				instanceGuid: instance.guid,
				guid: instance.app.guid,
				name: instance.app.name,
				creatorGuid: instance.app.creatorGuid,
				identifier: "",
				x: instance.x,
				y: instance.y,
				width: instance.width ? instance.width : 0,
				height: instance.height ? instance.height : 0,
				icon: instance.app.iconURL
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
			
			// For backward compatibility
			if (_connectedClientVersion < 4) {
				data.privileges = [];
				if (user.appliedPermissions.indexOf(Permission.CAN_EDIT_ROOMS) !== -1) {
					data.privileges.push('canAuthor');
				}
			}
			else {
				data.permissions = user.appliedPermissions.slice();
			}
			
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