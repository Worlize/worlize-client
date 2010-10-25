package com.worlize.interactivity.iptscrae.command
{
	import com.worlize.interactivity.iptscrae.WorlizeIptExecutionContext;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class MECommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			context.stack.push(new IntegerToken(WorlizeIptExecutionContext(context).hotspotId));
		}
	}
}