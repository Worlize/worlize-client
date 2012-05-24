package com.worlize.interactivity.iptscrae.command
{
	import com.worlize.interactivity.iptscrae.IptInteractivityController;
	import com.worlize.interactivity.iptscrae.WorlizeIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class SETLOCLOCALCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var pc:IptInteractivityController = WorlizeIptManager(context.manager).pc;
			
			var spotId:StringToken = context.stack.popType(StringToken);
			var y:IntegerToken = context.stack.popType(IntegerToken);
			var x:IntegerToken = context.stack.popType(IntegerToken);
			
			pc.moveSpotLocal(spotId.data, x.data, y.data);
		}
	}
}