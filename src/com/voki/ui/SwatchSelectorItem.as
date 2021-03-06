﻿package com.voki.ui {
	import com.oddcast.ui.ButtonSelectorItem;
	import com.oddcast.utils.ColorData;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	/**
	* ...
	* @author Sam Myer
	*/
	public class SwatchSelectorItem extends ButtonSelectorItem {
		public var swatch:MovieClip;
		
		override public function set data(o:Object):void {
			super.data = o;
			var c:ColorData = new ColorData(o as uint);
			swatch.transform.colorTransform = new ColorTransform(1, 1, 1, 1, c.r, c.g, c.b, 0);
		}
	}
	
}