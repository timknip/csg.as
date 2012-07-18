 package com.floorplanner.csg.geom
{
	/**
	 * # class Vertex
	 * 
	 * Represents a vertex of a polygon. Use your own vertex class instead of this
	 * one to provide additional features like texture coordinates and vertex
	 * colors. Custom vertex classes need to provide a `pos` property and `clone()`,
	 * `flip()`, and `interpolate()` methods that behave analogous to the ones
	 * defined by `CSG.Vertex`. This class provides `normal` so convenience
	 * functions like `CSG.sphere()` can return a smooth vertex normal, but `normal`
	 * is not used anywhere else.
	 */
	public class Vertex implements IVertex
	{
		private var _pos:Vector;
		private var _normal:Vector;
		
		public function Vertex(pos:Vector, normal:Vector = null)
		{
			this.pos = pos || new Vector();
			this.normal = normal || new Vector();
		}
		
		public function get normal():Vector
		{
			return _normal;
		}

		public function set normal(value:Vector):void
		{
			_normal = value;
		}

		public function get pos():Vector
		{
			return _pos;
		}

		public function set pos(value:Vector):void
		{
			_pos = value;
		}

		public function clone():IVertex
		{
			return new Vertex(this.pos.clone(), this.normal.clone());
		}
		
		public function flip():void
		{
			this.normal.negate();
		}
		
		public function interpolate(other:IVertex, t:Number):IVertex
		{
			return new Vertex(
				_lerp(this.pos, other.pos, t), 
				_lerp(this.normal, other.normal, t)
			);
		}
		
		private function _lerp(a:Vector, b:Vector, t:Number):Vector
		{
			var ab:Vector = b.subtract(a);
			ab.scaleBy(t);
			return a.add(ab);
		}
	}
}