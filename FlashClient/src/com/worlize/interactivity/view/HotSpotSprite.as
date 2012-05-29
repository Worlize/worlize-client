package com.worlize.interactivity.view
{
	import com.worlize.event.AuthorModeNotification;
	import com.worlize.event.NotificationCenter;
	import com.worlize.interactivity.event.DragHandleEvent;
	import com.worlize.interactivity.event.HotspotEvent;
	import com.worlize.interactivity.event.RoomEvent;
	import com.worlize.interactivity.iptscrae.IptEventHandler;
	import com.worlize.interactivity.model.Hotspot;
	import com.worlize.interactivity.model.InteractivityConfig;
	import com.worlize.interactivity.rpc.InteractivityClient;
	import com.worlize.model.PreferencesManager;
	import com.worlize.state.AuthorModeState;
	
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.setTimeout;
	
	import mx.core.FlexSprite;
	import mx.core.IVisualElement;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.managers.CursorManager;
	import mx.managers.SystemManager;
	
	import spark.core.SpriteVisualElement;

	public class HotSpotSprite extends SpriteVisualElement
	{
		private var logger:ILogger = Log.getLogger('com.worlize.interactivity.view.HotSpotSprite');
		
		private var _authorMode:Boolean = false;
		private var _selected:Boolean = false;
		
		public var hotSpot:Hotspot;
		public var client:InteractivityClient = InteractivityClient.getInstance();		

		private var mouseOver:Boolean = false;
		private var useHand:Boolean = false;
		
		private var dragging:Boolean = false;
		
		private var processMouseMove:Boolean = false;
		
		private var highlightOnMouseOver:Boolean;
		
		public function HotSpotSprite(hotSpot:Hotspot, highlightOnMouseOver:Boolean = false)
		{
			super();
			this.hotSpot = hotSpot;
			this.highlightOnMouseOver = highlightOnMouseOver;
			hotSpot.addEventListener(RoomEvent.ITEM_MOVED, handleHotspotMoved);
			hotSpot.addEventListener(HotspotEvent.REDRAW_REQUESTED, handleRedrawRequested);
			x = hotSpot.location.x;
			y = hotSpot.location.y;
			processMouseMove = hotSpot.hasEventHandler(IptEventHandler.TYPE_MOUSEMOVE);
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
			addNormalEventListeners();
		}
		
		private function handleAddedToStage(event:Event):void {
			var authorModeState:AuthorModeState = AuthorModeState.getInstance();
			authorMode = authorModeState.enabled;
			selected = (authorModeState.selectedItem === this.hotSpot);
			NotificationCenter.addListener(AuthorModeNotification.AUTHOR_ENABLED, handleAuthorEnabled);
			NotificationCenter.addListener(AuthorModeNotification.AUTHOR_DISABLED, handleAuthorDisabled);
			NotificationCenter.addListener(AuthorModeNotification.SELECTED_ITEM_CHANGED, handleSelectedItemChanged);
			draw();
		}
		
		private function handleRemovedFromStage(event:Event):void {
			// If the object is removed from the stage before the
			// MOUSE_UP handler is fired, we can't unregister the
			// event listener because we don't have a reference to
			// the stage anymore.
			if (dragging) {
				dragging = false;
				SystemManager.getSWFRoot(this).removeEventListener(MouseEvent.MOUSE_UP, handleStageMouseUp);
				SystemManager.getSWFRoot(this).removeEventListener(MouseEvent.MOUSE_UP, handleAuthorStageMouseUp);
			}
			
			NotificationCenter.removeListener(AuthorModeNotification.AUTHOR_ENABLED, handleAuthorEnabled);
			NotificationCenter.removeListener(AuthorModeNotification.AUTHOR_DISABLED, handleAuthorDisabled);
			NotificationCenter.removeListener(AuthorModeNotification.SELECTED_ITEM_CHANGED, handleSelectedItemChanged);
		}
		
		private function handleAuthorEnabled(notification:AuthorModeNotification):void {
			authorMode = true;
		}
		
		private function handleAuthorDisabled(notification:AuthorModeNotification):void {
			authorMode = false;
		}
		
		private function handleSelectedItemChanged(notification:AuthorModeNotification):void {
			selected = (notification.newValue === this.hotSpot);
		}
		
		private function set authorMode(newValue:Boolean):void {
			if (_authorMode !== newValue) {
				_authorMode = newValue;
				if (_authorMode) {
					enableAuthor();
				}
				else {
					disableAuthor();
				}
				draw();
			}
		}
		private function get authorMode():Boolean {
			return _authorMode;
		}
		
		public function set selected(newValue:Boolean):void {
			if (_selected != newValue) {
				_selected = newValue;
				draw();
			}
		}
		public function get selected():Boolean {
			return _selected;
		}
		
		private function addNormalEventListeners():void {
			addEventListener(MouseEvent.MOUSE_DOWN, handleHotSpotMouseDown);
			addEventListener(MouseEvent.ROLL_OVER, handleIptscraeRollOver);
			addEventListener(MouseEvent.ROLL_OUT, handleIptscraeRollOut);
			addEventListener(MouseEvent.MOUSE_UP, handleHotSpotMouseUp);
			if (processMouseMove ||
				hotSpot.hasEventHandler(IptEventHandler.TYPE_MOUSEDRAG)) {
				addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			}
			if (highlightOnMouseOver) {
				addEventListener(MouseEvent.ROLL_OVER, handleMouseOver);
				addEventListener(MouseEvent.ROLL_OUT, handleMouseOut);
			}
			useHand = true;
		}
		
		private function removeNormalEventListeners():void {
			removeEventListener(MouseEvent.MOUSE_DOWN, handleHotSpotMouseDown);
			removeEventListener(MouseEvent.MOUSE_UP, handleHotSpotMouseUp);
			removeEventListener(MouseEvent.ROLL_OVER, handleIptscraeRollOver);
			removeEventListener(MouseEvent.ROLL_OUT, handleIptscraeRollOut);
			if (processMouseMove ||
				hotSpot.hasEventHandler(IptEventHandler.TYPE_MOUSEDRAG)) {
				removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
			}
			if (highlightOnMouseOver) {
				removeEventListener(MouseEvent.ROLL_OVER, handleMouseOver);
				removeEventListener(MouseEvent.ROLL_OUT, handleMouseOut);
			}
			useHand = false;
		}
		
		private function addAuthorEventListeners():void {
			addEventListener(MouseEvent.MOUSE_DOWN, handleAuthorMouseDown);
			addEventListener(MouseEvent.MOUSE_OVER, handleAuthorMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, handleAuthorMouseOut);
		}
		
		private function removeAuthorEventListeners():void {
			removeEventListener(MouseEvent.MOUSE_DOWN, handleAuthorMouseDown);
			removeEventListener(Event.ENTER_FRAME, handleAuthorEnterFrame);
			removeEventListener(MouseEvent.MOUSE_OVER, handleAuthorMouseOver);
			removeEventListener(MouseEvent.MOUSE_OUT, handleAuthorMouseOut);
			SystemManager.getSWFRoot(this).removeEventListener(MouseEvent.MOUSE_UP, handleAuthorStageMouseUp);
		}
		
		private function enableAuthor():void {
			// Remove normal event listeners...
			removeNormalEventListeners();
			
			// ...and add author mode event listeners
			addAuthorEventListeners();
			
			// Add drag handles
			addDragHandles();
		}
		private function disableAuthor():void {
			// Remove author mode event listeners...
			removeAuthorEventListeners();
			
			// ...and restore normal event listeners
			addNormalEventListeners();
			
			// Remove drag handles
			removeDragHandles();
		}
		
		private function addDragHandles():void {
			removeDragHandles();
			for each (var point:Point in hotSpot.polygon) {
				var dragHandle:DragHandle = new DragHandle();
				dragHandle.x = point.x;
				dragHandle.y = point.y;
				dragHandle.addEventListener(DragHandleEvent.DRAG_COMPLETE, handleDragHandleDragComplete);
				dragHandle.addEventListener(DragHandleEvent.DRAG_MOVE, handleDragHandleDragMove);
				addChild(dragHandle);
			}
		}
		
		private function removeDragHandles():void {
			for (var i:int = 0; i < numChildren; i++) {
				var dragHandle:DragHandle = DragHandle(getChildAt(i));
				dragHandle.removeEventListener(DragHandleEvent.DRAG_COMPLETE, handleDragHandleDragComplete);
				dragHandle.removeEventListener(DragHandleEvent.DRAG_MOVE, handleDragHandleDragMove);
			}
			removeChildren();
		}
		
		private function handleDragHandleDragComplete(event:DragHandleEvent):void {
			hotSpot.savePosition();
		}
		
		private function handleDragHandleDragMove(event:DragHandleEvent):void {
			if (event.x + this.x > 950) {
				event.x = 950 - this.x;
			}
			if (event.x + this.x < 0) {
				event.x = 0 - this.x;
			}
			if (event.y + this.y > 570 - 25) {
				event.y = 570 - 25 - this.y;
			}
			if (event.y + this.y < 0) {
				event.y = 0 - this.y;
			}
			
			var dragHandle:DragHandle = DragHandle(event.target);
			try {
				var index:int = getChildIndex(dragHandle);
			}
			catch(e:ArgumentError) {
				// the drag handle isn't a member of this hotspot
				return;
			}
			
			var point:Point = hotSpot.polygon[index];
			if (point) {
				point.x = event.x;
				point.y = event.y;
				draw();
			}
		}
		
		private function handleAuthorMouseOver(event:MouseEvent):void {
			if (event.target === this) {
				Mouse.cursor = MouseCursor.HAND;
			}
		}
		private function handleAuthorMouseOut(event:MouseEvent):void {
			if (event.target === this) {
				Mouse.cursor = MouseCursor.AUTO;
			}
		}
		
		private function handleAuthorMouseDown(event:MouseEvent):void {
			event.stopImmediatePropagation();
			AuthorModeState.getInstance().selectedItem = this.hotSpot;
			stage.addEventListener(MouseEvent.MOUSE_UP, handleAuthorStageMouseUp);
			addEventListener(MouseEvent.MOUSE_MOVE, handleAuthorMouseMove);
			addEventListener(Event.ENTER_FRAME, handleAuthorEnterFrame);
			startPoint = new Point(x,y);
			startMousePos = new Point(parent.mouseX, parent.mouseY);
			hotSpot.selectForAuthoring();
		}
		
		private function handleAuthorMouseMove(event:MouseEvent):void {
			dragging = true;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleAuthorMouseMove);
		}
		
		private function handleAuthorStageMouseUp(event:MouseEvent):void {
			removeEventListener(Event.ENTER_FRAME, handleAuthorEnterFrame);
			removeEventListener(MouseEvent.MOUSE_MOVE, handleAuthorMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleAuthorStageMouseUp);
			if (dragging) {
				dragging = false;
				hotSpot.savePosition();
			}
		}
		
		private function handleIptscraeRollOver(event:MouseEvent):void {
			client.iptInteractivityController.triggerHotspotEvent(hotSpot, IptEventHandler.TYPE_ROLLOVER);
		}
		
		private function handleIptscraeRollOut(event:MouseEvent):void {
			client.iptInteractivityController.triggerHotspotEvent(hotSpot, IptEventHandler.TYPE_ROLLOUT);
		}

		private var startPoint:Point;
		private var startMousePos:Point;
		
		private var mousePos:Point = new Point(-1, -1);
		private var lastMousePos:Point = new Point(-1, -1);
		
		private function handleAuthorEnterFrame(event:Event):void {
			mousePos.x = parent.mouseX;
			mousePos.y = parent.mouseY;
			
			if (dragging) {
				var destX:int = startPoint.x + (mousePos.x - startMousePos.x);
				var destY:int = startPoint.y + (mousePos.y - startMousePos.y);
				
				for each (var point:Point in hotSpot.polygon) {
					if (destX + point.x > 950) {
						destX = 950 - point.x;
					}
					if (destY + point.y > 570-26) {
						destY = 570-26 - point.y;
					}
					if (destX + point.x < 0) {
						destX = -1 * point.x;
					}
					if (destY + point.y < 0) {
						destY = -1 * point.y;
					}
				}
				hotSpot.moveTo(destX, destY);
			}
		}

		private function handleEnterFrame(event:Event):void {
			var globalPos:Point;
			mousePos.x = client.currentRoom.roomView.mouseX;
			mousePos.y = client.currentRoom.roomView.mouseY;

			if (dragging) {
				if (mousePos.x != lastMousePos.x || mousePos.y != lastMousePos.y) {
					lastMousePos = mousePos.clone();
					client.iptInteractivityController.triggerHotspotEvent(hotSpot, IptEventHandler.TYPE_MOUSEDRAG);
				}
			}
			else if (processMouseMove) {
				globalPos = client.currentRoom.roomView.localToGlobal(mousePos);
				if (hitTestPoint(globalPos.x, globalPos.y, true) && (mousePos.x != lastMousePos.x || mousePos.y != lastMousePos.y)) {
					lastMousePos = mousePos.clone();
					client.iptInteractivityController.triggerHotspotEvent(hotSpot, IptEventHandler.TYPE_MOUSEMOVE);
				}
			}
		}
		
		private function handleIptscraeMouseMove(event:MouseEvent):void {
			mousePos.x = event.localX;
			mousePos.y = event.localY;
			client.iptInteractivityController.triggerHotspotEvent(hotSpot, IptEventHandler.TYPE_MOUSEMOVE);
		}
		
		private function handleHotspotMoved(event:RoomEvent):void {
			x = hotSpot.location.x;
			y = hotSpot.location.y;
		}
		
		private function handleRedrawRequested(event:HotspotEvent):void {
			draw();
			if (authorMode) {
				updateDragHandlePositions();
			}
		}
		
		private function updateDragHandlePositions():void {
			if (numChildren !== hotSpot.polygon.length) {
				addDragHandles();
				return;
			}
			for (var i:int = 0; i < hotSpot.polygon.length; i++) {
				try {
					var dragHandle:DragHandle = DragHandle(getChildAt(i));
				}
				catch(e:ArgumentError) {
					continue;
				}
				var point:Point = hotSpot.polygon[i];
				dragHandle.x = point.x;
				dragHandle.y = point.y;
			}
		}
		
		public function draw():void {
			var i:int, point:Point;
			graphics.clear();

			var points:Array = hotSpot.polygon;
			if (points.length < 3) {
				return;
			}
			var firstPoint:Point = Point(points[0]);
			

			if (authorMode) {
				// Draw thicker line underneath for contrast
				if (selected) {
					graphics.lineStyle(4, 0x000000, 0.5);
				}
				else {
					graphics.lineStyle(4, 0xFFFFFF, 0.5);
				}
				graphics.moveTo(firstPoint.x, firstPoint.y);
				for (i = 1; i < points.length; i++) {
					point = Point(points[i]);
					graphics.lineTo(point.x, point.y);
				}
				graphics.lineTo(firstPoint.x, firstPoint.y);
			}
			
			// Set line style
			if (authorMode && selected) {
				graphics.lineStyle(1, 0xFFFFFF, 0.7);
			}
			else if (authorMode) {
				graphics.lineStyle(1, 0x000000, 1.0);
			}
			else if (mouseOver && hotSpot.dest) {
				graphics.lineStyle(1, 0xFFFFFF, 0.0);
			}
			else {
				graphics.lineStyle(1, 0x000000, 0);
			}

			// Set fill style
			if (authorMode && selected) {
				graphics.beginFill(0xEEEEEE, 0.25);
			}
			else if (authorMode && !mouseOver) {
				graphics.beginFill(0x444444, 0.25);
			}
			else if (mouseOver && hotSpot.dest) {
				graphics.beginFill(0xf2f200, 0.2);
			}
			else {
				graphics.beginFill(0x000000, 0.0);
			}
			
			graphics.moveTo(firstPoint.x, firstPoint.y);
			for (i = 1; i < points.length; i++) {
				point = Point(points[i]);
				graphics.lineTo(point.x, point.y);
			}
			graphics.lineTo(firstPoint.x, firstPoint.y);
			graphics.endFill();
			
			if (mouseOver && !authorMode && hotSpot.dest) {
				filters = [
					new GlowFilter(0xf2f200, 1, 20, 20, 2, 3, false, true)
				];
			}
			else {
				filters = [];
			}
		}

		private function handleHotSpotMouseDown(event:MouseEvent):void {
//			trace("Clicked hotspot - id: " + hotSpot.id + " Destination: " + hotSpot.dest + " type: " + hotSpot.type + " state: " + hotSpot.state);
			
			dragging = true;
			stage.addEventListener(MouseEvent.MOUSE_UP, handleStageMouseUp);
			mousePos.x = client.currentRoom.roomView.mouseX;
			mousePos.y = client.currentRoom.roomView.mouseY;
			lastMousePos = mousePos.clone();
			
			var ranScript:Boolean = false;
			if (!authorMode && hotSpot.hasEventHandler(IptEventHandler.TYPE_SELECT)) {
				setTimeout(function():void {
					client.iptInteractivityController.triggerHotspotEvent(hotSpot, IptEventHandler.TYPE_SELECT);
				}, 1);
				ranScript = true;
			}
			if (!authorMode && hotSpot.hasEventHandler(IptEventHandler.TYPE_MOUSEDOWN)) {
				setTimeout(function():void {
					client.iptInteractivityController.triggerHotspotEvent(hotSpot, IptEventHandler.TYPE_MOUSEDOWN);
				}, 2);
				ranScript = true;
			}
			if (ranScript) {
				return;
			}
			
			
			if (hotSpot.dest != null) {
				client.gotoRoom(hotSpot.dest);
			}
		}
		
		private function handleStageMouseUp(event:MouseEvent):void {
			dragging = false;
			SystemManager.getSWFRoot(this).removeEventListener(MouseEvent.MOUSE_UP, handleStageMouseUp);
		}
		
		private function handleHotSpotMouseUp(event:MouseEvent):void {
			if (!authorMode && hotSpot.hasEventHandler(IptEventHandler.TYPE_MOUSEUP)) {
				client.iptInteractivityController.triggerHotspotEvent(hotSpot, IptEventHandler.TYPE_MOUSEUP);
			}
		}
		
		private function handleMouseOver(event:MouseEvent):void {
			if (useHand && hotSpot.dest) {
				Mouse.cursor = MouseCursor.BUTTON;
			}
			if (InteractivityConfig.highlightHotspotsOnMouseover) {
				mouseOver = true;
				draw();
			}
		}
		
		private function handleMouseOut(event:MouseEvent):void {
			if (useHand) {
				Mouse.cursor = MouseCursor.ARROW;
			}
			if (InteractivityConfig.highlightHotspotsOnMouseover) {
				mouseOver = false;
				draw();
			}
		}
	}
}