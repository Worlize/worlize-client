package com.worlize.interactivity.iptscrae
{
	import com.worlize.interactivity.model.Hotspot;
	
	import org.openpalace.iptscrae.IptTokenList;

	public interface IInteractivityController
	{
		function logError(message:String):void;
		function gotoURL(url:String):void;
		function launchApp(app:String):void;
		function getWhoChat():String;
		function midiLoop(loopNbr:int, name:String):void;
		function midiPlay(name:String):void;
		function selectHotSpot(spotId:int):void;
		function getNumDoors():int;
		function dimRoom(dimLevel:int):void;
		function getSelfPosY():int;
		function getSelfPosX():int;
		function moveUserAbs(x:int, y:int):void;
		function naked():void;
		function getMouseX():int;
		function getMouseY():int;
		function moveUserRel(xBy:int, yBy:int):void;
		function chat(text:String):void;
		function clearAlarms():void;
		function getWhoTarget():String;
		function beep():void;
		function getSpotDest(spotId:int):String;
		function doMacro(macro:int):void;
		function changeColor(colorNumber:int):void;
		function getUserName(userId:String):String;
		function getSelfUserName():String;
		function getNumRoomUsers():int;
		function getSelfUserId():String;
		function lock(spotId:int):void;
		function midiStop():void;
		function gotoRoom(roomId:String):void;
		function inSpot(spotId:int):Boolean;
		function sendGlobalMessage(message:String):void;
		function sendRoomMessage(message:String):void;
		function sendSusrMessage(message:String):void;
		function sendLocalMsg(message:String):void;
		function getRoomName():String;
		function getServerName():String;
		function statusMessage(message:String):void;
		function playSound(soundName:String):void;
		function getPosX(userId:String):int;
		function getPosY(userId:String):int;
		function setPicOffset(spotId:int, x:int, y:int):void;
		function killUser(userId:String):void;
		function getSpotIdByIndex(spotIndex:int):int;
		function setChatString(message:String):void;
		function getNumSpots():int;
		function unlock(spotId:int):void;
		function setFace(faceId:int):void;
		function logMessage(message:String):void;
		function sendPrivateMessage(message:String, userId:String):void;
		function getUserByName(userName:String):String;
		function getRoomId():String;
		function setScriptAlarm(tokenList:IptTokenList, spotId:int, futureTime:int):void;
		function moveSpot(spotId:int, xBy:int, yBy:int):void;
		function getRoomUserIdByIndex(userIndex:int):String;
		function getChatString():String;
		function setSpotAlarm(spotId:int, futureTime:int):void;
		function triggerHotspotEvent(hotspot:Hotspot, eventType:int):Boolean;
	}
}