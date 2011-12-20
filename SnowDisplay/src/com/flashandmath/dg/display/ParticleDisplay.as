/*

This class serves as a Sprite to which particle Sprites can be added as
children.  It requires all motion to be programmed in the main code.

The only functions (apart from the constructor) are:

	addParticle - adds a particle in a specified position, with optional initial velocity, 
	color, and size parameters.
	
	outsideTest - checks all particles to see if any are outside the display area, and 
	recycles those which are outside.  This function also performs wrapLeftRight wrapping.
	
	recycleParticle - removes a particle from the display.  Particle is saved in a recycle
	bin for future use.

*/

package com.flashandmath.dg.display {
	import com.flashandmath.dg.objects.*;
	import com.flashandmath.dg.dataStructures.*;
	import flash.geom.*;
	import flash.display.*;
	
	public class ParticleDisplay extends Sprite {
		
		//The linked list onStageList is a list of all the particles currently
		//being animated.		
		public var onStageList:LinkedList;
		//The recycleBin stores particles that are no longer part of the animation, but 
		//which can be used again when new particles are needed.
		public var recycleBin:LinkedList;
		
		public var numOnStage:Number;
		public var numInRecycleBin:Number;
		public var displayWidth:Number;
		public var displayHeight:Number;
		public var outsideMargin:Number;
						
		public var defaultInitialVelocity:Point;
		public var defaultParticleSize:Number;
		
		//the defaultParticleColor is only used when particles are not randomly colored by
		//grayscale, gradient, or fully random color.
		public var defaultParticleColor:uint;
		
		public var randomizeColor:Boolean;
		public var colorMethod:String;
		public var minGray:Number;
		public var maxGray:Number;
		public var _gradientColor1:uint;
		public var _gradientColor2:uint;
		
		
		//These variance parameters allow for controlled random variation in
		//particle velocities.
		public var initialVelocityVarianceX:Number;
		public var initialVelocityVarianceY:Number;
		public var initialVelocityVariancePercent:Number;
		
		public var wrapLeftRight:Boolean;
		public var wrapTopBottom:Boolean;
		
		public var particlesEmpty:Boolean;
		
		private var displayMask:Sprite;
		
		//used for gradient colors:
		private var r1:Number;
		private var g1:Number;
		private var b1:Number;
		private var r2:Number;
		private var g2:Number;
		private var b2:Number;
		
		
		public function ParticleDisplay(w:int = 400, h:int=300, useMask:Boolean = true) {			
			displayWidth = w;
			displayHeight = h;
			onStageList = new LinkedList();
			recycleBin = new LinkedList();
			defaultInitialVelocity = new Point(0,0);
			initialVelocityVarianceX = 0;
			initialVelocityVarianceY = 0;
			initialVelocityVariancePercent = 0;
			
			wrapLeftRight = false;
			wrapTopBottom = false;
			
			outsideMargin = 2;
			
			particlesEmpty = false;
			
			numOnStage = 0;
			numInRecycleBin = 0;
			
			if (useMask) {
				displayMask = new Sprite();
				displayMask.graphics.beginFill(0xFFFF00);
				displayMask.graphics.drawRect(0,0,w,h);
				displayMask.graphics.endFill();
				this.addChild(displayMask);
				this.mask = displayMask;
			}
			
			
			defaultParticleColor = 0xFFFFFF;
			defaultParticleSize = 1;
			randomizeColor = true;
			colorMethod = "gray";
			minGray = 0;
			maxGray = 1;
			_gradientColor1 = 0x0000FF;
			_gradientColor2 = 0x00FFFF;
			
		}
		
		public function get gradientColor1():uint {
			return _gradientColor1;
		}
		
		public function get gradientColor2():uint {
			return _gradientColor2;
		}
		
		public function set gradientColor1(input:uint):void {
			_gradientColor1 = uint(input);
			r1 = (_gradientColor1 >>16) & 0xFF;
			g1 = (_gradientColor1 >>8) & 0xFF;
			b1 = _gradientColor1 & 0xFF;
		}
		
		public function set gradientColor2(input:uint):void {
			_gradientColor2 = uint(input);
			r2 = (_gradientColor2 >>16) & 0xFF;
			g2 = (_gradientColor2 >>8) & 0xFF;
			b2 = _gradientColor2 & 0xFF;
		}
		
		//arguments are x, y, velx, vely, size, color
		public function addParticle(x0:Number, y0:Number, ...args):SimpleParticle {
			var particle:SimpleParticle; 
			var particleColor:uint;
			var particleSize:Number;
			var param:Number;
			var r:Number;
			var g:Number;
			var b:Number;
			var variance:Number;
			
			numOnStage++;
			
			//set size
			if (args.length > 2) {
				particleSize = args[2];
			}
			else {
				particleSize = defaultParticleSize;
			}

			//set color
			if (args.length > 3) {
				particleColor = args[3];
			}
			else if (randomizeColor) {
				if (colorMethod == "gray") {
					param = 255*(minGray + (maxGray-minGray)*Math.random());
					particleColor = param << 16 | param << 8 | param;
				}
				if (colorMethod == "gradient") {
					param = Math.random();
					r = int(r1 + param*(r2 - r1));
					g = int(g1 + param*(g2 - g1));
					b = int(b1 + param*(b2 - b1));
					particleColor = (r << 16) | (g << 8) | b;
				}
				if (colorMethod == "random") {
					particleColor = Math.random()*0xFFFFFF;
				}
			}
			else {
				particleColor = defaultParticleColor;
			}			
			

			//check recycle bin for available particle:
			if (recycleBin.first != null) {
				numInRecycleBin--;
				particle = recycleBin.first;
				//remove from bin
				if (particle.next != null) {
					recycleBin.first = particle.next;
					particle.next.prev = null;
				}
				else {
					recycleBin.first = null;
				}
				particle.x = x0;
				particle.y = y0;				
				particle.visible = true;
			}
			//if the recycle bin is empty, create a new particle:
			else {
				particle = new SimpleParticle(x0,y0);
				//add to display
				this.addChild(particle);
			}
			
			particle.size = particleSize;
			particle.color = particleColor;
			
			//add to beginning of onStageList
			if (onStageList.first == null) {
				onStageList.first = particle;
				particle.prev = null; //may be unnecessary
				particle.next = null;
			}
			else {
				particle.next = onStageList.first;
				onStageList.first.prev = particle;  //may be unnecessary
				onStageList.first = particle;
				particle.prev = null; //may be unnecessary
			}
						
			//set initial velocity
			if (args.length < 2) {
				variance = (1+Math.random()*initialVelocityVariancePercent);
				particle.vel.x = defaultInitialVelocity.x*variance+Math.random()*initialVelocityVarianceX;
				particle.vel.y = defaultInitialVelocity.y*variance+Math.random()*initialVelocityVarianceY;
			}
			else {
				particle.vel.x = args[0];
				particle.vel.y = args[1];
			}
			
			if (!particlesEmpty) {
				particle.redraw();
			}
			
			return particle;
		}
				
		public function outsideTest():void {
			var particle:SimpleParticle = onStageList.first;
			var nextParticle:SimpleParticle;
			var outside:Boolean;
			
			while (particle != null) {
				//before lists are altered, record next particle
				nextParticle = particle.next;
				outside = false;
				if (!wrapTopBottom) {
					outside ||= (particle.y > displayHeight + outsideMargin) || (particle.y < -outsideMargin);
				}				
				if (!wrapLeftRight) {
					outside ||= (particle.x > displayWidth + outsideMargin) || (particle.x < -outsideMargin);
				}
				if (outside) {
					recycleParticle(particle);
				}
				
				//wrapping:
				if (wrapLeftRight) {
					if (particle.x > displayWidth + outsideMargin) {
						particle.x = particle.x % (displayWidth + 2*outsideMargin);
					}
					else if (particle.x < -outsideMargin) {
						particle.x = (displayWidth + 2*outsideMargin + particle.x) % (displayWidth + 2*outsideMargin);
					}					
				}
				if (wrapTopBottom) {
					if (particle.y > displayHeight + outsideMargin) {
						particle.y = particle.y % (displayHeight + 2*outsideMargin);
					}
					else if (particle.y < -outsideMargin) {
						particle.y = (displayHeight + 2*outsideMargin + particle.y) % (displayHeight + 2*outsideMargin);
					}					
				}
				
				particle = nextParticle;
			}
				
		}
		
		public function recycleParticle(particle:SimpleParticle):void {
			numOnStage--;
			numInRecycleBin++;
						
			particle.visible = false;
			
			//remove from onStageList
			if (onStageList.first == particle) {
				if (particle.next != null) {
					particle.next.prev = null;
					onStageList.first = particle.next;
				}
				else {
					onStageList.first = null;
				}
			}
			else {
				if (particle.next == null) {
					particle.prev.next = null;
				}
				else {
					particle.prev.next = particle.next;
					particle.next.prev = particle.prev;
				}
			}

			//add to recycle bin
			if (recycleBin.first == null) {
				recycleBin.first = particle;
				particle.prev = null; //may be unnecessary
				particle.next = null;
			}
			else {
				particle.next = recycleBin.first;
				recycleBin.first.prev = particle;  //may be unnecessary
				recycleBin.first = particle;
				particle.prev = null; //may be unnecessary
			}
		}
		
		public function reset():void {
			var particle:SimpleParticle;
			var nextParticle:SimpleParticle;
			
			particle = onStageList.first;
			while (particle != null) {
				//before lists are altered, record next particle
				nextParticle = particle.next;
				this.removeChild(particle);
				particle = nextParticle;
			}
			particle = recycleBin.first;
			while (particle != null) {
				//before lists are altered, record next particle
				nextParticle = particle.next;
				this.removeChild(particle);
				particle = nextParticle;
			}			
			onStageList.first = null;
			recycleBin.first = null;
			numOnStage = 0;
		}
		
	}
}
				
		
			
