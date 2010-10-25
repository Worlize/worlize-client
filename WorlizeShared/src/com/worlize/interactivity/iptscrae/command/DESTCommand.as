package com.worlize.interactivity.iptscrae.command
{
	import com.worlize.interactivity.iptscrae.IptInteractivityController;
	import com.worlize.interactivity.iptscrae.WorlizeIptExecutionContext;
	import com.worlize.interactivity.iptscrae.WorlizeIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class DESTCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var pc:IptInteractivityController = WorlizeIptManager(context.manager).pc;
			var selfHotspotId:int = WorlizeIptExecutionContext(context).hotspotId;
			context.stack.push(new StringToken(pc.getSpotDest(selfHotspotId)));
		}
	}
}