package com.worlize.interactivity.iptscrae.command
{
	import com.worlize.interactivity.iptscrae.IptInteractivityController;
	import com.worlize.interactivity.iptscrae.WorlizeIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class SAYATCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var pc:IptInteractivityController = WorlizeIptManager(context.manager).pc;
			var y:IntegerToken = context.stack.popType(IntegerToken);
			var x:IntegerToken = context.stack.popType(IntegerToken);
			var message:StringToken = context.stack.popType(StringToken);
			pc.chat("@" + x.data + "," + y.data + " " + message.data); 
		}
	}
}