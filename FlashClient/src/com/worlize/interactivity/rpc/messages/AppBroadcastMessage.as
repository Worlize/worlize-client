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
		public var toUserGuids:Array;
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
			
			ba.writeUnsignedInt(ID);
			
			flags = 0x00;
			if (toUserGuids && toUserGuids.length > 0) {
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

			// If we have a list of "to" user guids, write out the count,
			// followed by the actual guids.
			if (flags & 0x01) {
				ba.writeShort(toUserGuids.length);
				for each (var userGuid:String in toUserGuids) {
					GUIDUtil.writeBytes(userGuid, ba);
				}
			}
			
			ba.writeBytes(message);
			
			ba.position = 0;
			return ba;
		}
	}
}