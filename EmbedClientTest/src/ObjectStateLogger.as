package
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.RoomEvent;
	import com.worlize.api.event.RoomObjectEvent;
	import com.worlize.api.model.RoomObject;
	
	import flash.display.Sprite;
	
	public class ObjectStateLogger extends Sprite
	{
		public var api:WorlizeAPI;
		
		public function ObjectStateLogger() {
			api = WorlizeAPI.init(this);
			api.thisRoom.addEventListener(RoomObjectEvent.STATE_CHANGED, handleObjectStateChanged);
			api.log("Object State Logger initialized.  My instance guid: " + api.thisObject.instanceGuid);
			for each (var obj:RoomObject in api.thisRoom.objects) {
				api.log("Object " + obj.instanceGuid + " state: " + obj.state);
			}
		}
		
		private function handleObjectStateChanged(event:RoomObjectEvent):void {
			api.log("Object " + event.roomObject.instanceGuid + " state changed to " + event.roomObject.state);
		}
	}
}