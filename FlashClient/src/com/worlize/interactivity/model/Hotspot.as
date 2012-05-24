package com.worlize.interactivity.model
{
	import com.worlize.interactivity.event.HotspotEvent;
	import com.worlize.interactivity.iptscrae.IptEventHandler;
	import com.worlize.interactivity.iptscrae.WorlizeIptManager;
	import com.worlize.interactivity.rpc.InteractivityClient;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.openpalace.iptscrae.IptTokenList;

	[Event(name="stateChanged",type="com.worlize.interactivity.event.HotspotEvent")]
	[Event(name="moved",type="com.worlize.interactivity.event.HotspotEvent")]

	[Bindable]
	public class Hotspot extends EventDispatcher implements IRoomItem
	{
		public var dest:String = null;
		public var guid:String;
		private var _flags:int = 0;
		public var polygon:Array = []; // Array of points
		private var _name:String = null;
		public var location:FlexPoint;
		public var scriptEventMask:int = 0;
		public var nbrScripts:int = 0;
		public var scriptString:String = "";
		public var eventHandlers:Vector.<IptEventHandler> = new Vector.<IptEventHandler>();
		
		public static function fromData(data:Object):Hotspot {
			var hs:Hotspot = new Hotspot();
			hs.guid = data.guid;
			hs.dest = data.dest;
			hs.location = new FlexPoint();
			hs.location.x = data.x || 950/2;
			hs.location.y = data.y || 570/2;
			if (data.hasOwnProperty('points') && data.points is Array) {
				for each (var pointArray:Array in data.points) {
					hs.polygon.push(new Point(pointArray[0], pointArray[1]));
				}
			}
			return hs;
		}
		
		public function get x():int {
			return location.x;
		}
		
		public function set x(newValue:int):void {
			location.x = newValue;
		}
		
		public function get y():int {
			return location.y;
		}
		
		public function set y(newValue:int):void {
			location.y = newValue;
		}
		
		public function requestRedraw():void {
			dispatchEvent(new HotspotEvent(HotspotEvent.REDRAW_REQUESTED));
		}
		
		public function Hotspot()
		{
		}
		
		public function savePosition():void {
			var points:Array = [];
			for each (var point:Point in polygon) {
				points.push([point.x, point.y]);
			}
			InteractivityClient.getInstance().moveHotspot(guid, location.x, location.y, points);
		}
		
		public function deleteHotspot():void {
			var logger:ILogger = Log.getLogger('com.worlize.interactivity.model.Hotspot');
			logger.info("Deleting hotspot " + this.guid);
			var client:InteractivityClient = InteractivityClient.getInstance();
			client.removeHotspot(guid);
		}
		
		public function selectForAuthoring():void {
			var selectEvent:HotspotEvent = new HotspotEvent(HotspotEvent.SELECTED_FOR_AUTHOR);
			selectEvent.hotSpot = this;
			dispatchEvent(selectEvent);
		}
		
		public function moveTo(x:int, y:int, points:Array = null):void {
			location.x = x;
			location.y = y;
			if (points) {
				polygon = [];
				for each (var p:Array in points) {
					polygon.push(new Point(p[0], p[1]));
				}
				requestRedraw();
			}
			var event:HotspotEvent = new HotspotEvent(HotspotEvent.MOVED);
			dispatchEvent(event);
		}
		
		public function hasEventHandler(eventType:int):Boolean {
			return (nbrScripts > 0 && (scriptEventMask & 1 << eventType) != 0);
		}
		
		public function getEventHandler(eventType:int):IptTokenList {
			if(nbrScripts > 0 && (scriptEventMask & 1 << eventType) != 0)
			{
				for(var i:int = 0; i < nbrScripts; i++)
				{
					var eventHandler:IptEventHandler = eventHandlers[i];
					if (eventHandler.eventType == eventType) {
						return eventHandler.tokenList;
					}
				}
				
			}
			return null;
		}

		public function loadScripts():void {
			nbrScripts = 0;
			scriptEventMask = 0;
			if(scriptString)
			{
//				trace("Hotspot " + id + " name: " + name + " script:\n" + scriptString);
				
				var manager:WorlizeIptManager = InteractivityClient.getInstance().iptInteractivityController.scriptManager;
				var foundHandlers:Object = manager.parseEventHandlers(scriptString);
				
				for (var eventName:String in foundHandlers) {
					var handler:IptTokenList = foundHandlers[eventName];
					var eventType:int = IptEventHandler.getEventType(eventName)
					var eventHandler:IptEventHandler =
						new IptEventHandler(eventType, handler.sourceScript, handler);
					eventHandlers.push(eventHandler);
//					trace("Got event handler.  Type: " + eventHandler.eventType + " Script: \n" + eventHandler.script);
					nbrScripts ++;
					scriptEventMask |= (1 << eventType);
				}
			}
		}

	}
}