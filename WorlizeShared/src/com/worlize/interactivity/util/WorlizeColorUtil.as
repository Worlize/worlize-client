package com.worlize.interactivity.util
{
	public class WorlizeColorUtil
	{
		public static function ARGBtoUint(alpha:uint, red:uint, green:uint, blue:uint):uint {
			var color:uint = 0x00000000;
			color = color | alpha << 24;
			color = color | red << 16;
			color = color | green << 8;
			color = color | blue;
			return color;
		}
	}
}