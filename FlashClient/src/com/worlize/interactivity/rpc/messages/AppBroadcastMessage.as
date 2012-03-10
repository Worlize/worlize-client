package com.worlize.interactivity.rpc.messages
{
	import com.worlize.util.GUIDUtil;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.IDataOutput;

	public class AppBroadcastMessage implements IBinaryServerMessage
	{
		public static const ID:uint = 0x42435354; // BCST
		
		public var fromAppInstanceGuid:String;
		public var toAppInstanceGuid:String;
		public var fromUserGuid:String;
		public var toUserGuid:String;
		public var message:ByteArray;
		public var flags:uint = 0x00;
		
		public function get broadcastToAllApps():Boolean {
			return Boolean(flags & 0x02);
		}
		
		public function deserialize(ba:ByteArray):void {
			var id:uint = ba.readUnsignedInt();
			
			flags = ba.readUnsignedByte();
			
			fromUserGuid = GUIDUtil.readBytes(ba);
			fromAppInstanceGuid = GUIDUtil.readBytes(ba);
			
			if (!broadcastToAllApps) {
				toAppInstanceGuid = GUIDUtil.readBytes(ba);
			}
			
			message = new ByteArray();
			ba.readBytes(message, 0, ba.bytesAvailable);
		}

		public function serialize():ByteArray {
			var ba:ByteArray = new ByteArray();
			ba.endian = Endian.BIG_ENDIAN;
			
			ba.writeInt(ID);
			
			flags = 0x00;
			if (toUserGuid) {
				flags |= 0x01;
			}
			if (toAppInstanceGuid === null) {
				flags |= 0x02;
			}
			
			ba.writeByte(flags);
			
			GUIDUtil.writeBytes(fromAppInstanceGuid, ba);
			
			if (toAppInstanceGuid) {
				GUIDUtil.writeBytes(toAppInstanceGuid, ba);
			}
			if (toUserGuid) {
				GUIDUtil.writeBytes(toUserGuid, ba);
			}
			
			ba.writeBytes(message);
			
			ba.position = 0;
			return ba;
		}
	}
}