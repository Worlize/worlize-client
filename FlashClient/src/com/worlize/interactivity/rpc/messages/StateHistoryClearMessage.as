package com.worlize.interactivity.rpc.messages
{
	import com.worlize.util.GUIDUtil;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class StateHistoryClearMessage implements IBinaryServerMessage
	{
		public static const ID:uint = 0x4C434C52; // LCLR
		
		public var appInstanceGuid:String;
		public var data:ByteArray;

		public function serialize():ByteArray {
			var ba:ByteArray = new ByteArray();
			ba.endian = Endian.BIG_ENDIAN;
			
			ba.writeUnsignedInt(ID);
			
			ba.writeByte(data ? 0x01 : 0x00);
			
			GUIDUtil.writeBytes(appInstanceGuid, ba);
			
			if (data) {
				ba.writeBytes(data);
			}
			
			return ba;
		}
		
		public function deserialize(ba:ByteArray):void {
			var id:uint = ba.readUnsignedInt();
			
			var flags:uint = ba.readUnsignedByte();
			
			appInstanceGuid = GUIDUtil.readBytes(ba);
			
			if (flags & 0x01) {
				data = new ByteArray();
				data.endian = Endian.BIG_ENDIAN;
				ba.readBytes(data, 0, ba.bytesAvailable);
			}
		}
	}
}