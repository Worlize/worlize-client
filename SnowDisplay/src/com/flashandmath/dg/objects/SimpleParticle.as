
package com.flashandmath.dg.objects {
	import flash.display.Sprite;
	import flash.geom.*;
	
	public class SimpleParticle extends Sprite {				
		public var size:Number;
		public var color:uint;
		
		public var vel:Point;
		public var accel:Point;
		public var airResistanceFactor:Number;
		public var windEffect:Number;
		
		public var evolvePhase:Number;
		public var evolveFreq:Number;
		
		public var tier:int;
		
		//The u,v,w variables are in case I want to do some 3D stuff
		//without using Flash native 3D
		public var u:Number;
		public var v:Number;
		public var w:Number;
		
		//The following attributes are for the purposes of creating a
		//linked list of SimpleParticle instances.
		public var next:SimpleParticle;
		public var prev:SimpleParticle;
		
		public function SimpleParticle(x0:int=0,y0:int=0) {
			super();
			this.x = x0;
			this.y = y0;
			accel = new Point();
			vel = new Point();
			size = 1;
			color = 0xDDDDDD;
			airResistanceFactor = 0.03;
			windEffect = 1;
			w = 0;
			evolvePhase = 2*Math.PI*Math.random();
			evolveFreq = 1 + 9*Math.random();
			tier = 0;
		}
		
		public function redraw():void {
			this.graphics.clear();
			//this.graphics.lineStyle(1,0xFFFFFF);
			this.graphics.beginFill(color);
			this.graphics.drawEllipse(-size,-size,2*size,2*size);
			this.graphics.endFill();
		}
		
	}
}
			
		