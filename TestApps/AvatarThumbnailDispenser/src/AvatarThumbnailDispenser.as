package
{
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.constants.AvatarType;
	import com.worlize.api.event.AuthorEvent;
	import com.worlize.api.event.ChangeEvent;
	import com.worlize.api.model.Avatar;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import mx.core.BitmapAsset;
	
	public class AvatarThumbnailDispenser extends Sprite
	{
		[Embed(source="savebutton.png")]
		public var saveButtonImage:Class;
		public var saveButtonBitmapData:BitmapData;
		
		public var api:WorlizeAPI;
		
		public var backgroundSprite:Sprite;
		public var thumbnailSprite:Sprite;
		public var saveButtonSprite:Sprite;
		public var saveButtonBitmap:Bitmap;
		
		public var loader:Loader;
		
		public var hovered:Boolean = false;
		public var prevCursor:String;
		
		public function AvatarThumbnailDispenser() {
			WorlizeAPI.options.defaultWidth = 84;
			WorlizeAPI.options.defaultHeight = 84;
			WorlizeAPI.options.editModeSupported = true;
			WorlizeAPI.options.name = "Single Avatar Dispenser";
			
			api = WorlizeAPI.init(this);
			
			initAssets();
			
			backgroundSprite = new Sprite();
			backgroundSprite.x = 1;
			backgroundSprite.y = 1;
			drawBackground();
			addChild(backgroundSprite);
			
			thumbnailSprite = new Sprite();
			thumbnailSprite.addEventListener(MouseEvent.CLICK, handleThumbnailClick);
			addChild(thumbnailSprite);
			
			loadFromConfigData();
			
			saveButtonSprite = new Sprite();
			saveButtonSprite.x = 8;
			saveButtonSprite.y = 27;
			saveButtonSprite.addEventListener(MouseEvent.CLICK, handleSaveButtonClick);
			saveButtonBitmap = new Bitmap(saveButtonBitmapData);
			saveButtonSprite.addChild(saveButtonBitmap);
			
			if (api.editMode) {
				showSaveButton();
			}
			else {
				hideSaveButton();
			}
			
			api.addEventListener(AuthorEvent.EDIT_MODE_ENABLED, showSaveButton);
			api.addEventListener(AuthorEvent.EDIT_MODE_DISABLED, hideSaveButton);
			api.config.addEventListener(ChangeEvent.PROPERTY_CHANGED, loadFromConfigData);
			
			addEventListener(MouseEvent.MOUSE_OVER, handleMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
		}
		
		private function handleMouseOver(event:MouseEvent):void {
			hovered = true;
			prevCursor = Mouse.cursor;
			Mouse.cursor = MouseCursor.BUTTON;
			drawBackground();
		}
		
		private function handleMouseOut(event:MouseEvent):void {
			hovered = false;
			Mouse.cursor = prevCursor;
			drawBackground();
		}
		
		private function loadFromConfigData(event:ChangeEvent=null):void {
			if (api.config.data.thumbnailURL) {
				loadThumb(api.config.data.thumbnailURL);
			}
		}
		
		private function initAssets():void {
			saveButtonBitmapData = BitmapAsset(new saveButtonImage()).bitmapData;
		}
		
		public function showSaveButton(event:Event = null):void {
			if (!contains(saveButtonSprite)) {
				addChild(saveButtonSprite);
			}
		}
		
		public function hideSaveButton(event:Event = null):void {
			if (contains(saveButtonSprite)) {
				removeChild(saveButtonSprite);
			}
		}
		
		private function handleThumbnailClick(event:MouseEvent):void {
			if (api.config.data.avatarGuid) {
				api.thisUser.setAvatar(api.config.data.avatarGuid);
			}
		}
		
		private function handleSaveButtonClick(event:MouseEvent):void {
			if (api.thisUser.avatar.type === AvatarType.IMAGE) {
				api.config.data.thumbnailURL = api.thisUser.avatar.thumbnailURL;
				api.config.data.avatarGuid = api.thisUser.avatar.guid;
				api.config.save();
			}
		}
		
		public function drawBackground():void {
			var g:Graphics = backgroundSprite.graphics;
			g.clear();
			g.beginFill(0xF0F0F0);
			if (hovered) {
				g.lineStyle(2, 0x66FF66);
			}
			else {
				g.lineStyle(2, 0xA0A0A0);
			}
			g.drawRect(0,0, 82, 82);
			g.endFill();
		}
		
		public function loadThumb(url:String):void {
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleLoaderComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleLoaderIOError);
			var request:URLRequest = new URLRequest(url);
			var context:LoaderContext = new LoaderContext(true);
			loader.load(request, context);
		}
		
		private function handleLoaderComplete(event:Event):void {
			thumbnailSprite.removeChildren();
			loader.content.x = 2;
			loader.content.y = 2;
			thumbnailSprite.addChild(loader.content);
		}
		
		private function handleLoaderIOError(event:IOErrorEvent):void {
			api.log("Avatar Dispenser: IO Error encountered while loading avatar thumbnail:");
			api.log(event.toString());
		}
	}
}