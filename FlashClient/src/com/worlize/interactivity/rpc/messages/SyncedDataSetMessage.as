package com.worlize.interactivity.rpc.messages
{
	import com.worlize.util.GUIDUtil;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class SyncedDataSetMessage implements IBinaryServerMessage
	{
		public static const ID:uint = 0x44534554; // DSET;
		
		public var appInstanceGuid:String;
		public var key:String;
		public var value:ByteArray;
		
		public function serialize():ByteArray {
			var ba:ByteArray = new ByteArray();
			ba.endian = Endian.BIG_ENDIAN;
			ba.writeUnsignedInt(ID);
			GUIDUtil.writeBytes(appInstanceGuid, ba);
			ba.writeUTF(key);
			ba.writeBytes(value);
			return ba;
		}
		
		public function deserialize(ba:ByteArray):void {
			var id:uint = ba.readUnsignedInt();
			appInstanceGuid = GUIDUtil.readBytes(ba);
			key = ba.readUTF();
			value = new ByteArray();
			value.endian = Endian.BIG_ENDIAN;
			ba.readBytes(value, 0, ba.bytesAvailable);
		}
	}
}