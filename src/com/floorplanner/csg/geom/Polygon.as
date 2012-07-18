package com.floorplanner.csg.geom
{
	/**
	 * class Polygon
	 * 
	 * Represents a convex polygon. The vertices used to initialize a polygon must
	 * be coplanar and form a convex loop.
	 * 
	 * Each convex polygon has a `shared` property, which is shared between all
	 * polygons that are clones of each other or were split from the same polygon.
	 * This can be used to define per-polygon properties (such as surface color).
	 */
	public class Polygon
	{
		public var vertices:Array;
		public var shared:*;
		public var plane:Plane;
		
		public function Polygon(vertices:Array = null, shared:* = null)
		{
			this.vertices = vertices;
			this.shared = shared;
			this.plane = Plane.fromPoints(vertices[0].pos, vertices[1].pos, vertices[2].pos);
		}
		
		public function clone():Polygon
		{
			var vertices:Array = [];
			for each (var v:IVertex in this.vertices) {
				vertices.push(v.clone());
			}
			return new Polygon(vertices, this.shared);
		}
		
		public function flip():void
		{
			this.vertices.reverse();
			for each (var v:IVertex in this.vertices) {
				v.flip();
			}
			this.plane.flip();
		}
	}
}