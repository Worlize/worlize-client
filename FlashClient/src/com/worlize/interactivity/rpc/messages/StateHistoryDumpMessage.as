package com.worlize.interactivity.rpc.messages
{
	import com.worlize.util.GUIDUtil;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class StateHistoryDumpMessage implements IBinaryServerMessage
	{
		public static const ID:uint = 0x4C444D50; // LDMP
		
		public var stateEntries:Array;
		public var appInstanceGuid:String;

		public function serialize():ByteArray {
			return null;
		}
		
		public function deserialize(ba:ByteArray):void {
			var id:uint = ba.readUnsignedInt();
			
			appInstanceGuid = GUIDUtil.readBytes(ba);
			
			var numEntries:uint = ba.readUnsignedInt();

			stateEntries = [];
			for (var i:int = 0; i < numEntries; i ++) {
				var length:uint = ba.readUnsignedShort();
				var data:ByteArray = new ByteArray();
				data.endian = Endian.BIG_ENDIAN;
				ba.readBytes(data, 0, length);
				stateEntries.push(data);
			}
		}
	}
}