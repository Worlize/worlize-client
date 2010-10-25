package com.worlize.interactivity.iptscrae.command
{
	import flash.geom.Point;
	
	import com.worlize.interactivity.iptscrae.WorlizeIptManager;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	
	public class GETSPOTLOCCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var hotspotId:IntegerToken = context.stack.popType(IntegerToken);
			var point:Point = WorlizeIptManager(context.manager).pc.getSpotLocation(hotspotId.data);
			context.stack.push(new IntegerToken(point.x));
			context.stack.push(new IntegerToken(point.y));
		}
	}
}