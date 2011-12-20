package com.flashandmath.dg.display {
	import flash.display.*;
	import flash.geom.*;
	import flash.events.*;
	import flash.utils.getTimer;
	import com.flashandmath.dg.objects.*;
	import com.flashandmath.dg.display.*;

	public class SnowDisplay extends Sprite {
		
		public var waitCount:int;
		public var display:ParticleDisplay;
		public var frame:Shape;
		public var particlesToAddEachFrame:int;
		public var colorToAccelFactorX:Number;
		public var colorToAccelFactorY:Number;
		public var perlinDataFront:BitmapData;
		public var perlinBitmapFront:Bitmap;
		public var perlinDataBack:BitmapData;
		public var perlinBitmapBack:Bitmap;
		public var randAccelFactorX:Number;
		public var randAccelFactorY:Number;
		public var airResistanceFactor:Number;
		public var initYVel:Number;
		public var minEffect:Number;
		public var gravity:Number;
		public var minParticleSize:Number;
		public var _maxParticleSize:Number;
		public var _zRange:Number;
		public var windX:Number;
		public var windY:Number;
		public var maxNumParticles:Number;
		public var _fLen:Number;
		public var _scaleCheat:Number;
		public var _zBack:Number;
		public var minScale:Number;
		public var make2D:Boolean;
		
		private var offsets1:Array;
		private var offsets2:Array;
		private var count:int;
		private var freq1:Vector.<Number>;
		private var freq2:Vector.<Number>;
		private var phase1:Vector.<Number>;
		private var phase2:Vector.<Number>;
		private var perlinSizeFactor:Number;
		private var numOctaves:int;
		private var SEED1:Number;
		private var SEED2:Number;
		private var gradientMatrix:Matrix;
		private var aveRed:uint;
		private var aveBlue:uint;
		private var scale:Number;
		
		//variables used in the onEnter function:
		private var t:Number;
		private var c1:uint;
		private var red1:uint;
		private var blue1:uint;
		private var c2:uint;
		private var red2:uint;
		private var blue2:uint;
		private var particleSize:Number;
		private var red:uint;
		private var blue:uint;
		private var particleNearness:Number;
		private var thisX:Number;
		private var thisZ:Number;
		private var randX:Number;
		private var randY:Number;
		private var b:Number;
							
		function SnowDisplay(w:int = 550, h:int = 300):void {
			
			make2D = false;
			
			//The waitCount is how long to wait (in frames) before adding more particles:
			waitCount = 1;			
			particlesToAddEachFrame = 2;
			
			//These variables control how strongly the Perlin noise color affects acceleration:
			colorToAccelFactorX = 0.0005;
			colorToAccelFactorY = 0.0005;
			
			//If you like, you can add some additional random acceleration here (which 
			//can produce a somewhat jittery motion):
			randAccelFactorX = 0;
			randAccelFactorY = 0;
			
			airResistanceFactor = 0.064;
			gravity = 0.025;
			
			//add some base wind here if you like:
			windX = 0;
			windY = 0;
			
			//Because of air resistance, falling snowflakes eventually achieve
			//a constant velocity, called the terminal velocity (rather than accelerating
			//towards the Earth).
			initYVel = Math.sqrt(gravity/airResistanceFactor);
			
			//You can make snowflakes not all affected by the turbulence by the same amount,
			//by setting minEffect to something between 0 and 1.  Then some snowflakes
			//will receive the full force of the turbulence, while others will react
			//by a lesser amount.
			minEffect = 1;
			
			maxNumParticles = 1000;
			
			//These variables determine the base size of the snowflakes at z-depth zero 
			//(with randomization between these values).  Snowflakes at different z-depths
			//will be scaled up or down to reflect distance.
			minParticleSize = 1.5;
			_maxParticleSize = 1.5;
			
			//focal length:
			_fLen = 600;
			//z-depth of the furthest snowflakes:
			_zBack = 0;
			//range of z-values to use for snowflakes:
			_zRange = 500;
			//The _scaleCheat parameter allows you to make snowflakes closer to the 
			//viewer not quite as big as they should be according to depth.  This helps if
			//you want the snowflakes not to get too big.
			_scaleCheat = 0.8;
			//To prevent snowflakes from being scaled too small, a minScale is set:
			minScale = 0.5;
			
			
			b = (_fLen-_zRange+zBack)/_fLen;
			
			//used for drawing the snowflakes:
			gradientMatrix = new Matrix();
			gradientMatrix.createGradientBox(2*_maxParticleSize,2*_maxParticleSize,0,-_maxParticleSize,-_maxParticleSize);
						
			display = new ParticleDisplay(w,h,true);
			display.x = 0;
			display.y = 0;
			display.outsideMargin = _fLen/(_fLen+_scaleCheat*(_zRange-_zBack))*_maxParticleSize+1;
			display.wrapLeftRight = true;
			display.wrapTopBottom = false;
			//Here we set the particles to have empty graphics so we can do our own
			//drawing of them in the code below.
			display.particlesEmpty = true;
						
			this.addChild(display);
			
			//Below we create variables for controlling Perlin noise.
			numOctaves = 4;
			perlinSizeFactor = 0.1;
			perlinDataFront = new BitmapData(perlinSizeFactor*display.displayWidth,perlinSizeFactor*display.displayHeight,false,0x000000);
			perlinDataBack = new BitmapData(perlinSizeFactor*display.displayWidth,perlinSizeFactor*display.displayHeight,false,0x000000);
			offsets1 = new Array;
			offsets2 = new Array;
			freq1 = new Vector.<Number>;
			freq2 = new Vector.<Number>;
			phase1 = new Vector.<Number>;
			phase2 = new Vector.<Number>;
			//The offsets1 are used in the creation of Perlin noise.  We want them to change 
			//smoothly according to sinusoidal functions, but with unrelated periods.  They
			//will change according to frequencies which are set to randomized values.
			//Note that we are making the back bitmap change more slowly than the
			//front, since it represents a wider area.
			var minFreq:Number = 2;
			var maxFreq:Number = 8;
			for (var i:int = 0; i<=numOctaves-1; i++) {
				offsets1.push(new Point());
				freq1.push(minFreq+(maxFreq-minFreq)*Math.random());
				freq1.push(minFreq+(maxFreq-minFreq)*Math.random());
				phase1.push(2*Math.PI*Math.random());
				phase1.push(2*Math.PI*Math.random());
				
				offsets2.push(new Point());
				freq2.push(0.5*(minFreq+(maxFreq-minFreq)*Math.random()));
				freq2.push(0.5*(minFreq+(maxFreq-minFreq)*Math.random()));
				phase2.push(2*Math.PI*Math.random());
				phase2.push(2*Math.PI*Math.random());
			}
			SEED1 = Math.random()*Number.MAX_VALUE;
			SEED2 = Math.random()*Number.MAX_VALUE;
			perlinBitmapFront = new Bitmap(perlinDataFront);
			perlinBitmapBack = new Bitmap(perlinDataBack);				
			
			count = waitCount-1;
			aveRed = 128;
			aveBlue = 128;

			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageListener);
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageListener);
		}
		
		public function set maxParticleSize(n:Number):void {
			_maxParticleSize = n;
			gradientMatrix = new Matrix();
			gradientMatrix.createGradientBox(2*_maxParticleSize,2*_maxParticleSize,0,-_maxParticleSize,-_maxParticleSize);
		}
		
		public function get maxParticleSize():Number {
			return _maxParticleSize;
		}
		
		public function set fLen(n:Number):void {
			_fLen = n;
			recalculateScalingVars();
		}
		public function set zRange(n:Number):void {
			//we prevent zRange from being zero, to avoid division by zero
			//in Perlin noise color interpolation.
			if (n == 0) {
				_zRange = 1;
			}
			else {
				_zRange = n;
			}
			recalculateScalingVars();
		}
		public function set zBack(n:Number):void {
			_zBack = n;
			recalculateScalingVars();
		}
		public function set scaleCheat(n:Number):void {
			_scaleCheat = n;
			recalculateScalingVars();
		}

		
		public function get fLen():Number {
			return _fLen;
			
		}
		public function get zRange():Number {
			return _zRange;
			
		}
		public function get zBack():Number {
			return _zBack;
		}
		public function get scaleCheat():Number {
			return _scaleCheat;
		}
		
		private function recalculateScalingVars():void {
			b = (_fLen-_zRange+zBack)/_fLen;
			display.outsideMargin = _fLen/(_fLen+_scaleCheat*(_zRange-_zBack))*_maxParticleSize+1;
		}
		
		private function addedToStageListener(evt:Event):void {
			//When added to stage, we start the animation.
			this.stage.addEventListener(Event.ENTER_FRAME, onEnter);
		}
		
		private function removedFromStageListener(evt:Event):void {
			//If removed from the stage, we should stop animating.
			this.stage.removeEventListener(Event.ENTER_FRAME, onEnter);
		}		
		
		private function onEnter(evt:Event):void {
			if (display.numOnStage < maxNumParticles) {
				//Add more particles:
				count++
				if (count >= waitCount) {
					count =0;
					for (var i:int = 0; i <= particlesToAddEachFrame-1; i++) {
						particleSize = minParticleSize+Math.random()*(_maxParticleSize - minParticleSize);
						//procedure for picking a point with favor towards back:
						randX = Math.random();
						randY = Math.random();
						if (randY > (1-2*b)*randX + b) {
							randX = 1-randX;
						}
												
						thisZ = _zBack-randX*_zRange;
						thisX = Math.random()*display.displayWidth;
						
						particleNearness = _fLen+thisZ;
										
						var thisParticle:SimpleParticle = display.addParticle(thisX,
														-particleSize/2,
														0.1*(Math.random()*2-1),
														(0.8+0.4*Math.random())*initYVel);
						
						//We are doing explicit drawing instead of using the redraw
						//method in the particle class.  particlesEmpty has been set to true
						//for the particle display.
						thisParticle.graphics.clear();
						thisParticle.graphics.beginGradientFill("radial",[0xFFFFFF,0xFFFFFF],[0.7,0],[2,255],gradientMatrix);
						thisParticle.graphics.drawEllipse(-particleSize,-particleSize,2*particleSize,2*particleSize);
						thisParticle.graphics.endFill();
						
						thisParticle.blendMode = BlendMode.NORMAL;
												
						if (!make2D) {
							thisParticle.w = thisZ;
							scale = Math.max(minScale,_fLen/(_fLen+_scaleCheat*thisParticle.w));
							thisParticle.scaleY = thisParticle.scaleX = scale;
						}
						else {
							thisParticle.w = 0;
							thisParticle.scaleY = thisParticle.scaleX = 1;
						}
						
						
						//The following linear function makes smallest particles most
						//subject to wind effect, and largest particles least subject to
						//wind effect.  If we have set minParticleSize and _maxParticleSize
						//to be the same, then we will just randomly assign windEffect.
						if (_maxParticleSize - minParticleSize != 0) {
							thisParticle.windEffect = 1 + (minEffect-1)*(particleSize - minParticleSize)/(_maxParticleSize - minParticleSize);
						}
						else {
							thisParticle.windEffect = 1 + (minEffect-1)*Math.random();
						}
					}
				}
			}
			
			//We continuously alter the Perlin noise, which will be used to determine
			//acceleration of the particles:
			t = getTimer()*0.0001;
			for (i = 0; i<=numOctaves-1; i++) {
				offsets1[i].x = perlinDataFront.height*Math.cos(freq1[i]*t+phase1[i]);
				offsets1[i].y = perlinDataFront.height*Math.cos(freq1[i+1]*t+phase1[i+1]);
				offsets2[i].x = perlinDataFront.height*Math.cos(freq2[i]*t+phase2[i]);
				offsets2[i].y = perlinDataFront.height*Math.cos(freq2[i+1]*t+phase2[i+1]);
			}
			perlinDataFront.perlinNoise(perlinDataFront.height,perlinDataFront.width,4,SEED1,true,false,5,false,offsets1);
			if (!make2D) {
				perlinDataBack.perlinNoise(perlinDataBack.height,perlinDataBack.width,4,SEED2,true,false,5,false,offsets2);
			}
			//The code below controls the motion of the particles.
			var particle:SimpleParticle = display.onStageList.first;
			var nextParticle:SimpleParticle;
			var numParticles:uint = 0;
			var redSum:Number = 0;
			var blueSum:Number = 0;
			while (particle != null) {
				//before lists are altered, record next particle
				nextParticle = particle.next;
				
				if (!make2D) {
					c1 = perlinDataFront.getPixel(perlinSizeFactor*(particle.x % display.displayWidth),perlinSizeFactor*(particle.y % display.displayHeight));
					red1 = c1 >> 16;
					blue1 = c1 & 0xFF;
					c2 = perlinDataBack.getPixel(perlinSizeFactor*(particle.x % display.displayWidth),perlinSizeFactor*(particle.y % display.displayHeight));
					red2 = c2 >> 16;
					blue2 = c2 & 0xFF;
					
					red = red2 + (red2-red1)*(particle.w-_zBack)/_zRange;
					blue = blue2 + (blue2-blue1)*(particle.w-_zBack)/_zRange;
				}
				else {
					//If we are creating a 2D snow effect, we will only use one Perlin
					//noise function to determine acceleration.
					c1 = perlinDataFront.getPixel(perlinSizeFactor*(particle.x % display.displayWidth),perlinSizeFactor*(particle.y % display.displayHeight));
					red = c1 >> 16;
					blue = c1 & 0xFF;
				}
				
				scale = _fLen/(_fLen+particle.w);
				
				//Note that we are continuously calculating average red and blue at the
				//particle positions, and using the deviations from these average values
				//to determine acceleration:
				particle.accel.x = particle.windEffect*colorToAccelFactorX*(red-aveRed) - airResistanceFactor*Math.abs(particle.vel.x)*particle.vel.x + randAccelFactorX*(Math.random()*2-1);
				particle.accel.y = gravity + particle.windEffect*colorToAccelFactorY*(blue - aveBlue) - airResistanceFactor*Math.abs(particle.vel.y)*particle.vel.y + randAccelFactorY*(Math.random()*2-1);
				
				particle.vel.x += particle.accel.x;
				particle.vel.y += particle.accel.y;
				
				particle.x += windX + scale*particle.vel.x;
				particle.y += windY + scale*particle.vel.y;
								
				//particle.alpha = 0.75+0.25*Math.pow(0.5+0.5*Math.cos(10*particle.evolveFreq*t + particle.evolvePhase),8);
								
				particle = nextParticle;
				
				redSum += red;
				blueSum += blue;
				numParticles++;
			}
			
			if (numParticles != 0) {
				aveRed = redSum/numParticles;
				aveBlue = blueSum/numParticles;
			}
			
			//remove particles out of frame using the outsideTest method of the ParticleDisplay class:
			display.outsideTest();
		}
		
		public function reset():void {
			display.reset();
		}
		
	}
}
