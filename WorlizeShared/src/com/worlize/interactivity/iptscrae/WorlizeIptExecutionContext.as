package com.worlize.interactivity.iptscrae
{
	import org.openpalace.iptscrae.IptError;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptManager;
	import org.openpalace.iptscrae.IptToken;
	import org.openpalace.iptscrae.IptTokenStack;
	import org.openpalace.iptscrae.IptUtil;
	import org.openpalace.iptscrae.IptVariableStore;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class WorlizeIptExecutionContext extends IptExecutionContext
	{
		public var hotspotId:int = 0;
		
		public function WorlizeIptExecutionContext(manager:IptManager, stack:IptTokenStack=null, variableStore:IptVariableStore=null)
		{
			super(manager, stack, variableStore);
		}
		
		override public function isExternalVariable(name:String) : Boolean {
			if (name.toUpperCase() == "CHATSTR") {
				return true;
			}
			return false;
		}
		
		override public function getExternalVariable(name:String) : IptToken {
			if (name.toUpperCase() == "CHATSTR") {
				return new StringToken(WorlizeIptManager(manager).pc.getChatString());
			}
			return new IptToken();
		}
		
		override public function setExternalVariable(name:String, value:IptToken) : void {
			if (name.toUpperCase() == "CHATSTR") {
				if (value is StringToken) {
					WorlizeIptManager(manager).pc.setChatString(StringToken(value).data);
				}
				else {
					throw new IptError("Invalid data type for special variable 'CHATSTR': " + IptUtil.className(value));
				}
			}
		}
	}
}