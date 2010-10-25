package com.worlize.interactivity.iptscrae.command
{
	import com.worlize.interactivity.iptscrae.WorlizeIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class SOUNDCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var sound:StringToken = context.stack.popType(StringToken);
			WorlizeIptManager(context.manager).pc.playSound(sound.data);
		}
	}
}