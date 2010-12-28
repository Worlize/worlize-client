package com.worlize.interactivity.iptscrae.command
{
	import com.worlize.interactivity.iptscrae.IptInteractivityController;
	import com.worlize.interactivity.iptscrae.WorlizeIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class NOTIFICATIONCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var pc:IptInteractivityController = WorlizeIptManager(context.manager).pc;
			var text:StringToken = context.stack.popType(StringToken);
			var title:StringToken = context.stack.popType(StringToken);
			pc.notification(text.data, title.data);
		}
	}
}