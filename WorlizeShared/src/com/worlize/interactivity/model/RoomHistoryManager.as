package com.worlize.interactivity.model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import com.worlize.interactivity.rpc.InteractivityClient;

	public class RoomHistoryManager extends EventDispatcher
	{
		public var client:InteractivityClient;
		
		private var history:Array = [];
		private var currentIndex:int = -1;
		
		public function addItem(guid:String, roomName:String="Unknown Room", worldName:String = "Unknown World"):void {
			history = history.slice(0, currentIndex+1);
			var roomHistoryEntry:RoomHistoryEntry = new RoomHistoryEntry();
			roomHistoryEntry.roomGuid = guid;
			roomHistoryEntry.roomName = roomName;
			roomHistoryEntry.worldName = worldName;
			history.push(roomHistoryEntry);
			currentIndex ++;
			dispatchEvent(new Event('historyChanged'));
		}
		
		[Bindable(event='historyChanged')]
		public function get canGoBack():Boolean {
			return (currentIndex > 0);
		}
		
		[Bindable(event='historyChanged')]
		public function get canGoForward():Boolean {
			return (currentIndex < history.length-1);
		}
		
		public function goBack():void {
			if (canGoBack) {
				currentIndex --;
				var roomHistoryEntry:RoomHistoryEntry = RoomHistoryEntry(history[currentIndex]);
				client.gotoRoom(roomHistoryEntry.roomGuid, false);
				dispatchEvent(new Event('historyChanged'));
			}
		}
		
		public function goForward():void {
			if (canGoForward) {
				currentIndex ++;
				var roomHistoryEntry:RoomHistoryEntry = RoomHistoryEntry(history[currentIndex]);
				client.gotoRoom(roomHistoryEntry.roomGuid, false);
				dispatchEvent(new Event('historyChanged'));
			}
		}
	}
}