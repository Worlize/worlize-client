package com.worlize.interactivity.iptscrae.command
{
	import com.worlize.interactivity.iptscrae.WorlizeIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	
	public class MIDISTOPCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext) : void {
			WorlizeIptManager(context.manager).pc.midiStop();
		}
	}
}