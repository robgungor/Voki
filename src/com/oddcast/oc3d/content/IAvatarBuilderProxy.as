package com.oddcast.oc3d.content
{
	import com.oddcast.oc3d.core.*;
	
	import flash.geom.Point;
	
	public interface IAvatarBuilderProxy extends IContentBuilder
	{
		function tryGetCurrentModel():IModelProxy;

		function instance():IInstance3D;
		
		function accessorySet():IAccessorySetProxy;
		
		function outputConfiguration():XML;

		// continuationFn:Function<IAccessory>
		function tryPickAccessory(view:IViewport3D, screenPos:Point, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
		
		// continuationFn:Function<IAccessoryProxy>
		function loadAccessory(id:int, continuationFn:Function, failedFn:Function=null, progressedFn:Function=null):void;
	}
}