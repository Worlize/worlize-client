package com.worlize.util
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;

	public class GUIDUtil
	{
		private static const GUID_REGEXP:RegExp =
			/^([\da-fA-F]{8})-([\da-fA-F]{4})-([\da-fA-F]{4})-([\da-fA-F]{4})-([\da-fA-F]{8})([\da-fA-F]{4})$/;
		
		public static function padhex(hexString:String, size:uint):String {
			var length:uint = size - hexString.length;
			
			while (length > 0) {
				hexString = "0" + hexString;
				length --;
			}
			
			return hexString;
		}
		
		public static function writeBytes(guid:String, bytes:IDataOutput):void {
			var match:Array = guid.match(GUID_REGEXP);
			if (!match) {
				throw new ArgumentError("Invalid GUID");
			}
			var originalEndian:String = bytes.endian;
			bytes.endian = Endian.BIG_ENDIAN;
			
			bytes.writeInt(parseInt(match[1], 16));
			bytes.writeShort(parseInt(match[2], 16));
			bytes.writeInt(parseInt(match[3]+match[4], 16));
			bytes.writeInt(parseInt(match[5], 16));
			bytes.writeShort(parseInt(match[6], 16));
			
			bytes.endian = originalEndian;
		}
		
		public static function readBytes(bytes:IDataInput):String {
			var guid:String;
			
			if (bytes.bytesAvailable < 16) {
				throw new Error("Insufficient data available on IDataInput to read binary GUID");
			}
			
			var originalEndian:String = bytes.endian;
			bytes.endian = Endian.BIG_ENDIAN;
			
			guid =  padhex(bytes.readUnsignedInt().toString(16), 8) + "-" +
					padhex(bytes.readUnsignedShort().toString(16), 4) + "-" +
					padhex(bytes.readUnsignedShort().toString(16), 4) + "-" +
					padhex(bytes.readUnsignedShort().toString(16), 4) + "-" +
					padhex(bytes.readUnsignedInt().toString(16), 8) +
					padhex(bytes.readUnsignedShort().toString(16), 4);
			
			bytes.endian = originalEndian;
			
			return guid;
		}
		
		public static function stringToByteArray(guid:String):ByteArray {
			var ba:ByteArray = new ByteArray();
			ba.endian = Endian.BIG_ENDIAN;
			writeBytes(guid, ba);
			ba.position = 0;
			return ba;
		}
	}
}