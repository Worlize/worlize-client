package com.worlize.interactivity.rpc.messages
{
	import flash.utils.ByteArray;

	public interface IBinaryServerMessage
	{
		function serialize():ByteArray;
		function deserialize(byteArray:ByteArray):void;
	}
}