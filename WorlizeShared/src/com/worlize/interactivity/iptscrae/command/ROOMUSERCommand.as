package com.worlize.interactivity.iptscrae.command
{
	import com.worlize.interactivity.iptscrae.IptInteractivityController;
	import com.worlize.interactivity.iptscrae.WorlizeIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class ROOMUSERCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var pc:IptInteractivityController = WorlizeIptManager(context.manager).pc;
			var userIndex:IntegerToken = context.stack.popType(IntegerToken);
			var userId:String;
			try {
				userId = pc.getRoomUserIdByIndex(userIndex.data);
			}
			catch (e:Error) {
				userId = "";
			}
			context.stack.push(new StringToken(userId));
		}
	}
}