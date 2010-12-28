package com.worlize.interactivity.iptscrae.command
{
	import com.worlize.interactivity.iptscrae.IptInteractivityController;
	import com.worlize.interactivity.iptscrae.WorlizeIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class WHOPOSCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var pc:IptInteractivityController = WorlizeIptManager(context.manager).pc;
			var userId:StringToken = context.stack.popType(StringToken);
			var x:int = pc.getPosX(userId.data);
			var y:int = pc.getPosY(userId.data);
			context.stack.push(new IntegerToken(x));
			context.stack.push(new IntegerToken(y));
		}
	}
}