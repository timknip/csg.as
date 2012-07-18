package com.floorplanner.csg.geom
{
	public interface IVertex
	{
		function get pos():Vector;
		function set pos(value:Vector):void;
		function get normal():Vector;
		function set normal(value:Vector):void;
		function clone():IVertex;
		function flip():void;
		function interpolate(other:IVertex, t:Number):IVertex;
	}
}