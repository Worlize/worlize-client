package com.worlize.interactivity.view
{
	import com.worlize.interactivity.event.DragHandleEvent;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import mx.managers.SystemManager;
	
	[Event(name="dragMove",type="com.worlize.interactivity.event.DragHandleEvent")]
	[Event(name="dragComplete",type="com.worlize.interactivity.event.DragHandleEvent")]
	public class DragHandle extends Sprite
	{
		private var dragging:Boolean = false;
		private var mouseOver:Boolean = false;
		private var lastPoint:Point = new Point(0,0);
		
		private var prevCursor:String = MouseCursor.ARROW;
		
		public function DragHandle()
		{
			super();
			draw();
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, handleRemovedFromStage);
		}
		
		private function handleAddedToStage(event:Event):void {
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			addEventListener(MouseEvent.MOUSE_OVER, handleMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
		}
		
		private function handleRemovedFromStage(event:Event):void {
			removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			removeEventListener(MouseEvent.MOUSE_OVER, handleMouseOver);
			removeEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
			if (dragging) {
				dragging = false;
				SystemManager.getSWFRoot(this).removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
				SystemManager.getSWFRoot(this).removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			}
		}
		
		private function handleMouseOver(event:MouseEvent):void {
			if (event.target === this) {
				prevCursor = Mouse.cursor;
				Mouse.cursor = MouseCursor.BUTTON;
				mouseOver = true;
				draw();
			}
		}
		
		private function handleMouseOut(event:MouseEvent):void {
			if (event.target === this) {
				Mouse.cursor = prevCursor;
				mouseOver = false;
				draw();
			}
		}
		
		private function handleMouseDown(event:MouseEvent):void {
			event.stopPropagation();
			dragging = true;
			lastPoint.x = x;
			lastPoint.y = y;
			SystemManager.getSWFRoot(this).addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			SystemManager.getSWFRoot(this).addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
		}
		
		private function handleMouseMove(event:MouseEvent):void {
			var moveEvent:DragHandleEvent = new DragHandleEvent(DragHandleEvent.DRAG_MOVE, false, true);
			var currentX:Number = parent.mouseX;
			var currentY:Number = parent.mouseY;
			moveEvent.x = x + (currentX - lastPoint.x);
			moveEvent.y = y + (currentY - lastPoint.y);
			var success:Boolean = dispatchEvent(moveEvent);
			if (success) {
				x = moveEvent.x;
				y = moveEvent.y;
				lastPoint.x = x;
				lastPoint.y = y;
			}
		}
		
		private function handleMouseUp(event:MouseEvent):void {
			dragging = false;
			SystemManager.getSWFRoot(this).removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			SystemManager.getSWFRoot(this).removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			dispatchEvent(new DragHandleEvent(DragHandleEvent.DRAG_COMPLETE));
			draw();
		}
		
		private function draw():void {
			var g:Graphics = graphics;
			g.clear();
			if (dragging || mouseOver) {
				g.lineStyle(1, 0x000000);
				g.beginFill(0xFFFFFF);
			}
			else {
				g.lineStyle(1, 0xFFFFFF);
				g.beginFill(0x000000);
			}
			g.drawRect(-4,-4,7,7);
			g.endFill();
		}
	}
}