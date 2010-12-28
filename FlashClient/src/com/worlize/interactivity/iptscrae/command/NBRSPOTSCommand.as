package com.worlize.interactivity.iptscrae.command
{
	import com.worlize.interactivity.iptscrae.IptInteractivityController;
	import com.worlize.interactivity.iptscrae.WorlizeIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class NBRSPOTSCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var pc:IptInteractivityController = WorlizeIptManager(context.manager).pc;
			context.stack.push(new IntegerToken(pc.getNumSpots()));
		}
	}
}