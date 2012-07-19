package
{
	import com.adobe.net.URI;
	import com.worlize.api.WorlizeAPI;
	import com.worlize.api.event.ChangeEvent;
	import com.worlize.api.event.ChatEvent;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;
	
	import mx.core.BitmapAsset;
	
	public class SimpleSlideShow extends Sprite
	{
		[Embed(source="left-arrow.png")]
		public var leftArrowImage:Class;
		public var leftArrowBitmap:Bitmap;
		
		[Embed(source="right-arrow.png")]
		public var rightArrowImage:Class;
		public var rightArrowBitmap:Bitmap;
		
		public var api:WorlizeAPI;
		
		public var imagesToLoad:int = 0;
		public var imagesLoaded:int = 0;
		public var currentIndex:int = 0;
		public var loaders:Array = [];
		
		public var imagesContainer:Sprite;
		public var leftArrow:Sprite;
		public var rightArrow:Sprite;
		
		public function SimpleSlideShow()
		{
			WorlizeAPI.options.defaultWidth = 500;
			WorlizeAPI.options.defaultHeight = 300;
			WorlizeAPI.options.name = "Simple Image Carousel";
			
			api = WorlizeAPI.init(this);
			
			api.thisRoom.addEventListener(ChatEvent.OUTGOING_CHAT, handleOutgoingChat);
			api.config.addEventListener(ChangeEvent.PROPERTY_CHANGED, handleConfigChanged);
			
			if (!(images is Array)) {
				images = [];
			}
			
			buildElements();
			
			updateFromConfig();
		}
		
		private function handleConfigChanged(event:ChangeEvent):void {
			updateFromConfig();
		}
		
		private function buildElements():void {
			removeChildren();
			
			imagesContainer = new Sprite();
			imagesContainer.visible = false;
			imagesContainer.mouseChildren = false;
			imagesContainer.x = 40;
			
			leftArrow = new Sprite();
			rightArrow = new Sprite();
			
			rightArrow.visible = rightArrow.mouseEnabled = false;
			leftArrow.visible = leftArrow.mouseEnabled = false;
			
			leftArrow.alpha = 0.7;
			rightArrow.alpha = 0.7;
			
			leftArrow.buttonMode = true;
			rightArrow.buttonMode = true;
			
			var g:Graphics;
			g = leftArrow.graphics;
			g.beginFill(0x000000, 0.5);
			g.drawRoundRectComplex(0,0,40,80,4,0,4,0);
			g.endFill();
			g = rightArrow.graphics;
			g.beginFill(0x000000, 0.5);
			g.drawRoundRectComplex(0,0,40,80,0,4,0,4);
			g.endFill();
			
			// Add the arrow icons
			leftArrowBitmap = new Bitmap(BitmapAsset(new leftArrowImage()).bitmapData);
			leftArrowBitmap.x = 0;
			leftArrowBitmap.y = 0;
			leftArrow.addChild(leftArrowBitmap);
			
			rightArrowBitmap = new Bitmap(BitmapAsset(new rightArrowImage()).bitmapData);
			rightArrowBitmap.x = 0;
			rightArrowBitmap.y = 0;
			rightArrow.addChild(rightArrowBitmap);
			
			addChild(imagesContainer);
			addChild(leftArrow);
			addChild(rightArrow);
			
			leftArrow.addEventListener(MouseEvent.CLICK, handleLeftArrowClick);
			rightArrow.addEventListener(MouseEvent.CLICK, handleRightArrowClick);
			leftArrow.addEventListener(MouseEvent.ROLL_OVER, handleArrowRollOver);
			rightArrow.addEventListener(MouseEvent.ROLL_OVER, handleArrowRollOver);
			leftArrow.addEventListener(MouseEvent.ROLL_OUT, handleArrowRollOut);
			rightArrow.addEventListener(MouseEvent.ROLL_OUT, handleArrowRollOut);
			
			positionArrows();
		}
		
		private function handleArrowRollOver(event:MouseEvent):void {
			DisplayObject(event.target).alpha = 1.0;
		}
		
		private function handleArrowRollOut(event:MouseEvent):void {
			DisplayObject(event.target).alpha = 0.7;
		}
		
		private function handleLeftArrowClick(event:MouseEvent):void {
			prev();
		}
		
		private function handleRightArrowClick(event:MouseEvent):void {
			next();
		}
		
		private function positionArrows():void {
			leftArrow.x = 0;
			leftArrow.y = api.thisObject.height / 2 - leftArrow.height / 2;
			
			rightArrow.x = api.thisObject.width - rightArrow.width;
			rightArrow.y = api.thisObject.height / 2 - rightArrow.height / 2;
		}
		
		private function updateFromConfig():void {
			unloadAllImages();
			hideSlideshow();
			currentIndex = 0;
			imagesLoaded = 0;
			imagesToLoad = images.length;
			for each (var url:String in images) {
				loadImage(url);
			}
		}
		
		private function unloadAllImages():void {
			for (var i:int = 0; i < imagesContainer.numChildren; i++) {
				var loader:Loader = imagesContainer.getChildAt(i) as Loader;
				
				loader.unload();
			}
			imagesContainer.removeChildren();
		}
		
		private function loadImage(url:String):void {
			var loader:Loader = new Loader();
			var context:LoaderContext = new LoaderContext(false);
			context.imageDecodingPolicy = ImageDecodingPolicy.ON_DEMAND;
			context.allowCodeImport = false;
			var request:URLRequest = new URLRequest(url);
			loader.contentLoaderInfo.addEventListener(
				Event.INIT,
				function(event:Event):void {
					// Disallow flash items.
					if (loader.contentLoaderInfo.contentType === 'application/x-shockwave-flash') {
						loader.unload();
						imagesContainer.removeChild(loader);
						imagesToLoad --;
						checkImagesLoaded();
					}
				}
			);
			loader.contentLoaderInfo.addEventListener(
				Event.COMPLETE,
				function(event:Event):void {
					imagesLoaded ++;
					checkImagesLoaded();
				}
			);
			loader.contentLoaderInfo.addEventListener(
				IOErrorEvent.IO_ERROR,
				function(event:IOErrorEvent):void {
					api.log("Carousel: Unable to load image: " + url);
					imagesContainer.removeChild(loader);
					imagesToLoad --;
					checkImagesLoaded();
				}
			);
			loader.visible = false;
			loader.mouseEnabled = loader.mouseChildren = false;
			loader.load(request, context);
			imagesContainer.addChild(loader);
		}
		
		private function checkImagesLoaded():void {
			if (imagesLoaded === imagesToLoad) {
				showSlideshow();
			}
		}
		
		private function showSlideshow():void {
			if (imagesContainer.numChildren <= 0) {
				api.log("Carousel: There are no images available to display");
				return;
			}
			var firstImage:DisplayObject = imagesContainer.getChildAt(0);
			api.thisObject.setSize(firstImage.width+80, firstImage.height);
			positionArrows();
			imagesContainer.visible = true;
			showImage(0);
		}
		
		private function hideSlideshow():void {
			imagesContainer.visible = false;
			leftArrow.visible = rightArrow.mouseEnabled = false;
			rightArrow.visible = rightArrow.mouseEnabled = false;
		}
		
		private function showImage(index:int):void {
			if (index >= 0 && index < imagesContainer.numChildren) {
				currentIndex = index;
				for (var i:int = 0; i < imagesContainer.numChildren; i ++) {
					var item:DisplayObject = imagesContainer.getChildAt(i);
					item.visible = (index === i);
				}
				leftArrow.visible = leftArrow.mouseEnabled = currentIndex > 0;
				rightArrow.visible = rightArrow.mouseEnabled = currentIndex < imagesContainer.numChildren-1;
			}
		}
		
		private function next():void {
			if (currentIndex >= imagesContainer.numChildren) {
				showImage(0);
				return;
			}
			showImage(++currentIndex);
		}
		
		private function prev():void {
			if (currentIndex === 0) {
				showImage(imagesContainer.numChildren-1);
				return;
			}
			showImage(--currentIndex);
		}
		
		private function set images(newValue:Array):void {
			api.config.data['images'] = newValue;
		}
		
		private function get images():Array {
			return api.config.data['images'];
		}
		
		private function handleOutgoingChat(event:ChatEvent):void {
			if (!api.thisUser.canAuthor) { return; }
			
			var t:String = event.originalText;
			var match:Array = t.match(/^carousel (.+)$/i);
			if (match === null) {
				return;
			}
			
			event.preventDefault();
			
			var cmdString:String = match[1];
			var command:String;
			var params:String;
			match = cmdString.match(/^([^ ]+) ?(.*)$/);
			if (match) {
				command = String(match[1]).toLowerCase();
				params = match[2];
			}
			
			switch (command) {
				case "help":
					logHelp();
					break;
				case "add":
					addImage(params);
					break;
				case "remove":
					removeImage(params);
					break;
				case "list":
					listImages();
					break;
				case "clear":
					removeAllImages();
					break;
				default:
					break;
			}
		}
		
		private function save():void {
			api.config.save();
		}
		
		private function logHelp():void {
			api.thisRoom.announceLocal("Check your log for instructions.");
			api.log("");
			api.log("Commands:");
			api.log("    carousel add &lt;url&gt;");
			api.log("    carousel remove &lt;url&gt;");
			api.log("    carousel list");
			api.log("    carousel clear");
			api.log("");
		}
		
		private function addImage(url:String):void {
			var uri:URI = new URI(url);
			if (!uri.isValid() || url.length < 1) {
				api.thisRoom.announceLocal("That URL is invalid.");
				return;
			}
			
			images.push(uri.toString());
			save();
			
			api.thisRoom.announceLocal("Image " + uri.toString() + " added");
		}
		
		private function removeImage(url:String):void {
			var uri:URI = new URI(url);
			if (!uri.isValid() || url.length < 1) {
				api.thisRoom.announceLocal("That URL is invalid.");
				return;
			}
			
			var index:int = images.indexOf(uri.toString());
			if (index === -1) {
				api.thisRoom.announceLocal("The specified URL is not in this carousel.");
				return;
			}
			
			images.splice(index, 1);
			save();
			
			api.thisRoom.announceLocal("Image " + uri.toString() + " removed");
		}
		
		private function removeAllImages():void {
			images = [];
			save();
			api.thisRoom.announceLocal("All images have been removed from the carousel.");
		}
		
		private function listImages():void {
			var len:int = images.length;
			api.log("There " + (len == 1 ? "is " : "are ") + len + (len == 1 ? ' image' : ' images') + " in the carousel.");
			var i:int = 0;
			for each (var url:String in images) {
				api.log((++i) + ".) " + url);
			}
		}
	}
}