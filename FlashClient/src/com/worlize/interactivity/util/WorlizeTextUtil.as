package com.worlize.interactivity.util
{
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	import flash.xml.XMLNodeType;
	
	public class WorlizeTextUtil
	{
		
		public static function htmlUnescape(str:String):String {
		    return new XMLDocument(str).firstChild.nodeValue;
		}
		
		public static function htmlEscape(str:String):String {
		    return XML( new XMLNode( XMLNodeType.TEXT_NODE, str ) ).toXMLString();
		}

	}
}