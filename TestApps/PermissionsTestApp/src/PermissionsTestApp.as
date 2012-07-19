package
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.UserEvent;
	
	import flash.display.Sprite;
	
	public class PermissionsTestApp extends Sprite
	{
		private var api:WorlizeAPI;
		public function PermissionsTestApp()
		{
			WorlizeAPI.options.defaultWidth = 50;
			WorlizeAPI.options.defaultHeight = 50;
			
			api = WorlizeAPI.init(this);
			
			api.thisRoom.addEventListener(UserEvent.USER_PERMISSIONS_CHANGED, handlePrivilegesChanged);
			
			api.log("Current user privileges: " + api.thisUser.permissions.join(', '));
			api.log("canAuthor: " + api.thisUser.canAuthor);
		}
		
		private function handlePrivilegesChanged(event:UserEvent):void {
			api.log(event.user.name + " privileges changed: " + event.user.permissions.join(', '));
			api.log("canAuthor: " + event.user.canAuthor);
		}
	}
}