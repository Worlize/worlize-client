package com.worlize.interactivity.iptscrae.command
{
	import com.worlize.interactivity.iptscrae.WorlizeIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class MIDIPLAYCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var name:StringToken = context.stack.popType(StringToken);
			WorlizeIptManager(context.manager).pc.midiPlay(name.data);
		}
	}
}