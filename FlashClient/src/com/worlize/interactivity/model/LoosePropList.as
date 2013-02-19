package com.worlize.interactivity.model
{
	
	import com.worlize.interactivity.event.LoosePropEvent;
	import com.worlize.model.Prop;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	[Event(name="propsReset",type="com.worlize.interactivity.event.LoosePropEvent")]
	[Event(name="propAdded",type="com.worlize.interactivity.event.LoosePropEvent")]
	[Event(name="propRemoved",type="com.worlize.interactivity.event.LoosePropEvent")]
	[Event(name="propMoved",type="com.worlize.interactivity.event.LoosePropEvent")]
	[Event(name="propBroughtForward",type="com.worlize.interactivity.event.LoosePropEvent")]
	[Event(name="propSentBackward",type="com.worlize.interactivity.event.LoosePropEvent")]
	public class LoosePropList extends EventDispatcher
	{
		private var propsByGuid:Object;
		public var props:Vector.<LooseProp>;
		public var loosePropsById:Object;
		private var refCountsByPropGuid:Object;
		
		public function LoosePropList(target:IEventDispatcher=null)
		{
			super(target);
			reset();
		}
		
		private function getOrInstantiateProp(data:Object):Prop {
			if (propsByGuid[data.guid]) {
				return propsByGuid[data.guid] as Prop;
			}
			var prop:Prop = Prop.fromData(data);
			propsByGuid[prop.guid] = prop;
			return prop;
		}
		
		private function retainProp(guid:String):void {
			if (guid in refCountsByPropGuid) {
				refCountsByPropGuid[guid] ++;
				return;
			}
			refCountsByPropGuid[guid] = 1;
		}
		
		private function releaseProp(guid:String):void {
			if (guid in refCountsByPropGuid) {
				refCountsByPropGuid[guid] --;
				if (refCountsByPropGuid[guid] < 1) {
					delete propsByGuid[guid];
				}
				return;
			}
		}
		
		public function reset():void {
			propsByGuid = {};
			loosePropsById = {};
			refCountsByPropGuid = {};
			props = new Vector.<LooseProp>();
			dispatchEvent(new LoosePropEvent(LoosePropEvent.PROPS_RESET));
		}
		
		public function add(data:Object):void {
			if (loosePropsById[data.id]) {
				throw new Error("Cannot add another loose prop with the same id.");
			}
			var looseProp:LooseProp = new LooseProp();
			looseProp.id = data.id;
			looseProp.x = data.x;
			looseProp.y = data.y;
			looseProp.prop = getOrInstantiateProp(data.prop);
			if (data.user) {
				looseProp.addedByUserGuid = data.user.guid;
				looseProp.addedByUserName = data.user.name;
			}
			loosePropsById[data.id] = looseProp;
			props.push(looseProp);
			retainProp(looseProp.prop.guid);
			var event:LoosePropEvent = new LoosePropEvent(LoosePropEvent.PROP_ADDED);
			event.looseProp = looseProp;
			dispatchEvent(event);
		}
		
		public function remove(id:uint):void {
			var looseProp:LooseProp = loosePropsById[id];
			if (looseProp) {
				delete loosePropsById[id];
				var i:int = props.indexOf(looseProp);
				if (i !== -1) {
					props.splice(i, 1);
					releaseProp(looseProp.prop.guid);
					var event:LoosePropEvent = new LoosePropEvent(LoosePropEvent.PROP_REMOVED);
					event.looseProp = looseProp;
					dispatchEvent(event);
				}
			}
		}
		
		public function move(id:uint, x:int, y:int):void {
			var looseProp:LooseProp = loosePropsById[id];
			if (looseProp) {
				looseProp.x = x;
				looseProp.y = y;
				var event:LoosePropEvent = new LoosePropEvent(LoosePropEvent.PROP_MOVED);
				event.looseProp = looseProp;
				dispatchEvent(event);
			}
		}
		
		public function bringForward(id:uint, layers:int = 1):void {
			var looseProp:LooseProp = loosePropsById[id];
			if (looseProp) {
				var i:int = props.indexOf(looseProp);
				if (i !== -1) {
					var newidx:int = Math.min(props.length - 1, i + layers);
					if (newidx <= i) { return; }
					props.splice(i, 1);
					props.splice(newidx, 0, looseProp);
					var event:LoosePropEvent = new LoosePropEvent(LoosePropEvent.PROP_BROUGHT_FORWARD);
					event.looseProp = looseProp;
					event.layerCount = newidx - i;
					dispatchEvent(event);
				}
			}
		}
		
		public function sendBackward(id:uint, layers:int = 1):void {
			var looseProp:LooseProp = loosePropsById[id];
			if (looseProp) {
				var i:int = props.indexOf(looseProp);
				if (i !== -1) {
					var newidx:int = Math.max(0, i - layers);
					if (newidx >= i) { return; }
					props.splice(i, 1);
					props.splice(newidx, 0, looseProp);
					var event:LoosePropEvent = new LoosePropEvent(LoosePropEvent.PROP_SENT_BACKWARD);
					event.looseProp = looseProp;
					event.layerCount = i - newidx;
					dispatchEvent(event);
				}
			}
		}
	}
}