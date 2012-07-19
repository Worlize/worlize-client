package
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.constants.AvatarType;
	import com.worlize.api.event.ChatEvent;
	import com.worlize.api.event.UserEvent;
	
	import flash.display.Sprite;
	
	public class BasicWordFilter extends Sprite
	{
		private var api:WorlizeAPI;
		
		public function BasicWordFilter()
		{
			// Initialize config options here
			WorlizeAPI.options.defaultWidth = 50;
			WorlizeAPI.options.defaultHeight = 50;
			WorlizeAPI.options.name = "Bad Language Filter";
			
			// WorlizeAPI.init must be called as soon as possible, ideally in the
			// main constructor for the App.
			WorlizeAPI.init(this);
			
			// Call this from anywhere to get the main API object
			api = WorlizeAPI.getInstance();
			
			// Watch for outgoing chat events to filter bad language
			api.thisRoom.addEventListener(ChatEvent.OUTGOING_CHAT, handleOutgoingChat);
		}
		
		private function handleOutgoingChat(event:ChatEvent):void {
			var filterRegex:RegExp = /fuck|damn|shit/ig;
			var usedBadLanguage:Boolean = event.text.search(filterRegex) !== -1;
			
			// Filter a few bad words...
			event.text = event.text.replace(filterRegex, '****');
			
			if (usedBadLanguage) {
				// Tell the user to shape up.
				api.thisRoom.announceLocal("Watch your language!!");
			}
		}
	}
}