package com.floorplanner.csg
{
	import com.floorplanner.csg.geom.IVertex;
	import com.floorplanner.csg.geom.Node;
	import com.floorplanner.csg.geom.Polygon;
	import com.floorplanner.csg.geom.Vertex;
	
	import flash.geom.Vector3D;
	
	/** 
	 * Constructive Solid Geometry (CSG) is a modeling technique that uses Boolean
	 * operations like union and intersection to combine 3D solids. This library
	 * implements CSG operations on meshes elegantly and concisely using BSP trees,
	 * and is meant to serve as an easily understandable implementation of the
	 * algorithm. All edge cases involving overlapping coplanar polygons in both
	 * solids are correctly handled.
	 * 
	 * Example usage:
	 * 
	 *     var cube = CSG.cube();
	 *     var sphere = CSG.sphere({ radius: 1.3 });
	 *     var polygons = cube.subtract(sphere).toPolygons();
	 * 
	 * ## Implementation Details
	 * 
	 * All CSG operations are implemented in terms of two functions, `clipTo()` and
	 * `invert()`, which remove parts of a BSP tree inside another BSP tree and swap
	 * solid and empty space, respectively. To find the union of `a` and `b`, we
	 * want to remove everything in `a` inside `b` and everything in `b` inside `a`,
	 * then combine polygons from `a` and `b` into one solid:
	 * 
	 *     a.clipTo(b);
	 *     b.clipTo(a);
	 *     a.build(b.allPolygons());
	 * 
	 * The only tricky part is handling overlapping coplanar polygons in both trees.
	 * The code above keeps both copies, but we need to keep them in one tree and
	 * remove them in the other tree. To remove them from `b` we can clip the
	 * inverse of `b` against `a`. The code for union now looks like this:
	 * 
	 *     a.clipTo(b);
	 *     b.clipTo(a);
	 *     b.invert();
	 *     b.clipTo(a);
	 *     b.invert();
	 *     a.build(b.allPolygons());
	 * 
	 * Subtraction and intersection naturally follow from set operations. If
	 * union is `A | B`, subtraction is `A - B = ~(~A | B)` and intersection is
	 * `A & B = ~(~A | ~B)` where `~` is the complement operator.
	 * 
	 * ## License
	 * 
	 * Copyright (c) 2011 Evan Wallace (http://madebyevan.com/), under the MIT license.
	 *
	 * class CSG
	 *
	 * Holds a binary space partition tree representing a 3D solid. Two solids can
	 * be combined using the `union()`, `subtract()`, and `intersect()` methods.
	 */ 
	public class CSG
	{
		public var polygons:Vector.<Polygon>;
		
		/**
		 * Constructor
		 */ 
		public function CSG()
		{
			this.polygons = new Vector.<Polygon>();
		}
		
		/**
		 * Clone
		 */ 
		public function clone():CSG
		{
			var csg:CSG = new CSG();
			for each (var p:Polygon in this.polygons) {
				csg.polygons.push(p.clone());
			}
			return csg;
		}
		
		public function inverse():CSG
		{
			var csg:CSG = this.clone();
			for each (var p:Polygon in csg.polygons) {
				p.flip();
			}
			return csg;
		}
		
		/**
		 * 
		 */ 
		public function toPolygons():Vector.<Polygon>
		{
			return this.polygons;	
		}
		
		/**
		  * Return a new CSG solid representing space in either this solid or in the
		  * solid `csg`. Neither this solid nor the solid `csg` are modified.
		  * 
		  *     A.union(B)
		  * 
		  *     +-------+            +-------+
		  *     |       |            |       |
		  *     |   A   |            |       |
		  *     |    +--+----+   =   |       +----+
		  *     +----+--+    |       +----+       |
		  *          |   B   |            |       |
		  *          |       |            |       |
		  *          +-------+            +-------+
		  * 
		  * @param csg
		  * 
		  * @return CSG
		  */
		public function union(csg:CSG):CSG
		{
			var a:Node = new Node(this.clone().polygons),
				b:Node = new Node(csg.clone().polygons);
			a.clipTo(b);
			b.clipTo(a);
			b.invert();
			b.clipTo(a);
			b.invert();
			a.build(b.allPolygons());
			return CSG.fromPolygons(a.allPolygons());
		}
		
		/** 
		 * Return a new CSG solid representing space in this solid but not in the
		 * solid `csg`. Neither this solid nor the solid `csg` are modified.
		 * 
		 *     A.subtract(B)
		 * 
		 *     +-------+            +-------+
		 *     |       |            |       |
		 *     |   A   |            |       |
		 *     |    +--+----+   =   |    +--+
		 *     +----+--+    |       +----+
		 *          |   B   |
		 *          |       |
		 *          +-------+
		 * 
		 * @param csg
		 * 
		 * @return CSG
		 */
		public function subtract(csg:CSG):CSG
		{
			var a:Node = new Node(this.clone().polygons),
				b:Node = new Node(csg.clone().polygons);
			a.invert();
			a.clipTo(b);
			b.clipTo(a);
			b.invert();
			b.clipTo(a);
			b.invert();
			a.build(b.allPolygons());
			a.invert();
			return CSG.fromPolygons(a.allPolygons());
		}
		
		/** 
		 * Return a new CSG solid representing space both this solid and in the
		 * solid `csg`. Neither this solid nor the solid `csg` are modified.
		 * 
		 *     A.intersect(B)
		 * 
		 *     +-------+
		 *     |       |
		 *     |   A   |
		 *     |    +--+----+   =   +--+
		 *     +----+--+    |       +--+
		 *          |   B   |
		 *          |       |
		 *          +-------+
		 * 
		 * @param csg
		 * 
		 * @return CSG
		 */ 
		public function intersect(csg:CSG):CSG
		{
			var a:Node = new Node(this.clone().polygons),
				b:Node = new Node(csg.clone().polygons);
			a.invert();
			b.clipTo(a);
			b.invert();
			a.clipTo(b);
			b.clipTo(a);
			a.build(b.allPolygons());
			a.invert();
			return CSG.fromPolygons(a.allPolygons());
		}
		
		/**
		 * Cube
		 * 
		 * @param center
		 * @param radius
		 * 
		 * @return CSG
		 */ 
		public static function cube(center:Vector3D=null, radius:Vector3D=null):CSG
		{
			var c:Vector3D = center || new Vector3D(),
				r:Vector3D = radius || new Vector3D(1, 1, 1),
				polygons:Vector.<Polygon> = new Vector.<Polygon>(),
				data:Array = [
					[[0, 4, 6, 2], [-1, 0, 0]],
					[[1, 3, 7, 5], [+1, 0, 0]],
					[[0, 1, 5, 4], [0, -1, 0]],
					[[2, 6, 7, 3], [0, +1, 0]],
					[[0, 2, 3, 1], [0, 0, -1]],
					[[4, 5, 7, 6], [0, 0, +1]]
				];
			for each (var array:Array in data) {
				var v:Array = array[0],
					n:Vector3D = new Vector3D(array[1][0], array[1][1], array[1][2]),
					verts:Array = v.map(function(elem:*, index:int, a:Array):IVertex {
							var i:int = elem as int;
							return new Vertex(new Vector3D(
								c.x + (r.x * (2 * ((i & 1)?1:0) - 1)),
								c.y + (r.y * (2 * ((i & 2)?1:0) - 1)),
								c.z + (r.z * (2 * ((i & 4)?1:0) - 1))),
								n
							);
						});
				polygons.push(new Polygon(Vector.<IVertex>(verts)));
			}
			return CSG.fromPolygons(polygons);
		}
		
		/**
		 * Sphere
		 * 
		 * @param center
		 * @param radius
		 * @param slices
		 * @param stacks
		 * 
		 * @return CSG
		 */ 
		public static function sphere(center:Vector3D=null, radius:Number=1, slices:Number=16, stacks:Number=8):CSG
		{
			var c:Vector3D = center || new Vector3D(),
				r:Number = radius,
				polygons:Vector.<Polygon> = new Vector.<Polygon>(),
				vertices:Vector.<IVertex>;
			
			function vertex(theta:Number, phi:Number):void {
				theta *= Math.PI * 2;
				phi *= Math.PI;
				var dir:Vector3D = new Vector3D(
					Math.cos(theta) * Math.sin(phi),
					Math.cos(phi),
					Math.sin(theta) * Math.sin(phi)
				);
				var sdir:Vector3D = dir.clone();
				sdir.scaleBy(r);
				vertices.push(new Vertex(c.add(sdir), dir));
			}
			for (var i:uint = 0; i < slices; i++) {
				for (var j:uint = 0; j < stacks; j++) {
					vertices = new Vector.<IVertex>();
					vertex(i / slices, j / stacks);
					if (j > 0) vertex((i + 1) / slices, j / stacks);
					if (j < stacks - 1) vertex((i + 1) / slices, (j + 1) / stacks);
					vertex(i / slices, (j + 1) / stacks);
					polygons.push(new Polygon(vertices));
				}
			}
			return CSG.fromPolygons(polygons);
		}
		
		/**
		 * Construct a CSG solid from a list of `Polygon` instances.
		 * 
		 * @param polygons
		 * 
		 * @return CSG
		 */ 
		public static function fromPolygons(polygons:Vector.<Polygon>):CSG
		{
			var csg:CSG = new CSG();
			csg.polygons = polygons;
			return csg;
		}
	}
}

