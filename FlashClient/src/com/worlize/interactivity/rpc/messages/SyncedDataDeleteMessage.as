package com.worlize.interactivity.rpc.messages
{
	import com.worlize.util.GUIDUtil;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class SyncedDataDeleteMessage implements IBinaryServerMessage
	{
		public static const ID:uint = 0x4444454c; // DDEL
		
		public var appInstanceGuid:String;
		public var key:String;
		
		public function serialize():ByteArray {
			var ba:ByteArray = new ByteArray();
			ba.endian = Endian.BIG_ENDIAN;
			ba.writeUnsignedInt(ID);
			GUIDUtil.writeBytes(appInstanceGuid, ba);
			ba.writeUTF(key);
			return ba;
		}
		
		public function deserialize(ba:ByteArray):void {
			var id:uint = ba.readUnsignedInt();
			appInstanceGuid = GUIDUtil.readBytes(ba);
			key = ba.readUTF();
		}
	}
}