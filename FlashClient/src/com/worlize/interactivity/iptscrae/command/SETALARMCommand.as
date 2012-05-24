package com.worlize.interactivity.iptscrae.command
{
	import com.worlize.interactivity.iptscrae.IptInteractivityController;
	import com.worlize.interactivity.iptscrae.WorlizeIptExecutionContext;
	import com.worlize.interactivity.iptscrae.WorlizeIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class SETALARMCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var pc:IptInteractivityController = WorlizeIptManager(context.manager).pc;
			var spotGuid:String = StringToken(context.stack.popType(StringToken)).data;
			var futureTime:IntegerToken = context.stack.popType(IntegerToken);
			if (spotGuid === "") {
				spotGuid = WorlizeIptExecutionContext(pc).hotspotGuid;
			}
			pc.setSpotAlarm(spotGuid, futureTime.data);
		}
	}
}