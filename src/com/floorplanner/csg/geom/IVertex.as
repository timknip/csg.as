package com.floorplanner.csg.geom
{
	import flash.geom.Vector3D;

	public interface IVertex
	{
		function get pos():Vector3D;
		function set pos(value:Vector3D):void;
		function clone():IVertex;
		function flip():void;
		function interpolate(other:IVertex, t:Number):IVertex;
	}
}