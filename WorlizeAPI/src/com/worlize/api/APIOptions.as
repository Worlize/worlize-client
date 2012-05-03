package com.worlize.api
{
	import com.worlize.worlize_internal;

	/**
	 * Allows the app developer to set various config options for the Worlize
	 * API.
	 * 
	 * <p><strong>Properties on this class must be set before the API
	 * is initialized.</strong></p>
	 *  
	 * @author Brian McKelvey
	 * @see WorlizeAPI#init()
	 * @productversion Worlize APIv.1
	 * @example Set config options
	 * <listing version="3.0">
	 * 
	 * public class AvatarDispenser extends Sprite
	 * {
	 *   // top level app constructor function
	 *   function AvatarDispenser() {
	 * 
	 *     // The object instance is accessed via the <code>options</code> static
	 *     // property on the WorlizeAPI class. 
	 *     var options:APIOptions = WorlizeAPI.options;
	 * 
	 *     // Give the app a name
	 *     options.name = "Avatar Dispenser Pro";
	 * 
	 *     // Specify the app's initial size
	 *     options.defaultWidth = 200;
	 *     options.defaultHeight = 150;
	 * 
	 *     // Initialize the api AFTER setting the config options
	 *     WorlizeAPI.init(this);
	 *   }
	 * }
	 * 
	 * </listing>
	 */	
	public class APIOptions {
		use namespace worlize_internal;
		
		/**
		 * @private
		 */		
		worlize_internal var sizeUnknown:Boolean = true;
		
		/**
		 * Whether the app is adjusted to take up the entire size of the room
		 * 
		 * <p><em>Not yet implemented</em></p>
		 * 
		 * @productversion Worlize API.v1 
		 */		
		public var fullSize:Boolean = false;
		
		/**
		 * Whether the app has a visual user interface.
		 * 
		 * <p>Certain apps will not need to provide a user interface, such as
		 * moderation apps that affect the actions that occur in the room, i.e.
		 * a bad language filter.</p>
		 * 
		 * <p>Apps that are non-visual will still have an opportunity to
		 * present an on-screen configuration interface when the "Edit Settings"
		 * mode is activated by a room author.</p>
		 *
		 * <p><em>Not yet implemented</em></p>
		 * 
		 * @productversion Worlize API.v1 
		 */		
		public var nonVisual:Boolean = false;
		
		/**
		 * Whether the app is dynamically sizable by the user.
		 * 
		 * <p>If true, then <code>defaultWidth</code> and
		 * <code>defaultHeight</code> will have no effect.  Instead, the
		 * user-adjusted size will be used as the initial app size.</p>
		 * 
		 * <p>When true, the values specified for the following properties will
		 * restrict the range of sizes the user can select for the app:
		 * <ul>
		 *   <li><code>minWidth</code></li>
		 *   <li><code>minHeight</code></li>
		 *   <li><code>maxWidth</code></li>
		 *   <li><code>maxHeight</code></li>
		 * </ul>
		 * </p>
		 * 
		 * <p><em>Not yet implemented</em></p>
		 * 
		 * @productversion Worlize API.v1
		 */		
		public var resizableByUser:Boolean = false;
		
		/**
		 * Whether the app supports a custom configuration user interface when
		 * a room author activates the app's edit mode.
		 * 
		 * <p>Set this to <code>true</code> to enable the "Edit Settings..."
		 * button in the Object Properties dialog when the user is in Author
		 * Mode.</p>
		 * 
		 * @productversion Worlize API.v1
		 */
		public var editModeSupported:Boolean = false;
		
		/**
		 * The name of the app, as it will appear to the user in their list
		 * of apps.
		 * 
		 * @productversion Worlize API.v1 
		 */		
		public var name:String = "Untitled App";
		
		/**
		 * When <code>resizableByUser</code> is true, specifies the minimum
		 * allowable width for the app.
		 * 
		 * <p>Ignored when <code>resizableByUser</code> is false.</p>
		 * 
		 * <p><em>Not yet implemented</em></p>
		 * 
		 * @productversion Worlize APIv.1 
		 */		
		public var minWidth:int = 0;
		
		/**
		 * When <code>resizableByUser</code> is true, specifies the minimum
		 * allowable height for the app.
		 * 
		 * <p>Ignored when <code>resizableByUser</code> is false.</p>
		 * 
		 * <p><em>Not yet implemented</em></p>
		 * 
		 * @productversion Worlize APIv.1 
		 */		
		public var minHeight:int = 0;
		
		/**
		 * When <code>resizableByUser</code> is true, specifies the maximum
		 * allowable width for the app.
		 * 
		 * <p>Ignored when <code>resizableByUser</code> is false.</p>
		 * 
		 * <p><em>Not yet implemented</em></p>
		 * 
		 * @productversion Worlize APIv.1 
		 */		
		public var maxWidth:int = 0x7FFFFFFF;
		
		/**
		 * When <code>resizableByUser</code> is true, specifies the maximum
		 * allowable height for the app.
		 * 
		 * <p>Ignored when <code>resizableByUser</code> is false.</p>
		 * 
		 * <p><em>Not yet implemented</em></p>
		 * 
		 * @productversion Worlize APIv.1 
		 */		
		public var maxHeight:int = 0x7FFFFFFF;
		
		private var _defaultWidth:int = 500;
		private var _defaultHeight:int = 375;
		
		/**
		 * The initial width of the object (app) in pixels.
		 * 
		 * <p>This value will be ignored if <code>resizableByUser</code> is
		 * true and the user has resized the object.</p>
		 * 
		 * <p><strong>NOTE:</strong> If you do not explicitly set either
		 * <code>defaultWidth</code> or <code>defaultHeight</code>, the natural
		 * height of the SWF file will be used.  This is done to support
		 * the setting of the stage size in Adobe Flash Professional.</p>
		 * 
		 * @default 500
		 * @productversion Worlize APIv.1
		 */
		public function get defaultWidth():int {
			return _defaultWidth;
		}
		
		/**
		 * @private
		 */		
		public function set defaultWidth(newValue:int):void {
			_defaultWidth = newValue;
			sizeUnknown = false;
		}
		
		/**
		 * The initial height of the object (app) in pixels. 
		 * 
		 * <p>This value will be ignored if <code>resizableByUser</code> is
		 * true and the user has resized the object.</p>
		 * 
		 * <p><strong>NOTE:</strong> If you do not explicitly set either
		 * <code>defaultWidth</code> or <code>defaultHeight</code>, the natural
		 * height of the SWF file will be used.  This is done to support
		 * the setting of the stage size in Adobe Flash Professional.</p>
		 * 
		 * @default 375 
		 * @productversion Worlize APIv.1
		 */		
		public function get defaultHeight():int {
			return _defaultHeight;
		}

		/**
		 * @private
		 */		
		public function set defaultHeight(newValue:int):void {
			_defaultHeight = newValue;
			sizeUnknown = false;
		}
		
		/**
		 * @private
		 */		
		public function toJSON():Object {
			return {
				fullSize: fullSize,
				nonVisual: nonVisual,
				resizableByUser: resizableByUser,
				minWidth: minWidth,
				minHeight: minHeight,
				maxWidth: maxWidth,
				maxHeight: maxHeight,
				editModeSupported: editModeSupported,
				name: name,
				defaultHeight: _defaultHeight,
				defaultWidth: _defaultWidth,
				sizeUnknown: sizeUnknown
			};
		}
	}
}