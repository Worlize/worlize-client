package com.worlize.interactivity.iptscrae.command
{
	import com.worlize.interactivity.iptscrae.WorlizeIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class DIMROOMCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var dimLevel:IntegerToken = context.stack.popType(IntegerToken);
			WorlizeIptManager(context.manager).pc.dimRoom(dimLevel.data);
		}
	}
}