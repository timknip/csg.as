package com.floorplanner.csg.geom
{
	public class Vector
	{
		public var x:Number;
		public var y:Number;
		public var z:Number;
		
		public function Vector(x:Number=0, y:Number=0, z:Number=0)
		{
			this.x = x;
			this.y = y;
			this.z = z;
		}
		
		public function clone():Vector
		{
			return new Vector(this.x, this.y, this.z);
		}
		
		public function negate():void
		{
			this.x = -this.x;
			this.y = -this.y;
			this.z = -this.z;
		}
		public function add(other:Vector):Vector
		{
			return new Vector(this.x+other.x, this.y+other.y, this.z+other.z);
		}
		
		public function scaleBy(t:Number):void
		{
			this.x *= t;
			this.y *= t;
			this.z *= t;
		}
		
		public function subtract(other:Vector):Vector
		{
			return new Vector(this.x-other.x, this.y-other.y, this.z-other.z);
		}
		
		public function crossProduct(a:Vector):Vector
		{
			return new Vector(
				this.y * a.z - this.z * a.y,
				this.z * a.x - this.x * a.z,
				this.x * a.y - this.y * a.x
			);
		}
		
		public function dotProduct(other:Vector):Number
		{
			return this.x*other.x + this.y*other.y + this.z*other.z;
		}
		
		public function length():Number
		{
			return Math.sqrt(this.dotProduct(this))
		}
		
		public function normalize():void
		{
			
		}
	}
}