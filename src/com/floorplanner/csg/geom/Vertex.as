 package com.floorplanner.csg.geom
{
	import flash.geom.Vector3D;

	/**
	 *class Vertex
	 * 
	 * Represents a vertex of a polygon. Use your own vertex class instead of this
	 * one to provide additional features like texture coordinates and vertex
	 * colors. Custom vertex classes need to implement the IVertex interface.
	 * 
	 * @see com.floorplanner.csg.IVertex
	 */
	public class Vertex implements IVertex
	{
		private var _pos:Vector3D;
		private var _normal:Vector3D;
		
		public function Vertex(pos:Vector3D, normal:Vector3D = null)
		{
			this.pos = pos || new Vector3D();
			this.normal = normal || new Vector3D();
		}
		
		public function get normal():Vector3D
		{
			return _normal;
		}

		public function set normal(value:Vector3D):void
		{
			_normal = value;
		}

		public function get pos():Vector3D
		{
			return _pos;
		}

		public function set pos(value:Vector3D):void
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
				_lerp(this.normal, Vertex(other).normal, t)
			);
			
		}
		
		private function _lerp(a:Vector3D, b:Vector3D, t:Number):Vector3D
		{
			var ab:Vector3D = b.subtract(a);
			ab.scaleBy(t);
			return a.add(ab);
		}
	}
}