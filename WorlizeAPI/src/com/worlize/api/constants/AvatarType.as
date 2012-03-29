package com.worlize.api.constants
{
	/**
	 * This class enumerates the possible types of avatars that can be seen
	 * in the <code>type</code> property of the <code>Avatar</code> class.
	 * 
	 * @author Brian McKelvey
	 * @productversion Worlize APIv.1
	 */	
	public final class AvatarType
	{
		/**
		 * The default "gummy" avatar that is displayed when the user has
		 * not selected any avatar from their locker. 
		 * 
		 * @productversion Worlize APIv.1
		 */
		public static const DEFAULT:String = "default";
		
		/**
		 * A standard image-based avatar.  Can be png, gif or jpeg.
		 * 
		 * @productversion Worlize APIv.1
		 */
		public static const IMAGE:String = "image";
		
		/**
		 * The user's webcam is being used as their avatar.
		 * 
		 * @productversion Worlize APIv.1 
		 */		
		public static const WEBCAM:String = "webcam";
	}
}