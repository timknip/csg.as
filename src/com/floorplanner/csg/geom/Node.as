package com.floorplanner.csg.geom
{
	/** 
	 * class Node
	 *
	 * Holds a node in a BSP tree. A BSP tree is built from a collection of polygons
	 * by picking a polygon to split along. That polygon (and all other coplanar
	 * polygons) are added directly to that node and the other polygons are added to
	 * the front and/or back subtrees. This is not a leafy BSP tree since there is
	 * no distinction between internal and leaf nodes.
	 */ 
	public class Node
	{
		public var plane:Plane;
		public var front:Node;
		public var back:Node;
		public var polygons:Vector.<Polygon>;
		
		public function Node(polygons:Vector.<Polygon> = null)
		{
			this.plane = null;
			this.front = null;
			this.back = null;
			this.polygons = new Vector.<Polygon>();
			if (polygons) {
				build(polygons);
			}
		}
		
		public function clone():Node
		{
			var node:Node = new Node();
			node.plane = this.plane && this.plane.clone();
			node.front = this.front && this.front.clone();
			node.back = this.back && this.back.clone();
			for each (var p:Polygon in this.polygons) {
				node.polygons.push(p.clone());
			}
			return node;
		}
		
		/**
		 * Convert solid space to empty space and empty space to solid space.
		 */ 
		public function invert():void
		{
			for (var i:uint = 0; i < this.polygons.length; i++) {
				this.polygons[i].flip();
			}
			this.plane.flip();
			if (this.front) this.front.invert();
			if (this.back) this.back.invert();
			var temp:Node = this.front;
			this.front = this.back;
			this.back = temp;
		}
		
		/**
		 * Recursively remove all polygons in `polygons` that are inside this BSP
		 * tree.
		 * @param polygons
		 */ 
		public function clipPolygons(polygons:Vector.<Polygon>):Vector.<Polygon> 
		{
			if (!this.plane) return polygons.slice();
			var front:Vector.<Polygon> = new Vector.<Polygon>(),
				back:Vector.<Polygon> = new Vector.<Polygon>();
			for (var i:uint = 0; i < polygons.length; i++) {
				this.plane.splitPolygon(polygons[i], front, back, front, back);
			}
			if (this.front) front = this.front.clipPolygons(front);
			if (this.back) back = this.back.clipPolygons(back);
			else back.length = 0;
			return front.concat(back);
		}
		
		/**
		 * Remove all polygons in this BSP tree that are inside the other BSP tree
		 *`bsp`.
		 * @param bsp
		 */ 
		public function clipTo(bsp:Node):void
		{
			this.polygons = bsp.clipPolygons(this.polygons);
			if (this.front) this.front.clipTo(bsp);
			if (this.back) this.back.clipTo(bsp);
		}
		
		/**
		 *  Return a list of all polygons in this BSP tree.
		 */ 
		public function allPolygons():Vector.<Polygon> 
		{
			var polygons:Vector.<Polygon> = this.polygons.slice();
			if (this.front) polygons = polygons.concat(this.front.allPolygons());
			if (this.back) polygons = polygons.concat(this.back.allPolygons());
			return polygons;
		}
		
		/**
		  * Build a BSP tree out of `polygons`. When called on an existing tree, the
		  * new polygons are filtered down to the bottom of the tree and become new
		  * nodes there. Each set of polygons is partitioned using the first polygon
		  * (no heuristic is used to pick a good split).
		  */
		public function build(polygons:Vector.<Polygon>):void
		{
			if (!polygons.length) return;
			if (!this.plane) this.plane = polygons[0].plane.clone();
			var front:Vector.<Polygon> = new Vector.<Polygon>(), 
				back:Vector.<Polygon> = new Vector.<Polygon>();
			for (var i:uint = 0; i < polygons.length; i++) {
				this.plane.splitPolygon(polygons[i], this.polygons, this.polygons, front, back);
			}
			if (front.length) {
				if (!this.front) this.front = new Node();
				this.front.build(front);
			}
			if (back.length) {
				if (!this.back) this.back = new Node();
				this.back.build(back);
			}
		}
	}
}