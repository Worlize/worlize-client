package com.worlize.interactivity.iptscrae.command
{
	import com.worlize.interactivity.iptscrae.WorlizeIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class MIDILOOPCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			var name:StringToken = context.stack.popType(StringToken);
			var loopCount:IntegerToken = context.stack.popType(IntegerToken);
			WorlizeIptManager(context.manager).pc.midiLoop(loopCount.data, name.data);
		}
	}
}