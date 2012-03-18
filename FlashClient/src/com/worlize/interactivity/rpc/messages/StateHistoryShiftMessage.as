package com.worlize.interactivity.rpc.messages
{
	import com.worlize.util.GUIDUtil;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class StateHistoryShiftMessage implements IBinaryServerMessage
	{
		public static const ID:uint = 0x4C534654; // LSFT
		
		public var userGuid:String;
		public var appInstanceGuid:String;

		public function serialize():ByteArray {
			var ba:ByteArray = new ByteArray();
			ba.endian = Endian.BIG_ENDIAN;
			
			ba.writeInt(ID);
			GUIDUtil.writeBytes(appInstanceGuid, ba);
			
			return ba;
		}
		
		public function deserialize(ba:ByteArray):void {
			var id:uint = ba.readUnsignedInt();
			
			var flags:uint = ba.readUnsignedByte();

			appInstanceGuid = GUIDUtil.readBytes(ba);
			
			// If we have a user guid, read it
			if (Boolean(flags & 0x01)) {
				userGuid = GUIDUtil.readBytes(ba);
			}
		}
	}
}