package com.floorplanner.csg.geom
{
	import flash.geom.Vector3D;

	public class Plane
	{
		public static var EPSILON:Number = 1e-5;
		
		public static const COPLANAR:uint = 0;
		public static const FRONT:uint = 1;
		public static const BACK:uint = 2;
		public static const SPANNING:uint = 3;
		
		public var normal:Vector3D;
		public var w:Number;
		
		public function Plane(normal:Vector3D=null, w:Number=0.0)
		{
			this.normal = normal;
			this.w = w;
		}
		
		public function clone():Plane
		{
			return new Plane(this.normal.clone(), this.w);
		}
		
		public function flip():void
		{
			this.normal.negate();
			this.w = -this.w;
		}
		
		/**
		 * Split `polygon` by this plane if needed, then put the polygon or polygon
		 * fragments in the appropriate lists. Coplanar polygons go into either
		 * `coplanarFront` or `coplanarBack` depending on their orientation with
		 * respect to this plane. Polygons in front or in back of this plane go into
		 * either `front` or `back`
		 */
		public function splitPolygon(polygon:Polygon, 
									 coplanarFront:Vector.<Polygon>, 
									 coplanarBack:Vector.<Polygon>, 
									 front:Vector.<Polygon>, 
									 back:Vector.<Polygon>):void
		{
			var vertices:Vector.<IVertex> = polygon.vertices,
				polygonType:uint = 0,
				types:Vector.<uint> = new Vector.<uint>(),
				type:uint,
				t:Number,
				i:uint;
			
			for (i = 0; i < vertices.length; i++) {
				t = this.normal.dotProduct(vertices[i].pos) - this.w;
				type = (t < -Plane.EPSILON) ? BACK : (t > Plane.EPSILON) ? FRONT : COPLANAR;
				polygonType |= type;
				types.push(type);
			}
			
			// Put the polygon in the correct list, splitting it when necessary.
			switch (polygonType) {
				case COPLANAR:
					(this.normal.dotProduct(polygon.plane.normal) > 0 ? coplanarFront : coplanarBack).push(polygon);
					break;
				case FRONT:
					front.push(polygon);
					break;
				case BACK:
					back.push(polygon);
					break;
				case SPANNING:
					var f:Vector.<IVertex> = new Vector.<IVertex>(),
						b:Vector.<IVertex> = new Vector.<IVertex>();
					for (i = 0; i < vertices.length; i++) {
						var j:uint = (i + 1) % vertices.length;
						var ti:uint = types[i], tj:uint = types[j];
						var vi:IVertex = vertices[i], vj:IVertex = vertices[j];
						if (ti != BACK) f.push(vi);
						if (ti != FRONT) b.push(ti != BACK ? vi.clone() : vi);
						if ((ti | tj) == SPANNING) {
							t = (this.w - this.normal.dotProduct(vi.pos)) / 
								 this.normal.dotProduct(vj.pos.subtract(vi.pos));
							var v:IVertex = vi.interpolate(vj, t);
							f.push(v);
							b.push(v.clone());
						}
					}
					if (f.length >= 3) front.push(new Polygon(f, polygon.shared));
					if (b.length >= 3) back.push(new Polygon(b, polygon.shared));
					break;
				default:
					break;
			}
		}
		
		public static function fromPoints(a:Vector3D, b:Vector3D, c:Vector3D):Plane
		{
			var n:Vector3D = b.subtract(a).crossProduct(c.subtract(a));
			n.normalize();
			return new Plane(n, n.dotProduct(a));
		}
	}
}