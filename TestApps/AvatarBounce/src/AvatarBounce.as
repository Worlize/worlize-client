package
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.ChatEvent;
	import com.worlize.api.model.ThisUser;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class AvatarBounce extends Sprite
	{
		private var api:WorlizeAPI;
		
		private var bouncing:Boolean = false;
		
		private var velY:int = 0;
		private var velX:int = 0;
		private var gravity:int = 1;
		private var user:ThisUser;
		private var frameCounter:uint = 0;
		
		public function AvatarBounce() {
			WorlizeAPI.options.defaultWidth = 64;
			WorlizeAPI.options.defaultHeight = 64;
			api = WorlizeAPI.init(this);
			
			api.thisRoom.addEventListener(ChatEvent.OUTGOING_CHAT,
										  handleOutgoingChat);
			user = api.thisUser;
		}
		
		private function handleOutgoingChat(event:ChatEvent):void {
			var lcChat:String = event.originalText.toLowerCase();
			if (lcChat === 'bounce on') {
				event.preventDefault(); // don't actually say 'bounce on'
				startBouncing();
			}
			else if (lcChat === 'bounce off') {
				event.preventDefault(); // don't actually say 'bounce off'
				stopBouncing();
			}
		}
		
		private function startBouncing():void {
			if (bouncing) { return; }
			user.removeAvatar();
			
			bouncing = true;
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			
			velX = 3;
			velY = 1;
			if (user.y > api.thisRoom.height - 150) {
				user.moveTo(user.x, api.thisRoom.height - 150);
			}
		}
		
		private function stopBouncing():void {
			if (!bouncing) { return; }
			bouncing = false;
			removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
		
		private function handleEnterFrame(event:Event):void {
			var newX:uint
			var newY:uint;
			
			velY += gravity;
			
			// If we hit the bottom, reverse the direction and change our color
			if (user.y + velY > api.thisRoom.height - 50) {
				user.color = Math.floor(Math.random()*12);
				velY -= gravity;
				velY *= -1;
			}
			if (user.x + velX > api.thisRoom.width - 25 || user.x + velX < 25) {
				velX *= -1;
			}
			
			newX = user.x + velX;
			newY = user.y + velY;
			
			user.moveTo(newX, newY);
		}
	}
}