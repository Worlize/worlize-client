package com.worlize.interactivity.iptscrae.command
{
	import com.worlize.interactivity.iptscrae.IptInteractivityController;
	import com.worlize.interactivity.iptscrae.WorlizeIptExecutionContext;
	import com.worlize.interactivity.iptscrae.WorlizeIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class SETALARMCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var pc:IptInteractivityController = WorlizeIptManager(context.manager).pc;
			var spotId:int = context.stack.popType(IntegerToken).data;
			var futureTime:IntegerToken = context.stack.popType(IntegerToken);
			if (spotId == 0) {
				spotId = WorlizeIptExecutionContext(pc).hotspotId;
			}
			pc.setSpotAlarm(spotId, futureTime.data);
		}
	}
}