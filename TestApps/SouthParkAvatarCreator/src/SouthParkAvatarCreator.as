package
{
	import com.worlize.api.WorlizeAPI;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	
	public class SouthParkAvatarCreator extends Sprite
	{
		public var api:WorlizeAPI;
		
		public var loader:Loader;
		
		public function SouthParkAvatarCreator()
		{
			WorlizeAPI.options.defaultWidth = 950;
			WorlizeAPI.options.defaultHeight = 570;
			WorlizeAPI.options.fullSize = true;
			WorlizeAPI.options.name = "South Park Avatar Creator";
			WorlizeAPI.options.resizableByUser = false;
			
			api = WorlizeAPI.init(this);
			
			Security.allowDomain("services.southparkstudios.com");
			
			loader = new Loader();
			addChild(loader);
			var loaderContext:LoaderContext = new LoaderContext(true, null, SecurityDomain.currentDomain);
			loaderContext.parameters = {
				browser: "flagShip",
				localAppConfig: "xml/app_config.xml",
				base: "http://services.southparkstudios.com/avatar/"
			};
			var request:URLRequest = new URLRequest("http://services.southparkstudios.com/avatar/swf/");
			loader.load(request, loaderContext);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoaderComplete);
		}
		
		private function handleLoaderComplete(event:Event):void {
			loader.x = 950/2 - loader.width/2;
			loader.y = 570/2 - loader.height/2;
		}
	}
}