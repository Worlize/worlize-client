package com.worlize.interactivity.rpc.messages
{
	import com.worlize.util.GUIDUtil;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class SyncedDataDumpMessage implements IBinaryServerMessage
	{
		public static const ID:uint = 0x44444d50; // DDMP
		
		public var appInstanceGuid:String;
		public var data:Object;
		
		public function serialize():ByteArray {
			return null;
		}
		
		public function deserialize(ba:ByteArray):void {
			var id:uint = ba.readUnsignedInt();
			appInstanceGuid = GUIDUtil.readBytes(ba);
			data = {};
			var count:uint = ba.readUnsignedInt();
			for (var i:uint = 0; i < count; i ++) {
				var key:String = ba.readUTF();
				var length:uint = ba.readUnsignedInt();
				var value:ByteArray = new ByteArray();
				value.endian = Endian.BIG_ENDIAN;
				ba.readBytes(value, 0, length);
				data[key] = value;
			}
		}
	}
}