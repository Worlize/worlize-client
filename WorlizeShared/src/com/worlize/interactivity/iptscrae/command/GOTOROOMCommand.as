package com.worlize.interactivity.iptscrae.command
{
	import com.worlize.interactivity.iptscrae.WorlizeIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class GOTOROOMCommand extends IptCommand
	{
		public override function execute(context:IptExecutionContext) : void {
			var roomId:StringToken = context.stack.popType(StringToken);
			// A GOTOROOM command cancels the rest of the script.
			context.exitRequested = true;
			WorlizeIptManager(context.manager).pc.gotoRoom(roomId.data);
		}
	}
}