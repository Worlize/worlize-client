package com.worlize.interactivity.iptscrae.command
{
	import com.worlize.interactivity.iptscrae.WorlizeIptManager;
	
	import flash.geom.Point;
	
	import org.openpalace.iptscrae.IptCommand;
	import org.openpalace.iptscrae.IptExecutionContext;
	import org.openpalace.iptscrae.token.IntegerToken;
	import org.openpalace.iptscrae.token.StringToken;
	
	public class GETSPOTLOCCommand extends IptCommand
	{
		override public function execute(context:IptExecutionContext):void {
			var hotspotId:StringToken = context.stack.popType(StringToken);
			var point:Point = WorlizeIptManager(context.manager).pc.getSpotLocation(hotspotId.data);
			context.stack.push(new IntegerToken(point.x));
			context.stack.push(new IntegerToken(point.y));
		}
	}
}