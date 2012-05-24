package com.worlize.interactivity.iptscrae.command
{
	import com.worlize.interactivity.iptscrae.WorlizeIptExecutionContext;
	
	import org.openpalace.iptscrae.IptAlarm;
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.IptTokenList;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class ALARMEXECCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var delayTicks:IntegerToken = context.stack.popType(IntegerToken);
			var tokenList:IptTokenList = context.stack.popType(IptTokenList);
			var newContext:WorlizeIptExecutionContext = new WorlizeIptExecutionContext(context.manager);
			newContext.hotspotGuid = WorlizeIptExecutionContext(context).hotspotGuid;
			var alarm:IptAlarm = new IptAlarm(tokenList, context.manager, delayTicks.data, newContext);
			context.manager.addAlarm(alarm);
		}
	}
}
