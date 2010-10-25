package com.worlize.interactivity.iptscrae
{
	
	import org.openpalace.iptscrae.IptManager;
	
	public class WorlizeIptManager extends IptManager
	{
		public var pc:IptInteractivityController;
		
		public function WorlizeIptManager(pc:IptInteractivityController = null)
		{
			super();
			if (pc == null) {
				pc = new IptInteractivityController();
			}
			this.pc = pc;
			executionContextClass = WorlizeIptExecutionContext;
		}
		
	}
}