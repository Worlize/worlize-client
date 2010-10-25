package com.worlize.interactivity.iptscrae.command
{
	import com.worlize.interactivity.iptscrae.WorlizeIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class SUSRMSGCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var message:StringToken = context.stack.popType(StringToken);
			WorlizeIptManager(context.manager).pc.sendSusrMessage(message.data);
		}
	}
}