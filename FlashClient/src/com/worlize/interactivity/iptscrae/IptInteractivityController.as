package com.worlize.interactivity.iptscrae
{
	import com.worlize.components.visualnotification.VisualNotification;
	import com.worlize.components.visualnotification.VisualNotificationManager;
	import com.worlize.interactivity.model.CurrentRoom;
	import com.worlize.interactivity.model.Hotspot;
	import com.worlize.interactivity.model.IRoomItem;
	import com.worlize.interactivity.model.InteractivityUser;
	import com.worlize.interactivity.rpc.InteractivityClient;
	import com.worlize.interactivity.util.WorlizeColorUtil;
	import com.worlize.interactivity.view.SoundPlayer;
	
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.openpalace.iptscrae.IptAlarm;
	import org.openpalace.iptscrae.IptEngineEvent;
	import org.openpalace.iptscrae.IptTokenList;
	
	import spark.primitives.Rect;

	public class IptInteractivityController implements IInteractivityController
	{
		[Bindable]
		public var scriptManager:WorlizeIptManager;
		[Bindable]
		public var output:String;
		public var client:InteractivityClient;
		
		private var logger:ILogger = Log.getLogger('com.worlize.interactivity.iptscrae.IptInteractivityController');
		
		public function IptInteractivityController()
		{
			output = "";
			scriptManager = new WorlizeIptManager(this);
			scriptManager.parser.removeCommand("ALARMEXEC");
			scriptManager.parser.removeCommand("IPTVERSION");
			
			scriptManager.parser.addCommands(WorlizeIptscraeCommands.commands);
			scriptManager.addEventListener(IptEngineEvent.TRACE, handleTrace);
		}
		
		private function handleTrace(event:IptEngineEvent):void {
			logResult(event.message);
		}
		
		public function notification(text:String, title:String):void {
			var notification:VisualNotification = new VisualNotification();
			notification.text = text;
			notification.title = title;
			VisualNotificationManager.getInstance().showNotification(notification);
		}
		
		public function logError(message:String):void {
			logResult(message);
		}
		
		private function logResult(value:String):void {
			output += value + "\n";
			client.currentRoom.logScript(value);
			logger.debug(value);
		}
				
		public function triggerHotspotEvent(hotspot:Hotspot, eventType:int):Boolean {
			var tokenList:IptTokenList = hotspot.getEventHandler(eventType);
			if (tokenList) {
				var context:WorlizeIptExecutionContext = new WorlizeIptExecutionContext(scriptManager);
				context.hotspotGuid = hotspot.guid;
				scriptManager.executeTokenListWithContext(tokenList, context);
				scriptManager.start();
				return true;
			}
			return false;
		}
		
		public function triggerHotspotEvents(eventType:int):Boolean {
			var ranScripts:Boolean = false;
			for (var i:int = client.currentRoom.items.length-1; i > -1; i --) {
				var item:IRoomItem = IRoomItem(client.currentRoom.items.getItemAt(i));
				if (!(item is Hotspot)) { continue; }
				var hotspot:Hotspot = Hotspot(item);
				if (triggerHotspotEvent(hotspot, eventType)) {
					ranScripts = true;
				};				
			}
			if (triggerHotspotEvent(client.cyborgHotspot, eventType)) {
				ranScripts = true;
			}
			return ranScripts;
		}
		
		public function getHotspotEvents(eventType:int):Vector.<IptTokenList> {
			var scripts:Vector.<IptTokenList> = new Vector.<IptTokenList>;
			var handler:IptTokenList;
			for (var i:int = client.currentRoom.items.length-1; i > -1; i --) {
				var item:IRoomItem = IRoomItem(client.currentRoom.items.getItemAt(i));
				if (!(item is Hotspot)) { continue; }
				var hotspot:Hotspot = Hotspot(item);
				handler = hotspot.getEventHandler(eventType);
				if (handler) {
					scripts.push(handler);
				}				
			}
			handler = client.cyborgHotspot.getEventHandler(eventType);
			if (handler) {
				scripts.push(handler);
			}
			return scripts.length > 0 ? scripts : null;
		}
		
		
		public function executeScript(script:String):void {
			if (scriptManager) {
				scriptManager.execute(script);
				scriptManager.start();
			}
		}
		
		public function gotoURL(url:String):void
		{
			client.gotoURL(url);
		}
		
		public function launchApp(app:String):void
		{
			logResult("launchApp: " + app);
		}
		
		public function getWhoChat():String
		{
			return client.whochat;
		}
		
		public function midiLoop(loopNbr:int, name:String):void
		{
			var match:Array = name.match(/(.*)\.(.*)/);
			if (!match) {
				name = name + ".mid";
			}
//			ExternalInterface.call("midiLoop", client.mediaServer + name, loopNbr);
		}
		
		public function midiPlay(name:String):void
		{
			var match:Array = name.match(/(.*)\.(.*)/);
			if (!match) {
				name = name + ".mid";
			}
//			ExternalInterface.call("midiPlay", client.mediaServer + name);
		}
		
		public function selectHotSpot(spotGuid:String):void
		{
			var hotspot:Hotspot = client.currentRoom.getHotspotByGuid(spotGuid);
			if (hotspot) {
				triggerHotspotEvent(hotspot, IptEventHandler.TYPE_SELECT);
			}
		}
		
		public function getNumDoors():int
		{
			var count:int = 0;
			for each (var item:IRoomItem in client.currentRoom.items) {
				if (item is Hotspot) {
					count ++;
				}
			}
			return count;
		}
		
		public function dimRoom(dimLevel:int):void
		{
			client.currentRoom.dimRoom(dimLevel);
		}
		
		public function getSelfPosY():int
		{
			return client.currentUser.y;
		}
		
		public function getSelfPosX():int
		{
			return client.currentUser.x;
		}
		
		public function moveUserAbs(x:int, y:int):void
		{
			client.move(x, y);
		}
		
		public function naked():void
		{
			client.naked();
		}
		
		public function getMouseX():int
		{
			return client.currentRoom.roomView.mouseX;
		}
		
		public function getMouseY():int
		{
			return client.currentRoom.roomView.mouseY;
		}
		
		public function moveUserRel(xBy:int, yBy:int):void
		{
			client.move(client.currentUser.x + xBy, client.currentUser.y + yBy);
		}
		
		public function chat(text:String):void
		{
			client.roomChat(text);
		}
		
		public function clearAlarms():void
		{
			scriptManager.abort();
		}
		
		public function getWhoTarget():String
		{
			if (client.currentRoom.selectedUser) {
				return client.currentRoom.selectedUser.id;
			}
			return "";
		}
		
		public function beep():void
		{
			logResult("beep");
		}
		
		public function getSpotDest(spotId:String):String
		{
			var hotspot:Hotspot = client.currentRoom.getHotspotByGuid(spotId);
			if (hotspot) {
				return hotspot.dest;
			}
			return "";
		}
				
		public function doMacro(macro:int):void
		{
			logResult("doMacro macro: " + macro);
		}
		
		public function changeColor(colorNumber:int):void
		{
			client.setColor(colorNumber);
		}
		
		public function getUserName(userId:String):String
		{
			var user:InteractivityUser = client.currentRoom.getUserById(userId);
			if (user) {
				return user.name;
			}
			return "";
		}
		
		public function getSelfUserName():String
		{
			return client.currentUser.name;
		}
		
		public function getNumRoomUsers():int
		{
			return client.currentRoom.users.length;
		}
		
		public function getSelfUserId():String
		{
			return client.currentUser.id;
		}
		
		public function lock(spotGuid:String):void
		{
			client.lockDoor(client.currentRoom.id, spotGuid);
		}
		
		public function midiStop():void
		{
			ExternalInterface.call("midiStop");
		}
		
		public function gotoRoom(roomId:String):void
		{
			client.gotoRoom(roomId);
		}
		
		public function inSpot(spotGuid:String):Boolean
		{
			// TODO: Should we fix this?
			
			var x:int = client.currentUser.x;
			var y:int = client.currentUser.y;
			var point:Point = new Point(x, y);
			var globalPoint:Point = client.currentRoom.roomView.localToGlobal(point);
			
			var hotspot:Hotspot = client.currentRoom.getHotspotByGuid(spotGuid);
			if (hotspot) {
//				return client.currentRoom.roomView.hotSpotCanvas.hitTestHotSpot(hotspot, globalPoint);
			}
			
			return false;
		}
		
		public function sendGlobalMessage(message:String):void
		{
			client.globalMessage(message);
		}
		
		public function sendRoomMessage(message:String):void
		{
			client.roomMessage(message);
		}
		
		public function sendSusrMessage(message:String):void
		{
			client.superUserMessage(message);
		}
		
		public function sendLocalMsg(message:String):void
		{
			client.currentRoom.localMessage(message);
		}
		
		public function getRoomName():String
		{
			return client.currentRoom.name;
		}
		
		public function getServerName():String
		{
			return client.currentWorld.name;
		}
		
		public function statusMessage(message:String):void
		{
			client.currentRoom.statusMessage(message);
		}
		
		public function playSound(soundName:String):void
		{
			SoundPlayer.getInstance().playSound(soundName);
		}
		
		public function getPosX(userId:String):int
		{
			var user:InteractivityUser = client.currentRoom.getUserById(userId);
			if (user) {
				return user.x;
			}
			return 0;
		}
		
		public function getPosY(userId:String):int
		{
			var user:InteractivityUser = client.currentRoom.getUserById(userId);
			if (user) {
				return user.y;
			}
			return 0;
		}
		
		public function setPicOffset(spotGuid:String, x:int, y:int):void
		{
			// TODO: Implement this
			logResult("setPicOffset spotId: " + spotGuid + " x: " + x + " y: " + y);
		}
		
		public function getSpotLocation(spotGuid:String):Point {
			var item:IRoomItem = IRoomItem(client.currentRoom.itemsByGuid[spotGuid]);
			var point:Point = new Point(0,0);
			if (item && item is Hotspot) {
				var hotspot:Hotspot = Hotspot(item);
				point.x = hotspot.location.x;
				point.y = hotspot.location.y;
			}
			return point;
		}
		
		public function killUser(userId:String):void
		{
			client.privateMessage("`kill", userId);
		}
		
		public function getSpotIdByIndex(spotIndex:int):String
		{
			var hotspots:Array = [];
			for each (var item:IRoomItem in client.currentRoom.items) {
				if (item is Hotspot) {
					hotspots.push(item);
				}
			}
			
			if (spotIndex < 0 || spotIndex > hotspots.length-1) {
				return null;
			}
			
			var hotspot:Hotspot = Hotspot(hotspots[spotIndex]);
			if (hotspot) {
				return hotspot.guid;
			}
			return null;
		}
		
		public function setChatString(message:String):void
		{
//			trace("Setting chat message to: \"" + message + "\"");
			if (message.length > 254) {
				message = message.substr(0, 254);
			}
			client.chatstr = message;
		}
		
		public function getNumSpots():int
		{
			return getNumDoors();
		}
		
		public function unlock(spotGuid:String):void
		{
			client.unlockDoor(client.currentRoom.id, spotGuid);
		}
		
		public function setFace(faceId:int):void
		{
			client.setFace(faceId);
		}
		
		public function enableWebcam():void {
			client.setVideoAvatar();
		}
		
		public function logMessage(message:String):void
		{
			client.currentRoom.logMessage(message);
		}
		
		public function sendPrivateMessage(message:String, userId:String):void
		{
			client.privateMessage(message, userId);
		}
		
		public function getUserByName(userName:String):String
		{
			var user:InteractivityUser = client.currentRoom.getUserByName(userName);
			if (user) {
				return user.id;
			}
			return "";
		}
		
		public function getRoomId():String
		{
			return client.currentRoom.id;
		}
		
		public function getWorldId():String {
			return client.currentWorld.guid;
		}
		
		public function setScriptAlarm(tokenList:IptTokenList, spotGuid:String, futureTime:int):void {
			var context:WorlizeIptExecutionContext = new WorlizeIptExecutionContext(scriptManager);
			context.hotspotGuid = spotGuid;
			var alarm:IptAlarm = new IptAlarm(tokenList, scriptManager, futureTime, context);
			scriptManager.addAlarm(alarm);
		}
		
		public function moveSpot(spotGuid:String, xBy:int, yBy:int):void
		{
			// TODO: Implement
			logResult("moveSpot spotId: " + spotGuid + " xBy: " + xBy + " yBy: " + yBy);
		}
		
		public function moveSpotLocal(spotGuid:String, xBy:int, yBy:int):void
		{
			var hotspot:Hotspot = client.currentRoom.getHotspotByGuid(spotGuid);
			if (hotspot) {
				hotspot.moveTo(hotspot.location.x, hotspot.location.y);
			}
		}
		
		public function getRoomUserIdByIndex(userIndex:int):String
		{
			var user:InteractivityUser = client.currentRoom.getUserByIndex(userIndex);
			if (user) {
				return user.id;
			}
			return "";
		}
		
		public function getChatString():String
		{
			return client.chatstr;
		}
	
		public function setSpotAlarm(spotGuid:String, futureTime:int):void
		{
			var hotspot:Hotspot = client.currentRoom.getHotspotByGuid(spotGuid);
			if (hotspot) {
				var tokenList:IptTokenList = hotspot.getEventHandler(IptEventHandler.TYPE_ALARM);
				if (tokenList) {
					setScriptAlarm(tokenList, hotspot.guid, futureTime);
				}
			}
		}
		
		public function getRoomWidth():int {
			return client.currentRoom.roomView.backgroundImage.width;
		}
		
		public function getRoomHeight():int {
			return client.currentRoom.roomView.backgroundImage.height;
		}
		
		public function hideAvatars():void {
			client.currentRoom.showAvatars = false;
		}
		
		public function showAvatars():void {
			client.currentRoom.showAvatars = true;
		}
		
		public function clearLooseProps():void {
			client.clearLooseProps();
		}
	}
}