package com.worlize.interactivity.rpc.messages
{
	import com.worlize.util.GUIDUtil;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class StateHistoryPushMessage implements IBinaryServerMessage
	{
		public static const ID:uint = 0x4C505348; // LPSH
		
		public var userGuid:String;
		public var appInstanceGuid:String;
		public var data:ByteArray;
		
		public function serialize():ByteArray {
			var ba:ByteArray = new ByteArray();
			ba.endian = Endian.BIG_ENDIAN;
			
			ba.writeInt(ID);
			GUIDUtil.writeBytes(appInstanceGuid, ba);
			ba.writeBytes(data);
			
			return ba;
		}
		
		public function deserialize(ba:ByteArray):void {
			var id:uint = ba.readUnsignedInt();
			
			appInstanceGuid = GUIDUtil.readBytes(ba);
			userGuid = GUIDUtil.readBytes(ba);
			data = new ByteArray();
			data.endian = Endian.BIG_ENDIAN;
			ba.readBytes(data, 0, ba.bytesAvailable);
		}
	}
}