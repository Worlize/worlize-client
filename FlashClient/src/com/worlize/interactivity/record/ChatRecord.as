package com.worlize.interactivity.record
{
	import org.openpalace.iptscrae.IptTokenList;

	public class ChatRecord
	{
		public static const INCHAT:int = 0;
		public static const OUTCHAT:int = 1;
		
		public var direction:int;
		public var whochat:String;
		public var whotarget:String;
		public var chatstr:String;
		public var whisper:Boolean;
		public var canceled:Boolean;
		public var modified:Boolean;
		public var eventHandlers:Vector.<IptTokenList>;
		private var _originalChatstr:String;
		
		public function ChatRecord(direction:int = INCHAT, whochat:String = null, whotarget:String = null, chatstr:String = "", isWhisper:Boolean = false)
		{
			this.direction = direction;
			this.whochat = whochat;
			this.whotarget = whotarget;
			this.chatstr = chatstr;
			this.whisper = isWhisper;
			this.canceled = false;
			this.modified = false;
			this._originalChatstr = chatstr;
		}
		
		public function get originalChatstr():String {
			return _originalChatstr;
		}
		
		public function clone():ChatRecord {
			return new ChatRecord(direction, whochat, whotarget, chatstr, whisper);
		}
	}
}