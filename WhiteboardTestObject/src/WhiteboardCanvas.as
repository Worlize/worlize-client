package
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.StateHistoryEvent;
	import com.worlize.api.event.ChatEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class WhiteboardCanvas extends Sprite
	{
		private var api:WorlizeAPI;
		
		public var color:uint = 0x00000000;
		public var weight:uint = 2;
		
		private var lastX:Number;
		private var lastY:Number;
		
		
		public function WhiteboardCanvas() {
			api = WorlizeAPI.getInstance();
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
		}
		
		private function handleAddedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			clear();
			rebuildFromHistory();
			initializeListeners();
		}
		
		public function eraseCanvas():void {
			api.stateHistory.clear();
		}
		
		private function clear():void {
			graphics.clear();
			graphics.lineStyle(1, 0x000000);
			graphics.beginFill(0xFFFFFF);
			graphics.drawRect(0, 0, api.thisObject.width-1, api.thisObject.height-1);
			graphics.endFill();
		}
		
		private function rebuildFromHistory():void {
			if (api.stateHistory.length > 0) {
				for each (var entry:Object in api.stateHistory) {
					if (entry is Array) {
						handleDrawCommand(entry as Array);
					}
				}
			}
		}
		
		private function initializeListeners():void {
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			api.stateHistory.addEventListener(StateHistoryEvent.ENTRY_ADDED, handleStateHistoryItemAdded);
			api.stateHistory.addEventListener(StateHistoryEvent.CLEARED, handleStateHistoryCleared);
			api.thisRoom.addEventListener(ChatEvent.OUTGOING_CHAT, handleOutgoingChat);
		}
		
		private function handleStateHistoryItemAdded(event:StateHistoryEvent):void {
			if (event.entry is Array) {
				handleDrawCommand(event.entry as Array);
			}
		}
		
		private function handleStateHistoryCleared(event:StateHistoryEvent):void {
			clear();
		}
		
		private function handleOutgoingChat(event:ChatEvent):void {
			if (event.text.toLowerCase() === 'clear') {
				event.preventDefault();
				eraseCanvas();
			}
		}
		
		private function handleDrawCommand(data:Array):void {
			graphics.moveTo(data[0], data[1]);
			graphics.lineStyle(data[5], data[4]);
			graphics.lineTo(data[2], data[3]);
		}
		
		private function handleMouseDown(event:MouseEvent):void {
			lastX = mouseX;
			lastY = mouseY;
			api.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
		}
		
		private function handleMouseUp(event:MouseEvent):void {
			removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			api.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
		}
		
		private function handleMouseMove(event:MouseEvent):void {
			if (lastX !== event.localX || lastY !== event.localY) {
				api.stateHistory.push([
					lastX, lastY, event.localX, event.localY, color, weight 
				]);
				lastX = mouseX;
				lastY = mouseY;
			}
		}
	}
}