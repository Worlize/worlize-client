package com.worlize.interactivity.iptscrae.command
{
	import com.worlize.interactivity.iptscrae.WorlizeIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class SETFACECommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var face:IntegerToken = context.stack.popType(IntegerToken);
			WorlizeIptManager(context.manager).pc.setFace(face.data);
		}
	}
}