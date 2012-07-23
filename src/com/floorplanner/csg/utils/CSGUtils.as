package com.floorplanner.csg.utils
{
	import com.floorplanner.csg.geom.IVertex;
	import com.floorplanner.csg.geom.Plane;
	import com.floorplanner.csg.geom.Polygon;
	import com.floorplanner.csg.geom.Vertex;
	
	import flash.geom.Vector3D;

	public class CSGUtils
	{
		/**
		 * Creates a Polygon from an array of points.
		 * 
		 * @param points
		 * @param shared
		 * 
		 * @return Polygon
		 */ 
		public static function createPolygon(points:Vector.<Vector3D>, shared:* = null):Polygon
		{
			if (points.length < 2) {
				return null;
			}
			
			var vertices:Vector.<IVertex> = new Vector.<IVertex>();
			for each (var pos:Vector3D in points) {
				vertices.push(new Vertex(pos));
			}
			var polygon:Polygon = new Polygon(vertices, shared);
			
			return polygon;
		}
		
		/**
		 * Extrudes a polygon.
		 * 
		 * @param polygon The polygon to extrude
		 * @param distance Extrusion distance
		 * @param normal Optional normal to extrude along, default is polygon normal
		 * 
		 * @return Vector.<Polygon>
		 */ 
		public static function extrudePolygon(
			polygon:Polygon, 
			distance:Number, 
			normal:Vector3D = null):Vector.<Polygon>
		{
			normal = normal || polygon.plane.normal;

			var du:Vector3D = normal.clone(),
				vertices:Vector.<IVertex> = polygon.vertices,
				top:Vector.<IVertex> = new Vector.<IVertex>(),
				bot:Vector.<IVertex> = new Vector.<IVertex>(),
				polygons:Vector.<Polygon> = new Vector.<Polygon>(),
				invNormal:Vector3D = normal.clone();
			
			du.scaleBy(distance);
			invNormal.negate();
			
			for (var i:uint = 0; i < vertices.length; i++) {
				var j:uint = (i+1) % vertices.length,
					p1:Vector3D = vertices[i].pos,
					p2:Vector3D = vertices[j].pos,
					p3:Vector3D = p2.clone().add(du),
					p4:Vector3D = p1.clone().add(du),
					plane:Plane = Plane.fromPoints(p1, p2, p3),
					v1:Vertex = new Vertex(p1, plane.normal),
					v2:Vertex = new Vertex(p2, plane.normal),
					v3:Vertex = new Vertex(p3, plane.normal),
					v4:Vertex = new Vertex(p4, plane.normal),
					poly:Polygon = new Polygon(Vector.<IVertex>([v1, v2, v3, v4]), polygon.shared);
				polygons.push(poly);
				top.push(new Vertex(p4.clone(), normal));
				bot.unshift(new Vertex(p1.clone(), invNormal));
			}

			polygons.push(new Polygon(top, polygon.shared));
			polygons.push(new Polygon(bot, polygon.shared));
			
			return polygons;
		}
	}
}